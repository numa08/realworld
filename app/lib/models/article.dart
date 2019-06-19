import 'package:app/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable()
class Article extends Equatable {
  final String slug;
  final String title;
  final String description;
  final String body;
  @JsonKey()
  @FireDatetimeJsonConverter()
  final FireDateTime createdAt;
  @JsonKey()
  @FireDatetimeJsonConverter()
  final FireDateTime updatedAt;
  final String authorRef;

  Article(this.slug, this.title, this.description, this.body, this.createdAt,
      this.updatedAt, this.authorRef)
      : assert(slug != null),
        assert(title != null),
        assert(description != null),
        assert(body != null),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(authorRef != null);

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
