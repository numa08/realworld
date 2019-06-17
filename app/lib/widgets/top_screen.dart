import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      );
}

class _Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    var repository = AccountRepository();
    _accountBloc = AccountBloc(accountRepository: repository);
  }

  @override
  void dispose() {
    _accountBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _accountBloc,
        builder: (context, accountState) {
          if (accountState is AccountNotLoaded) {
            _accountBloc.dispatch(FetchAccount());
            return Center(child: CircularProgressIndicator());
          }
          if (accountState is AccountStream) {
            return StreamBuilder(
                stream: accountState.accountStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null) {
                    _accountBloc.dispatch(LoginAnonymousAccount());
                    return Center(child: CircularProgressIndicator());
                  }
                  return Text('login with ${snapshot.data.username}');
                });
          }
        });
  }
}

class _DrawerHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerHeaderState();
}

class _DrawerHeaderState extends State<_DrawerHeader> {
  AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    var repository = AccountRepository();
    _accountBloc = AccountBloc(accountRepository: repository);
  }

  @override
  void dispose() {
    _accountBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder(
      bloc: _accountBloc,
      builder: (context, accountState) {
        if (accountState is AccountNotLoaded) {
          _accountBloc.dispatch(FetchAccount());
          return Builder(
            builder: _placeholderDrawerHeader,
          );
        }
        if (accountState is AccountStream) {
          return StreamBuilder(
            stream: accountState.accountStream,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Builder(builder: _placeholderDrawerHeader);
              } else {
                return Builder(
                  builder:
                      _accountDrawerHeader(snapshot.data, onPressSignIn: () {
                    Navigator.of(context).pop();
                    var signInScreen = SignInScreen();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => signInScreen,
                            fullscreenDialog: true));
                  }),
                );
              }
            },
          );
        }
      });
}

WidgetBuilder _placeholderDrawerHeader = (context) => Container(
      height: 64,
      child: DrawerHeader(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        CircleAvatar(
          minRadius: 24,
          maxRadius: 24,
          backgroundColor: Colors.grey,
        ),
        Container(
          width: 100.0,
          height: 12,
          color: Colors.grey,
        )
      ])),
    );

WidgetBuilder _accountDrawerHeader(Account account,
        {VoidCallback onPressSignIn}) =>
    (context) => Container(
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
                  Builder(
                      builder:
                          _accountAvatarImage(account.image, account.username)),
                  Center(child: Text(account.username)),
                ],
              ),
              Builder(
                builder: (context) {
                  if (account.isAnonymous) {
                    return FlatButton(
                      onPressed: onPressSignIn,
                      child: Text('Sign in/ Sign up'),
                    );
                  } else {
                    return Container(
                      width: 0,
                      height: 0,
                    );
                  }
                },
              )
            ],
          )),
        );

WidgetBuilder _accountAvatarImage(Uri imageUri, String username) => (context) {
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
    };
