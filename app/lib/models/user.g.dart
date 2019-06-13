// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      json['email'] as String,
      json['token'] as String,
      json['username'] as String,
      json['bio'] as String,
      json['image'] == null ? null : Uri.parse(json['image'] as String));
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'token': instance.token,
      'username': instance.username,
      'bio': instance.bio,
      'image': instance.image?.toString()
    };
