class Project {
  final int id;
  final String name;
  final String? description;

  Project({required this.id, required this.name, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static Project fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int,
      name: map['name'],
      description: map['description'],
    );
  }
}