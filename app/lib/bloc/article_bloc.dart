import 'dart:async';
import 'dart:core';

import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';

class ArticleBloc extends Bloc {
  final AccountRepository accountRepository;
  final ArticleRepository articleRepository;
  final UserRepository userRepository;
  final String articleId;

  final StreamController<Article> _articleStreamController =
      StreamController.broadcast();
  final StreamController<User> _userStreamController =
      StreamController.broadcast();
  StreamSubscription _userSubscription;

  Stream<Article> get article => _articleStreamController.stream;

  ArticleBloc(this.accountRepository, this.articleRepository,
      this.userRepository, this.articleId) {
    articleRepository
        .findArticle(articleId)
        .listen(_articleStreamController.add);

    _articleStreamController.stream.where((a) => a != null).listen((a) {
      debugPrint("find article ${a.toJson()}");
      if (_userSubscription == null) {
        _userSubscription = userRepository
            .findUser(a.authorRef)
            .listen(_userStreamController.add);
      }
    });
  }

  @override
  void dispose() async {
    await accountRepository.dispose();
    await _userSubscription.cancel();
    await _userStreamController.close();
    await _articleStreamController.close();
  }
}
