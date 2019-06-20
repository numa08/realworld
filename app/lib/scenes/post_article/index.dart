import 'dart:async';

import 'package:app/bloc/bloc.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';

class PostScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider<PostBloc>(
        creator: (_context, _bag) =>
            PostBloc(AccountRepository(), ArticleRepository()),
        child: Builder(builder: (context) {
          final bloc = BlocProvider.of<PostBloc>(context);
          bloc.inputTitle.add("test title");
          bloc.inputDescription.add("test description");
          bloc.inputBody.add("test body");
          bloc.inputTag.add("test tag");
          return Scaffold(
            appBar: AppBar(
              title: Text('conduit'),
              actions: [
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => bloc.postArticle.add(null),
                )
              ],
            ),
            body: _Home(
              initialTitle: Stream.empty(),
              initialDescription: Stream.empty(),
              initialBody: Stream.empty(),
              initialTag: Stream.empty(),
              titleError: Stream.empty(),
              descriptionError: Stream.empty(),
              bodyError: Stream.empty(),
            ),
          );
        }),
      );
}

class _Home extends StatefulWidget {
  final Stream<String> initialTitle;
  final Stream<String> initialDescription;
  final Stream<String> initialBody;
  final Stream<String> initialTag;
  final Stream<String> titleError;
  final Stream<String> descriptionError;
  final Stream<String> bodyError;

  const _Home(
      {Key key,
      this.initialTitle,
      this.initialDescription,
      this.initialBody,
      this.initialTag,
      this.titleError,
      this.descriptionError,
      this.bodyError})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  String initialTitle;
  String initialDescription;
  String initialBody;
  String initialTag;
  String titleError;
  String descriptionError;
  String bodyError;

  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    subscriptions.addAll([
      widget.initialTitle.listen((t) {
        setState(() {
          this.initialTitle = t;
        });
      }),
      widget.initialDescription.listen((t) {
        setState(() {
          this.initialDescription = t;
        });
      }),
      widget.initialBody.listen((t) {
        setState(() {
          this.initialBody = t;
        });
      }),
      widget.initialTag.listen((t) {
        setState(() {
          this.initialTag = t;
        });
      }),
      widget.titleError.listen((e) {
        setState(() {
          this.titleError = e;
        });
      }),
      widget.descriptionError.listen((e) {
        setState(() {
          this.descriptionError = e;
        });
      }),
      widget.bodyError.listen((e) {
        setState(() {
          this.bodyError = e;
        });
      })
    ]);
  }

  @override
  void dispose() {
    subscriptions.forEach((s) => s.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(),
      );
}
