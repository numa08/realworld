import 'dart:async';

import 'package:app/bloc/bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:stream_transform/stream_transform.dart';

class TopBloc implements Bloc {
  TopBloc(
      this._accountRepository, this._articleRepository, this._userRepository)
      : assert(_accountRepository != null),
        assert(_articleRepository != null),
        assert(_userRepository != null) {
    _signInWithAnonymousController.stream.listen((_) async {
      await _accountRepository.signInAnonymously();
    });
    _fetchAccountController.stream.listen((_) => _accountRepository.fetch());
    _signOutController.stream.listen((_) async {
      await _accountRepository.signOut();
    });
    _tapArticleController.stream
        .transform(combineLatest<int, List<Article>, ArticleSceneArguments>(
            _articleRepository.articles, _createArgument))
        .pipe(_showArticleController);
  }

  final AccountRepository _accountRepository;
  final ArticleRepository _articleRepository;
  final UserRepository _userRepository;

  final _signInWithAnonymousController = StreamController<void>.broadcast();
  final _signInController = StreamController<void>.broadcast();
  final _signOutController = StreamController<void>.broadcast();
  final _fetchAccountController = StreamController<void>.broadcast();
  final _addArticleController = StreamController<void>.broadcast();
  final _tapArticleController = StreamController<int>.broadcast();
  final _showArticleController =
      StreamController<ArticleSceneArguments>.broadcast();

  Stream<Account> get account => _accountRepository.account;
  Stream<AuthState> get authState => _accountRepository.authState;
  Stream<void> get moveToSignIn => _signInController.stream;
  Stream<void> get moveToAddArticle => _addArticleController.stream;
  Sink<void> get signInWithAnonymous => _signInWithAnonymousController.sink;
  Sink<void> get signIn => _signInController.sink;
  Sink<void> get signOut => _signOutController.sink;
  Sink<void> get fetchAccount => _fetchAccountController.sink;
  Sink<void> get tapAddArticle => _addArticleController.sink;
  Sink<int> get tapArticle => _tapArticleController.sink;
  Stream<ArticleSceneArguments> get moveToArticle =>
      _showArticleController.stream;
  Stream<List<ArticleWithHeroTag>> get articles =>
      _articleRepository.articles.map((list) {
        return list
            .asMap()
            .map<int, ArticleWithHeroTag>((index, article) {
              final heroTag = _heroTag(article, index);
              return MapEntry(index, ArticleWithHeroTag(article, heroTag));
            })
            .values
            .toList();
      });

  Stream<User> user(String userRef) => _userRepository.findUser(userRef);

  @override
  void dispose() async {
    await _accountRepository.dispose();
    await _signInWithAnonymousController.close();
    await _signInController.close();
    await _signOutController.close();
    await _fetchAccountController.close();
    await _addArticleController.close();
    await _tapArticleController.close();
    await _showArticleController.close();
  }

  ArticleSceneArguments _createArgument(int index, List<Article> articles) =>
      ArticleSceneArguments(
          heroTag: _heroTag(articles[index], index),
          initialArticle: articles[index],
          articleId: articles[index].id);

  String _heroTag(Article article, int index) => '${article.title}-$index';
}

class ArticleWithHeroTag {
  ArticleWithHeroTag(this.article, this.titleHero);
  final Article article;
  final String titleHero;
}
