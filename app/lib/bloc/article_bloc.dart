import 'dart:async';
import 'dart:core';

import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';

class ArticleBloc extends Bloc {
  ArticleBloc(this.accountRepository, this.articleRepository,
      this.userRepository, this.articleId) {
    articleRepository
        .findArticle(articleId)
        .listen(_articleStreamController.add);

    _articleStreamController.stream.where((a) => a != null).listen((a) {
      debugPrint('find article ${a.toJson()}');
      _userSubscription ??= userRepository
          .findUser(a.authorRef)
          .listen(_userStreamController.add);
    });
  }

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

  @override
  void dispose() async {
    await accountRepository.dispose();
    await _userSubscription.cancel();
    await _userStreamController.close();
    await _articleStreamController.close();
  }
}

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
