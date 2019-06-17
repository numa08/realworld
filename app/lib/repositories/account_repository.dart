import 'dart:async';

import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountRepository {
  factory AccountRepository() {
    return new AccountRepository._internal();
  }

  AccountRepository._internal() {
    this.firestore = Firestore.instance;
    this.firebaseAuth = FirebaseAuth.instance;
    this.googleSignIn = GoogleSignIn();
  }

  Firestore firestore;
  FirebaseAuth firebaseAuth;
  GoogleSignIn googleSignIn;

  final StreamController<Account> _accountStream = StreamController.broadcast();
  Stream<Account> get account => _accountStream.stream.distinct();

  void fetch() async {
    account.listen((_) => print('on add $_'));
    firebaseAuth.onAuthStateChanged.listen((user) {
      if (user == null) {
        _accountStream.add(null);
        return;
      }
      _listenUserStore(user);
    });

    var currentUser = await firebaseAuth.currentUser();
    if (currentUser == null) {
      _accountStream.add(null);
      return;
    }
    if (currentUser.isAnonymous) {
      _accountStream.add(AnonymousUser(currentUser.uid));
      return;
    }

    QuerySnapshot userQuery = await firestore
        .collection('users')
        .where('token', isEqualTo: currentUser.uid)
        .getDocuments();

    if (userQuery == null) {
      _accountStream.add(null);
      return;
    }
    var userDocuments = userQuery.documents;
    if (userDocuments == null || userDocuments.isEmpty) {
      _accountStream.add(null);
      return;
    }
    userDocuments.map((d) => User.fromJson(d.data)).forEach(_accountStream.add);
  }

  void signInAnonymously() async {
    var firebaseUser = await firebaseAuth.signInAnonymously();
    var account = AnonymousUser(firebaseUser.uid);
    _accountStream.add(account);
  }

  Future<void> signUpWithGoogle() async {
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final firebaseUser = await firebaseAuth.signInWithCredential(credential);
    var user = User(firebaseUser.email, firebaseUser.uid,
        firebaseUser.displayName, "", null);
    await firestore.collection('users').add(user.toJson());
  }

  Future<void> signOut() => firebaseAuth.signOut();

  void _listenUserStore(FirebaseUser firebaseUser) {
    firestore
        .collection('users')
        .where('token', isEqualTo: firebaseUser.uid)
        .snapshots()
        .map((query) => query.documents.map((d) => User.fromJson(d.data)))
        .listen((users) {
      users.forEach(_accountStream.add);
    });
  }

  void dispose() async {
    await _accountStream.close();
  }
}
