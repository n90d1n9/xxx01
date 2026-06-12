const inventoryDefaultWarehouseBranchName = 'Main Branch';

class Warehouse {
  final String id;
  final String name;
  final String? branchId;
  final String branchName;
  final String location;
  final String? description;
  final num? capacity;

  Warehouse({
    required this.id,
    required this.name,
    this.branchId,
    this.branchName = inventoryDefaultWarehouseBranchName,
    required this.location,
    this.description,
    this.capacity,
  });

  String get branchLabel {
    final normalized = branchName.trim();
    return normalized.isEmpty
        ? inventoryDefaultWarehouseBranchName
        : normalized;
  }

  Warehouse copyWith({
    String? id,
    String? name,
    String? branchId,
    String? branchName,
    String? location,
    String? description,
    num? capacity,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      location: location ?? this.location,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, branchId: $branchId, branchName: $branchName, location: $location, description: $description, capacity: $capacity)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branchId': branchId,
      'branchName': branchName,
      'location': location,
      'description': description,
      'capacity': capacity,
    };
  }

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      branchId: json['branchId'],
      branchName: json['branchName'] ?? inventoryDefaultWarehouseBranchName,
      location: json['location'],
      description: json['description'],
      capacity: json['capacity'],
    );
  }
}
