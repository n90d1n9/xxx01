import 'dormitory.dart';
import 'student.dart';

class Room {
  final int id; // Unique identifier for the room
  final String name; // Room name, min=3, max=50, required, unique
  final String? description; // Room description
  final int capacity; // Maximum capacity, min=1, required
  final bool isActive; // Whether room is currently active, default=true
  final Dormitory
  dormitory; // Dormitory where the room is located, manyToOne relationship
  final List<Student>
  students; // Students residing in the room, oneToMany relationship

  Room({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    this.isActive = true,
    required this.dormitory,
    this.students = const [],
  });

  Room copyWith({
    int? id,
    String? name,
    String? description,
    int? capacity,
    bool? isActive,
    Dormitory? dormitory,
    List<Student>? students,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      dormitory: dormitory ?? this.dormitory,
      students: students ?? this.students,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'isActive': isActive,
      'dormitory': dormitory.toJson(),
      'students': students.map((e) => e.toJson()).toList(),
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      capacity: json['capacity'],
      isActive: json['isActive'],
      dormitory: Dormitory.fromJson(json['dormitory']),
      students:
          (json['students'] as List).map((e) => Student.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, name: $name, description: $description, capacity: $capacity, isActive: $isActive, dormitory: $dormitory, students: $students)';
  }
}
