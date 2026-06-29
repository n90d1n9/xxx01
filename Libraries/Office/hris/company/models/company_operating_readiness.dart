enum CompanyOperatingReadinessArea {
  payroll,
  attendance,
  leave,
  onboarding,
  recruitment,
  employeeSelfService,
  performance,
  compliance,
}

enum CompanyOperatingReadinessStatus {
  ready,
  inProgress,
  needsReview,
  blocked,
  notStarted,
}

enum CompanyOperatingReadinessIssue {
  missingEntity,
  missingOwner,
  needsReview,
  blocked,
  notStarted,
  overdueReview,
  lowCoverage,
}

extension CompanyOperatingReadinessAreaLabels on CompanyOperatingReadinessArea {
  String get label {
    switch (this) {
      case CompanyOperatingReadinessArea.payroll:
        return 'Payroll';
      case CompanyOperatingReadinessArea.attendance:
        return 'Attendance';
      case CompanyOperatingReadinessArea.leave:
        return 'Leave';
      case CompanyOperatingReadinessArea.onboarding:
        return 'Onboarding';
      case CompanyOperatingReadinessArea.recruitment:
        return 'Recruitment';
      case CompanyOperatingReadinessArea.employeeSelfService:
        return 'Employee self-service';
      case CompanyOperatingReadinessArea.performance:
        return 'Performance';
      case CompanyOperatingReadinessArea.compliance:
        return 'Compliance';
    }
  }
}

extension CompanyOperatingReadinessStatusLabels
    on CompanyOperatingReadinessStatus {
  String get label {
    switch (this) {
      case CompanyOperatingReadinessStatus.ready:
        return 'Ready';
      case CompanyOperatingReadinessStatus.inProgress:
        return 'In progress';
      case CompanyOperatingReadinessStatus.needsReview:
        return 'Needs review';
      case CompanyOperatingReadinessStatus.blocked:
        return 'Blocked';
      case CompanyOperatingReadinessStatus.notStarted:
        return 'Not started';
    }
  }
}

extension CompanyOperatingReadinessIssueLabels
    on CompanyOperatingReadinessIssue {
  String get label {
    switch (this) {
      case CompanyOperatingReadinessIssue.missingEntity:
        return 'Assign entity';
      case CompanyOperatingReadinessIssue.missingOwner:
        return 'Assign owner';
      case CompanyOperatingReadinessIssue.needsReview:
        return 'Review service';
      case CompanyOperatingReadinessIssue.blocked:
        return 'Remove blocker';
      case CompanyOperatingReadinessIssue.notStarted:
        return 'Start rollout';
      case CompanyOperatingReadinessIssue.overdueReview:
        return 'Review overdue';
      case CompanyOperatingReadinessIssue.lowCoverage:
        return 'Improve coverage';
    }
  }
}

class CompanyOperatingReadinessItem {
  final String id;
  final CompanyOperatingReadinessArea area;
  final String entityName;
  final String ownerName;
  final CompanyOperatingReadinessStatus status;
  final int coveragePercent;
  final DateTime lastReviewDate;
  final DateTime nextReviewDate;
  final String blocker;
  final String linkedModule;

  const CompanyOperatingReadinessItem({
    required this.id,
    required this.area,
    required this.entityName,
    required this.ownerName,
    required this.status,
    required this.coveragePercent,
    required this.lastReviewDate,
    required this.nextReviewDate,
    required this.blocker,
    required this.linkedModule,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyOperatingReadinessIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (entityName.trim().isEmpty)
        CompanyOperatingReadinessIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyOperatingReadinessIssue.missingOwner,
      if (status == CompanyOperatingReadinessStatus.needsReview)
        CompanyOperatingReadinessIssue.needsReview,
      if (status == CompanyOperatingReadinessStatus.blocked)
        CompanyOperatingReadinessIssue.blocked,
      if (status == CompanyOperatingReadinessStatus.notStarted)
        CompanyOperatingReadinessIssue.notStarted,
      if (days < 0) CompanyOperatingReadinessIssue.overdueReview,
      if (coveragePercent < 80) CompanyOperatingReadinessIssue.lowCoverage,
    ];
  }

