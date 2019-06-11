import 'package:app/models/models.dart';
import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String slug;
  final String title;
  final String description;
  final String body;
  final List<String> tagList;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool favorited;
  final int favoritesCount;
  final Profile author;

  Article(
      this.slug,
      this.title,
      this.description,
      this.body,
      this.tagList,
      this.createdAt,
      this.updatedAt,
      this.favorited,
      this.favoritesCount,
      this.author)
      : super([slug]);
}
