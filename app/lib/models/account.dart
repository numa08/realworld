import 'package:equatable/equatable.dart';

abstract class Account extends Equatable {
  String get email;
  String get token;
  String get username;
  String get bio;
  Uri get image;
  bool get isAnonymous;

  Account([List props = const []]) : super(props);
}

class AnonymousUser extends Account {
  AnonymousUser(this.token);

  @override
  String get bio => 'guest';

  @override
  String get email => 'guest';

  @override
  Uri get image => null;

  @override
  bool get isAnonymous => true;

  @override
  final String token;

  @override
  String get username => 'guest';

  @override
  bool operator ==(Object other) => true;

  @override
  int get hashCode => super.hashCode;
}
