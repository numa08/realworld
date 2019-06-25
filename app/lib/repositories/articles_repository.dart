import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class ArticleRepository {
  factory ArticleRepository() =>
      _FirestoreArticleRepository(Firestore.instance, FirebaseAuth.instance);

  Stream<List<Article>> get articles;
  Future<void> post(Article article);
  Stream<Article> findArticle(String articleRef);
}

class _FirestoreArticleRepository implements ArticleRepository {
  _FirestoreArticleRepository(this._firestore, this._firebaseAuth);

  final Firestore _firestore;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<void> post(Article article) async {
    final authorRef = article.authorRef ??
        await _firebaseAuth.currentUser().then((u) => '/users/${u.uid}');

    final id = article.id ??
        _firestore
            .document(authorRef)
            .collection('articles')
            .document()
            .documentID;

    final data = article.copyWith(id: id, authorRef: authorRef).toJson();

    await _firestore
        .document(authorRef)
        .collection('articles')
        .document(id)
        .setData(data, merge: true);
    debugPrint('post article to $authorRef/articles/$id');
    final tags = article.tags;
    if (tags.isEmpty) {
      return;
    }
    final batch = _firestore.batch();
    for (final tag in tags
        .where((t) => t.isNotEmpty)
        .map((t) => Tag('$authorRef/articles/$id', t))) {
      batch.setData(
          _firestore
              .document(tag.articleRef)
              .collection('tags')
              .document(tag.tag),
          tag.toJson());
    }
    await batch.commit();
  }

  @override
  Stream<List<Article>> get articles => _firestore
      .collection('articles')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((q) => q.documents
          .map((d) {
            try {
              return Article.fromJson(d.data);
            } on Exception catch (_) {
              return null;
            }
          })
          .where((a) => a != null)
          .toList())
      .asBroadcastStream();

  @override
  Stream<Article> findArticle(String articleId) => _firestore
          .collection('articles')
          .document(articleId)
          .snapshots()
          .map((d) {
        try {
          return Article.fromJson(d.data);
        } on Exception catch (_) {
          return null;
        }
      }).asBroadcastStream();
}
