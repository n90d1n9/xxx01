enum CompanyJobFamily {
  executive,
  engineering,
  operations,
  people,
  finance,
  sales,
  support,
  general,
}

enum CompanyJobProfileStatus {
  active,
  draft,
  pendingApproval,
  needsReview,
  retired,
}

enum CompanyJobProfileIssue {
  missingCode,
  missingTitle,
  missingEntity,
  missingOrgUnit,
  missingLevel,
  missingCompensationBand,
  missingOwner,
  missingDescription,
  missingSkills,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingApproval,
  needsReview,
  retired,
}

extension CompanyJobFamilyLabels on CompanyJobFamily {
  String get label {
    switch (this) {
      case CompanyJobFamily.executive:
        return 'Executive';
      case CompanyJobFamily.engineering:
        return 'Engineering';
      case CompanyJobFamily.operations:
        return 'Operations';
      case CompanyJobFamily.people:
        return 'People';
      case CompanyJobFamily.finance:
        return 'Finance';
      case CompanyJobFamily.sales:
        return 'Sales';
      case CompanyJobFamily.support:
        return 'Support';
      case CompanyJobFamily.general:
        return 'General';
    }
  }
}

extension CompanyJobProfileStatusLabels on CompanyJobProfileStatus {
  String get label {
    switch (this) {
      case CompanyJobProfileStatus.active:
        return 'Active';
      case CompanyJobProfileStatus.draft:
        return 'Draft';
      case CompanyJobProfileStatus.pendingApproval:
        return 'Pending approval';
      case CompanyJobProfileStatus.needsReview:
        return 'Needs review';
      case CompanyJobProfileStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyJobProfileIssueLabels on CompanyJobProfileIssue {
  String get label {
    switch (this) {
      case CompanyJobProfileIssue.missingCode:
        return 'Add job code';
      case CompanyJobProfileIssue.missingTitle:
        return 'Add job title';
      case CompanyJobProfileIssue.missingEntity:
        return 'Assign entity';
      case CompanyJobProfileIssue.missingOrgUnit:
        return 'Assign org unit';
      case CompanyJobProfileIssue.missingLevel:
        return 'Add level';
      case CompanyJobProfileIssue.missingCompensationBand:
        return 'Link band';
      case CompanyJobProfileIssue.missingOwner:
        return 'Assign owner';
      case CompanyJobProfileIssue.missingDescription:
        return 'Add description';
      case CompanyJobProfileIssue.missingSkills:
        return 'Add skills';
      case CompanyJobProfileIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyJobProfileIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyJobProfileIssue.draft:
        return 'Finalize draft';
      case CompanyJobProfileIssue.pendingApproval:
        return 'Approve profile';
      case CompanyJobProfileIssue.needsReview:
        return 'Review profile';
      case CompanyJobProfileIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyJobProfile {
  final String id;
  final String jobCode;
  final String jobTitle;
  final String entityName;
  final String orgUnitName;
  final CompanyJobFamily family;
  final String levelName;
  final CompanyJobProfileStatus status;
  final String compensationBand;
  final String ownerName;
  final DateTime nextReviewDate;
  final String jobDescription;
  final String skillsSummary;
  final String linkedPolicy;

  const CompanyJobProfile({
    required this.id,
    required this.jobCode,
    required this.jobTitle,
    required this.entityName,
    required this.orgUnitName,
    required this.family,
    required this.levelName,
    required this.status,
    required this.compensationBand,
    required this.ownerName,
    required this.nextReviewDate,
    required this.jobDescription,
    required this.skillsSummary,
    required this.linkedPolicy,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyJobProfileIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (jobCode.trim().isEmpty) CompanyJobProfileIssue.missingCode,
      if (jobTitle.trim().isEmpty) CompanyJobProfileIssue.missingTitle,
      if (entityName.trim().isEmpty) CompanyJobProfileIssue.missingEntity,
      if (orgUnitName.trim().isEmpty) CompanyJobProfileIssue.missingOrgUnit,
      if (levelName.trim().isEmpty) CompanyJobProfileIssue.missingLevel,
      if (compensationBand.trim().isEmpty)
        CompanyJobProfileIssue.missingCompensationBand,
      if (ownerName.trim().isEmpty) CompanyJobProfileIssue.missingOwner,
      if (jobDescription.trim().isEmpty)
        CompanyJobProfileIssue.missingDescription,
      if (skillsSummary.trim().isEmpty) CompanyJobProfileIssue.missingSkills,
      if (days < 0) CompanyJobProfileIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyJobProfileIssue.reviewDueSoon,
      if (status == CompanyJobProfileStatus.draft) CompanyJobProfileIssue.draft,
      if (status == CompanyJobProfileStatus.pendingApproval)
        CompanyJobProfileIssue.pendingApproval,
      if (status == CompanyJobProfileStatus.needsReview)
        CompanyJobProfileIssue.needsReview,
      if (status == CompanyJobProfileStatus.retired)
        CompanyJobProfileIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyJobProfile copyWith({
    String? id,
    String? jobCode,
    String? jobTitle,
    String? entityName,
    String? orgUnitName,
    CompanyJobFamily? family,
    String? levelName,
    CompanyJobProfileStatus? status,
    String? compensationBand,
    String? ownerName,
    DateTime? nextReviewDate,
    String? jobDescription,
    String? skillsSummary,
    String? linkedPolicy,
  }) {
    return CompanyJobProfile(
      id: id ?? this.id,
      jobCode: jobCode ?? this.jobCode,
      jobTitle: jobTitle ?? this.jobTitle,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      family: family ?? this.family,
      levelName: levelName ?? this.levelName,
      status: status ?? this.status,
      compensationBand: compensationBand ?? this.compensationBand,
      ownerName: ownerName ?? this.ownerName,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      jobDescription: jobDescription ?? this.jobDescription,
      skillsSummary: skillsSummary ?? this.skillsSummary,
      linkedPolicy: linkedPolicy ?? this.linkedPolicy,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyJobProfileDraft {
  final String jobCode;
  final String jobTitle;
  final String entityName;
  final String orgUnitName;
  final CompanyJobFamily family;
  final String levelName;
  final CompanyJobProfileStatus status;
  final String compensationBand;
  final String ownerName;
  final String nextReviewDateText;
  final String jobDescription;
  final String skillsSummary;
  final String linkedPolicy;

  const CompanyJobProfileDraft({
    required this.jobCode,
    required this.jobTitle,
    required this.entityName,
    required this.orgUnitName,
    required this.family,
    required this.levelName,
    required this.status,
    required this.compensationBand,
    required this.ownerName,
    required this.nextReviewDateText,
    required this.jobDescription,
    required this.skillsSummary,
    required this.linkedPolicy,
  });

  factory CompanyJobProfileDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String orgUnitName = 'People Operations',
    String compensationBand = '',
  }) {
    return CompanyJobProfileDraft(
      jobCode: '',
      jobTitle: '',
      entityName: entityName,
      orgUnitName: orgUnitName,
      family: CompanyJobFamily.general,
      levelName: '',
      status: CompanyJobProfileStatus.active,
      compensationBand: compensationBand,
      ownerName: '',
      nextReviewDateText: '',
      jobDescription: '',
      skillsSummary: '',
      linkedPolicy: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    return jobCode.trim().isNotEmpty &&
        jobTitle.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        orgUnitName.trim().isNotEmpty &&
        levelName.trim().isNotEmpty &&
        compensationBand.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        nextReviewDate != null &&
        jobDescription.trim().isNotEmpty &&
        skillsSummary.trim().isNotEmpty;
  }

  CompanyJobProfile toJobProfile(String id) {
    if (!isReady) {
      throw StateError('Complete job profile fields before saving.');
    }
    return CompanyJobProfile(
      id: id,
      jobCode: jobCode.trim().toUpperCase(),
      jobTitle: jobTitle.trim(),
      entityName: entityName.trim(),
      orgUnitName: orgUnitName.trim(),
      family: family,
      levelName: levelName.trim(),
      status: status,
      compensationBand: compensationBand.trim().toUpperCase(),
      ownerName: ownerName.trim(),
      nextReviewDate: nextReviewDate!,
      jobDescription: jobDescription.trim(),
      skillsSummary: skillsSummary.trim(),
      linkedPolicy: linkedPolicy.trim(),
    );
  }

  CompanyJobProfileDraft copyWith({
    String? jobCode,
    String? jobTitle,
    String? entityName,
    String? orgUnitName,
    CompanyJobFamily? family,
    String? levelName,
    CompanyJobProfileStatus? status,
    String? compensationBand,
    String? ownerName,
    String? nextReviewDateText,
    String? jobDescription,
    String? skillsSummary,
    String? linkedPolicy,
  }) {
    return CompanyJobProfileDraft(
      jobCode: jobCode ?? this.jobCode,
      jobTitle: jobTitle ?? this.jobTitle,
      entityName: entityName ?? this.entityName,
      orgUnitName: orgUnitName ?? this.orgUnitName,
      family: family ?? this.family,
      levelName: levelName ?? this.levelName,
      status: status ?? this.status,
      compensationBand: compensationBand ?? this.compensationBand,
      ownerName: ownerName ?? this.ownerName,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      jobDescription: jobDescription ?? this.jobDescription,
      skillsSummary: skillsSummary ?? this.skillsSummary,
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
