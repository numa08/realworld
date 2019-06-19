import 'package:app/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class SignInEvent extends Equatable {
  SignInEvent([List props = const []]) : super(props);
}

class SignInWithGoogle extends SignInEvent {}

abstract class SignInState extends Equatable {
  SignInState([List props = const []]) : super(props);
}

class SignUp extends SignInState {}

class SignInProgress extends SignInState {}

class SignInComplete extends SignInState {}

class SignInError extends SignInState {
  final String error;

  SignInError(this.error) : super([error]);
}

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AccountRepository _accountRepository;

  SignInBloc(this._accountRepository);

  @override
  SignInState get initialState => SignUp();

  @override
  void dispose() {
    _accountRepository.dispose();
    super.dispose();
  }

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is SignInWithGoogle) {
      yield SignInProgress();
      try {
        await _accountRepository.signInWithGoogle();
        yield SignInComplete();
      } catch (e, st) {
        print(st.toString());
        yield SignInError(e.toString());
      }
    }
  }
}
