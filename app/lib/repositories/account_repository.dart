import 'dart:async';

import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AccountRepository {
  factory AccountRepository() {
    return _FirebaseAccountRepository(
        Firestore.instance, FirebaseAuth.instance, GoogleSignIn());
  }

  Stream<Account> get account;
  Stream<AuthState> get authState;

  void fetch();
  Future<void> signInAnonymously();
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> dispose();
}

class _FirebaseAccountRepository implements AccountRepository {
  _FirebaseAccountRepository(
      this._firestore, this._firebaseAuth, this._googleSignIn);

  final Firestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  StreamSubscription<User> _userSubscription;

  final StreamController<Account> _accountStream = StreamController.broadcast();

  @override
  Stream<Account> get account =>
      _accountStream.stream.asBroadcastStream().distinct();

  @override
  Stream<AuthState> get authState => _firebaseAuth.onAuthStateChanged
      .map((u) => u == null ? NotSignedIn() : SignedIn())
      .asBroadcastStream();

  @override
  void fetch() async {
    _firebaseAuth.onAuthStateChanged.listen((u) async {
      debugPrint('on auth state changed $u');
      try {
        if (u == null) {
          return;
        }
        if (u.isAnonymous) {
          _accountStream.add(AnonymousUser(u.uid));
          return;
        }
      } finally {
        // サインアウトが通知されたら、 firestore の監視の停止を試みる
        await _userSubscription?.cancel();
        _userSubscription = null;
      }
      if (_userSubscription == null) {
        _listenUserStore(u);
      }
    });
  }

  @override
  Future<void> signInAnonymously() => _firebaseAuth.signInAnonymously();

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final firebaseUser = await _firebaseAuth.signInWithCredential(credential);
    final users = await _fetchUser(firebaseUser.uid);
    if (users != null) {
      return;
    }
    // sign up
    final user = User(
        firebaseUser.email,
        firebaseUser.uid,
        firebaseUser.displayName,
        '',
        Uri.parse(firebaseUser.photoUrl),
        FieldValueNow(),
        FieldValueNow());
    await _firestore
        .collection('users')
        .document(firebaseUser.uid)
        .setData(user.toJson());
  }

  @override
  Future<void> dispose() async {
    await _accountStream.close();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _userSubscription.cancel();
    _userSubscription = null;
  }

  void _listenUserStore(FirebaseUser firebaseUser) {
    _userSubscription = _firestore
        .collection('users')
        .document(firebaseUser.uid)
        .snapshots()
        .where((d) => d != null && d.data != null)
        .map((d) => User.fromJson(d.data))
        .listen(_accountStream.add);
  }

  Future<User> _fetchUser(String token) async {
    final userData = await _firestore.collection('users').document(token).get();
    if (userData == null || userData.data == null) {
      return null;
    }
    return User.fromJson(userData.data);
  }
}
