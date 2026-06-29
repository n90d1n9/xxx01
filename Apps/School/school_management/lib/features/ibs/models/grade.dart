import 'enums.dart';
import 'student.dart';
import 'subject.dart';
import 'teacher.dart';

class Grade {
  final int id; // Unique identifier for the grade
  final DateTime examDate; // Date of examination, required
  final double score; // Numerical score, min=0, max=100, required
  final String? comments; // Teacher comments
  final GradeType gradeType; // Type of the grade
  final Student
  student; // Student associated with the grade, manyToOne relationship
  final Subject
  subject; // Subject associated with the grade, manyToOne relationship
  final Teacher
  teacher; // Teacher associated with the grade, manyToOne relationship

  Grade({
    required this.id,
    required this.examDate,
    required this.score,
    this.comments,
    required this.gradeType,
    required this.student,
    required this.subject,
    required this.teacher,
  });

  Grade copyWith({
    int? id,
    DateTime? examDate,
    double? score,
    String? comments,
    GradeType? gradeType,
    Student? student,
    Subject? subject,
    Teacher? teacher,
  }) {
    return Grade(
      id: id ?? this.id,
      examDate: examDate ?? this.examDate,
      score: score ?? this.score,
      comments: comments ?? this.comments,
      gradeType: gradeType ?? this.gradeType,
      student: student ?? this.student,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examDate': examDate.toIso8601String(),
      'score': score,
      'comments': comments,
      'gradeType': gradeType.toString(),
      'student': student.toJson(),
      'subject': subject.toJson(),
      'teacher': teacher.toJson(),
    };
  }

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      examDate: DateTime.parse(json['examDate']),
      score: json['score'],
      comments: json['comments'],
      gradeType: GradeType.values.firstWhere(
        (e) => e.toString() == json['gradeType'],
      ),
      student: Student.fromJson(json['student']),
      subject: Subject.fromJson(json['subject']),
      teacher: Teacher.fromJson(json['teacher']),
    );
  }

  @override
  String toString() {
    return 'Grade(id: $id, examDate: $examDate, score: $score, comments: $comments, gradeType: $gradeType, student: $student, subject: $subject, teacher: $teacher)';
  }
}
