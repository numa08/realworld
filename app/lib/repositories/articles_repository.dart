import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class ArticleRepository {
  Stream<List<Article>> get articles;
  Future<void> post(Article article);
  Stream<Article> findArticle(String articleRef);

  factory ArticleRepository() =>
      _FirestoreArticleRepository(Firestore.instance);
}

class _FirestoreArticleRepository implements ArticleRepository {
  final Firestore _firestore;

  _FirestoreArticleRepository(this._firestore);

  @override
  Future<void> post(Article article) async {
    final data = article.toJson();

    final id = article.id ??
        _firestore
            .document(article.authorRef)
            .collection('articles')
            .document()
            .documentID;

    await _firestore
        .document(article.authorRef)
        .collection('articles')
        .document(id)
        .setData(data, merge: true);
    debugPrint('post article to ${article.authorRef}/articles/$id');
    var tags = article.tags;
    if (tags == null) {
      return;
    }
    final batch = _firestore.batch();
    tags.map((t) => Tag('${article.authorRef}/articles/$id', t)).forEach((tag) {
      batch.setData(
          _firestore
              .document(tag.articleRef)
              .collection('tags')
              .document(tag.tag),
          tag.toJson());
    });
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
            } catch (_) {
              return null;
            }
          })
          .where((a) => a != null)
          .toList())
      .asBroadcastStream();

  @override
  Stream<Article> findArticle(String articleRef) => Stream.empty();
}
