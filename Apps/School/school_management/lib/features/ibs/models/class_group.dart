import 'schedule.dart';
import 'student.dart';
import 'subject.dart';
import 'teacher.dart';

class ClassGroup {
  final int id; // Unique identifier for the class group
  final String name; // Class name
  final String? description; // Class description
  final (int from, int to)? academicYear; // Academic year (e.g., 2024-2025)
  final DateTime? startDate; // Class start date
  final DateTime? endDate; // Class end date
  final int capacity; // Maximum number of students
  final bool isActive; // Whether class is currently active
  final List<Student> students; // Students in the class
  final List<Teacher> teachers; // Teachers in the class
  final List<Subject> subjects; // Subjects taught in the class
  final List<Schedule> schedules; // Schedules for the class

  const ClassGroup({
    required this.id,
    required this.name,
    this.description,
    this.academicYear = (2024, 2025),
    this.startDate,
    this.endDate,
    this.capacity = 30,
    this.isActive = true,
    this.students = const [],
    this.teachers = const [],
    this.subjects = const [],
    this.schedules = const [],
    required List<int> studentIds,
  });

  ClassGroup copyWith({
    int? id,
    String? name,
    String? description,
    (int from, int to)? academicYear,
    DateTime? startDate,
    DateTime? endDate,
    int? capacity,
    bool? isActive,
    List<Student>? students,
    List<Teacher>? teachers,
    List<Subject>? subjects,
    List<Schedule>? schedules,
    List<int>? studentIds,
    String? subject,
  }) {
    return ClassGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      academicYear: academicYear ?? this.academicYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      students: students ?? this.students,
      teachers: teachers ?? this.teachers,
      subjects: subjects ?? this.subjects,
      schedules: schedules ?? this.schedules,
      studentIds: studentIds ?? this.students.map((e) => e.id).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'academicYear': academicYear,
      'startDate': startDate!.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'capacity': capacity,
      'isActive': isActive,
      'students': students.map((e) => e.toJson()).toList(),
      'teachers': teachers.map((e) => e.toJson()).toList(),
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }

  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    return ClassGroup(
      id: json['id'],
      name: json['name'],
      studentIds:
          json['studentIds'] != null ? List<int>.from(json['studentIds']) : [],
      description: json['description'],
      academicYear: json['academicYear'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      capacity: json['capacity'],
      isActive: json['isActive'],
      students:
          (json['students'] as List).map((e) => Student.fromJson(e)).toList(),
      teachers:
          (json['teachers'] as List).map((e) => Teacher.fromJson(e)).toList(),
      subjects:
          (json['subjects'] as List).map((e) => Subject.fromJson(e)).toList(),
      schedules:
          (json['schedules'] as List).map((e) => Schedule.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'ClassGroup(id: $id, name: $name, description: $description, academicYear: $academicYear, startDate: $startDate, endDate: $endDate, capacity: $capacity, isActive: $isActive, students: $students, teachers: $teachers, subjects: $subjects, schedules: $schedules)';
  }
}
