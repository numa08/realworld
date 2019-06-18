import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  AccountEvent([List props = const []]) : super(props);
}

class FetchDrawerHeaderAccount extends AccountEvent {}

class SignOutDrawerHeaderAccount extends AccountEvent {}

abstract class AccountState extends Equatable {
  AccountState([List props = const []]) : super(props);
}

class DrawerHeaderAccountNotLoaded extends AccountState {
  DrawerHeaderAccountNotLoaded() : super();
}

class ShowDrawerHeaderAccount extends AccountState {
  ShowDrawerHeaderAccount() : super();
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;

  AccountBloc(this._accountRepository);

  Stream<Account> get account => _accountRepository.account;

  @override
  AccountState get initialState => DrawerHeaderAccountNotLoaded();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is FetchDrawerHeaderAccount) {
      _accountRepository.fetch();
      yield ShowDrawerHeaderAccount();
    }
    if (event is SignOutDrawerHeaderAccount) {
      _accountRepository.signOut();
      yield DrawerHeaderAccountNotLoaded();
    }
  }

  @override
  void dispose() {
    _accountRepository.dispose();
    super.dispose();
  }
}
