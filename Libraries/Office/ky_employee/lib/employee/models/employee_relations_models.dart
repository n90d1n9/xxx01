enum EmployeeRelationsEventType {
  recognition('Recognition'),
  commendation('Commendation'),
  coaching('Coaching'),
  conductIncident('Conduct incident'),
  writtenWarning('Written warning'),
  performanceImprovement('Performance improvement');

  final String label;

  const EmployeeRelationsEventType(this.label);

  bool get isPositive {
    return switch (this) {
      EmployeeRelationsEventType.recognition ||
      EmployeeRelationsEventType.commendation => true,
      EmployeeRelationsEventType.coaching ||
      EmployeeRelationsEventType.conductIncident ||
      EmployeeRelationsEventType.writtenWarning ||
      EmployeeRelationsEventType.performanceImprovement => false,
    };
  }
}

enum EmployeeRelationsSeverity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const EmployeeRelationsSeverity(this.label);

  bool get isHighRisk {
    return this == EmployeeRelationsSeverity.high ||
        this == EmployeeRelationsSeverity.critical;
  }
}

enum EmployeeRelationsStatus {
  documented('Documented'),
  followUpDue('Follow-up due'),
  inProgress('In progress'),
  resolved('Resolved'),
  archived('Archived');

  final String label;

  const EmployeeRelationsStatus(this.label);
}

enum EmployeeRelationsVisibility {
  team('Team'),
  managerOnly('Manager only'),
  confidential('Confidential');

  final String label;

  const EmployeeRelationsVisibility(this.label);
}

class EmployeeRelationsEvent {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeRelationsEventType type;
  final String title;
  final String owner;
  final DateTime occurredAt;
  final DateTime? followUpDate;
  final EmployeeRelationsSeverity severity;
  final EmployeeRelationsStatus status;
  final EmployeeRelationsVisibility visibility;
  final String summary;

  const EmployeeRelationsEvent({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.owner,
    required this.occurredAt,
    required this.followUpDate,
    required this.severity,
    required this.status,
    required this.visibility,
    required this.summary,
  });

  bool get isPositive => type.isPositive;

  bool get isCorrective => !type.isPositive;

  bool get isOpen {
    return isCorrective &&
        status != EmployeeRelationsStatus.resolved &&
        status != EmployeeRelationsStatus.archived;
  }

  bool isOverdue(DateTime asOfDate) {
    final dueDate = followUpDate;
    if (dueDate == null) return false;
    return isOpen && dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return isOpen &&
        (isOverdue(asOfDate) ||
            status == EmployeeRelationsStatus.followUpDue ||
            severity.isHighRisk);
  }

  EmployeeRelationsEvent copyWith({
    DateTime? followUpDate,
    EmployeeRelationsStatus? status,
    EmployeeRelationsSeverity? severity,
  }) {
    return EmployeeRelationsEvent(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      owner: owner,
      occurredAt: occurredAt,
      followUpDate: followUpDate ?? this.followUpDate,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      visibility: visibility,
      summary: summary,
    );
  }
}

class EmployeeRelationsProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeRelationsEvent> events;

  const EmployeeRelationsProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.events,
  });

  EmployeeRelationsProfile copyWith({List<EmployeeRelationsEvent>? events}) {
    return EmployeeRelationsProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      events: events ?? this.events,
    );
  }

  int get recognitionCount => events.where((event) => event.isPositive).length;

  int get correctiveOpenCount {
    return events.where((event) => event.isOpen).length;
  }

  int get overdueFollowUpCount {
    return events.where((event) => event.isOverdue(asOfDate)).length;
  }

  int get highSeverityOpenCount {
    return events
        .where((event) => event.isOpen && event.severity.isHighRisk)
        .length;
  }

  int get confidentialCount {
    return events
        .where(
          (event) =>
              event.visibility == EmployeeRelationsVisibility.confidential,
        )
        .length;
  }

  int get attentionCount {
    return events.where((event) => event.needsAttention(asOfDate)).length;
  }

  String get nextAction {
    if (overdueFollowUpCount > 0) {
      return 'Follow up on $overdueFollowUpCount overdue employee relations event${overdueFollowUpCount == 1 ? '' : 's'}.';
    }
    if (highSeverityOpenCount > 0) {
      return 'Prioritize $highSeverityOpenCount high-severity relations event${highSeverityOpenCount == 1 ? '' : 's'}.';
    }
    if (correctiveOpenCount > 0) {
      return 'Keep $correctiveOpenCount corrective event${correctiveOpenCount == 1 ? '' : 's'} moving.';
    }
    if (recognitionCount == 0) {
      return 'Document recognition when positive impact is observed.';
    }
    return 'Recognition and conduct records are current.';
  }
}

class EmployeeRelationsEventDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeRelationsEventType type;
  final String title;
  final String owner;
  final DateTime occurredAt;
  final DateTime followUpDate;
  final EmployeeRelationsSeverity severity;
  final EmployeeRelationsVisibility visibility;
  final String summary;

  const EmployeeRelationsEventDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.owner,
    required this.occurredAt,
    required this.followUpDate,
    required this.severity,
    required this.visibility,
    required this.summary,
  });

  EmployeeRelationsEventDraft copyWith({
    EmployeeRelationsEventType? type,
    String? title,
    String? owner,
    DateTime? occurredAt,
    DateTime? followUpDate,
    EmployeeRelationsSeverity? severity,
    EmployeeRelationsVisibility? visibility,
    String? summary,
  }) {
    return EmployeeRelationsEventDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      occurredAt: occurredAt ?? this.occurredAt,
      followUpDate: followUpDate ?? this.followUpDate,
      severity: severity ?? this.severity,
      visibility: visibility ?? this.visibility,
      summary: summary ?? this.summary,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Title must be at least 4 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (occurredAt.isAfter(asOfDate)) {
      errors.add('Event date cannot be in the future');
    }
    if (!type.isPositive && followUpDate.isBefore(occurredAt)) {
      errors.add('Follow-up date cannot be before the event date');
    }
    if (summary.trim().length < 12) {
      errors.add('Summary must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          owner.trim().length >= 3,
          !occurredAt.isAfter(asOfDate),
          type.isPositive || !followUpDate.isBefore(occurredAt),
          summary.trim().length >= 12,
        ].where((item) => item).length;
    return complete / 5;
  }

  EmployeeRelationsEvent toEvent({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeRelationsEvent(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      owner: owner.trim(),
      occurredAt: occurredAt,
      followUpDate: type.isPositive ? null : followUpDate,
      severity: severity,
      status:
          type.isPositive
              ? EmployeeRelationsStatus.documented
              : EmployeeRelationsStatus.followUpDue,
      visibility: visibility,
      summary: summary.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
