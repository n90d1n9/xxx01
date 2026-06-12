import 'enums.dart';
import 'room.dart';
import 'staff.dart';
import 'student.dart';

class Dormitory {
  final int id; // Unique identifier for the dormitory
  final String name; // Dormitory name, min=3, max=50, required, unique
  final String? description; // Dormitory description
  final int capacity; // Maximum capacity, min=1, required
  final String? address; // Dormitory address, min=5, max=200
  final bool isActive; // Whether dormitory is currently active, default=true
  final DormitoryType dormitoryType; // Type of the dormitory
  final Gender gender; // Gender allowed in the dormitory
  final List<Room> rooms; // Rooms in the dormitory, oneToMany relationship
  final List<Student>
  students; // Students residing in the dormitory, oneToMany relationship
  final Staff supervisor; // Supervisor of the dormitory, manyToOne relationship

  Dormitory({
    required this.id,
    required this.name,
    this.description,
    required this.capacity,
    this.address,
    this.isActive = true,
    required this.dormitoryType,
    required this.gender,
    this.rooms = const [],
    this.students = const [],
    required this.supervisor,
  });

  Dormitory copyWith({
    int? id,
    String? name,
    String? description,
    int? capacity,
    String? address,
    bool? isActive,
    DormitoryType? dormitoryType,
    Gender? gender,
    List<Room>? rooms,
    List<Student>? students,
    Staff? supervisor,
  }) {
    return Dormitory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      dormitoryType: dormitoryType ?? this.dormitoryType,
      gender: gender ?? this.gender,
      rooms: rooms ?? this.rooms,
      students: students ?? this.students,
      supervisor: supervisor ?? this.supervisor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'address': address,
      'isActive': isActive,
      'dormitoryType': dormitoryType.toString(),
      'gender': gender.toString(),
      'rooms': rooms.map((e) => e.toJson()).toList(),
      'students': students.map((e) => e.toJson()).toList(),
      'supervisor': supervisor.toJson(),
    };
  }

  factory Dormitory.fromJson(Map<String, dynamic> json) {
    return Dormitory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      capacity: json['capacity'],
      address: json['address'],
      isActive: json['isActive'],
      dormitoryType: DormitoryType.values.firstWhere(
        (e) => e.toString() == json['dormitoryType'],
      ),
      gender: Gender.values.firstWhere((e) => e.toString() == json['gender']),
      rooms: (json['rooms'] as List).map((e) => Room.fromJson(e)).toList(),
      students:
          (json['students'] as List).map((e) => Student.fromJson(e)).toList(),
      supervisor: Staff.fromJson(json['supervisor']),
    );
  }

  @override
  String toString() {
    return 'Dormitory(id: $id, name: $name, description: $description, capacity: $capacity, address: $address, isActive: $isActive, dormitoryType: $dormitoryType, gender: $gender, rooms: $rooms, students: $students, supervisor: $supervisor)';
  }
}
