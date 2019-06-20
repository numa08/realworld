// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) {
  return Article(
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      body: json['body'] as String,
      createdAt: const FireDatetimeJsonConverter().fromJson(json['createdAt']),
      updatedAt: const FireDatetimeJsonConverter().fromJson(json['updatedAt']),
      authorRef: json['authorRef'] as String,
      tags: (json['tags'] as List)?.map((e) => e as String)?.toList());
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
