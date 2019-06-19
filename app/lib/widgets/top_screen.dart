import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class TopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('conduit'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [_DrawerHeader()],
          ),
        ),
        body: Center(
          child: _Home(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Future<void> _addTestArticle() async {
              final user = await FirebaseAuth.instance.currentUser();
              if (user == null || user.isAnonymous) {
                return;
              }
              var article = Article(
                  'test-slug',
                  'test title',
                  'test description',
                  'test body',
                  FieldValueNow(),
                  FieldValueNow(),
                  '/users/${user.uid}',
                  ["test", "test2"]);
              await ArticleRepository().add(article);
            }

            _addTestArticle();
          },
          child: Icon(Icons.add),
        ),
      );
}

class _Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc =
        HomeBloc(AccountRepository(), ArticleRepository(), UserRepository());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.authState.listen((account) {
      if (account is NotSignedIn) {
        _bloc.dispatch(SignInAnonymousAccount());
      }
    });
    return BlocListener(
      bloc: _bloc,
      listener: (context, state) {
        if (state is HomeAccountNotLoaded) {
          _bloc.dispatch(FetchHomeAccount());
        }
      },
      child: StreamBuilder<List<Article>>(
          stream: _bloc.articles,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return CircularProgressIndicator();
            }
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) => GestureDetector(
                      onTap: () => print("tap $index"),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Hero(
                                tag: 'profile',
                                child: _accountAvatar(context,
                                    _bloc.user(snapshot.data[index].authorRef)),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'article-title',
                                    child: Text(snapshot.data[index].title,
                                        style:
                                            Theme.of(context).textTheme.title),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Wrap(
                                    spacing: 4.0,
                                    children: [
                                      _accountNameLabel(
                                          context,
                                          _bloc.user(
                                              snapshot.data[index].authorRef)),
                                      Text(timeago.format(snapshot
                                          .data[index].createdAt.dateTime))
                                    ],
                                  ),
                                  Wrap(
                                      spacing: 8.0,
                                      alignment: WrapAlignment.start,
                                      children: snapshot.data[index].tags
                                          .map((t) => Hero(
                                                tag: 'article-tag',
                                                child: ActionChip(
                                                  label: Text(t),
                                                  onPressed: () {},
                                                ),
                                              ))
                                          .toList())
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
          }),
    );
  }
}

class _DrawerHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerHeaderState();
}

class _DrawerHeaderState extends State<_DrawerHeader> {
  AccountBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AccountBloc(AccountRepository());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener(
        bloc: _bloc,
        listener: (context, state) {
          if (state is DrawerHeaderAccountNotLoaded) {
            _bloc.dispatch(FetchDrawerHeaderAccount());
          }
        },
        child: Container(
          height: 64,
          child: DrawerHeader(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _accountAvatar(context, _bloc.account),
                  _accountNameLabel(context, _bloc.account)
                ],
              ),
              _signInOutButton(context, _bloc.account,
                  onTapSignIn: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignInScreen(),
                          fullscreenDialog: true)),
                  onTapSignOut: () =>
                      _bloc.dispatch(SignOutDrawerHeaderAccount()))
            ],
          )),
        ),
      );
}

Widget _accountAvatarImage(Uri imageUri, String username) {
  if (imageUri == null) {
    return CircleAvatar(
      minRadius: 24,
      maxRadius: 24,
      backgroundColor: Colors.blue,
      child: Center(
        child: Text(
          username[0],
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
  return CircleAvatar(
    minRadius: 24,
    maxRadius: 24,
    backgroundImage: NetworkImage(imageUri.toString()),
  );
}

Widget _accountAvatar(BuildContext context, Stream<Account> account) =>
    StreamBuilder<Account>(
      stream: account,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Builder(
              builder: (context) => CircleAvatar(
                    minRadius: 24,
                    maxRadius: 24,
                    backgroundColor: Colors.grey,
                  ));
        } else {
          return _accountAvatarImage(
              snapshot.data.image, snapshot.data.username);
        }
      },
    );

Widget _accountNameLabel(BuildContext context, Stream<Account> account) =>
    StreamBuilder<Account>(
      stream: account,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Builder(
              builder: (context) => Container(
                    width: 100.0,
                    height: 12,
                    color: Colors.grey,
                  ));
        } else {
          return Center(child: Text(snapshot.data.username));
        }
      },
    );

Widget _signInOutButton(BuildContext context, Stream<Account> account,
        {VoidCallback onTapSignIn, VoidCallback onTapSignOut}) =>
    StreamBuilder<Account>(
        stream: account,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }
          if (snapshot.data.isAnonymous) {
            return FlatButton(
              child: Text('Sign In/Up'),
              onPressed: onTapSignIn,
            );
          }
          return FlatButton(
            child: Text('Sign Out'),
            onPressed: onTapSignOut,
          );
        });
