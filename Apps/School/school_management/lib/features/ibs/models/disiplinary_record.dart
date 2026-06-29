import 'enums.dart';
import 'staff.dart';
import 'student.dart';

class DisciplinaryRecord {
  final int id; // Unique identifier for the disciplinary record
  final DateTime date; // Date of incident, required
  final String description; // Description of incident, required
  final String action; // Disciplinary action taken, required
  final String? notes; // Additional notes
  final IncidentSeverity severity; // Severity of the incident, default=minor
  final Student
  student; // Student associated with the record, manyToOne relationship
  final Staff
  reportedBy; // Staff who reported the incident, manyToOne relationship

  DisciplinaryRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.action,
    this.notes,
    this.severity = IncidentSeverity.minor,
    required this.student,
    required this.reportedBy,
  });

  DisciplinaryRecord copyWith({
    int? id,
    DateTime? date,
    String? description,
    String? action,
    String? notes,
    IncidentSeverity? severity,
    Student? student,
    Staff? reportedBy,
  }) {
    return DisciplinaryRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      action: action ?? this.action,
      notes: notes ?? this.notes,
      severity: severity ?? this.severity,
      student: student ?? this.student,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'action': action,
      'notes': notes,
      'severity': severity.toString(),
      'student': student.toJson(),
      'reportedBy': reportedBy.toJson(),
    };
  }

  factory DisciplinaryRecord.fromJson(Map<String, dynamic> json) {
    return DisciplinaryRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      action: json['action'],
      notes: json['notes'],
      severity: IncidentSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
      ),
      student: Student.fromJson(json['student']),
      reportedBy: Staff.fromJson(json['reportedBy']),
    );
  }

  @override
  String toString() {
    return 'DisciplinaryRecord(id: $id, date: $date, description: $description, action: $action, notes: $notes, severity: $severity, student: $student, reportedBy: $reportedBy)';
  }
}
