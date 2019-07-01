import 'dart:async';

import 'package:app/bloc/bloc.dart';
import 'package:app/components/components.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:app/scenes/post_article/index.dart';
import 'package:app/scenes/scenes.dart';
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
            final bloc = BlocProvider.of<TopBloc>(context);
            bloc.fetchAccount.add(null);
            return _TopBody();
          },
        ),
      );
}

class _TopBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TopBodyState();
}

class _TopBodyState extends State<_TopBody> {
  StreamSubscription _authStateChangedSubscription;
  StreamSubscription _moveToAddArticleSubscription;
  StreamSubscription _moveToArticleSubscription;

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<TopBloc>(context);
    _authStateChangedSubscription = bloc.authState.listen((state) {
      if (state is NotSignedIn) {
        bloc.signInWithAnonymous.add(null);
      }
    });
    _moveToAddArticleSubscription = bloc.moveToAddArticle.listen((_) {
      Navigator.push<MaterialPageRoute>(
          context, MaterialPageRoute(builder: (_) => PostScene()));
    });
    _moveToArticleSubscription = bloc.moveToArticle.listen((arg) {
      Navigator.push<MaterialPageRoute>(
          context,
          MaterialPageRoute(
              builder: (_) => ArticleScene(),
              settings: RouteSettings(arguments: arg)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TopBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('conduit'),
        ),
        body: _ArticleListView(
            articleStream: bloc.articles, userStream: bloc.user),
        drawer: TopDrawer(),
        floatingActionButton: _AddArticleButton(
          account: bloc.account,
          onTapAdd: () => bloc.tapAddArticle.add(null),
        ));
  }

  @override
  void dispose() {
    _authStateChangedSubscription?.cancel();
    _moveToAddArticleSubscription?.cancel();
    _moveToArticleSubscription?.cancel();
    super.dispose();
  }
}

class _ArticleListView extends StatelessWidget {
  const _ArticleListView(
      {Key key, @required this.articleStream, @required this.userStream})
      : super(key: key);

  final Stream<List<Article>> articleStream;
  final Stream<User> Function(String) userStream;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TopBloc>(context);
    return StreamBuilder<List<Article>>(
        stream: articleStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(child: const CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) => GestureDetector(
                    onTap: () => bloc.tapArticle.add(index),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            AccountAvatar(
                              account:
                                  userStream(snapshot.data[index].authorRef),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: _heroTag(snapshot.data[index], index),
                                  child: Text(snapshot.data[index].title,
                                      style: Theme.of(context).textTheme.title),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Wrap(
                                  spacing: 4,
                                  children: [
                                    AccountNameLabel(
                                      account: userStream(
                                          snapshot.data[index].authorRef),
                                    ),
                                    _TimeAgoText(
                                      date: snapshot
                                          .data[index].createdAt.dateTime,
                                    )
                                  ],
                                ),
                                Wrap(
                                    spacing: 8,
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

  String _heroTag(Article article, int index) => '${article.title}-$index';
}

class _AddArticleButton extends StatelessWidget {
  const _AddArticleButton({Key key, this.account, this.onTapAdd})
      : super(key: key);

  final Stream<Account> account;
  final VoidCallback onTapAdd;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
        stream: account.map((a) => a != null && !a.isAnonymous),
        initialData: false,
        builder: (context, snapshot) => Visibility(
            visible: snapshot.data,
            child: FloatingActionButton(
              onPressed: onTapAdd,
              child: const Icon(Icons.add),
            )),
      );
}

class _TimeAgoText extends StatelessWidget {
  const _TimeAgoText({Key key, this.date}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: Stream.periodic(Duration(seconds: 1)),
        builder: (context, _) => Text(timeago.format(date)),
      );
}
