import 'class_group.dart';
import 'subject.dart';
import 'teacher.dart';

class Schedule {
  final int id; // Unique identifier for the schedule
  final String day; // Day of the week, min=3, max=10, required
  final DateTime startTime; // Start time, required
  final DateTime endTime; // End time, required
  final String? location; // Location or room, min=3, max=100
  final String? notes; // Additional notes
  final ClassGroup
  classGroup; // Class group associated with the schedule, manyToOne relationship
  final Subject
  subject; // Subject associated with the schedule, manyToOne relationship
  final Teacher
  teacher; // Teacher associated with the schedule, manyToOne relationship

  Schedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.location,
    this.notes,
    required this.classGroup,
    required this.subject,
    required this.teacher,
  });

  Schedule copyWith({
    int? id,
    String? day,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? notes,
    ClassGroup? classGroup,
    Subject? subject,
    Teacher? teacher,
  }) {
    return Schedule(
      id: id ?? this.id,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      classGroup: classGroup ?? this.classGroup,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'notes': notes,
      'classGroup': classGroup.toJson(),
      'subject': subject.toJson(),
      'teacher': teacher.toJson(),
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      day: json['day'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      notes: json['notes'],
      classGroup: ClassGroup.fromJson(json['classGroup']),
      subject: Subject.fromJson(json['subject']),
      teacher: Teacher.fromJson(json['teacher']),
    );
  }

  @override
  String toString() {
    return 'Schedule(id: $id, day: $day, startTime: $startTime, endTime: $endTime, location: $location, notes: $notes, classGroup: $classGroup, subject: $subject, teacher: $teacher)';
  }
}
