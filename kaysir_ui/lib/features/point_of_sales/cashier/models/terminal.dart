class Terminal {
  final String id;
  final String name;
  final String location;
  final bool isActive;

  Terminal({
    required this.id,
    required this.name,
    required this.location,
    required this.isActive,
  });

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'location': location, 'isActive': isActive};
  }

  @override
  String toString() {
    return 'Terminal(id: $id, name: $name, location: $location, isActive: $isActive)';
  }
}
