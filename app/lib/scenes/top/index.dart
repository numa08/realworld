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
        child: Scaffold(
          appBar: AppBar(
            title: Text('conduit'),
          ),
          body: Builder(builder: (context) {
            final bloc = BlocProvider.of<TopBloc>(context);
            bloc.authState.listen((state) {
              if (state is NotSignedIn) {
                bloc.signInWithAnonymous.add(null);
              }
            });
            bloc.fetchAccount.add(null);
            bloc.moveToAddArticle.listen((_) => Navigator.push(context,
                MaterialPageRoute(builder: (_context) => PostScene())));
            return _ArticleListView(
                articleStream: bloc.articles, userStream: bloc.user);
          }),
          drawer: TopDrawer(),
          floatingActionButton: Builder(builder: (context) {
            final bloc = BlocProvider.of<TopBloc>(context);
            return _AddArticleButton(
              account: bloc.account,
              onTapAdd: () => bloc.tapAddArticle.add(null),
            );
          }),
        ),
      );
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
                          Hero(
                            tag: 'profile-$index',
                            child: AccountAvatar(
                              account:
                                  userStream(snapshot.data[index].authorRef),
                            ),
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
                                tag: 'article-title-$index',
                                child: Text(snapshot.data[index].title,
                                    style: Theme.of(context).textTheme.title),
                              ),
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
                                  Text(timeago.format(
                                      snapshot.data[index].createdAt.dateTime))
                                ],
                              ),
                              Wrap(
                                  spacing: 8.0,
                                  alignment: WrapAlignment.start,
                                  children: snapshot.data[index].tags
                                      .map((t) => Hero(
                                            tag: 'article-tag-$index-$t',
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