  bool requiresAttention(DateTime asOfDate) {
    return issues(asOfDate).isNotEmpty;
  }

  CompanyOperatingReadinessItem copyWith({
    String? id,
    CompanyOperatingReadinessArea? area,
    String? entityName,
    String? ownerName,
    CompanyOperatingReadinessStatus? status,
    int? coveragePercent,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    String? blocker,
    String? linkedModule,
  }) {
    return CompanyOperatingReadinessItem(
      id: id ?? this.id,
      area: area ?? this.area,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      coveragePercent: coveragePercent ?? this.coveragePercent,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      blocker: blocker ?? this.blocker,
      linkedModule: linkedModule ?? this.linkedModule,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyOperatingReadinessDraft {
  final CompanyOperatingReadinessArea area;
  final String entityName;
  final String ownerName;
  final CompanyOperatingReadinessStatus status;
  final String coveragePercentText;
  final String lastReviewDateText;
  final String nextReviewDateText;
  final String blocker;
  final String linkedModule;

  const CompanyOperatingReadinessDraft({
    required this.area,
    required this.entityName,
    required this.ownerName,
    required this.status,
    required this.coveragePercentText,
    required this.lastReviewDateText,
    required this.nextReviewDateText,
    required this.blocker,
    required this.linkedModule,
  });

  factory CompanyOperatingReadinessDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyOperatingReadinessDraft(
      area: CompanyOperatingReadinessArea.payroll,
      entityName: entityName,
      ownerName: '',
      status: CompanyOperatingReadinessStatus.inProgress,
      coveragePercentText: '80',
      lastReviewDateText: '',
      nextReviewDateText: '',
      blocker: '',
      linkedModule: 'People Operations',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePercent(String? value) {
    final percent = int.tryParse(value?.trim() ?? '');
    if (percent == null || percent < 0 || percent > 100) {
      return 'Enter 0-100';
    }
    return null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  int? get coveragePercent => int.tryParse(coveragePercentText.trim());

  DateTime? get lastReviewDate => _parseDate(lastReviewDateText);

  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    return entityName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        linkedModule.trim().isNotEmpty &&
        coveragePercent != null &&
        coveragePercent! >= 0 &&
        coveragePercent! <= 100 &&
        lastReviewDate != null &&
        nextReviewDate != null;
  }

  CompanyOperatingReadinessItem toReadinessItem(String id) {
    if (!isReady) {
      throw StateError('Complete operating readiness fields before saving.');
    }

    return CompanyOperatingReadinessItem(
      id: id,
      area: area,
      entityName: entityName.trim(),
      ownerName: ownerName.trim(),
      status: status,
      coveragePercent: coveragePercent!,
      lastReviewDate: lastReviewDate!,
      nextReviewDate: nextReviewDate!,
      blocker: blocker.trim(),
      linkedModule: linkedModule.trim(),
    );
  }

  CompanyOperatingReadinessDraft copyWith({
    CompanyOperatingReadinessArea? area,
    String? entityName,
    String? ownerName,
    CompanyOperatingReadinessStatus? status,
    String? coveragePercentText,
    String? lastReviewDateText,
    String? nextReviewDateText,
    String? blocker,
    String? linkedModule,
  }) {
    return CompanyOperatingReadinessDraft(
      area: area ?? this.area,
      entityName: entityName ?? this.entityName,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      coveragePercentText: coveragePercentText ?? this.coveragePercentText,
      lastReviewDateText: lastReviewDateText ?? this.lastReviewDateText,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      blocker: blocker ?? this.blocker,
      linkedModule: linkedModule ?? this.linkedModule,
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
