abstract class Account {
  String get email;
  String get token;
  String get username;
  String get bio;
  Uri get image;
  bool get isAnonymous;
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
}
