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

  Stream<Article> get editingArticle => _editingArticleController.stream;
  Sink<void> get postArticle => _postArticleController.sink;
  Sink<String> get inputTitle => _inputTitleController.sink;
  Sink<String> get inputDescription => _inputDescriptionController.sink;
  Sink<String> get inputBody => _inputBodyController.sink;
  Sink<String> get inputTag => _inputTagController.sink;

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

    final inputArticle = StreamZip([
      _inputTitleController.stream,
      _inputDescriptionController.stream,
      _inputBodyController.stream,
      _inputTagController.stream
    ]).map((i) {
      return _editingArticle(
          title: i[0], description: i[1], body: i[2], tag: i[3]);
    });

    final newArticle = StreamZip([editingArticle, inputArticle]).map((a) {
      final editing = a[0];
      final input = a[1];
      return input.copyWith(
          id: editing.id,
          createdAt: editing.createdAt,
          authorRef: editing.authorRef);
    });

    StreamSubscription postArticleSubscription;
    newArticle.listen((newArticle) {
      postArticleSubscription?.cancel();
      postArticleSubscription = _postArticleController.stream.listen((_) async {
        _articleRepository.post(newArticle);
      });
    });

    _postArticleController.stream.listen((_) {});
  }

  @override
  void dispose() async {
    await _accountRepository.dispose();
    await _postArticleController.close();
    await _inputTitleController.close();
    await _inputDescriptionController.close();
    await _inputTagController.close();
    await _inputBodyController.close();
    await _editingArticleController.close();
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
          authorRef: "",
          tags: tag.split(" "));
}
