import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/profile_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({
    required this.uid,
  });

  static CollectionReference _profileCollection =
  FirebaseFirestore.instance.collection('users');

  Stream<Profile> get profile {
    return _profileCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }

  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    return Profile(
      name: snapshot.get('name') ?? '',
      age: snapshot.get('age') ?? '',
    );
  }
}