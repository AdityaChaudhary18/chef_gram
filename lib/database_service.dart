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
      state: snapshot.get('state') ?? '',
      city: snapshot.get('city') ?? '',
      beat: snapshot.get('beat') ?? '',
      timeTargetUpdated: snapshot.get('timeTargetUpdated'),
    );
  }

  void updateTodayTarget(String state, String city, String beat) {
    _profileCollection.doc(uid).update({
      'state': state,
      'city': city,
      'beat': beat,
      'timeTargetUpdated': DateTime.now(),
    });
  }
}
