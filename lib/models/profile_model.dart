import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String name;
  int age;
  int monthlyTarget;
  String role;
  Timestamp? timeTargetUpdated;
  int phoneNo;
  bool hasDayEnded;
  bool isActive;
  Map<String, dynamic>? targetData;

  Profile(
      {required this.name,
      required this.monthlyTarget,
      required this.isActive,
      required this.age,
      this.targetData,
      required this.hasDayEnded,
      required this.phoneNo,
      required this.role,
      this.timeTargetUpdated});

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'],
        isActive = json['isActive'],
        hasDayEnded = json['hasDayEnded'],
        monthlyTarget = json['monthlyTarget'],
        targetData = json['targetData'],
        role = json['role'],
        phoneNo = json['phoneNo'],
        timeTargetUpdated = json['timeTargetUpdated'];
}
