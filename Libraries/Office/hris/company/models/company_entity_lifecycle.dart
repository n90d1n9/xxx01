enum CompanyEntityLifecycleType {
  incorporation,
  branchOpening,
  payrollActivation,
  restructuring,
  closure,
  merger,
}

enum CompanyEntityLifecycleStatus {
  planned,
  inProgress,
  blocked,
  launched,
  archived,
}

enum CompanyEntityLifecycleIssue {
  missingEntity,
  missingOwner,
  missingMilestone,
  missingDependency,
  overdueTarget,
  blocked,
  lowProgress,
}

extension CompanyEntityLifecycleTypeLabels on CompanyEntityLifecycleType {
  String get label {
    switch (this) {
      case CompanyEntityLifecycleType.incorporation:
        return 'Incorporation';
      case CompanyEntityLifecycleType.branchOpening:
        return 'Branch opening';
      case CompanyEntityLifecycleType.payrollActivation:
        return 'Payroll activation';
      case CompanyEntityLifecycleType.restructuring:
        return 'Restructuring';
      case CompanyEntityLifecycleType.closure:
        return 'Closure';
      case CompanyEntityLifecycleType.merger:
        return 'Merger';
    }
  }
}

extension CompanyEntityLifecycleStatusLabels on CompanyEntityLifecycleStatus {
  String get label {
    switch (this) {
      case CompanyEntityLifecycleStatus.planned:
        return 'Planned';
      case CompanyEntityLifecycleStatus.inProgress:
        return 'In progress';
      case CompanyEntityLifecycleStatus.blocked:
        return 'Blocked';
      case CompanyEntityLifecycleStatus.launched:
        return 'Launched';
      case CompanyEntityLifecycleStatus.archived:
        return 'Archived';
    }
  }
}

extension CompanyEntityLifecycleIssueLabels on CompanyEntityLifecycleIssue {
  String get label {
    switch (this) {
      case CompanyEntityLifecycleIssue.missingEntity:
        return 'Assign entity';
      case CompanyEntityLifecycleIssue.missingOwner:
        return 'Assign owner';
      case CompanyEntityLifecycleIssue.missingMilestone:
        return 'Add milestone';
      case CompanyEntityLifecycleIssue.missingDependency:
        return 'Map dependency';
      case CompanyEntityLifecycleIssue.overdueTarget:
        return 'Target overdue';
      case CompanyEntityLifecycleIssue.blocked:
        return 'Resolve blocker';
      case CompanyEntityLifecycleIssue.lowProgress:
        return 'Increase progress';
    }
  }
}

class CompanyEntityLifecycleMilestone {
  final String id;
  final String title;
  final String entityName;
  final CompanyEntityLifecycleType type;
  final CompanyEntityLifecycleStatus status;
  final String ownerName;
  final DateTime targetDate;
  final int progressPercent;
  final String dependencySummary;
  final String blocker;
  final String nextMilestone;

  const CompanyEntityLifecycleMilestone({
    required this.id,
    required this.title,
    required this.entityName,
    required this.type,
    required this.status,
    required this.ownerName,
    required this.targetDate,
    required this.progressPercent,
    required this.dependencySummary,
    required this.blocker,
    required this.nextMilestone,
  });

