enum CompanyCompensationBandFamily {
  executive,
  engineering,
  operations,
  people,
  finance,
  sales,
  general,
}

enum CompanyCompensationBandStatus {
  active,
  draft,
  pendingApproval,
  needsReview,
  retired,
}

enum CompanyCompensationBandIssue {
  missingCode,
  missingLevel,
  missingEntity,
  missingOwner,
  missingApprover,
  missingCurrency,
  invalidRange,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingApproval,
  needsReview,
  retired,
}

extension CompanyCompensationBandFamilyLabels on CompanyCompensationBandFamily {
  String get label {
    switch (this) {
      case CompanyCompensationBandFamily.executive:
        return 'Executive';
      case CompanyCompensationBandFamily.engineering:
        return 'Engineering';
      case CompanyCompensationBandFamily.operations:
        return 'Operations';
      case CompanyCompensationBandFamily.people:
        return 'People';
      case CompanyCompensationBandFamily.finance:
        return 'Finance';
      case CompanyCompensationBandFamily.sales:
        return 'Sales';
      case CompanyCompensationBandFamily.general:
        return 'General';
    }
  }
}

extension CompanyCompensationBandStatusLabels on CompanyCompensationBandStatus {
  String get label {
    switch (this) {
      case CompanyCompensationBandStatus.active:
        return 'Active';
      case CompanyCompensationBandStatus.draft:
        return 'Draft';
      case CompanyCompensationBandStatus.pendingApproval:
        return 'Pending approval';
      case CompanyCompensationBandStatus.needsReview:
        return 'Needs review';
      case CompanyCompensationBandStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyCompensationBandIssueLabels on CompanyCompensationBandIssue {
  String get label {
    switch (this) {
      case CompanyCompensationBandIssue.missingCode:
        return 'Add band code';
      case CompanyCompensationBandIssue.missingLevel:
        return 'Add level';
      case CompanyCompensationBandIssue.missingEntity:
        return 'Assign entity';
      case CompanyCompensationBandIssue.missingOwner:
        return 'Assign owner';
      case CompanyCompensationBandIssue.missingApprover:
        return 'Assign approver';
      case CompanyCompensationBandIssue.missingCurrency:
        return 'Add currency';
      case CompanyCompensationBandIssue.invalidRange:
        return 'Fix range';
      case CompanyCompensationBandIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyCompensationBandIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyCompensationBandIssue.draft:
        return 'Finalize draft';
      case CompanyCompensationBandIssue.pendingApproval:
        return 'Approve band';
      case CompanyCompensationBandIssue.needsReview:
        return 'Review band';
      case CompanyCompensationBandIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyCompensationBand {
  final String id;
  final String bandCode;
  final String entityName;
  final CompanyCompensationBandFamily family;
  final String levelName;
  final CompanyCompensationBandStatus status;
  final int minSalary;
  final int midpointSalary;
  final int maxSalary;
  final String currency;
  final String ownerName;
  final String approverName;
  final DateTime effectiveDate;
  final DateTime nextReviewDate;
  final String linkedPolicy;

  const CompanyCompensationBand({
    required this.id,
    required this.bandCode,
    required this.entityName,
    required this.family,
    required this.levelName,
    required this.status,
    required this.minSalary,
    required this.midpointSalary,
    required this.maxSalary,
    required this.currency,
    required this.ownerName,
    required this.approverName,
    required this.effectiveDate,
    required this.nextReviewDate,
    required this.linkedPolicy,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  bool get hasValidRange {
    return minSalary > 0 &&
        midpointSalary >= minSalary &&
        maxSalary >= midpointSalary;
  }

  List<CompanyCompensationBandIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (bandCode.trim().isEmpty) CompanyCompensationBandIssue.missingCode,
      if (levelName.trim().isEmpty) CompanyCompensationBandIssue.missingLevel,
      if (entityName.trim().isEmpty) CompanyCompensationBandIssue.missingEntity,
      if (ownerName.trim().isEmpty) CompanyCompensationBandIssue.missingOwner,
      if (approverName.trim().isEmpty)
        CompanyCompensationBandIssue.missingApprover,
      if (currency.trim().isEmpty) CompanyCompensationBandIssue.missingCurrency,
      if (!hasValidRange) CompanyCompensationBandIssue.invalidRange,
      if (days < 0) CompanyCompensationBandIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyCompensationBandIssue.reviewDueSoon,
      if (status == CompanyCompensationBandStatus.draft)
        CompanyCompensationBandIssue.draft,
      if (status == CompanyCompensationBandStatus.pendingApproval)
        CompanyCompensationBandIssue.pendingApproval,
      if (status == CompanyCompensationBandStatus.needsReview)
        CompanyCompensationBandIssue.needsReview,
      if (status == CompanyCompensationBandStatus.retired)
        CompanyCompensationBandIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyCompensationBand copyWith({
    String? id,
    String? bandCode,
    String? entityName,
    CompanyCompensationBandFamily? family,
    String? levelName,
    CompanyCompensationBandStatus? status,
    int? minSalary,
    int? midpointSalary,
    int? maxSalary,
    String? currency,
    String? ownerName,
    String? approverName,
    DateTime? effectiveDate,
    DateTime? nextReviewDate,
    String? linkedPolicy,
  }) {
    return CompanyCompensationBand(
      id: id ?? this.id,
      bandCode: bandCode ?? this.bandCode,
      entityName: entityName ?? this.entityName,
      family: family ?? this.family,
      levelName: levelName ?? this.levelName,
      status: status ?? this.status,
      minSalary: minSalary ?? this.minSalary,
      midpointSalary: midpointSalary ?? this.midpointSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      currency: currency ?? this.currency,
      ownerName: ownerName ?? this.ownerName,
      approverName: approverName ?? this.approverName,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      linkedPolicy: linkedPolicy ?? this.linkedPolicy,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyCompensationBandDraft {
  final String bandCode;
  final String entityName;
  final CompanyCompensationBandFamily family;
  final String levelName;
  final CompanyCompensationBandStatus status;
  final String minSalaryText;
  final String midpointSalaryText;
  final String maxSalaryText;
  final String currency;
  final String ownerName;
  final String approverName;
  final String effectiveDateText;
  final String nextReviewDateText;
  final String linkedPolicy;

  const CompanyCompensationBandDraft({
    required this.bandCode,
    required this.entityName,
    required this.family,
    required this.levelName,
    required this.status,
    required this.minSalaryText,
    required this.midpointSalaryText,
    required this.maxSalaryText,
    required this.currency,
    required this.ownerName,
    required this.approverName,
    required this.effectiveDateText,
    required this.nextReviewDateText,
    required this.linkedPolicy,
  });

  factory CompanyCompensationBandDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
  }) {
    return CompanyCompensationBandDraft(
      bandCode: '',
      entityName: entityName,
      family: CompanyCompensationBandFamily.general,
      levelName: '',
      status: CompanyCompensationBandStatus.active,
      minSalaryText: '',
      midpointSalaryText: '',
      maxSalaryText: '',
      currency: 'IDR',
      ownerName: '',
      approverName: '',
      effectiveDateText: '',
      nextReviewDateText: '',
      linkedPolicy: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePositiveInt(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  int? get minSalary => int.tryParse(minSalaryText.trim());
  int? get midpointSalary => int.tryParse(midpointSalaryText.trim());
  int? get maxSalary => int.tryParse(maxSalaryText.trim());
  DateTime? get effectiveDate => _parseDate(effectiveDateText);
  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    final min = minSalary;
    final midpoint = midpointSalary;
    final max = maxSalary;
    return bandCode.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        levelName.trim().isNotEmpty &&
        min != null &&
        midpoint != null &&
        max != null &&
        min > 0 &&
        midpoint >= min &&
        max >= midpoint &&
        currency.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        approverName.trim().isNotEmpty &&
        effectiveDate != null &&
        nextReviewDate != null;
  }

  CompanyCompensationBand toBand(String id) {
    if (!isReady) {
      throw StateError('Complete compensation band fields before saving.');
    }
    return CompanyCompensationBand(
      id: id,
      bandCode: bandCode.trim().toUpperCase(),
      entityName: entityName.trim(),
      family: family,
      levelName: levelName.trim(),
      status: status,
      minSalary: minSalary!,
      midpointSalary: midpointSalary!,
      maxSalary: maxSalary!,
      currency: currency.trim().toUpperCase(),
      ownerName: ownerName.trim(),
      approverName: approverName.trim(),
      effectiveDate: effectiveDate!,
      nextReviewDate: nextReviewDate!,
      linkedPolicy: linkedPolicy.trim(),
    );
  }

  CompanyCompensationBandDraft copyWith({
    String? bandCode,
    String? entityName,
    CompanyCompensationBandFamily? family,
    String? levelName,
    CompanyCompensationBandStatus? status,
    String? minSalaryText,
    String? midpointSalaryText,
    String? maxSalaryText,
    String? currency,
    String? ownerName,
    String? approverName,
    String? effectiveDateText,
    String? nextReviewDateText,
    String? linkedPolicy,
  }) {
    return CompanyCompensationBandDraft(
      bandCode: bandCode ?? this.bandCode,
      entityName: entityName ?? this.entityName,
      family: family ?? this.family,
      levelName: levelName ?? this.levelName,
      status: status ?? this.status,
      minSalaryText: minSalaryText ?? this.minSalaryText,
      midpointSalaryText: midpointSalaryText ?? this.midpointSalaryText,
      maxSalaryText: maxSalaryText ?? this.maxSalaryText,
      currency: currency ?? this.currency,
      ownerName: ownerName ?? this.ownerName,
      approverName: approverName ?? this.approverName,
      effectiveDateText: effectiveDateText ?? this.effectiveDateText,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      linkedPolicy: linkedPolicy ?? this.linkedPolicy,
    );
  }

  static DateTime? _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }
}
