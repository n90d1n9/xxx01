enum CompanyProbationPlanType {
  probation,
  internship,
  roleTransfer,
  contractorCheckpoint,
  executive,
}

enum CompanyProbationPlanStatus {
  active,
  draft,
  pendingOwnerReview,
  needsReview,
  retired,
}

enum CompanyProbationPlanIssue {
  missingName,
  missingEntity,
  missingJobProfile,
  missingOnboardingPack,
  missingOwner,
  missingManagerRole,
  invalidCadence,
  invalidCheckpointCount,
  invalidFirstReviewDue,
  invalidFinalDecisionDue,
  missingSuccessCriteria,
  missingFeedbackTemplate,
  reviewOverdue,
  reviewDueSoon,
  draft,
  pendingOwnerReview,
  needsReview,
  retired,
}

extension CompanyProbationPlanTypeLabels on CompanyProbationPlanType {
  String get label {
    switch (this) {
      case CompanyProbationPlanType.probation:
        return 'Probation';
      case CompanyProbationPlanType.internship:
        return 'Internship';
      case CompanyProbationPlanType.roleTransfer:
        return 'Role transfer';
      case CompanyProbationPlanType.contractorCheckpoint:
        return 'Contractor checkpoint';
      case CompanyProbationPlanType.executive:
        return 'Executive';
    }
  }
}

extension CompanyProbationPlanStatusLabels on CompanyProbationPlanStatus {
  String get label {
    switch (this) {
      case CompanyProbationPlanStatus.active:
        return 'Active';
      case CompanyProbationPlanStatus.draft:
        return 'Draft';
      case CompanyProbationPlanStatus.pendingOwnerReview:
        return 'Pending owner review';
      case CompanyProbationPlanStatus.needsReview:
        return 'Needs review';
      case CompanyProbationPlanStatus.retired:
        return 'Retired';
    }
  }
}

extension CompanyProbationPlanIssueLabels on CompanyProbationPlanIssue {
  String get label {
    switch (this) {
      case CompanyProbationPlanIssue.missingName:
        return 'Add plan name';
      case CompanyProbationPlanIssue.missingEntity:
        return 'Assign entity';
      case CompanyProbationPlanIssue.missingJobProfile:
        return 'Link job profile';
      case CompanyProbationPlanIssue.missingOnboardingPack:
        return 'Link onboarding pack';
      case CompanyProbationPlanIssue.missingOwner:
        return 'Assign owner';
      case CompanyProbationPlanIssue.missingManagerRole:
        return 'Add manager role';
      case CompanyProbationPlanIssue.invalidCadence:
        return 'Fix cadence';
      case CompanyProbationPlanIssue.invalidCheckpointCount:
        return 'Add checkpoints';
      case CompanyProbationPlanIssue.invalidFirstReviewDue:
        return 'Fix first review';
      case CompanyProbationPlanIssue.invalidFinalDecisionDue:
        return 'Fix final decision';
      case CompanyProbationPlanIssue.missingSuccessCriteria:
        return 'Add success criteria';
      case CompanyProbationPlanIssue.missingFeedbackTemplate:
        return 'Add feedback template';
      case CompanyProbationPlanIssue.reviewOverdue:
        return 'Review overdue';
      case CompanyProbationPlanIssue.reviewDueSoon:
        return 'Review due soon';
      case CompanyProbationPlanIssue.draft:
        return 'Finalize draft';
      case CompanyProbationPlanIssue.pendingOwnerReview:
        return 'Complete owner review';
      case CompanyProbationPlanIssue.needsReview:
        return 'Review plan';
      case CompanyProbationPlanIssue.retired:
        return 'Retired';
    }
  }
}

class CompanyProbationPlan {
  final String id;
  final String planName;
  final String entityName;
  final CompanyProbationPlanType type;
  final CompanyProbationPlanStatus status;
  final String jobProfileCode;
  final String onboardingPackName;
  final String ownerName;
  final String managerRole;
  final int reviewCadenceDays;
  final int checkpointCount;
  final int firstReviewDueDays;
  final int finalDecisionDueDays;
  final DateTime nextReviewDate;
  final String successCriteria;
  final String feedbackTemplate;
  final String notes;

  const CompanyProbationPlan({
    required this.id,
    required this.planName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.onboardingPackName,
    required this.ownerName,
    required this.managerRole,
    required this.reviewCadenceDays,
    required this.checkpointCount,
    required this.firstReviewDueDays,
    required this.finalDecisionDueDays,
    required this.nextReviewDate,
    required this.successCriteria,
    required this.feedbackTemplate,
    required this.notes,
  });

  int daysUntilReview(DateTime asOfDate) {
    return _dateOnly(nextReviewDate).difference(_dateOnly(asOfDate)).inDays;
  }

