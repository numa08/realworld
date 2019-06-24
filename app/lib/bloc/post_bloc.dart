import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:async/async.dart';
import 'package:bloc_provider/bloc_provider.dart';

class PostBloc implements Bloc {
  final AccountRepository _accountRepository;
  final ArticleRepository _articleRepository;
  final String editingArticleRef;

  final StreamController<void> _postArticleController =
      StreamController.broadcast();
  final StreamController<String> _inputTitleController =
      StreamController.broadcast();
  final StreamController<String> _inputDescriptionController =
      StreamController.broadcast();
  final StreamController<String> _inputBodyController =
      StreamController.broadcast();
  final StreamController<String> _inputTagController =
      StreamController.broadcast();
  final StreamController<Article> _editingArticleController =
      StreamController.broadcast();
  final StreamController<String> _titleErrorController =
      StreamController.broadcast();
  final StreamController<String> _descriptionErrorController =
      StreamController.broadcast();
  final StreamController<String> _bodyErrorController =
      StreamController.broadcast();
  final StreamController<void> _titleFocusLostController =
      StreamController.broadcast();
  final StreamController<void> _descriptionFocusLostController =
      StreamController.broadcast();
  final StreamController<void> _bodyFocusLostController =
      StreamController.broadcast();
  final StreamController<void> _postCompleteController =
      StreamController.broadcast(sync: true);

  Stream<String> get initialTitle =>
      _editingArticleController.stream.map((a) => a.title);
  Stream<String> get initialDescription =>
      _editingArticleController.stream.map((a) => a.description);
  Stream<String> get initialBody =>
      _editingArticleController.stream.map((a) => a.body);
  Stream<String> get initialTag =>
      _editingArticleController.stream.map((a) => a.tags.join(" "));
  Stream<String> get titleError => _titleErrorController.stream;
  Stream<String> get descriptionError => _descriptionErrorController.stream;
  Stream<String> get bodyError => _bodyErrorController.stream;
  Sink<void> get postArticle => _postArticleController.sink;
  Sink<String> get inputTitle => _inputTitleController.sink;
  Sink<String> get inputDescription => _inputDescriptionController.sink;
  Sink<String> get inputBody => _inputBodyController.sink;
  Sink<String> get inputTag => _inputTagController.sink;
  Sink<void> get titleFocusLost => _titleFocusLostController.sink;
  Sink<void> get descriptionFocusLost => _descriptionFocusLostController.sink;
  Sink<void> get bodyFocusLost => _bodyFocusLostController.sink;
  Stream<void> get postComplete => _postCompleteController.stream;

  PostBloc(this._accountRepository, this._articleRepository,
      {this.editingArticleRef}) {
    if (editingArticleRef == null) {
      _accountRepository.account
          .map((a) => Article.empty(a))
          .pipe(_editingArticleController);
      _accountRepository.fetch();
    } else {
      _articleRepository
          .findArticle(editingArticleRef)
          .pipe(_editingArticleController);
    }

    Article newArticle;
    String inputtedTitle;
    String inputtedDescription;
    String inputtedBody;

    _inputTitleController.stream.listen((t) => inputtedTitle = t);
    _inputDescriptionController.stream.listen((t) => inputtedDescription = t);
    _inputBodyController.stream.listen((t) => inputtedBody = t);

    _titleFocusLostController.stream
        .map((_) => _validate(inputtedTitle) ? null : "Title can't be null")
        .pipe(_titleErrorController);
    _descriptionFocusLostController.stream
        .map((_) =>
            _validate(inputtedDescription) ? null : "Description can't be null")
        .pipe(_descriptionErrorController);
    _bodyFocusLostController.stream
        .map((_) => _validate(inputtedBody) ? null : "Body can't be null")
        .pipe(_bodyErrorController);

    StreamZip([
      StreamGroup.merge([initialTitle, _inputTitleController.stream])
          .where(_validate),
      StreamGroup.merge(
              [initialDescription, _inputDescriptionController.stream])
          .where(_validate),
      StreamGroup.merge([initialBody, _inputBodyController.stream])
          .where(_validate),
      StreamGroup.merge([initialTag, _inputTagController.stream])
    ]).listen((i) {
      newArticle = _editingArticle(
          title: i[0], description: i[1], body: i[2], tag: i[3]);
    });

    String titleError;
    String descriptionError;
    String bodyError;

    bool hasError() =>
        titleError != null || descriptionError != null || bodyError != null;

    _titleErrorController.stream.listen((e) => titleError = e);
    _descriptionErrorController.stream.listen((e) => descriptionError = e);
    _bodyErrorController.stream.listen((e) => bodyError = e);

    _postArticleController.stream.listen((_) {
      print('on post article');
      if (newArticle == null) {
        print('new article is null');
        return;
      }
      if (hasError()) {
        print(
            'has error title err $titleError, description error $descriptionError, body error $bodyError');
        return;
      }
      _articleRepository.post(newArticle);
      _postCompleteController.add(null);
    });
  }

  bool _validate(String value) => value != null && value.isNotEmpty;

  @override
  void dispose() {
    _accountRepository.dispose();
    forceClose(_postArticleController);
    forceClose(_inputTitleController);
    forceClose(_inputDescriptionController);
    forceClose(_inputTagController);
    forceClose(_inputBodyController);
    forceClose(_editingArticleController);
    forceClose(_titleErrorController);
    forceClose(_descriptionErrorController);
    forceClose(_bodyErrorController);
    forceClose(_titleFocusLostController);
    forceClose(_descriptionFocusLostController);
    forceClose(_bodyFocusLostController);
    forceClose(_postCompleteController);
  }

  Article _editingArticle(
          {String title, String description, String body, String tag}) =>
      Article(
          slug: title.toLowerCase().replaceAll(" ", '-'),
          title: title,
          description: description,
          body: body,
          createdAt: FieldValueNow(),
          updatedAt: FieldValueNow(),
          authorRef: null,
          tags: tag.split(" "));
}

Future forceClose(StreamController stream) async {
  try {
    return await stream.close();
  } catch (_) {
    return null;
  }
}
