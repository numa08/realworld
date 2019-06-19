import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRepository {
  Stream<User> findUser(String reference);

  factory UserRepository() => _FirestoreUserRepository(Firestore.instance);
}

class _FirestoreUserRepository implements UserRepository {
  final Firestore _firestore;

  _FirestoreUserRepository(this._firestore) : assert(_firestore != null);

  @override
  Stream<User> findUser(String reference) => _firestore
      .document(reference)
      .snapshots()
      .map((d) {
        try {
          return User.fromJson(d.data);
        } catch (_) {
          return null;
        }
      })
      .where((u) => u != null)
      .distinct();
}
