import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String name;
  int age;
  int monthlyTarget;
  String role;
  Timestamp? timeTargetUpdated;
  String phoneNo;
  Map<String, dynamic>? targetData;

  Profile(
      {required this.name,
      required this.monthlyTarget,
      required this.age,
      this.targetData,
        required this.phoneNo,
      required this.role,
      this.timeTargetUpdated});

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'],
        monthlyTarget = json['monthlyTarget'],
        targetData = json['targetData'],
        role = json['role'],
  phoneNo = json['phoneNo'],
        timeTargetUpdated = json['timeTargetUpdated'];
}
