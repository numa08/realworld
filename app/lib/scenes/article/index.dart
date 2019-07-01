import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class ArticleSceneArguments {
  ArticleSceneArguments(
      {@required this.heroTag,
      @required this.articleId,
      @required this.initialArticle});
  final String heroTag;
  final String articleId;
  // We need this for Hero animation
  final Article initialArticle;
}

class ArticleScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context).settings.arguments as ArticleSceneArguments;
    final articleId = arguments.articleId;
    final heroTag = arguments.heroTag;

    return BlocProvider(
      creator: (_context, _bag) => ArticleBloc(AccountRepository(),
          ArticleRepository(), UserRepository(), articleId),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('conduit'),
          ),
          body: _Body(
            heroTag: heroTag,
            initialArticle: arguments.initialArticle,
          ),
        );
      }),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key key, this.heroTag, this.initialArticle}) : super(key: key);

  final String heroTag;
  final Article initialArticle;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ArticleBloc>(context);
    return StreamBuilder<Article>(
      stream: bloc.article,
      initialData: initialArticle,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;
          return SafeArea(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: Text(
                        data.title,
                        style: Theme.of(context)
                            .textTheme
                            .display1
                            .merge(TextStyle(color: Colors.black)),
                      ),
                    ),
                    Text(
                      data.description,
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.start,
                      children: data.tags
                          .where((t) => t.isNotEmpty)
                          .map((t) => ActionChip(
                                label: Text(t),
                                onPressed: () {},
                              ))
                          .toList(),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      data.body,
                      style: Theme.of(context).textTheme.body1,
                    )
                  ]),
            ),
          ));
        } else {
          return _EmptyView();
        }
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: const Text('Could not find article !!'),
      );
}
