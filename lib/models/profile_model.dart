import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String name;
  int age;
  Timestamp? timeTargetUpdated;
  Map<String, dynamic>? targetData;

  Profile(
      {required this.name,
      required this.age,
      this.targetData,
      this.timeTargetUpdated});

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'],
        targetData = json['targetData'],
        timeTargetUpdated = json['timeTargetUpdated'];
}
