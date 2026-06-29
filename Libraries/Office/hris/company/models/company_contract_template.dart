enum CompanyContractTemplateType {
  permanentEmployment,
  fixedTermEmployment,
  internship,
  contractor,
  offerLetter,
  addendum,
}

enum CompanyContractTemplateStatus {
  active,
  draft,
  pendingLegalReview,
  needsReview,
  retired,
}

enum CompanyContractTemplateIssue {
  missingName,
  missingEntity,
  missingJobProfile,
  missingCompensationBand,
  missingOwner,
  missingLegalReviewer,
  missingSignatory,
  missingLanguage,
  missingVersion,
  missingClauseSummary,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingLegalReview,
  needsReview,
  retired,
}

extension CompanyContractTemplateTypeLabels on CompanyContractTemplateType {
  String get label {
    switch (this) {
      case CompanyContractTemplateType.permanentEmployment:
        return 'Permanent employment';
      case CompanyContractTemplateType.fixedTermEmployment:
        return 'Fixed-term employment';
      case CompanyContractTemplateType.internship:
        return 'Internship';
      case CompanyContractTemplateType.contractor:
        return 'Contractor';
      case CompanyContractTemplateType.offerLetter:
        return 'Offer letter';
      case CompanyContractTemplateType.addendum:
        return 'Addendum';
    }
  }
}

