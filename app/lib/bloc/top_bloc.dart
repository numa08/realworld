import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';

class TopBloc implements Bloc {
  final AccountRepository _accountRepository;
  final ArticleRepository _articleRepository;
  final UserRepository _userRepository;

  final _signInWithAnonymousController = StreamController<void>.broadcast();
  final _signInController = StreamController<void>.broadcast();
  final _signOutController = StreamController<void>.broadcast();
  final _fetchAccountController = StreamController<void>.broadcast();
  final _addArticleController = StreamController<void>.broadcast();

  Stream<Account> get account => _accountRepository.account;
  Stream<AuthState> get authState => _accountRepository.authState;
  Stream<List<Article>> get articles => _articleRepository.articles;
  Stream<void> get moveToSignIn => _signInController.stream;
  Stream<void> get moveToAddArticle => _addArticleController.stream;
  Sink<void> get signInWithAnonymous => _signInWithAnonymousController.sink;
  Sink<void> get signIn => _signInController.sink;
  Sink<void> get signOut => _signOutController.sink;
  Sink<void> get fetchAccount => _fetchAccountController.sink;
  Sink<void> get tapAddArticle => _addArticleController.sink;

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
  }

  Stream<User> user(String userRef) => _userRepository.findUser(userRef);

  @override
  void dispose() async {
    await _accountRepository.dispose();
    await _signInWithAnonymousController.close();
    await _signInController.close();
    await _signOutController.close();
    await _fetchAccountController.close();
    await _addArticleController.close();
  }
}
