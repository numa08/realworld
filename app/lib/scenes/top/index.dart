import 'dart:async';

import 'package:app/bloc/bloc.dart';
import 'package:app/components/components.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/scenes/post_article/index.dart';
import 'package:app/scenes/top/drawer.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class TopScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider<TopBloc>(
        creator: (_context, _bag) =>
            TopBloc(AccountRepository(), ArticleRepository(), UserRepository()),
        child: Builder(
          builder: (context) {
            final TopBloc bloc = BlocProvider.of(context);
            bloc.fetchAccount.add(null);
            return _TopBody(
              bloc: bloc,
            );
          },
        ),
      );
}

class _TopBody extends StatefulWidget {
  final TopBloc bloc;

  const _TopBody({Key key, this.bloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopBodyState();
}

class _TopBodyState extends State<_TopBody> {
  StreamSubscription _authStateChangedSubscription;
  StreamSubscription _moveToAddArticleSubscription;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('conduit'),
      ),
      body: _ArticleListView(
          articleStream: widget.bloc.articles, userStream: widget.bloc.user),
      drawer: TopDrawer(),
      floatingActionButton: _AddArticleButton(
        account: widget.bloc.account,
        onTapAdd: () => widget.bloc.tapAddArticle.add(null),
      ));

  @override
  void didUpdateWidget(_TopBody oldWidget) {
    if (_authStateChangedSubscription == null) {
      setState(() {
        _authStateChangedSubscription = widget.bloc.authState.listen((state) {
          if (state is NotSignedIn) {
            widget.bloc.signInWithAnonymous.add(null);
          }
        });
      });
    }
    if (_moveToAddArticleSubscription == null) {
      setState(() {
        _moveToAddArticleSubscription =
            widget.bloc.moveToAddArticle.listen((_) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => PostScene()));
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _authStateChangedSubscription?.cancel();
    _moveToAddArticleSubscription?.cancel();
    super.dispose();
  }
}

class _ArticleListView extends StatelessWidget {
  final Stream<List<Article>> articleStream;
  final Stream<User> Function(String) userStream;

  const _ArticleListView(
      {Key key, @required this.articleStream, @required this.userStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Article>>(
      stream: articleStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
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
                          AccountAvatar(
                            account: userStream(snapshot.data[index].authorRef),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(snapshot.data[index].title,
                                  style: Theme.of(context).textTheme.title),
                              SizedBox(
                                height: 8,
                              ),
                              Wrap(
                                spacing: 4.0,
                                children: [
                                  AccountNameLabel(
                                    account: userStream(
                                        snapshot.data[index].authorRef),
                                  ),
                                  _TimeAgoText(
                                    date:
                                        snapshot.data[index].createdAt.dateTime,
                                  )
                                ],
                              ),
                              Wrap(
                                  spacing: 8.0,
                                  alignment: WrapAlignment.start,
                                  children: snapshot.data[index].tags
                                      .where((t) => t.isNotEmpty)
                                      .map((t) => ActionChip(
                                            label: Text(t),
                                            onPressed: () {},
                                          ))
                                      .toList())
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
      });
}

class _AddArticleButton extends StatelessWidget {
  final Stream<Account> account;
  final VoidCallback onTapAdd;

  const _AddArticleButton({Key key, this.account, this.onTapAdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
        stream: account.map((a) => a != null && !a.isAnonymous),
        initialData: false,
        builder: (context, snapshot) => Visibility(
            visible: snapshot.data,
            child: FloatingActionButton(
              onPressed: onTapAdd,
              child: Icon(Icons.add),
            )),
      );
}

class _TimeAgoText extends StatelessWidget {
  final DateTime date;

  const _TimeAgoText({Key key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: Stream.periodic(Duration(seconds: 1)),
        builder: (context, _) => Text(timeago.format(date)),
      );
}
