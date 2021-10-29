class Employee {
  String name;
  int age;

  Employee({required this.name, required this.age});

  Employee.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'];
}
