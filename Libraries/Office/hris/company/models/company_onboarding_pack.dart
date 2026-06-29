enum CompanyOnboardingPackType {
  preboarding,
  onboarding,
  roleTransfer,
  contractor,
  internship,
}

enum CompanyOnboardingPackStatus {
  active,
  draft,
  pendingOwnerReview,
  needsReview,
  retired,
}

enum CompanyOnboardingPackIssue {
  missingName,
  missingEntity,
  missingJobProfile,
  missingContractTemplate,
  missingOwner,
  missingManagerHandoff,
  missingDocumentChecklist,
  missingAccessChecklist,
  missingEquipmentChecklist,
  noRequiredTasks,
  invalidAutomationCoverage,
  missingSla,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingOwnerReview,
  needsReview,
  retired,
}

extension CompanyOnboardingPackTypeLabels on CompanyOnboardingPackType {
  String get label {
    switch (this) {
      case CompanyOnboardingPackType.preboarding:
        return 'Preboarding';
      case CompanyOnboardingPackType.onboarding:
        return 'Onboarding';
      case CompanyOnboardingPackType.roleTransfer:
        return 'Role transfer';
      case CompanyOnboardingPackType.contractor:
        return 'Contractor';
      case CompanyOnboardingPackType.internship:
        return 'Internship';
    }
  }
}

