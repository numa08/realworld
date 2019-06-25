import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  Profile(this.username, this.bio, this.image, {this.following})
      : super(<String>[username]);

  final String username;
  final String bio;
  final Uri image;
  final bool following;
}