extension CompanyContractTemplateStatusLabels on CompanyContractTemplateStatus {
  String get label {
    switch (this) {
      case CompanyContractTemplateStatus.active:
        return 'Active';
      case CompanyContractTemplateStatus.draft:
        return 'Draft';
      case CompanyContractTemplateStatus.pendingLegalReview:
        return 'Pending legal review';
      case CompanyContractTemplateStatus.needsReview:
        return 'Needs review';
      case CompanyContractTemplateStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyContractTemplateIssueLabels on CompanyContractTemplateIssue {
  String get label {
    switch (this) {
      case CompanyContractTemplateIssue.missingName:
        return 'Add template name';
      case CompanyContractTemplateIssue.missingEntity:
        return 'Assign entity';
      case CompanyContractTemplateIssue.missingJobProfile:
        return 'Link job profile';
      case CompanyContractTemplateIssue.missingCompensationBand:
        return 'Link band';
      case CompanyContractTemplateIssue.missingOwner:
        return 'Assign owner';
      case CompanyContractTemplateIssue.missingLegalReviewer:
        return 'Assign legal reviewer';
      case CompanyContractTemplateIssue.missingSignatory:
        return 'Assign signatory';
      case CompanyContractTemplateIssue.missingLanguage:
        return 'Add language';
      case CompanyContractTemplateIssue.missingVersion:
        return 'Add version';
      case CompanyContractTemplateIssue.missingClauseSummary:
        return 'Add clauses';
      case CompanyContractTemplateIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyContractTemplateIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyContractTemplateIssue.draft:
        return 'Finalize draft';
      case CompanyContractTemplateIssue.pendingLegalReview:
        return 'Complete legal review';
      case CompanyContractTemplateIssue.needsReview:
        return 'Review template';
      case CompanyContractTemplateIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyContractTemplate {
  final String id;
  final String templateName;
  final String entityName;
  final CompanyContractTemplateType type;
  final CompanyContractTemplateStatus status;
  final String jobProfileCode;
  final String compensationBand;
  final String ownerName;
  final String legalReviewerName;
  final String signatoryRole;
  final String language;
  final String versionLabel;
  final DateTime nextReviewDate;
  final String clauseSummary;
  final String onboardingChecklist;

  const CompanyContractTemplate({
    required this.id,
    required this.templateName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.compensationBand,
    required this.ownerName,
    required this.legalReviewerName,
    required this.signatoryRole,
    required this.language,
    required this.versionLabel,
    required this.nextReviewDate,
    required this.clauseSummary,
    required this.onboardingChecklist,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyContractTemplateIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (templateName.trim().isEmpty) CompanyContractTemplateIssue.missingName,
      if (entityName.trim().isEmpty) CompanyContractTemplateIssue.missingEntity,
      if (jobProfileCode.trim().isEmpty)
        CompanyContractTemplateIssue.missingJobProfile,
      if (compensationBand.trim().isEmpty)
        CompanyContractTemplateIssue.missingCompensationBand,
      if (ownerName.trim().isEmpty) CompanyContractTemplateIssue.missingOwner,
      if (legalReviewerName.trim().isEmpty)
        CompanyContractTemplateIssue.missingLegalReviewer,
      if (signatoryRole.trim().isEmpty)
        CompanyContractTemplateIssue.missingSignatory,
      if (language.trim().isEmpty) CompanyContractTemplateIssue.missingLanguage,
      if (versionLabel.trim().isEmpty)
        CompanyContractTemplateIssue.missingVersion,
      if (clauseSummary.trim().isEmpty)
        CompanyContractTemplateIssue.missingClauseSummary,
      if (days < 0) CompanyContractTemplateIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyContractTemplateIssue.reviewDueSoon,
      if (status == CompanyContractTemplateStatus.draft)
        CompanyContractTemplateIssue.draft,
      if (status == CompanyContractTemplateStatus.pendingLegalReview)
        CompanyContractTemplateIssue.pendingLegalReview,
      if (status == CompanyContractTemplateStatus.needsReview)
        CompanyContractTemplateIssue.needsReview,
      if (status == CompanyContractTemplateStatus.retired)
        CompanyContractTemplateIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyContractTemplate copyWith({
    String? id,
    String? templateName,
    String? entityName,
    CompanyContractTemplateType? type,
    CompanyContractTemplateStatus? status,
    String? jobProfileCode,
    String? compensationBand,
    String? ownerName,
    String? legalReviewerName,
    String? signatoryRole,
    String? language,
    String? versionLabel,
    DateTime? nextReviewDate,
    String? clauseSummary,
    String? onboardingChecklist,
  }) {
    return CompanyContractTemplate(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      compensationBand: compensationBand ?? this.compensationBand,
      ownerName: ownerName ?? this.ownerName,
      legalReviewerName: legalReviewerName ?? this.legalReviewerName,
      signatoryRole: signatoryRole ?? this.signatoryRole,
      language: language ?? this.language,
      versionLabel: versionLabel ?? this.versionLabel,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      clauseSummary: clauseSummary ?? this.clauseSummary,
      onboardingChecklist: onboardingChecklist ?? this.onboardingChecklist,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyContractTemplateDraft {
  final String templateName;
  final String entityName;
  final CompanyContractTemplateType type;
  final CompanyContractTemplateStatus status;
  final String jobProfileCode;
  final String compensationBand;
  final String ownerName;
  final String legalReviewerName;
  final String signatoryRole;
  final String language;
  final String versionLabel;
  final String nextReviewDateText;
  final String clauseSummary;
  final String onboardingChecklist;

  const CompanyContractTemplateDraft({
    required this.templateName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.compensationBand,
    required this.ownerName,
    required this.legalReviewerName,
    required this.signatoryRole,
    required this.language,
    required this.versionLabel,
    required this.nextReviewDateText,
    required this.clauseSummary,
    required this.onboardingChecklist,
  });

  factory CompanyContractTemplateDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String compensationBand = '',
  }) {
    return CompanyContractTemplateDraft(
      templateName: '',
      entityName: entityName,
      type: CompanyContractTemplateType.permanentEmployment,
      status: CompanyContractTemplateStatus.active,
      jobProfileCode: jobProfileCode,
      compensationBand: compensationBand,
      ownerName: '',
      legalReviewerName: '',
      signatoryRole: '',
      language: 'Bahasa Indonesia',
      versionLabel: '',
      nextReviewDateText: '',
      clauseSummary: '',
      onboardingChecklist: '',
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
    return templateName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        jobProfileCode.trim().isNotEmpty &&
        compensationBand.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        legalReviewerName.trim().isNotEmpty &&
        signatoryRole.trim().isNotEmpty &&
        language.trim().isNotEmpty &&
        versionLabel.trim().isNotEmpty &&
        nextReviewDate != null &&
        clauseSummary.trim().isNotEmpty;
  }

  CompanyContractTemplate toContractTemplate(String id) {
    if (!isReady) {
      throw StateError('Complete contract template fields before saving.');
    }
    return CompanyContractTemplate(
      id: id,
      templateName: templateName.trim(),
      entityName: entityName.trim(),
      type: type,
      status: status,
      jobProfileCode: jobProfileCode.trim().toUpperCase(),
      compensationBand: compensationBand.trim().toUpperCase(),
      ownerName: ownerName.trim(),
      legalReviewerName: legalReviewerName.trim(),
      signatoryRole: signatoryRole.trim(),
      language: language.trim(),
      versionLabel: versionLabel.trim(),
      nextReviewDate: nextReviewDate!,
      clauseSummary: clauseSummary.trim(),
      onboardingChecklist: onboardingChecklist.trim(),
    );
  }

  CompanyContractTemplateDraft copyWith({
    String? templateName,
    String? entityName,
    CompanyContractTemplateType? type,
    CompanyContractTemplateStatus? status,
    String? jobProfileCode,
    String? compensationBand,
    String? ownerName,
    String? legalReviewerName,
    String? signatoryRole,
    String? language,
    String? versionLabel,
    String? nextReviewDateText,
    String? clauseSummary,
    String? onboardingChecklist,
  }) {
    return CompanyContractTemplateDraft(
      templateName: templateName ?? this.templateName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      compensationBand: compensationBand ?? this.compensationBand,
      ownerName: ownerName ?? this.ownerName,
      legalReviewerName: legalReviewerName ?? this.legalReviewerName,
      signatoryRole: signatoryRole ?? this.signatoryRole,
      language: language ?? this.language,
      versionLabel: versionLabel ?? this.versionLabel,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      clauseSummary: clauseSummary ?? this.clauseSummary,
      onboardingChecklist: onboardingChecklist ?? this.onboardingChecklist,
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
