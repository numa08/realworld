import 'dart:async';

import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class ArticleRepository {
  final Firestore firestore;

  final StreamController<List<Article>> _articleStream =
      StreamController<List<Article>>();
  Stream<List<Article>> get articles => _articleStream.stream;
//
//  Stream<Article> article(String slug) {}
//
//  Stream<Article> create() {}
//
//  Stream<Article> update() {}
//  Stream<void> delete(String slug) {}
//
//  Stream<Comment> addComment(String slug) {}
//  Stream<Comment> comment(String slug) {}
//  Stream<void> deleteComment(String slug, int id) {}
//  Stream<void> favorite(String slug) {}
//  Stream<void> unfavorite(String slug) {}

  ArticleRepository({@required this.firestore}) : assert(firestore != null);

  void fetch() {
    firestore.collection('articles').snapshots().listen((data) => {
          _articleStream.add(data.documents.map(_mapDocumentToArticle).toList())
        });
  }

  void dispose() {
    _articleStream.close();
  }

  Article _mapDocumentToArticle(DocumentSnapshot doc) {
    return Article('mock', 'title', 'description', 'body', [], DateTime.now(),
        DateTime.now(), false, 1, null);
  }
}
