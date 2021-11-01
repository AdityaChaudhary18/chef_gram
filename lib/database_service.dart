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
    shopsToVisit = snapshot.get('targetData.shopsToVisit') ?? [];
    return Profile(
      name: snapshot.get('name') ?? '',
      age: snapshot.get('age') ?? '',
      targetData: snapshot.get('targetData') ?? {},
      timeTargetUpdated: snapshot.get('timeTargetUpdated') ??
          DateTime.now().subtract(Duration(days: 1)),
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
      'targetData': {
        'state': state,
        'city': city,
        'beat': beat,
        'shopsToVisit': shopsToVisit,
      },
      'timeTargetUpdated': DateTime.now(),
    });
  }

  List catalog = [];

  Future<List> getCatalog() async {
    if (catalog.isEmpty) {
      var collection = FirebaseFirestore.instance.collection('catalog');
      var querySnapshot = await collection.get();
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        catalog.add({
          "name": data["name"],
          "price": data["price"],
          "quantity": data["quantity"],
          "image": data["image"]
        });
      }
      return catalog;
    } else
      return catalog;
  }
}
