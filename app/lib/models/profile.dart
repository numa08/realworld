import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String username;
  final String bio;
  final Uri image;
  final bool following;

  Profile(this.username, this.bio, this.image, this.following)
      : super([username]);
}
