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

class AccountNotLoaded extends AccountState {}

// Bloc が通知する Stream は widget の更新が完了したら\終了する必要がある。
// そのため firestore が通知する stream をそのまま State に変換をしても、
// ソースとなる Stream が無限なので、 Bloc のライフサイクルが止まってしまう。
// そこで、 State の中で Stream を通知することで Widget では StreamBuilder
// を使って Bloc のライフサイクルを止めること無く描画ができるようになる
class AccountStream extends AccountState {
  final Stream<Account> accountStream;

  AccountStream({@required this.accountStream}) : assert(accountStream != null);

  @override
  bool operator ==(Object other) => other is AccountStream;

  @override
  int get hashCode => super.hashCode;
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  AccountBloc({@required this.accountRepository})
      : assert(accountRepository != null);

  @override
  AccountState get initialState => AccountNotLoaded();

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is FetchAccount) {
      accountRepository.fetch();
      yield AccountStream(accountStream: accountRepository.account);
    }
    if (event is LoginAnonymousAccount) {
      accountRepository.signInAnonymously();
      yield AccountStream(accountStream: accountRepository.account);
    }
  }

  @override
  void dispose() {
    accountRepository.dispose();
    super.dispose();
  }
}