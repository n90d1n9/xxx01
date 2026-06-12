enum CompanyDocumentRequirementStage {
  preboarding,
  onboarding,
  probation,
  activeEmployment,
  offboarding,
  postEmployment,
}

enum CompanyDocumentRequirementStatus {
  active,
  draft,
  pendingLegalReview,
  needsReview,
  retired,
}

enum CompanyDocumentRequirementIssue {
  missingName,
  missingEntity,
  missingStage,
  missingJobProfile,
  missingContractTemplate,
  missingOnboardingPack,
  missingProbationPlan,
  missingOffboardingPack,
  missingOwner,
  missingEvidenceOwner,
  missingPolicyReference,
  missingCollectionChannel,
  missingStorageLocation,
  missingRetentionRule,
  noRequiredDocuments,
  missingReview,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingLegalReview,
  needsReview,
  retired,
}

extension CompanyDocumentRequirementStageLabels
    on CompanyDocumentRequirementStage {
  String get label {
    switch (this) {
      case CompanyDocumentRequirementStage.preboarding:
        return 'Preboarding';
      case CompanyDocumentRequirementStage.onboarding:
        return 'Onboarding';
      case CompanyDocumentRequirementStage.probation:
        return 'Probation';
      case CompanyDocumentRequirementStage.activeEmployment:
        return 'Active employment';
      case CompanyDocumentRequirementStage.offboarding:
        return 'Offboarding';
      case CompanyDocumentRequirementStage.postEmployment:
        return 'Post-employment';
    }
  }
}

