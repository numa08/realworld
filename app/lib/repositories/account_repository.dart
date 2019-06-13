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

  final StreamController<User> _userStream = StreamController();
  Stream<User> get user => _userStream.stream;

  void fetch() async {
    var currentUser = await firebaseAuth.currentUser();
    if (currentUser == null) {
      _userStream.add(null);
      return;
    }
    QuerySnapshot userQuery;
    try {
      userQuery = await firestore
          .collection('users')
          .where('token', isEqualTo: currentUser.uid)
          .snapshots()
          .single
          .timeout(const Duration(seconds: 3));
    } on TimeoutException catch (_) {
      userQuery = null;
    }
    if (userQuery == null) {
      _userStream.add(null);
      return;
    }
    var userDocuments = userQuery.documents;
    if (userDocuments == null || userDocuments.isEmpty) {
      _userStream.add(null);
      return;
    }
    userDocuments.map((d) => User.fromJson(d.data)).forEach(_userStream.add);
  }

  void signInAnonymously() async {
    var firebaseUser = await firebaseAuth.signInAnonymously();
    var user = User(null, firebaseUser.uid, "guest", "guest", null);
    await firestore.collection('users').add(user.toJson());
    _userStream.add(user);
  }

  void dispose() {
    _userStream.close();
  }
}
