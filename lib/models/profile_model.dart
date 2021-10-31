import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String name;
  int age;
  String? beat;
  String? city;
  String? state;
  Timestamp? timeTargetUpdated;
  List? shopsToVisit;

  Profile(
      {required this.name,
      required this.age,
      this.city,
      this.state,
      this.beat,
      this.timeTargetUpdated,
      this.shopsToVisit});

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'],
        city = json['city'],
        state = json['state'],
        beat = json['beat'],
        timeTargetUpdated = json['timeTargetUpdated'],
        shopsToVisit = json['shopsToVisit'] ?? [];
}
