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

class ShowHomeAccount extends HomeState {
  ShowHomeAccount() : super();
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AccountRepository _accountRepository;
  final ArticleRepository _articleRepository;
  final UserRepository _userRepository;

  HomeBloc(
      this._accountRepository, this._articleRepository, this._userRepository);

  @override
  HomeState get initialState => HomeAccountNotLoaded();

  Stream<AuthState> get authState => _accountRepository.authState;
  Stream<List<Article>> get articles => _articleRepository.articles;

  Stream<User> user(String reference) => _userRepository.findUser(reference);

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
