import 'package:app/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable()
class Article extends Equatable {
  final String id;
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
  final List<String> tags;

  Article(
      {this.id,
      this.slug,
      this.title,
      this.description,
      this.body,
      this.createdAt,
      this.updatedAt,
      this.authorRef,
      this.tags})
      : assert(slug != null),
        assert(title != null),
        assert(description != null),
        assert(body != null),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(authorRef != null),
        assert(tags != null);

  Article copyWith(
          {String id,
          String slug,
          String title,
          String description,
          String body,
          FireDateTime createdAt,
          FireDateTime updatedAt,
          String authorRef,
          List<String> tags}) =>
      Article(
          id: slug ?? this.id,
          slug: slug ?? this.slug,
          title: title ?? this.title,
          description: description ?? this.description,
          body: body ?? this.body,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          authorRef: authorRef ?? this.authorRef,
          tags: tags ?? this.tags);

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);

  factory Article.empty(Account author) => Article(
      id: null,
      slug: "",
      title: "",
      description: "",
      body: "",
      createdAt: FieldValueNow(),
      updatedAt: FieldValueNow(),
      authorRef: "/users/${author.token}",
      tags: []);
}