extension CompanyOnboardingPackStatusLabels on CompanyOnboardingPackStatus {
  String get label {
    switch (this) {
      case CompanyOnboardingPackStatus.active:
        return 'Active';
      case CompanyOnboardingPackStatus.draft:
        return 'Draft';
      case CompanyOnboardingPackStatus.pendingOwnerReview:
        return 'Pending owner review';
      case CompanyOnboardingPackStatus.needsReview:
        return 'Needs review';
      case CompanyOnboardingPackStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyOnboardingPackIssueLabels on CompanyOnboardingPackIssue {
  String get label {
    switch (this) {
      case CompanyOnboardingPackIssue.missingName:
        return 'Add pack name';
      case CompanyOnboardingPackIssue.missingEntity:
        return 'Assign entity';
      case CompanyOnboardingPackIssue.missingJobProfile:
        return 'Link job profile';
      case CompanyOnboardingPackIssue.missingContractTemplate:
        return 'Link contract template';
      case CompanyOnboardingPackIssue.missingOwner:
        return 'Assign owner';
      case CompanyOnboardingPackIssue.missingManagerHandoff:
        return 'Add manager handoff';
      case CompanyOnboardingPackIssue.missingDocumentChecklist:
        return 'Add document checklist';
      case CompanyOnboardingPackIssue.missingAccessChecklist:
        return 'Add access checklist';
      case CompanyOnboardingPackIssue.missingEquipmentChecklist:
        return 'Add equipment checklist';
      case CompanyOnboardingPackIssue.noRequiredTasks:
        return 'Add tasks';
      case CompanyOnboardingPackIssue.invalidAutomationCoverage:
        return 'Fix automation';
      case CompanyOnboardingPackIssue.missingSla:
        return 'Add SLA';
      case CompanyOnboardingPackIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyOnboardingPackIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyOnboardingPackIssue.draft:
        return 'Finalize draft';
      case CompanyOnboardingPackIssue.pendingOwnerReview:
        return 'Complete owner review';
      case CompanyOnboardingPackIssue.needsReview:
        return 'Review pack';
      case CompanyOnboardingPackIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyOnboardingPack {
  final String id;
  final String packName;
  final String entityName;
  final CompanyOnboardingPackType type;
  final CompanyOnboardingPackStatus status;
  final String jobProfileCode;
  final String contractTemplateName;
  final String ownerName;
  final String managerHandoff;
  final String documentChecklist;
  final String accessChecklist;
  final String equipmentChecklist;
  final int requiredTaskCount;
  final int automationCoveragePercent;
  final int slaDays;
  final DateTime nextReviewDate;
  final String notes;

  const CompanyOnboardingPack({
    required this.id,
    required this.packName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.contractTemplateName,
    required this.ownerName,
    required this.managerHandoff,
    required this.documentChecklist,
    required this.accessChecklist,
    required this.equipmentChecklist,
    required this.requiredTaskCount,
    required this.automationCoveragePercent,
    required this.slaDays,
    required this.nextReviewDate,
    required this.notes,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyOnboardingPackIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (packName.trim().isEmpty) CompanyOnboardingPackIssue.missingName,
      if (entityName.trim().isEmpty) CompanyOnboardingPackIssue.missingEntity,
      if (jobProfileCode.trim().isEmpty)
        CompanyOnboardingPackIssue.missingJobProfile,
      if (contractTemplateName.trim().isEmpty)
        CompanyOnboardingPackIssue.missingContractTemplate,
      if (ownerName.trim().isEmpty) CompanyOnboardingPackIssue.missingOwner,
      if (managerHandoff.trim().isEmpty)
        CompanyOnboardingPackIssue.missingManagerHandoff,
      if (documentChecklist.trim().isEmpty)
        CompanyOnboardingPackIssue.missingDocumentChecklist,
      if (accessChecklist.trim().isEmpty)
        CompanyOnboardingPackIssue.missingAccessChecklist,
      if (equipmentChecklist.trim().isEmpty)
        CompanyOnboardingPackIssue.missingEquipmentChecklist,
      if (requiredTaskCount <= 0) CompanyOnboardingPackIssue.noRequiredTasks,
      if (automationCoveragePercent < 0 || automationCoveragePercent > 100)
        CompanyOnboardingPackIssue.invalidAutomationCoverage,
      if (slaDays <= 0) CompanyOnboardingPackIssue.missingSla,
      if (days < 0) CompanyOnboardingPackIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyOnboardingPackIssue.reviewDueSoon,
      if (status == CompanyOnboardingPackStatus.draft)
        CompanyOnboardingPackIssue.draft,
      if (status == CompanyOnboardingPackStatus.pendingOwnerReview)
        CompanyOnboardingPackIssue.pendingOwnerReview,
      if (status == CompanyOnboardingPackStatus.needsReview)
        CompanyOnboardingPackIssue.needsReview,
      if (status == CompanyOnboardingPackStatus.retired)
        CompanyOnboardingPackIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyOnboardingPack copyWith({
    String? id,
    String? packName,
    String? entityName,
    CompanyOnboardingPackType? type,
    CompanyOnboardingPackStatus? status,
    String? jobProfileCode,
    String? contractTemplateName,
    String? ownerName,
    String? managerHandoff,
    String? documentChecklist,
    String? accessChecklist,
    String? equipmentChecklist,
    int? requiredTaskCount,
    int? automationCoveragePercent,
    int? slaDays,
    DateTime? nextReviewDate,
    String? notes,
  }) {
    return CompanyOnboardingPack(
      id: id ?? this.id,
      packName: packName ?? this.packName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      contractTemplateName: contractTemplateName ?? this.contractTemplateName,
      ownerName: ownerName ?? this.ownerName,
      managerHandoff: managerHandoff ?? this.managerHandoff,
      documentChecklist: documentChecklist ?? this.documentChecklist,
      accessChecklist: accessChecklist ?? this.accessChecklist,
      equipmentChecklist: equipmentChecklist ?? this.equipmentChecklist,
      requiredTaskCount: requiredTaskCount ?? this.requiredTaskCount,
      automationCoveragePercent:
          automationCoveragePercent ?? this.automationCoveragePercent,
      slaDays: slaDays ?? this.slaDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      notes: notes ?? this.notes,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyOnboardingPackDraft {
  final String packName;
  final String entityName;
  final CompanyOnboardingPackType type;
  final CompanyOnboardingPackStatus status;
  final String jobProfileCode;
  final String contractTemplateName;
  final String ownerName;
  final String managerHandoff;
  final String documentChecklist;
  final String accessChecklist;
  final String equipmentChecklist;
  final String requiredTaskCountText;
  final String automationCoverageText;
  final String slaDaysText;
  final String nextReviewDateText;
  final String notes;

  const CompanyOnboardingPackDraft({
    required this.packName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.contractTemplateName,
    required this.ownerName,
    required this.managerHandoff,
    required this.documentChecklist,
    required this.accessChecklist,
    required this.equipmentChecklist,
    required this.requiredTaskCountText,
    required this.automationCoverageText,
    required this.slaDaysText,
    required this.nextReviewDateText,
    required this.notes,
  });

  factory CompanyOnboardingPackDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String contractTemplateName = '',
  }) {
    return CompanyOnboardingPackDraft(
      packName: '',
      entityName: entityName,
      type: CompanyOnboardingPackType.onboarding,
      status: CompanyOnboardingPackStatus.active,
      jobProfileCode: jobProfileCode,
      contractTemplateName: contractTemplateName,
      ownerName: '',
      managerHandoff: '',
      documentChecklist: '',
      accessChecklist: '',
      equipmentChecklist: '',
      requiredTaskCountText: '',
      automationCoverageText: '0',
      slaDaysText: '',
      nextReviewDateText: '',
      notes: '',
    );
  }

  static String? validateRequired(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  static String? validatePositiveInt(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'Enter $label' : null;
  }

  static String? validatePercent(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 0 || number > 100) {
      return 'Use 0-100';
    }
    return null;
  }

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  int? get requiredTaskCount => int.tryParse(requiredTaskCountText.trim());
  int? get automationCoverage => int.tryParse(automationCoverageText.trim());
  int? get slaDays => int.tryParse(slaDaysText.trim());
  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    final tasks = requiredTaskCount;
    final automation = automationCoverage;
    final sla = slaDays;
    return packName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        jobProfileCode.trim().isNotEmpty &&
        contractTemplateName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        managerHandoff.trim().isNotEmpty &&
        documentChecklist.trim().isNotEmpty &&
        accessChecklist.trim().isNotEmpty &&
        equipmentChecklist.trim().isNotEmpty &&
        tasks != null &&
        tasks > 0 &&
        automation != null &&
        automation >= 0 &&
        automation <= 100 &&
        sla != null &&
        sla > 0 &&
        nextReviewDate != null;
  }

  CompanyOnboardingPack toOnboardingPack(String id) {
    if (!isReady) {
      throw StateError('Complete onboarding pack fields before saving.');
    }
    return CompanyOnboardingPack(
      id: id,
      packName: packName.trim(),
      entityName: entityName.trim(),
      type: type,
      status: status,
      jobProfileCode: jobProfileCode.trim().toUpperCase(),
      contractTemplateName: contractTemplateName.trim(),
      ownerName: ownerName.trim(),
      managerHandoff: managerHandoff.trim(),
      documentChecklist: documentChecklist.trim(),
      accessChecklist: accessChecklist.trim(),
      equipmentChecklist: equipmentChecklist.trim(),
      requiredTaskCount: requiredTaskCount!,
      automationCoveragePercent: automationCoverage!,
      slaDays: slaDays!,
      nextReviewDate: nextReviewDate!,
      notes: notes.trim(),
    );
  }

  CompanyOnboardingPackDraft copyWith({
    String? packName,
    String? entityName,
    CompanyOnboardingPackType? type,
    CompanyOnboardingPackStatus? status,
    String? jobProfileCode,
    String? contractTemplateName,
    String? ownerName,
    String? managerHandoff,
    String? documentChecklist,
    String? accessChecklist,
    String? equipmentChecklist,
    String? requiredTaskCountText,
    String? automationCoverageText,
    String? slaDaysText,
    String? nextReviewDateText,
    String? notes,
  }) {
    return CompanyOnboardingPackDraft(
      packName: packName ?? this.packName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      contractTemplateName: contractTemplateName ?? this.contractTemplateName,
      ownerName: ownerName ?? this.ownerName,
      managerHandoff: managerHandoff ?? this.managerHandoff,
      documentChecklist: documentChecklist ?? this.documentChecklist,
      accessChecklist: accessChecklist ?? this.accessChecklist,
      equipmentChecklist: equipmentChecklist ?? this.equipmentChecklist,
      requiredTaskCountText:
          requiredTaskCountText ?? this.requiredTaskCountText,
      automationCoverageText:
          automationCoverageText ?? this.automationCoverageText,
      slaDaysText: slaDaysText ?? this.slaDaysText,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      notes: notes ?? this.notes,
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
