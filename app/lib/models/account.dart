import 'package:equatable/equatable.dart';

abstract class Account extends Equatable {
  Account([List<dynamic> props = const <dynamic>[]]) : super(props);

  String get email;
  String get token;
  String get username;
  String get bio;
  Uri get image;
  bool get isAnonymous;
}

class AnonymousUser extends Account {
  AnonymousUser(this.token) : super(<dynamic>[token]);

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
}
