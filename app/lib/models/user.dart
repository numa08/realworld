import 'package:app/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Account {
  final String email;
  final String token;
  final String username;
  final String bio;
  final Uri image;
  @JsonKey()
  @FireDatetimeJsonConverter()
  final FireDateTime createdAt;
  @JsonKey()
  @FireDatetimeJsonConverter()
  final FireDateTime updatedAt;

  User(this.email, this.token, this.username, this.bio, this.image,
      this.createdAt, this.updatedAt)
      : super([token, createdAt, updatedAt]);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool get isAnonymous => false;
}
