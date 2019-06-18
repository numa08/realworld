import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

class FetchHomeAccount extends HomeEvent {}

class SignInAnonymousAccount extends HomeEvent {}

abstract class HomeState extends Equatable {
  HomeState([List props = const []]) : super(props);
}

class HomeAccountNotLoaded extends HomeState {}

class ShowHomeAccount extends HomeState {}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AccountRepository _accountRepository;

  HomeBloc(this._accountRepository);

  @override
  HomeState get initialState => HomeAccountNotLoaded();

  Stream<Account> get account => _accountRepository.account;

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchHomeAccount) {
      _accountRepository.fetch();
      yield ShowHomeAccount();
    }
    if (event is SignInAnonymousAccount) {
      _accountRepository.signInAnonymously();
      yield ShowHomeAccount();
    }
  }

  @override
  void dispose() {
    _accountRepository.dispose();
    super.dispose();
  }
}
