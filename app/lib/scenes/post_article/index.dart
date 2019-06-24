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
        child: Builder(
          builder: (context) => _PostBody(
                bloc: BlocProvider.of(context),
              ),
        ),
      );
}

class _PostBody extends StatefulWidget {
  final PostBloc bloc;

  const _PostBody({Key key, this.bloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostBodyState();
}

class _PostBodyState extends State<_PostBody> {
  StreamSubscription _onPostCompleteSubscription;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('conduit'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => widget.bloc.postArticle.add(null),
          )
        ],
      ),
      body: SafeArea(child: _Home()));

  @override
  void didUpdateWidget(_PostBody oldWidget) {
    if (_onPostCompleteSubscription == null) {
      setState(() {
        _onPostCompleteSubscription = widget.bloc.postComplete.listen((_) {
          Navigator.pop(context);
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _onPostCompleteSubscription?.cancel();
    super.dispose();
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<PostBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        _StreamTextField(
          initialText: bloc.initialTitle,
          errorText: bloc.titleError,
          inputtedText: bloc.inputTitle,
          focusLost: bloc.titleFocusLost,
          border: UnderlineInputBorder(),
          style: Theme.of(context).textTheme.title,
          hintText: 'Article Title',
          labelText: 'Title',
        ),
        _StreamTextField(
          initialText: bloc.initialDescription,
          errorText: bloc.descriptionError,
          inputtedText: bloc.inputDescription,
          focusLost: bloc.descriptionFocusLost,
          border: UnderlineInputBorder(),
          style: Theme.of(context).textTheme.subtitle,
          hintText: "What's this article about?",
          labelText: 'Description',
        ),
        Expanded(
          child: _StreamTextField(
            initialText: bloc.initialBody,
            errorText: bloc.bodyError,
            inputtedText: bloc.inputBody,
            focusLost: bloc.bodyFocusLost,
            hintText: 'Write your article',
            style: Theme.of(context).textTheme.body1,
            border: UnderlineInputBorder(),
            expanded: true,
          ),
        ),
        _StreamTextField(
          initialText: bloc.initialTag,
          errorText: Stream.empty(),
          inputtedText: bloc.inputTag,
          hintText: 'Tag',
          style: Theme.of(context).textTheme.subtitle,
          border: UnderlineInputBorder(),
        )
      ]),
    );
  }
}

class _StreamTextField extends StatefulWidget {
  final Stream<String> initialText;
  final Stream<String> errorText;
  final Sink<String> inputtedText;
  final Sink<void> focusLost;
  final TextStyle style;
  final InputBorder border;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool expanded;

  const _StreamTextField({
    Key key,
    @required this.initialText,
    @required this.errorText,
    @required this.inputtedText,
    this.focusLost,
    this.style,
    this.border,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.expanded,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StreamTextFieldState();
}

class _StreamTextFieldState extends State<_StreamTextField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _errorText;
  final _subscriptions = List<StreamSubscription>();

  @override
  void initState() {
    _subscriptions.addAll([
      widget.initialText.listen((t) {
        _controller.text = t;
      }),
      widget.errorText.listen((t) {
        setState(() {
          _errorText = t;
        });
      })
    ]);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.focusLost?.add(null);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        focusNode: _focusNode,
        onChanged: widget.inputtedText.add,
        expands: widget.expanded ?? false,
        maxLines: null,
        minLines: null,
        style: widget.style,
        controller: _controller,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
            hintText: widget.hintText,
            border: widget.border,
            labelText: widget.labelText,
            errorText: _errorText),
      );
}
