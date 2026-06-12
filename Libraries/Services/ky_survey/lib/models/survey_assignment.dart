enum SurveyAssignmentStatus {
  queued,
  inProgress,
  needsReview,
  completed,
  blocked,
}

SurveyAssignmentStatus surveyAssignmentStatusFromJson(Object? value) {
  if (value is SurveyAssignmentStatus) {
    return value;
  }

  if (value is String) {
    for (final status in SurveyAssignmentStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
  }

  return SurveyAssignmentStatus.queued;
}

class SurveyAssignment {
  final String id;
  final String surveyId;
  final String assigneeId;
  final String assigneeName;
  final String territory;
  final SurveyAssignmentStatus status;
  final int targetResponses;
  final int completedResponses;
  final DateTime dueAt;
  final DateTime assignedAt;
  final String? note;

  const SurveyAssignment({
    required this.id,
    required this.surveyId,
    required this.assigneeId,
    required this.assigneeName,
    required this.territory,
    required this.dueAt,
    required this.assignedAt,
    this.status = SurveyAssignmentStatus.queued,
    this.targetResponses = 0,
    this.completedResponses = 0,
    this.note,
  });

  double get completionRate {
    if (targetResponses == 0) {
      return 0;
    }

    return (completedResponses / targetResponses).clamp(0, 1).toDouble();
  }

  bool isOverdue({DateTime? now}) {
    final today = now ?? DateTime.now();
    return !status.isDone && dueAt.isBefore(today);
  }

  SurveyAssignment copyWith({
    String? id,
    String? surveyId,
    String? assigneeId,
    String? assigneeName,
    String? territory,
    SurveyAssignmentStatus? status,
    int? targetResponses,
    int? completedResponses,
    DateTime? dueAt,
    DateTime? assignedAt,
    String? note,
  }) {
    return SurveyAssignment(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      territory: territory ?? this.territory,
      status: status ?? this.status,
      targetResponses: targetResponses ?? this.targetResponses,
      completedResponses: completedResponses ?? this.completedResponses,
      dueAt: dueAt ?? this.dueAt,
      assignedAt: assignedAt ?? this.assignedAt,
      note: note ?? this.note,
    );
  }

  factory SurveyAssignment.fromJson(Map<String, dynamic> json) {
    return SurveyAssignment(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      assigneeId: json['assigneeId'] as String,
      assigneeName: json['assigneeName'] as String,
      territory: json['territory'] as String,
      status: surveyAssignmentStatusFromJson(json['status']),
      targetResponses: json['targetResponses'] as int? ?? 0,
      completedResponses: json['completedResponses'] as int? ?? 0,
      dueAt: DateTime.parse(json['dueAt'] as String),
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'territory': territory,
      'status': status.name,
      'targetResponses': targetResponses,
      'completedResponses': completedResponses,
      'dueAt': dueAt.toIso8601String(),
      'assignedAt': assignedAt.toIso8601String(),
      'note': note,
    };
  }
}

extension SurveyAssignmentStatusDetails on SurveyAssignmentStatus {
  String get label {
    switch (this) {
      case SurveyAssignmentStatus.queued:
        return 'Queued';
      case SurveyAssignmentStatus.inProgress:
        return 'In Progress';
      case SurveyAssignmentStatus.needsReview:
        return 'Needs Review';
      case SurveyAssignmentStatus.completed:
        return 'Completed';
      case SurveyAssignmentStatus.blocked:
        return 'Blocked';
    }
  }

  bool get isActive {
    switch (this) {
      case SurveyAssignmentStatus.queued:
      case SurveyAssignmentStatus.inProgress:
      case SurveyAssignmentStatus.needsReview:
      case SurveyAssignmentStatus.blocked:
        return true;
      case SurveyAssignmentStatus.completed:
        return false;
    }
  }

  bool get isDone => this == SurveyAssignmentStatus.completed;
}