  int daysUntilTarget(DateTime asOfDate) {
    return _dateOnly(targetDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyEntityLifecycleIssue> issues(DateTime asOfDate) {
    if (status == CompanyEntityLifecycleStatus.launched ||
        status == CompanyEntityLifecycleStatus.archived) {
      return [];
    }

    final days = daysUntilTarget(asOfDate);
    return [
      if (entityName.trim().isEmpty) CompanyEntityLifecycleIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyEntityLifecycleIssue.missingOwner,
      if (nextMilestone.trim().isEmpty)
        CompanyEntityLifecycleIssue.missingMilestone,
      if (dependencySummary.trim().isEmpty)
        CompanyEntityLifecycleIssue.missingDependency,
      if (days < 0) CompanyEntityLifecycleIssue.overdueTarget,
      if (status == CompanyEntityLifecycleStatus.blocked)
        CompanyEntityLifecycleIssue.blocked,
      if (days <= 30 && progressPercent < 60)
        CompanyEntityLifecycleIssue.lowProgress,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  CompanyEntityLifecycleMilestone copyWith({
    String? id,
    String? title,
    String? entityName,
    CompanyEntityLifecycleType? type,
    CompanyEntityLifecycleStatus? status,
    String? ownerName,
    DateTime? targetDate,
    int? progressPercent,
    String? dependencySummary,
    String? blocker,
    String? nextMilestone,
  }) {
    return CompanyEntityLifecycleMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      targetDate: targetDate ?? this.targetDate,
      progressPercent: progressPercent ?? this.progressPercent,
      dependencySummary: dependencySummary ?? this.dependencySummary,
      blocker: blocker ?? this.blocker,
      nextMilestone: nextMilestone ?? this.nextMilestone,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyEntityLifecycleDraft {
  final String title;
  final String entityName;
  final CompanyEntityLifecycleType type;
  final CompanyEntityLifecycleStatus status;
  final String ownerName;
  final String targetDateText;
  final String progressPercentText;
  final String dependencySummary;
  final String blocker;
  final String nextMilestone;

  const CompanyEntityLifecycleDraft({
    required this.title,
    required this.entityName,
    required this.type,
    required this.status,
    required this.ownerName,
    required this.targetDateText,
    required this.progressPercentText,
    required this.dependencySummary,
    required this.blocker,
    required this.nextMilestone,
  });

  factory CompanyEntityLifecycleDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyEntityLifecycleDraft(
      title: '',
      entityName: entityName,
      type: CompanyEntityLifecycleType.branchOpening,
      status: CompanyEntityLifecycleStatus.planned,
      ownerName: '',
      targetDateText: '',
      progressPercentText: '25',
      dependencySummary: '',
      blocker: '',
      nextMilestone: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  static String? validatePercent(String? value) {
    final percent = int.tryParse(value?.trim() ?? '');
    if (percent == null || percent < 0 || percent > 100) {
      return 'Enter 0-100';
    }
    return null;
  }

  DateTime? get targetDate => _parseDate(targetDateText);

  int? get progressPercent => int.tryParse(progressPercentText.trim());

  bool get isReady {
    return title.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        targetDate != null &&
        progressPercent != null &&
        progressPercent! >= 0 &&
        progressPercent! <= 100 &&
        dependencySummary.trim().isNotEmpty &&
        nextMilestone.trim().isNotEmpty;
  }

  CompanyEntityLifecycleMilestone toLifecycleMilestone(String id) {
    if (!isReady) {
      throw StateError('Complete entity lifecycle milestone before saving.');
    }

    return CompanyEntityLifecycleMilestone(
      id: id,
      title: title.trim(),
      entityName: entityName.trim(),
      type: type,
      status: status,
      ownerName: ownerName.trim(),
      targetDate: targetDate!,
      progressPercent: progressPercent!,
      dependencySummary: dependencySummary.trim(),
      blocker: blocker.trim(),
      nextMilestone: nextMilestone.trim(),
    );
  }

  CompanyEntityLifecycleDraft copyWith({
    String? title,
    String? entityName,
    CompanyEntityLifecycleType? type,
    CompanyEntityLifecycleStatus? status,
    String? ownerName,
    String? targetDateText,
    String? progressPercentText,
    String? dependencySummary,
    String? blocker,
    String? nextMilestone,
  }) {
    return CompanyEntityLifecycleDraft(
      title: title ?? this.title,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      targetDateText: targetDateText ?? this.targetDateText,
      progressPercentText: progressPercentText ?? this.progressPercentText,
      dependencySummary: dependencySummary ?? this.dependencySummary,
      blocker: blocker ?? this.blocker,
      nextMilestone: nextMilestone ?? this.nextMilestone,
    );
  }

  static DateTime? _parseDate(String value) {
    final normalized = value.trim();
    if (normalized.length != 10) return null;
    final date = DateTime.tryParse(normalized);
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }
}
