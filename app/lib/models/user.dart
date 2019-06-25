import 'package:app/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Account {
  User(this.email, this.token, this.username, this.bio, this.image,
      this.createdAt, this.updatedAt)
      : super(<dynamic>[token, createdAt, updatedAt]);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  final String email;
  @override
  final String token;
  @override
  final String username;
  @override
  final String bio;
  @override
  final Uri image;
  @JsonKey()
  @FireDatetimeJsonConverter()
  final FireDateTime createdAt;
  @JsonKey()
  @FireDatetimeJsonConverter()
  final FireDateTime updatedAt;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool get isAnonymous => false;
}
