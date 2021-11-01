import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/profile_model.dart';

class DatabaseService {
  final String uid;

  DatabaseService({
    required this.uid,
  });

  List shopsToVisit = [];

  static CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection('users');

  static CollectionReference _beatCollection =
      FirebaseFirestore.instance.collection('beats');

  static CollectionReference _shopCollection =
      FirebaseFirestore.instance.collection('shops');

  Stream<Profile> get profile {
    return _profileCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }

  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    shopsToVisit = snapshot.get('shopsToVisit') ?? [];
    return Profile(
      name: snapshot.get('name') ?? '',
      age: snapshot.get('age') ?? '',
      state: snapshot.get('state') ?? '',
      city: snapshot.get('city') ?? '',
      beat: snapshot.get('beat') ?? '',
      timeTargetUpdated: snapshot.get('timeTargetUpdated') ??
          DateTime.now().subtract(Duration(days: 1)),
      shopsToVisit: shopsToVisit,
    );
  }

  void updateTodayTarget(String state, String city, String beat) async {
    shopsToVisit.clear();
    var beatDoc = await _beatCollection.doc(beat.replaceAll(' ', '')).get();
    List shops = beatDoc.get('shops');
    for (var shop in shops) {
      Map<String, dynamic> shopData = new Map();
      shopData['isVisited'] = false;
      shopData['shopRef'] = shop;
      shopsToVisit.add(shopData);
    }
    _profileCollection.doc(uid).update({
      'state': state,
      'city': city,
      'beat': beat,
      'timeTargetUpdated': DateTime.now(),
      'shopsToVisit': shopsToVisit,
    });
  }
}