extension CompanyDocumentRequirementStatusLabels
    on CompanyDocumentRequirementStatus {
  String get label {
    switch (this) {
      case CompanyDocumentRequirementStatus.active:
        return 'Active';
      case CompanyDocumentRequirementStatus.draft:
        return 'Draft';
      case CompanyDocumentRequirementStatus.pendingLegalReview:
        return 'Pending legal review';
      case CompanyDocumentRequirementStatus.needsReview:
        return 'Needs review';
      case CompanyDocumentRequirementStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyDocumentRequirementIssueLabels
    on CompanyDocumentRequirementIssue {
  String get label {
    switch (this) {
      case CompanyDocumentRequirementIssue.missingName:
        return 'Add requirement name';
      case CompanyDocumentRequirementIssue.missingEntity:
        return 'Assign entity';
      case CompanyDocumentRequirementIssue.missingStage:
        return 'Select stage';
      case CompanyDocumentRequirementIssue.missingJobProfile:
        return 'Link job profile';
      case CompanyDocumentRequirementIssue.missingContractTemplate:
        return 'Link contract template';
      case CompanyDocumentRequirementIssue.missingOnboardingPack:
        return 'Link onboarding pack';
      case CompanyDocumentRequirementIssue.missingProbationPlan:
        return 'Link probation plan';
      case CompanyDocumentRequirementIssue.missingOffboardingPack:
        return 'Link offboarding pack';
      case CompanyDocumentRequirementIssue.missingOwner:
        return 'Assign owner';
      case CompanyDocumentRequirementIssue.missingEvidenceOwner:
        return 'Assign evidence owner';
      case CompanyDocumentRequirementIssue.missingPolicyReference:
        return 'Link policy';
      case CompanyDocumentRequirementIssue.missingCollectionChannel:
        return 'Add collection channel';
      case CompanyDocumentRequirementIssue.missingStorageLocation:
        return 'Add storage location';
      case CompanyDocumentRequirementIssue.missingRetentionRule:
        return 'Add retention rule';
      case CompanyDocumentRequirementIssue.noRequiredDocuments:
        return 'Add required documents';
      case CompanyDocumentRequirementIssue.missingReview:
        return 'Add review date';
      case CompanyDocumentRequirementIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyDocumentRequirementIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyDocumentRequirementIssue.draft:
        return 'Finalize draft';
      case CompanyDocumentRequirementIssue.pendingLegalReview:
        return 'Complete legal review';
      case CompanyDocumentRequirementIssue.needsReview:
        return 'Review requirement';
      case CompanyDocumentRequirementIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyDocumentRequirement {
  final String id;
  final String requirementName;
  final String entityName;
  final CompanyDocumentRequirementStage stage;
  final CompanyDocumentRequirementStatus status;
  final String jobProfileCode;
  final String contractTemplateName;
  final String onboardingPackName;
  final String probationPlanName;
  final String offboardingPackName;
  final String ownerName;
  final String evidenceOwnerName;
  final String policyReference;
  final String collectionChannel;
  final String storageLocation;
  final String retentionRule;
  final int requiredDocumentCount;
  final DateTime nextReviewDate;
  final String notes;

  const CompanyDocumentRequirement({
    required this.id,
    required this.requirementName,
    required this.entityName,
    required this.stage,
    required this.status,
    required this.jobProfileCode,
    required this.contractTemplateName,
    required this.onboardingPackName,
    required this.probationPlanName,
    required this.offboardingPackName,
    required this.ownerName,
    required this.evidenceOwnerName,
    required this.policyReference,
    required this.collectionChannel,
    required this.storageLocation,
    required this.retentionRule,
    required this.requiredDocumentCount,
    required this.nextReviewDate,
    required this.notes,
  });

  bool get requiresContractTemplate =>
      stage == CompanyDocumentRequirementStage.preboarding ||
      stage == CompanyDocumentRequirementStage.onboarding;

  bool get requiresOnboardingPack =>
      stage == CompanyDocumentRequirementStage.preboarding ||
      stage == CompanyDocumentRequirementStage.onboarding;

  bool get requiresProbationPlan =>
      stage == CompanyDocumentRequirementStage.probation;

  bool get requiresOffboardingPack =>
      stage == CompanyDocumentRequirementStage.offboarding ||
      stage == CompanyDocumentRequirementStage.postEmployment;

  String get lifecycleLinkLabel {
    if (requiresContractTemplate && contractTemplateName.trim().isNotEmpty) {
      return contractTemplateName;
    }
    if (requiresOnboardingPack && onboardingPackName.trim().isNotEmpty) {
      return onboardingPackName;
    }
    if (requiresProbationPlan && probationPlanName.trim().isNotEmpty) {
      return probationPlanName;
    }
    if (requiresOffboardingPack && offboardingPackName.trim().isNotEmpty) {
      return offboardingPackName;
    }
    return 'Core HRIS record';
  }

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyDocumentRequirementIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    return [
      if (requirementName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingName,
      if (entityName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingEntity,
      if (jobProfileCode.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingJobProfile,
      if (requiresContractTemplate && contractTemplateName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingContractTemplate,
      if (requiresOnboardingPack && onboardingPackName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingOnboardingPack,
      if (requiresProbationPlan && probationPlanName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingProbationPlan,
      if (requiresOffboardingPack && offboardingPackName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingOffboardingPack,
      if (ownerName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingOwner,
      if (evidenceOwnerName.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingEvidenceOwner,
      if (policyReference.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingPolicyReference,
      if (collectionChannel.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingCollectionChannel,
      if (storageLocation.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingStorageLocation,
      if (retentionRule.trim().isEmpty)
        CompanyDocumentRequirementIssue.missingRetentionRule,
      if (requiredDocumentCount <= 0)
        CompanyDocumentRequirementIssue.noRequiredDocuments,
      if (days < 0) CompanyDocumentRequirementIssue.reviewOverdue,
      if (days >= 0 && days <= 45)
        CompanyDocumentRequirementIssue.reviewDueSoon,
      if (status == CompanyDocumentRequirementStatus.draft)
        CompanyDocumentRequirementIssue.draft,
      if (status == CompanyDocumentRequirementStatus.pendingLegalReview)
        CompanyDocumentRequirementIssue.pendingLegalReview,
      if (status == CompanyDocumentRequirementStatus.needsReview)
        CompanyDocumentRequirementIssue.needsReview,
      if (status == CompanyDocumentRequirementStatus.retired)
        CompanyDocumentRequirementIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyDocumentRequirement copyWith({
    String? id,
    String? requirementName,
    String? entityName,
    CompanyDocumentRequirementStage? stage,
    CompanyDocumentRequirementStatus? status,
    String? jobProfileCode,
    String? contractTemplateName,
    String? onboardingPackName,
    String? probationPlanName,
    String? offboardingPackName,
    String? ownerName,
    String? evidenceOwnerName,
    String? policyReference,
    String? collectionChannel,
    String? storageLocation,
    String? retentionRule,
    int? requiredDocumentCount,
    DateTime? nextReviewDate,
    String? notes,
  }) {
    return CompanyDocumentRequirement(
      id: id ?? this.id,
      requirementName: requirementName ?? this.requirementName,
      entityName: entityName ?? this.entityName,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      contractTemplateName: contractTemplateName ?? this.contractTemplateName,
      onboardingPackName: onboardingPackName ?? this.onboardingPackName,
      probationPlanName: probationPlanName ?? this.probationPlanName,
      offboardingPackName: offboardingPackName ?? this.offboardingPackName,
      ownerName: ownerName ?? this.ownerName,
      evidenceOwnerName: evidenceOwnerName ?? this.evidenceOwnerName,
      policyReference: policyReference ?? this.policyReference,
      collectionChannel: collectionChannel ?? this.collectionChannel,
      storageLocation: storageLocation ?? this.storageLocation,
      retentionRule: retentionRule ?? this.retentionRule,
      requiredDocumentCount:
          requiredDocumentCount ?? this.requiredDocumentCount,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      notes: notes ?? this.notes,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyDocumentRequirementDraft {
  final String requirementName;
  final String entityName;
  final CompanyDocumentRequirementStage stage;
  final CompanyDocumentRequirementStatus status;
  final String jobProfileCode;
  final String contractTemplateName;
  final String onboardingPackName;
  final String probationPlanName;
  final String offboardingPackName;
  final String ownerName;
  final String evidenceOwnerName;
  final String policyReference;
  final String collectionChannel;
  final String storageLocation;
  final String retentionRule;
  final String requiredDocumentCountText;
  final String nextReviewDateText;
  final String notes;

  const CompanyDocumentRequirementDraft({
    required this.requirementName,
    required this.entityName,
    required this.stage,
    required this.status,
    required this.jobProfileCode,
    required this.contractTemplateName,
    required this.onboardingPackName,
    required this.probationPlanName,
    required this.offboardingPackName,
    required this.ownerName,
    required this.evidenceOwnerName,
    required this.policyReference,
    required this.collectionChannel,
    required this.storageLocation,
    required this.retentionRule,
    required this.requiredDocumentCountText,
    required this.nextReviewDateText,
    required this.notes,
  });

  factory CompanyDocumentRequirementDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String contractTemplateName = '',
    String onboardingPackName = '',
    String probationPlanName = '',
    String offboardingPackName = '',
  }) {
    return CompanyDocumentRequirementDraft(
      requirementName: '',
      entityName: entityName,
      stage: CompanyDocumentRequirementStage.preboarding,
      status: CompanyDocumentRequirementStatus.active,
      jobProfileCode: jobProfileCode,
      contractTemplateName: contractTemplateName,
      onboardingPackName: onboardingPackName,
      probationPlanName: probationPlanName,
      offboardingPackName: offboardingPackName,
      ownerName: '',
      evidenceOwnerName: '',
      policyReference: '',
      collectionChannel: '',
      storageLocation: '',
      retentionRule: '',
      requiredDocumentCountText: '',
      nextReviewDateText: '',
      notes: '',
    );
  }

  bool get requiresContractTemplate =>
      stage == CompanyDocumentRequirementStage.preboarding ||
      stage == CompanyDocumentRequirementStage.onboarding;

  bool get requiresOnboardingPack =>
      stage == CompanyDocumentRequirementStage.preboarding ||
      stage == CompanyDocumentRequirementStage.onboarding;

  bool get requiresProbationPlan =>
      stage == CompanyDocumentRequirementStage.probation;

  bool get requiresOffboardingPack =>
      stage == CompanyDocumentRequirementStage.offboarding ||
      stage == CompanyDocumentRequirementStage.postEmployment;

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

  int? get requiredDocumentCount =>
      int.tryParse(requiredDocumentCountText.trim());
  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    final documentCount = requiredDocumentCount;
    return requirementName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        jobProfileCode.trim().isNotEmpty &&
        (!requiresContractTemplate || contractTemplateName.trim().isNotEmpty) &&
        (!requiresOnboardingPack || onboardingPackName.trim().isNotEmpty) &&
        (!requiresProbationPlan || probationPlanName.trim().isNotEmpty) &&
        (!requiresOffboardingPack || offboardingPackName.trim().isNotEmpty) &&
        ownerName.trim().isNotEmpty &&
        evidenceOwnerName.trim().isNotEmpty &&
        policyReference.trim().isNotEmpty &&
        collectionChannel.trim().isNotEmpty &&
        storageLocation.trim().isNotEmpty &&
        retentionRule.trim().isNotEmpty &&
        documentCount != null &&
        documentCount > 0 &&
        nextReviewDate != null;
  }

  CompanyDocumentRequirement toDocumentRequirement(String id) {
    if (!isReady) {
      throw StateError('Complete document requirement fields before saving.');
    }
    return CompanyDocumentRequirement(
      id: id,
      requirementName: requirementName.trim(),
      entityName: entityName.trim(),
      stage: stage,
      status: status,
      jobProfileCode: jobProfileCode.trim().toUpperCase(),
      contractTemplateName: contractTemplateName.trim(),
      onboardingPackName: onboardingPackName.trim(),
      probationPlanName: probationPlanName.trim(),
      offboardingPackName: offboardingPackName.trim(),
      ownerName: ownerName.trim(),
      evidenceOwnerName: evidenceOwnerName.trim(),
      policyReference: policyReference.trim(),
      collectionChannel: collectionChannel.trim(),
      storageLocation: storageLocation.trim(),
      retentionRule: retentionRule.trim(),
      requiredDocumentCount: requiredDocumentCount!,
      nextReviewDate: nextReviewDate!,
      notes: notes.trim(),
    );
  }

  CompanyDocumentRequirementDraft copyWith({
    String? requirementName,
    String? entityName,
    CompanyDocumentRequirementStage? stage,
    CompanyDocumentRequirementStatus? status,
    String? jobProfileCode,
    String? contractTemplateName,
    String? onboardingPackName,
    String? probationPlanName,
    String? offboardingPackName,
    String? ownerName,
    String? evidenceOwnerName,
    String? policyReference,
    String? collectionChannel,
    String? storageLocation,
    String? retentionRule,
    String? requiredDocumentCountText,
    String? nextReviewDateText,
    String? notes,
  }) {
    return CompanyDocumentRequirementDraft(
      requirementName: requirementName ?? this.requirementName,
      entityName: entityName ?? this.entityName,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      contractTemplateName: contractTemplateName ?? this.contractTemplateName,
      onboardingPackName: onboardingPackName ?? this.onboardingPackName,
      probationPlanName: probationPlanName ?? this.probationPlanName,
      offboardingPackName: offboardingPackName ?? this.offboardingPackName,
      ownerName: ownerName ?? this.ownerName,
      evidenceOwnerName: evidenceOwnerName ?? this.evidenceOwnerName,
      policyReference: policyReference ?? this.policyReference,
      collectionChannel: collectionChannel ?? this.collectionChannel,
      storageLocation: storageLocation ?? this.storageLocation,
      retentionRule: retentionRule ?? this.retentionRule,
      requiredDocumentCountText:
          requiredDocumentCountText ?? this.requiredDocumentCountText,
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