  List<CompanyProbationPlanIssue> issues(DateTime asOfDate) {
    final days = daysUntilReview(asOfDate);
    final invalidFirstReview = firstReviewDueDays <= 0;
    final invalidFinalDecision =
        finalDecisionDueDays <= 0 ||
        (!invalidFirstReview && finalDecisionDueDays < firstReviewDueDays);

    return [
      if (planName.trim().isEmpty) CompanyProbationPlanIssue.missingName,
      if (entityName.trim().isEmpty) CompanyProbationPlanIssue.missingEntity,
      if (jobProfileCode.trim().isEmpty)
        CompanyProbationPlanIssue.missingJobProfile,
      if (onboardingPackName.trim().isEmpty)
        CompanyProbationPlanIssue.missingOnboardingPack,
      if (ownerName.trim().isEmpty) CompanyProbationPlanIssue.missingOwner,
      if (managerRole.trim().isEmpty)
        CompanyProbationPlanIssue.missingManagerRole,
      if (reviewCadenceDays <= 0 ||
          (!invalidFinalDecision && reviewCadenceDays > finalDecisionDueDays))
        CompanyProbationPlanIssue.invalidCadence,
      if (checkpointCount <= 0)
        CompanyProbationPlanIssue.invalidCheckpointCount,
      if (invalidFirstReview) CompanyProbationPlanIssue.invalidFirstReviewDue,
      if (invalidFinalDecision)
        CompanyProbationPlanIssue.invalidFinalDecisionDue,
      if (successCriteria.trim().isEmpty)
        CompanyProbationPlanIssue.missingSuccessCriteria,
      if (feedbackTemplate.trim().isEmpty)
        CompanyProbationPlanIssue.missingFeedbackTemplate,
      if (days < 0) CompanyProbationPlanIssue.reviewOverdue,
      if (days >= 0 && days <= 45) CompanyProbationPlanIssue.reviewDueSoon,
      if (status == CompanyProbationPlanStatus.draft)
        CompanyProbationPlanIssue.draft,
      if (status == CompanyProbationPlanStatus.pendingOwnerReview)
        CompanyProbationPlanIssue.pendingOwnerReview,
      if (status == CompanyProbationPlanStatus.needsReview)
        CompanyProbationPlanIssue.needsReview,
      if (status == CompanyProbationPlanStatus.retired)
        CompanyProbationPlanIssue.retired,
    ];
  }

  bool requiresAttention(DateTime asOfDate) => issues(asOfDate).isNotEmpty;

