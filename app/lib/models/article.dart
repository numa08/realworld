import 'package:app/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'article.g.dart';

@JsonSerializable()
class Article extends Equatable {
  Article(
      {this.id,
      @required this.slug,
      @required this.title,
      @required this.description,
      @required this.body,
      @required this.createdAt,
      @required this.updatedAt,
      this.authorRef,
      @required this.tags})
      : assert(slug != null),
        assert(title != null),
        assert(description != null),
        assert(body != null),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(tags != null);

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  factory Article.empty(Account author) => Article(
      id: null,
      slug: '',
      title: '',
      description: '',
      body: '',
      createdAt: FieldValueNow(),
      updatedAt: FieldValueNow(),
      authorRef: '/users/${author.token}',
      tags: []);

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
          id: id ?? this.id,
          slug: slug ?? this.slug,
          title: title ?? this.title,
          description: description ?? this.description,
          body: body ?? this.body,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          authorRef: authorRef ?? this.authorRef,
          tags: tags ?? this.tags);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
