import 'dart:convert';

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
    print(snapshot.data());
    shopsToVisit = snapshot.get('targetData.shopsToVisit') ?? [];
    return Profile(
      name: snapshot.get('name') ?? '',
      age: snapshot.get('age') ?? '',
      monthlyTarget: snapshot.get('monthlyTarget') ?? 0,
      targetData: snapshot.get('targetData') ?? {},
      role: snapshot.get('role'),
      phoneNo: snapshot.get('phoneNo') ?? '',
      hasDayEnded: snapshot.get('hasDayEnded') ?? false,
      timeTargetUpdated: snapshot.get('timeTargetUpdated') ??
          DateTime.now().subtract(Duration(days: 1)),
    );
  }

  List _shopsInfo = [];

  Future<List> getShopInfo(String beat) async {
    if (_shopsInfo.isEmpty) {
      var beatDoc = await FirebaseFirestore.instance
          .collection('shops')
          .where('beat', isEqualTo: beat)
          .get();
      List shops = beatDoc.docs;
      for (var shop in shops) {
        _shopsInfo.add({...shop.data(), 'shopRef': 'shops/${shop.id}'});
      }
    }
    final jsonList = _shopsInfo.map((item) => jsonEncode(item)).toList();
    final uniqueJsonList = jsonList.toSet().toList();
    _shopsInfo = uniqueJsonList.map((item) => jsonDecode(item)).toList();
    return _shopsInfo;
  }

  void updateTodayTarget(String state, String city, String beat) async {
    shopsToVisit.clear();
    _shopsInfo.clear();
    List shopInfo = await getShopInfo(beat);
    for (var shop in shopInfo) {
      Map<String, dynamic> shopData = new Map();
      shopData['isVisited'] = false;
      shopData['orderSuccessful'] = false;
      shopData['shopRef'] = shop['shopRef'];
      shopData['comment'] = 'Not Visited';
      shopsToVisit.add(shopData);
    }
    _profileCollection.doc(uid).update({
      'hasDayEnded': false,
      'targetData': {
        'todayTarget': 10000,
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

  void resetBeatDate() {
    FirebaseFirestore.instance.collection('users').doc(uid).update(
        {"timeTargetUpdated": DateTime.now().subtract(Duration(days: 1))});
  }
}
