import 'dart:async';

import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AccountRepository {
  Stream<Account> get account;
  Stream<AuthState> get authState;

  void fetch();
  void signInAnonymously();
  void signInWithGoogle();
  void signOut();
  void dispose();

  factory AccountRepository() {
    return new _FirebaseAccountRepository(
        Firestore.instance, FirebaseAuth.instance, GoogleSignIn());
  }
}

class _FirebaseAccountRepository implements AccountRepository {
  final Firestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  _FirebaseAccountRepository(
      this._firestore, this._firebaseAuth, this._googleSignIn);

  final StreamController<Account> _accountStream = StreamController.broadcast();

  @override
  Stream<Account> get account => _accountStream.stream.distinct();

  @override
  Stream<AuthState> get authState => _firebaseAuth.onAuthStateChanged
      .map((u) => u == null ? NotSignedIn() : SignedIn())
      .asBroadcastStream();

  @override
  void fetch() async {
    _firebaseAuth.onAuthStateChanged.listen((u) {
      if (u == null) {
        return;
      }
      if (u.isAnonymous) {
        _accountStream.add(AnonymousUser(u.uid));
        return;
      }
      _listenUserStore(u);
    });
  }

  @override
  void signInAnonymously() => _firebaseAuth.signInAnonymously();

  @override
  void signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final firebaseUser = await _firebaseAuth.signInWithCredential(credential);
    final users = await _fetchUser(firebaseUser.uid);
    if (users != null && users.isNotEmpty) {
      return;
    }
    // sign up
    var user = User(firebaseUser.email, firebaseUser.uid,
        firebaseUser.displayName, "", null);
    await _firestore.collection('users').add(user.toJson());
  }

  @override
  void dispose() async {
    await _accountStream.close();
  }

  @override
  void signOut() async => _firebaseAuth.signOut();

  void _listenUserStore(FirebaseUser firebaseUser) {
    _firestore
        .collection('users')
        .where('token', isEqualTo: firebaseUser.uid)
        .snapshots()
        .map((query) => query.documents.map((d) => User.fromJson(d.data)))
        .listen((users) {
      users.forEach(_accountStream.add);
    });
  }

  Future<Iterable<User>> _fetchUser(String token) async {
    final QuerySnapshot query = await _firestore
        .collection('users')
        .where('token', isEqualTo: token)
        .getDocuments();
    if (query == null) {
      return null;
    }
    var documents = query.documents;
    if (documents == null || documents.isEmpty) {
      return null;
    }
    return documents.map((d) => User.fromJson(d.data));
  }
}
