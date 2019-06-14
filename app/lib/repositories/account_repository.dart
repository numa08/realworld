import 'dart:async';

import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class AccountRepository {
  final Firestore firestore;
  final FirebaseAuth firebaseAuth;

  AccountRepository({@required this.firebaseAuth, @required this.firestore})
      : assert(firebaseAuth != null),
        assert(firestore != null);

  final StreamController<Account> _accountStream = StreamController();
  Stream<Account> get account => _accountStream.stream;

  void fetch() async {
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

  void dispose() {
    _accountStream.close();
  }
}
