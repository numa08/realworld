import 'dart:async';

import 'package:app/repositories/repositories.dart';
import 'package:bloc_provider/bloc_provider.dart';

class SignInBloc implements Bloc {
  final AccountRepository _accountRepository;

  final StreamController<void> _signInWithGoogleStream =
      StreamController.broadcast();
  Sink<void> get signInWithGoogle => _signInWithGoogleStream.sink;
  final StreamController<void> _signInCompleteStream =
      StreamController.broadcast();
  Stream<void> get signInComplete => _signInCompleteStream.stream;
  final StreamController<bool> _isSignInProgressController =
      StreamController.broadcast();
  Stream<bool> get isSignInProgress => _isSignInProgressController.stream;
  SignInBloc(this._accountRepository) {
    _signInWithGoogleStream.stream.listen((_) async {
      _isSignInProgressController.add(true);
      await _accountRepository.signInWithGoogle();
      _isSignInProgressController.add(false);
      _signInCompleteStream.add(null);
    });
  }

  @override
  void dispose() async {
    await _signInWithGoogleStream.close();
    await _signInCompleteStream.close();
    await _isSignInProgressController.close();
  }
}
