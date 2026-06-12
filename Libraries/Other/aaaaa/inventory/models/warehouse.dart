class Warehouse {
  final String id;
  final String name;
  final String location;
  final String? description;
  final num? capacity;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.capacity,
  });

  Warehouse copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    num? capacity,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, location: $location, description: $description, capacity: $capacity)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'capacity': capacity,
    };
  }

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      capacity: json['capacity'],
    );
  }
}
