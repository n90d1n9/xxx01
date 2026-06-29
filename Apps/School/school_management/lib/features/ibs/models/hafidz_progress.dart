import 'enums.dart';
import 'student.dart';
import 'surah.dart';
import 'teacher.dart';

class HafizProgress {
  final int id; // Unique identifier for the progress record
  final DateTime date; // Date of recording, required
  final int startVerse; // Starting verse number, min=1, required
  final int endVerse; // Ending verse number, min=1, required
  final String? comments; // Teacher comments
  final double
  qualityScore; // Quality of memorization score, min=0, max=10, default=0
  final MemorizationStatus
  memorizationStatus; // Memorization status, default=inProgress
  final Student?
  student; // Student associated with the progress, manyToOne relationship
  final int
  surahId; // Surah associated with the progress, manyToOne relationship
  final Teacher?
  assessor; // Teacher who assessed the progress, manyToOne relationship

  HafizProgress({
    required this.id,
    required this.date,
    required this.startVerse,
    required this.endVerse,
    this.comments,
    this.qualityScore = 0,
    this.memorizationStatus = MemorizationStatus.inProgress,
    this.student,
    this.surahId = 1,
    this.assessor,
  });

  HafizProgress copyWith({
    int? id,
    DateTime? date,
    int? startVerse,
    int? endVerse,
    String? comments,
    double? qualityScore,
    MemorizationStatus? memorizationStatus,
    Student? student,
    int? surahId,
    Teacher? assessor,
  }) {
    return HafizProgress(
      id: id ?? this.id,
      date: date ?? this.date,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      comments: comments ?? this.comments,
      qualityScore: qualityScore ?? this.qualityScore,
      memorizationStatus: memorizationStatus ?? this.memorizationStatus,
      student: student ?? this.student,
      surahId: surahId ?? this.surahId,
      assessor: assessor ?? this.assessor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startVerse': startVerse,
      'endVerse': endVerse,
      'comments': comments,
      'qualityScore': qualityScore,
      'memorizationStatus': memorizationStatus.toString(),
      'student': student!.toJson(),
      'surah': surahId,
      'assessor': assessor!.toJson(),
    };
  }

  factory HafizProgress.fromJson(Map<String, dynamic> json) {
    return HafizProgress(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startVerse: json['startVerse'],
      endVerse: json['endVerse'],
      comments: json['comments'],
      qualityScore: json['qualityScore'],
      memorizationStatus: MemorizationStatus.values.firstWhere(
        (e) => e.toString() == json['memorizationStatus'],
      ),
      student: Student.fromJson(json['student']),
      surahId: json['surahId'],
      assessor: Teacher.fromJson(json['assessor']),
    );
  }

  @override
  String toString() {
    return 'HafizProgress(id: $id, date: $date, startVerse: $startVerse, endVerse: $endVerse, comments: $comments, qualityScore: $qualityScore, memorizationStatus: $memorizationStatus, student: $student, surah: $surahId, assessor: $assessor)';
  }
}
