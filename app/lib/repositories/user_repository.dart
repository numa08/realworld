import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRepository {
  factory UserRepository() => _FirestoreUserRepository(Firestore.instance);
  Stream<User> findUser(String reference);
}

class _FirestoreUserRepository implements UserRepository {
  _FirestoreUserRepository(this._firestore) : assert(_firestore != null);

  final Firestore _firestore;

  @override
  Stream<User> findUser(String reference) => _firestore
      .document(reference)
      .snapshots()
      .map((d) {
        try {
          return User.fromJson(d.data);
        } on Exception catch (_) {
          return null;
        }
      })
      .where((u) => u != null)
      .distinct();
}
