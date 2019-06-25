import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class ArticleScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final articleId = ModalRoute.of(context).settings.arguments as String;

    return BlocProvider(
      creator: (_context, _bag) => ArticleBloc(AccountRepository(),
          ArticleRepository(), UserRepository(), articleId),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('conduit'),
          ),
          body: _Body(),
        );
      }),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ArticleBloc>(context);
    return StreamBuilder<Article>(
      stream: bloc.article,
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
                    Text(
                      data.title,
                      style: Theme.of(context)
                          .textTheme
                          .display1
                          .merge(TextStyle(color: Colors.black)),
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

class _StreamText extends StatelessWidget {
  const _StreamText(this.textStream, {this.textStyle});

  final Stream<String> textStream;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) => StreamBuilder<String>(
        stream: textStream,
        initialData: '',
        builder: (_context, snapshot) => Text(
              snapshot.data,
              style: textStyle,
            ),
      );
}

class _StreamTagWrap extends StatelessWidget {
  const _StreamTagWrap(this.tagStream);

  final Stream<List<String>> tagStream;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<String>>(
        stream: tagStream,
        builder: (context, snapshot) => Wrap(
              spacing: 8,
              alignment: WrapAlignment.start,
              children: snapshot.data
                      ?.where((t) => t.isNotEmpty)
                      ?.map((t) => ActionChip(
                            label: Text(t),
                            onPressed: () {},
                          ))
                      ?.toList() ??
                  [],
            ),
      );
}
