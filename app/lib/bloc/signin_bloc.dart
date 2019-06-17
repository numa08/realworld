import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class SignInEvent extends Equatable {
  SignInEvent([List props = const []]) : super(props);
}

class ChangeSignInMode extends SignInEvent {
  @override
  bool operator ==(Object other) => other is ChangeSignInMode;

  @override
  int get hashCode => super.hashCode;
}

class ChangeSignUpMode extends SignInEvent {
  @override
  bool operator ==(Object other) => other is ChangeSignUpMode;

  @override
  int get hashCode => super.hashCode;
}

class SignInWithEmailAndPassword extends SignInEvent {
  final String email;
  final String password;

  SignInWithEmailAndPassword({@required this.email, @required this.password})
      : super([email, password]);
}

class SignUpWithEmailAndPassword extends SignInEvent {
  final String email;
  final String password;
  final String username;

  SignUpWithEmailAndPassword(
      {@required this.email, @required this.password, @required this.username})
      : super([email, password, username]);
}

abstract class SignInState extends Equatable {
  SignInState([List props = const []]) : super(props);
}

class SignInMode extends SignInState {
  @override
  bool operator ==(Object other) => other is SignInMode;

  @override
  int get hashCode => super.hashCode;
}

class SignUpMode extends SignInState {
  @override
  bool operator ==(Object other) => other is SignUpMode;

  @override
  int get hashCode => super.hashCode;
}

class SignInProgress extends SignInState {
  @override
  bool operator ==(Object other) => other is SignInProgress;

  @override
  int get hashCode => super.hashCode;
}

class SignInComplete extends SignInState {
  @override
  bool operator ==(Object other) => other is SignInComplete;

  @override
  int get hashCode => super.hashCode;
}

class SignInError extends SignInState {
  final String error;

  SignInError(this.error) : super([error]);
}

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  @override
  SignInState get initialState => SignUpMode();

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is ChangeSignInMode) {
      yield SignInMode();
    }
    if (event is ChangeSignUpMode) {
      yield SignUpMode();
    }
  }
}
