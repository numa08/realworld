import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {}

class SignedIn extends AuthState {}

class NotSignedIn extends AuthState {}
