enum EmployeeTimelineEventType {
  hire('Hire'),
  record('Record'),
  work('Work'),
  growth('Growth'),
  pay('Pay'),
  security('Security'),
  note('Note');

  final String label;

  const EmployeeTimelineEventType(this.label);
}

enum EmployeeTimelinePriority {
  info('Info'),
  milestone('Milestone'),
  followUp('Follow-up'),
  risk('Risk');

  final String label;

  const EmployeeTimelinePriority(this.label);
}

enum EmployeeTimelineStatus {
  open('Open'),
  completed('Completed'),
  resolved('Resolved');

  final String label;

  const EmployeeTimelineStatus(this.label);
}

class EmployeeTimelineEntry {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeTimelineEventType type;
  final String title;
  final String detail;
  final String owner;
  final DateTime occurredAt;
  final DateTime? dueAt;
  final EmployeeTimelinePriority priority;
  final EmployeeTimelineStatus status;
  final bool pinned;

  const EmployeeTimelineEntry({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.title,
    required this.detail,
    required this.owner,
    required this.occurredAt,
    required this.dueAt,
    required this.priority,
    required this.status,
    required this.pinned,
  });

  bool get isOpen => status == EmployeeTimelineStatus.open;

  bool get isFollowUp {
    return priority == EmployeeTimelinePriority.followUp ||
        priority == EmployeeTimelinePriority.risk;
  }

  bool isOverdue(DateTime asOfDate) {
    final dueDate = dueAt;
    if (dueDate == null || !isOpen) return false;
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    return dueDate.isBefore(today);
  }

  bool isDueSoon(DateTime asOfDate) {
    final dueDate = dueAt;
    if (dueDate == null || !isOpen) return false;
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    return !dueDate.isBefore(today) &&
        !dueDate.isAfter(today.add(const Duration(days: 7)));
  }

  bool needsAttention(DateTime asOfDate) {
    return isOverdue(asOfDate) || (isFollowUp && isDueSoon(asOfDate));
  }

  bool get canResolve => status == EmployeeTimelineStatus.open;

  bool get canReopen => status == EmployeeTimelineStatus.resolved;

  EmployeeTimelineEntry copyWith({
    EmployeeTimelineStatus? status,
    bool? pinned,
  }) {
    return EmployeeTimelineEntry(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title,
      detail: detail,
      owner: owner,
      occurredAt: occurredAt,
      dueAt: dueAt,
      priority: priority,
      status: status ?? this.status,
      pinned: pinned ?? this.pinned,
    );
  }
}

class EmployeeTimelineProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeTimelineEntry> entries;

  const EmployeeTimelineProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.entries,
  });

  EmployeeTimelineProfile copyWith({List<EmployeeTimelineEntry>? entries}) {
    return EmployeeTimelineProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      entries: entries ?? this.entries,
    );
  }

  int get pinnedCount => entries.where((entry) => entry.pinned).length;

  int get openFollowUpCount {
    return entries.where((entry) => entry.isOpen && entry.isFollowUp).length;
  }

  int get overdueCount {
    return entries.where((entry) => entry.isOverdue(asOfDate)).length;
  }

  int get attentionCount {
    return entries.where((entry) => entry.needsAttention(asOfDate)).length;
  }

  int get recentCount {
    final cutoff = asOfDate.subtract(const Duration(days: 30));
    return entries.where((entry) => !entry.occurredAt.isBefore(cutoff)).length;
  }

  String get nextAction {
    if (overdueCount > 0) {
      return 'Resolve $overdueCount overdue timeline follow-up${overdueCount == 1 ? '' : 's'}.';
    }
    if (attentionCount > 0) {
      return 'Review $attentionCount active timeline follow-up${attentionCount == 1 ? '' : 's'}.';
    }
    if (pinnedCount > 0) {
      return '$pinnedCount pinned timeline moment${pinnedCount == 1 ? '' : 's'}.';
    }
    return 'Timeline is current.';
  }
}

class EmployeeTimelineDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeTimelineEventType type;
  final String title;
  final String detail;
  final String owner;
  final DateTime occurredAt;
  final DateTime? dueAt;
  final EmployeeTimelinePriority priority;
  final bool pinned;

  const EmployeeTimelineDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.title,
    required this.detail,
    required this.owner,
    required this.occurredAt,
    required this.dueAt,
    required this.priority,
    required this.pinned,
  });

  EmployeeTimelineDraft copyWith({
    EmployeeTimelineEventType? type,
    String? title,
    String? detail,
    String? owner,
    DateTime? occurredAt,
    DateTime? dueAt,
    bool clearDueAt = false,
    EmployeeTimelinePriority? priority,
    bool? pinned,
  }) {
    return EmployeeTimelineDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      owner: owner ?? this.owner,
      occurredAt: occurredAt ?? this.occurredAt,
      dueAt: clearDueAt ? null : dueAt ?? this.dueAt,
      priority: priority ?? this.priority,
      pinned: pinned ?? this.pinned,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.trim().length < 4) {
      errors.add('Title must be at least 4 characters');
    }
    if (detail.trim().length < 10) {
      errors.add('Detail must be at least 10 characters');
    }
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (occurredAt.isAfter(asOfDate)) {
      errors.add('Event date cannot be in the future');
    }
    final dueDate = dueAt;
    if (dueDate != null && dueDate.isBefore(occurredAt)) {
      errors.add('Follow-up date cannot be before event date');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final complete =
        [
          title.trim().length >= 4,
          detail.trim().length >= 10,
          owner.trim().length >= 3,
          !occurredAt.isAfter(asOfDate),
          dueAt == null || !dueAt!.isBefore(occurredAt),
        ].where((item) => item).length;
    return complete / 5;
  }

  EmployeeTimelineEntry toEntry({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeTimelineEntry(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      title: title.trim(),
      detail: detail.trim(),
      owner: owner.trim(),
      occurredAt: occurredAt,
      dueAt: dueAt,
      priority: priority,
      status: EmployeeTimelineStatus.open,
      pinned: pinned,
    );
  }
}
