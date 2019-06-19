import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ArticleRepository {
  Stream<List<Article>> get articles;
  Future<void> add(Article article);

  factory ArticleRepository() =>
      _FirestoreArticleRepository(Firestore.instance);
}

class _FirestoreArticleRepository implements ArticleRepository {
  final Firestore _firestore;

  _FirestoreArticleRepository(this._firestore);

  @override
  Future<void> add(Article article) async {
    final data = article.toJson();
    await _firestore
        .document('/users/${article.authorRef}')
        .collection('articles')
        .add(data);
  }

  @override
  Stream<List<Article>> get articles => _firestore
      .collection('articles')
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
}