  CompanyProbationPlan copyWith({
    String? id,
    String? planName,
    String? entityName,
    CompanyProbationPlanType? type,
    CompanyProbationPlanStatus? status,
    String? jobProfileCode,
    String? onboardingPackName,
    String? ownerName,
    String? managerRole,
    int? reviewCadenceDays,
    int? checkpointCount,
    int? firstReviewDueDays,
    int? finalDecisionDueDays,
    DateTime? nextReviewDate,
    String? successCriteria,
    String? feedbackTemplate,
    String? notes,
  }) {
    return CompanyProbationPlan(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      onboardingPackName: onboardingPackName ?? this.onboardingPackName,
      ownerName: ownerName ?? this.ownerName,
      managerRole: managerRole ?? this.managerRole,
      reviewCadenceDays: reviewCadenceDays ?? this.reviewCadenceDays,
      checkpointCount: checkpointCount ?? this.checkpointCount,
      firstReviewDueDays: firstReviewDueDays ?? this.firstReviewDueDays,
      finalDecisionDueDays: finalDecisionDueDays ?? this.finalDecisionDueDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      successCriteria: successCriteria ?? this.successCriteria,
      feedbackTemplate: feedbackTemplate ?? this.feedbackTemplate,
      notes: notes ?? this.notes,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CompanyProbationPlanDraft {
  final String planName;
  final String entityName;
  final CompanyProbationPlanType type;
  final CompanyProbationPlanStatus status;
  final String jobProfileCode;
  final String onboardingPackName;
  final String ownerName;
  final String managerRole;
  final String reviewCadenceDaysText;
  final String checkpointCountText;
  final String firstReviewDueDaysText;
  final String finalDecisionDueDaysText;
  final String nextReviewDateText;
  final String successCriteria;
  final String feedbackTemplate;
  final String notes;

  const CompanyProbationPlanDraft({
    required this.planName,
    required this.entityName,
    required this.type,
    required this.status,
    required this.jobProfileCode,
    required this.onboardingPackName,
    required this.ownerName,
    required this.managerRole,
    required this.reviewCadenceDaysText,
    required this.checkpointCountText,
    required this.firstReviewDueDaysText,
    required this.finalDecisionDueDaysText,
    required this.nextReviewDateText,
    required this.successCriteria,
    required this.feedbackTemplate,
    required this.notes,
  });

  factory CompanyProbationPlanDraft.empty({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String onboardingPackName = '',
  }) {
    return CompanyProbationPlanDraft(
      planName: '',
      entityName: entityName,
      type: CompanyProbationPlanType.probation,
      status: CompanyProbationPlanStatus.active,
      jobProfileCode: jobProfileCode,
      onboardingPackName: onboardingPackName,
      ownerName: '',
      managerRole: '',
      reviewCadenceDaysText: '',
      checkpointCountText: '',
      firstReviewDueDaysText: '',
      finalDecisionDueDaysText: '',
      nextReviewDateText: '',
      successCriteria: '',
      feedbackTemplate: '',
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

  static String? validateDate(String? value) {
    final date = _parseDate(value?.trim() ?? '');
    return date == null ? 'Use YYYY-MM-DD' : null;
  }

  int? get reviewCadenceDays => int.tryParse(reviewCadenceDaysText.trim());
  int? get checkpointCount => int.tryParse(checkpointCountText.trim());
  int? get firstReviewDueDays => int.tryParse(firstReviewDueDaysText.trim());
  int? get finalDecisionDueDays =>
      int.tryParse(finalDecisionDueDaysText.trim());
  DateTime? get nextReviewDate => _parseDate(nextReviewDateText);

  bool get isReady {
    final cadence = reviewCadenceDays;
    final checkpoints = checkpointCount;
    final firstReview = firstReviewDueDays;
    final finalDecision = finalDecisionDueDays;
    return planName.trim().isNotEmpty &&
        entityName.trim().isNotEmpty &&
        jobProfileCode.trim().isNotEmpty &&
        onboardingPackName.trim().isNotEmpty &&
        ownerName.trim().isNotEmpty &&
        managerRole.trim().isNotEmpty &&
        cadence != null &&
        cadence > 0 &&
        checkpoints != null &&
        checkpoints > 0 &&
        firstReview != null &&
        firstReview > 0 &&
        finalDecision != null &&
        finalDecision >= firstReview &&
        cadence <= finalDecision &&
        nextReviewDate != null &&
        successCriteria.trim().isNotEmpty &&
        feedbackTemplate.trim().isNotEmpty;
  }

  CompanyProbationPlan toProbationPlan(String id) {
    if (!isReady) {
      throw StateError('Complete probation plan fields before saving.');
    }
    return CompanyProbationPlan(
      id: id,
      planName: planName.trim(),
      entityName: entityName.trim(),
      type: type,
      status: status,
      jobProfileCode: jobProfileCode.trim().toUpperCase(),
      onboardingPackName: onboardingPackName.trim(),
      ownerName: ownerName.trim(),
      managerRole: managerRole.trim(),
      reviewCadenceDays: reviewCadenceDays!,
      checkpointCount: checkpointCount!,
      firstReviewDueDays: firstReviewDueDays!,
      finalDecisionDueDays: finalDecisionDueDays!,
      nextReviewDate: nextReviewDate!,
      successCriteria: successCriteria.trim(),
      feedbackTemplate: feedbackTemplate.trim(),
      notes: notes.trim(),
    );
  }

  CompanyProbationPlanDraft copyWith({
    String? planName,
    String? entityName,
    CompanyProbationPlanType? type,
    CompanyProbationPlanStatus? status,
    String? jobProfileCode,
    String? onboardingPackName,
    String? ownerName,
    String? managerRole,
    String? reviewCadenceDaysText,
    String? checkpointCountText,
    String? firstReviewDueDaysText,
    String? finalDecisionDueDaysText,
    String? nextReviewDateText,
    String? successCriteria,
    String? feedbackTemplate,
    String? notes,
  }) {
    return CompanyProbationPlanDraft(
      planName: planName ?? this.planName,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      status: status ?? this.status,
      jobProfileCode: jobProfileCode ?? this.jobProfileCode,
      onboardingPackName: onboardingPackName ?? this.onboardingPackName,
      ownerName: ownerName ?? this.ownerName,
      managerRole: managerRole ?? this.managerRole,
      reviewCadenceDaysText:
          reviewCadenceDaysText ?? this.reviewCadenceDaysText,
      checkpointCountText: checkpointCountText ?? this.checkpointCountText,
      firstReviewDueDaysText:
          firstReviewDueDaysText ?? this.firstReviewDueDaysText,
      finalDecisionDueDaysText:
          finalDecisionDueDaysText ?? this.finalDecisionDueDaysText,
      nextReviewDateText: nextReviewDateText ?? this.nextReviewDateText,
      successCriteria: successCriteria ?? this.successCriteria,
      feedbackTemplate: feedbackTemplate ?? this.feedbackTemplate,
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
