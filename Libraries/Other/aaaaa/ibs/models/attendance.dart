import 'class_group.dart';
import 'enums.dart';
import 'student.dart';
import 'subject.dart';

class Attendance {
  final int id; // Unique identifier for the attendance record
  final DateTime date; // Attendance date, required
  final String? notes; // Additional notes
  final AttendanceStatus status; // Attendance status, default=present
  final Student
  student; // Student associated with the attendance, manyToOne relationship
  final ClassGroup
  classGroup; // Class group associated with the attendance, manyToOne relationship
  final Subject
  subject; // Subject associated with the attendance, manyToOne relationship

  Attendance({
    required this.id,
    required this.date,
    this.notes,
    this.status = AttendanceStatus.present,
    required this.student,
    required this.classGroup,
    required this.subject,
  });

  Attendance copyWith({
    int? id,
    DateTime? date,
    String? notes,
    AttendanceStatus? status,
    Student? student,
    ClassGroup? classGroup,
    Subject? subject,
  }) {
    return Attendance(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      student: student ?? this.student,
      classGroup: classGroup ?? this.classGroup,
      subject: subject ?? this.subject,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'notes': notes,
      'status': status.toString(),
      'student': student.toJson(),
      'classGroup': classGroup.toJson(),
      'subject': subject.toJson(),
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      student: Student.fromJson(json['student']),
      classGroup: ClassGroup.fromJson(json['classGroup']),
      subject: Subject.fromJson(json['subject']),
    );
  }

  @override
  String toString() {
    return 'Attendance(id: $id, date: $date, notes: $notes, status: $status, student: $student, classGroup: $classGroup, subject: $subject)';
  }
}
