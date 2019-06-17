import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AccountEvent extends Equatable {
  AccountEvent([List props = const []]) : super(props);
}

class FetchAccount extends AccountEvent {}

class LoginAnonymousAccount extends AccountEvent {}

abstract class AccountState extends Equatable {
  AccountState([List props = const []]) : super(props);
}

class AccountNotLoaded extends AccountState {
  AccountNotLoaded() : super();
}

class AccountShowing extends AccountState {
  AccountShowing() : super();
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  AccountBloc({@required this.accountRepository})
      : assert(accountRepository != null);

  Stream<Account> get accountStream => accountRepository.account;

  @override
  AccountState get initialState => AccountNotLoaded();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is FetchAccount) {
      accountRepository.fetch();
      yield AccountShowing();
    }
    if (event is LoginAnonymousAccount) {
      accountRepository.signInAnonymously();
      yield AccountShowing();
    }
  }

  @override
  void dispose() {
    accountRepository.dispose();
    super.dispose();
  }
}
