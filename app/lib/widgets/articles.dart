import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Articles extends StatelessWidget {
  final ArticleBloc articleBloc;

  const Articles({Key key, @required this.articleBloc})
      : assert(articleBloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => BlocProviderTree(
        blocProviders: [
          BlocProvider<ArticleBloc>(
            bloc: articleBloc,
          )
        ],
        child: ArticleList(),
      );
}

class ArticleList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<ArticleBloc>(context);
    assert(bloc != null);
    StreamBuilder<List<Article>> articleStream;
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, ArticleState state) {
        if (state is ArticleNotLoaded) {
          bloc.dispatch(AllArticles());
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ArticleLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ArticleStream) {
          if (articleStream == null) {
            articleStream = StreamBuilder(
              stream: state.articleStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Article>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    var article = snapshot.data;
                    if (article.isEmpty) {
                      return Center(
                        child: Text('Welcome to conduit'),
                      );
                    } else {
                      return Center(
                        child: Text('We have articles!'),
                      );
                    }
                }
              },
            );
          }
          return articleStream;
        }
      },
    );
  }
}
