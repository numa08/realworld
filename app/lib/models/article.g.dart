// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) {
  return Article(
      json['slug'] as String,
      json['title'] as String,
      json['description'] as String,
      json['body'] as String,
      const FireDatetimeJsonConverter().fromJson(json['createdAt']),
      const FireDatetimeJsonConverter().fromJson(json['updatedAt']),
      json['authorRef'] as String,
      (json['tags'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'description': instance.description,
      'body': instance.body,
      'createdAt': const FireDatetimeJsonConverter().toJson(instance.createdAt),
      'updatedAt': const FireDatetimeJsonConverter().toJson(instance.updatedAt),
      'authorRef': instance.authorRef,
      'tags': instance.tags
    };
