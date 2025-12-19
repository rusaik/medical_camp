class Patient {
  final String? id;
  final String name;
  final int age;
  final String gender;
  final String campId;
  final bool isSynced;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.campId,
    this.isSynced = false,
  });

  factory Patient.fromDocument(Map<String, dynamic> doc) {
    return Patient(
      id: doc['id'],
      name: doc['name'],
      age: doc['age'],
      gender: doc['gender'],
      campId: doc['camp_id'],
      isSynced: true,
    );
  }

  Map<String, dynamic> toDocumentData() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'camp_id': campId,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'camp_id': campId,
  };

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    gender: json['gender'],
    campId: json['camp_id'],
  );
}