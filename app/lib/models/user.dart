import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String token;
  final String username;
  final String bio;
  final Uri image;

  User(this.email, this.token, this.username, this.bio, this.image)
      : super([email]);
}
