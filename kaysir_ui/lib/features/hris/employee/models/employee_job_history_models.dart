import 'employee_directory_models.dart';

enum EmployeeJobHistoryEventType {
  hire('Hire'),
  promotion('Promotion'),
  transfer('Transfer'),
  managerChange('Manager change'),
  departmentChange('Department change'),
  contractChange('Contract change'),
  compensationChange('Compensation change'),
  locationChange('Location change');

  final String label;

  const EmployeeJobHistoryEventType(this.label);
}

enum EmployeeJobHistoryStatus {
  effective('Effective'),
  scheduled('Scheduled'),
  pendingEvidence('Pending evidence'),
  reversed('Reversed');

  final String label;

  const EmployeeJobHistoryStatus(this.label);
}

enum EmployeeJobHistorySource {
  employeeRecordAction('Record action'),
  jobAssignment('Job assignment'),
  managerChange('Manager change'),
  contractLifecycle('Contract lifecycle'),
  payroll('Payroll'),
  manualCorrection('Manual correction');

  final String label;

  const EmployeeJobHistorySource(this.label);
}

class EmployeeJobHistoryEvent {
  final String id;
  final String employeeId;
  final EmployeeJobHistoryEventType type;
  final String title;
  final String fromValue;
  final String toValue;
  final DateTime effectiveDate;
  final DateTime recordedAt;
  final EmployeeJobHistorySource source;
  final EmployeeJobHistoryStatus status;
  final String owner;
  final String note;
  final String evidence;

  const EmployeeJobHistoryEvent({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.fromValue,
    required this.toValue,
    required this.effectiveDate,
    required this.recordedAt,
    required this.source,
    required this.status,
    required this.owner,
    required this.note,
    required this.evidence,
  });

  bool get isEffective => status == EmployeeJobHistoryStatus.effective;

  bool get isScheduled => status == EmployeeJobHistoryStatus.scheduled;

  bool get isReversed => status == EmployeeJobHistoryStatus.reversed;

  bool get hasEvidence => evidence.trim().isNotEmpty;

  bool get requiresEvidence {
    return switch (type) {
      EmployeeJobHistoryEventType.hire ||
      EmployeeJobHistoryEventType.promotion ||
      EmployeeJobHistoryEventType.transfer ||
      EmployeeJobHistoryEventType.managerChange ||
      EmployeeJobHistoryEventType.contractChange ||
      EmployeeJobHistoryEventType.compensationChange => true,
      EmployeeJobHistoryEventType.departmentChange ||
      EmployeeJobHistoryEventType.locationChange => false,
    };
  }

  bool get needsEvidence {
    return !isReversed &&
        (status == EmployeeJobHistoryStatus.pendingEvidence ||
            (requiresEvidence && !hasEvidence));
  }

  bool isOverdue(DateTime asOfDate) {
    final today = _dateOnly(asOfDate);
    return !isEffective && !isReversed && effectiveDate.isBefore(today);
  }

  bool isScheduledSoon(DateTime asOfDate) {
    final today = _dateOnly(asOfDate);
    final horizon = today.add(const Duration(days: 14));
    return isScheduled &&
        !effectiveDate.isBefore(today) &&
        !effectiveDate.isAfter(horizon);
  }

  bool needsAttention(DateTime asOfDate) {
    return isOverdue(asOfDate) || needsEvidence || isScheduledSoon(asOfDate);
  }

  EmployeeJobHistoryEvent copyWith({
    DateTime? recordedAt,
    EmployeeJobHistoryStatus? status,
    String? note,
    String? evidence,
  }) {
    return EmployeeJobHistoryEvent(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      fromValue: fromValue,
      toValue: toValue,
      effectiveDate: effectiveDate,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source,
      status: status ?? this.status,
      owner: owner,
      note: note ?? this.note,
      evidence: evidence ?? this.evidence,
    );
  }
}

class EmployeeJobHistoryProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String currentPosition;
  final String currentDepartment;
  final String currentManager;
  final List<EmployeeJobHistoryEvent> history;

  const EmployeeJobHistoryProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.currentPosition,
    required this.currentDepartment,
    required this.currentManager,
    required this.history,
  });

  EmployeeJobHistoryProfile copyWith({List<EmployeeJobHistoryEvent>? history}) {
    return EmployeeJobHistoryProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      currentPosition: currentPosition,
      currentDepartment: currentDepartment,
      currentManager: currentManager,
      history: history ?? this.history,
    );
  }

  List<EmployeeJobHistoryEvent> get sortedHistory {
    final sorted = [...history]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        asOfDate,
      ).compareTo(_attentionRank(b, asOfDate));
      if (attentionCompare != 0) return attentionCompare;

      final dateCompare = b.effectiveDate.compareTo(a.effectiveDate);
      if (dateCompare != 0) return dateCompare;

      return b.recordedAt.compareTo(a.recordedAt);
    });
    return sorted;
  }

  int get effectiveCount {
    return history.where((event) => event.isEffective).length;
  }

  int get scheduledCount {
    return history.where((event) => event.isScheduled).length;
  }

  int get pendingEvidenceCount {
    return history.where((event) => event.needsEvidence).length;
  }

  int get reversedCount {
    return history.where((event) => event.isReversed).length;
  }

  int get overdueCount {
    return history.where((event) => event.isOverdue(asOfDate)).length;
  }

  int get scheduledSoonCount {
    return history.where((event) => event.isScheduledSoon(asOfDate)).length;
  }

  int get attentionCount {
    return history.where((event) => event.needsAttention(asOfDate)).length;
  }

  EmployeeJobHistoryEvent? get latestEffectiveEvent {
    final effective =
        history.where((event) => event.isEffective).toList()
          ..sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
    if (effective.isEmpty) return null;
    return effective.first;
  }

  EmployeeJobHistoryEvent? get nextScheduledEvent {
    final scheduled =
        history
            .where((event) => event.isScheduled && !event.isReversed)
            .toList()
          ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
    if (scheduled.isEmpty) return null;
    return scheduled.first;
  }

  String get nextAction {
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue job-history event${overdueCount == 1 ? '' : 's'}.';
    }
    if (pendingEvidenceCount > 0) {
      return 'Attach evidence for $pendingEvidenceCount job-history event${pendingEvidenceCount == 1 ? '' : 's'}.';
    }
    if (scheduledSoonCount > 0) {
      return 'Validate $scheduledSoonCount scheduled job-history event${scheduledSoonCount == 1 ? '' : 's'} due soon.';
    }
    final latest = latestEffectiveEvent;
    if (latest == null) {
      return 'Create the first job-history event.';
    }
    return 'Latest effective change: ${latest.title}.';
  }
}

class EmployeeJobHistoryEventDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime earliestDate;
  final EmployeeJobHistoryEventType type;
  final String title;
  final String fromValue;
  final String toValue;
  final DateTime? effectiveDate;
  final EmployeeJobHistorySource source;
  final String owner;
  final String note;
  final String evidence;

  const EmployeeJobHistoryEventDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.earliestDate,
    required this.type,
    required this.title,
    required this.fromValue,
    required this.toValue,
    required this.effectiveDate,
    required this.source,
    required this.owner,
    required this.note,
    required this.evidence,
  });

  factory EmployeeJobHistoryEventDraft.fromMember({
    required EmployeeDirectoryMember member,
    required DateTime asOfDate,
  }) {
    final today = _dateOnly(asOfDate);
    return EmployeeJobHistoryEventDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: today,
      earliestDate: _dateOnly(member.joiningDate),
      type: EmployeeJobHistoryEventType.transfer,
      title: '',
      fromValue: '${member.position} - ${member.department}',
      toValue: '',
      effectiveDate: today.add(const Duration(days: 14)),
      source: EmployeeJobHistorySource.manualCorrection,
      owner: 'People Operations',
      note: '',
      evidence: '',
    );
  }

  EmployeeJobHistoryEventDraft copyWith({
    EmployeeJobHistoryEventType? type,
    String? title,
    String? fromValue,
    String? toValue,
    DateTime? effectiveDate,
    EmployeeJobHistorySource? source,
    String? owner,
    String? note,
    String? evidence,
  }) {
    return EmployeeJobHistoryEventDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      earliestDate: earliestDate,
      type: type ?? this.type,
      title: title ?? this.title,
      fromValue: fromValue ?? this.fromValue,
      toValue: toValue ?? this.toValue,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      source: source ?? this.source,
      owner: owner ?? this.owner,
      note: note ?? this.note,
      evidence: evidence ?? this.evidence,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Event title must be at least 4 characters');
    }
    if (fromValue.trim().length < 2) {
      errors.add('Previous value is required');
    }
    if (toValue.trim().length < 2) {
      errors.add('New value is required');
    }
    if (fromValue.trim().toLowerCase() == toValue.trim().toLowerCase()) {
      errors.add('Previous and new values must be different');
    }
    final date = effectiveDate;
    if (date == null) {
      errors.add('Effective date is required');
    } else if (date.isBefore(earliestDate)) {
      errors.add('Effective date cannot be before hire date');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (note.trim().length < 10) {
      errors.add('Note must be at least 10 characters');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          title.trim().length >= 4,
          fromValue.trim().length >= 2,
          toValue.trim().length >= 2 &&
              fromValue.trim().toLowerCase() != toValue.trim().toLowerCase(),
          effectiveDate != null && !effectiveDate!.isBefore(earliestDate),
          owner.trim().length >= 3,
          note.trim().length >= 10,
        ].where((item) => item).length;
    return completed / 6;
  }

  EmployeeJobHistoryEvent toEvent({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    final date = _dateOnly(effectiveDate!);
    final normalizedEvidence = evidence.trim();
    final status =
        _requiresEvidence(type) && normalizedEvidence.isEmpty
            ? EmployeeJobHistoryStatus.pendingEvidence
            : date.isAfter(asOfDate)
            ? EmployeeJobHistoryStatus.scheduled
            : EmployeeJobHistoryStatus.effective;

    return EmployeeJobHistoryEvent(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title.trim(),
      fromValue: fromValue.trim(),
      toValue: toValue.trim(),
      effectiveDate: date,
      recordedAt: asOfDate,
      source: source,
      status: status,
      owner: owner.trim(),
      note: note.trim(),
      evidence: normalizedEvidence,
    );
  }
}

bool _requiresEvidence(EmployeeJobHistoryEventType type) {
  return switch (type) {
    EmployeeJobHistoryEventType.hire ||
    EmployeeJobHistoryEventType.promotion ||
    EmployeeJobHistoryEventType.transfer ||
    EmployeeJobHistoryEventType.managerChange ||
    EmployeeJobHistoryEventType.contractChange ||
    EmployeeJobHistoryEventType.compensationChange => true,
    EmployeeJobHistoryEventType.departmentChange ||
    EmployeeJobHistoryEventType.locationChange => false,
  };
}

int _attentionRank(EmployeeJobHistoryEvent event, DateTime asOfDate) {
  if (event.isOverdue(asOfDate)) return 0;
  if (event.needsEvidence) return 1;
  if (event.isScheduledSoon(asOfDate)) return 2;
  if (event.isScheduled) return 3;
  if (event.isEffective) return 4;
  return 5;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
