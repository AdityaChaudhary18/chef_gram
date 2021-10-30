class Profile {
  String name;
  int age;

  Profile({required this.name, required this.age});

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'];
}
