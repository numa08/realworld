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

    final users = await _fetchUser(currentUser.uid);
    users.forEach(_accountStream.add);
  }

  Future<void> signInAnonymously() async {
    var firebaseUser = await firebaseAuth.signInAnonymously();
    var account = AnonymousUser(firebaseUser.uid);
    _accountStream.add(account);
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final firebaseUser = await firebaseAuth.signInWithCredential(credential);
    final users = await _fetchUser(firebaseUser.uid);
    if (users != null && users.isNotEmpty) {
      return;
    }
    var user = User(firebaseUser.email, firebaseUser.uid,
        firebaseUser.displayName, "", null);
    await firestore.collection('users').add(user.toJson());
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await signInAnonymously();
  }

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

  Future<Iterable<User>> _fetchUser(String token) async {
    QuerySnapshot query = await firestore
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

  void dispose() async {
    await _accountStream.close();
  }
}
