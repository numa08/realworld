import 'package:app/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class SignInEvent extends Equatable {
  SignInEvent([List props = const []]) : super(props);
}

class SignUpWithGoogle extends SignInEvent {}

abstract class SignInState extends Equatable {
  SignInState([List props = const []]) : super(props);
}

class SignUp extends SignInState {}

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
  final AccountRepository accountRepository;

  SignInBloc({@required this.accountRepository})
      : assert(accountRepository != null);

  @override
  SignInState get initialState => SignUp();

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is SignUpWithGoogle) {
      yield SignInProgress();
      try {
        await accountRepository.signUpWithGoogle();
        yield SignInComplete();
      } catch (e) {
        yield SignInError(e.toString());
      }
    }
  }
}
