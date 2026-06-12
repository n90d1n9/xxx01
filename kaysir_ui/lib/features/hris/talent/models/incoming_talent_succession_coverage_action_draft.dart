import 'incoming_talent_succession_coverage_action.dart';
import 'incoming_talent_succession_coverage_action_policy.dart';
import 'incoming_talent_succession_coverage_dashboard.dart';
import 'incoming_talent_succession_coverage_review.dart';

class IncomingTalentSuccessionCoverageActionDraft {
  final String coverageReviewId;
  final String scopeLabel;
  final String departmentScope;
  final bool attentionOnly;
  final String reviewerName;
  final IncomingTalentSuccessionCoverageReviewDecision? reviewDecision;
  final IncomingTalentSuccessionCoverageHealth? coverageHealth;
  final int coverageScore;
  final String ownerName;
  final IncomingTalentSuccessionCoverageActionType? actionType;
  final IncomingTalentSuccessionCoverageActionStatus? status;
  final DateTime? dueDate;
  final String actionPlan;
  final String escalationPath;
  final String resolutionEvidence;
  final DateTime asOfDate;

  const IncomingTalentSuccessionCoverageActionDraft({
    required this.coverageReviewId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.attentionOnly,
    required this.reviewerName,
    required this.reviewDecision,
    required this.coverageHealth,
    required this.coverageScore,
    required this.ownerName,
    required this.actionType,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.escalationPath,
    required this.resolutionEvidence,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionCoverageActionDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionCoverageActionDraft(
      coverageReviewId: '',
      scopeLabel: '',
      departmentScope: '',
      attentionOnly: false,
      reviewerName: '',
      reviewDecision: null,
      coverageHealth: null,
      coverageScore: 0,
      ownerName: '',
      actionType: null,
      status: null,
      dueDate: null,
      actionPlan: '',
      escalationPath: '',
      resolutionEvidence: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionCoverageActionDraft.fromReview({
    required IncomingTalentSuccessionCoverageReview review,
    required DateTime asOfDate,
  }) {
    final actionType = defaultCoverageActionType(review);

    return IncomingTalentSuccessionCoverageActionDraft(
      coverageReviewId: review.id,
      scopeLabel: review.scopeLabel,
      departmentScope: review.departmentScope,
      attentionOnly: review.attentionOnly,
      reviewerName: review.reviewerName,
      reviewDecision: review.decision,
      coverageHealth: review.coverageHealth,
      coverageScore: review.coverageScore,
      ownerName: review.reviewerName,
      actionType: actionType,
      status: IncomingTalentSuccessionCoverageActionStatus.planned,
      dueDate: defaultCoverageActionDueDate(review: review, asOfDate: asOfDate),
      actionPlan: '${actionType.label}: ${review.executiveCommitment}',
      escalationPath: defaultCoverageActionEscalationPath(review),
      resolutionEvidence:
          'Confirm coverage score improves and executive commitment is closed.',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionCoverageActionDraft copyWith({
    String? coverageReviewId,
    String? scopeLabel,
    String? departmentScope,
    bool? attentionOnly,
    String? reviewerName,
    IncomingTalentSuccessionCoverageReviewDecision? reviewDecision,
    IncomingTalentSuccessionCoverageHealth? coverageHealth,
    int? coverageScore,
    String? ownerName,
    IncomingTalentSuccessionCoverageActionType? actionType,
    IncomingTalentSuccessionCoverageActionStatus? status,
    DateTime? dueDate,
    String? actionPlan,
    String? escalationPath,
    String? resolutionEvidence,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageActionDraft(
      coverageReviewId: coverageReviewId ?? this.coverageReviewId,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      departmentScope: departmentScope ?? this.departmentScope,
      attentionOnly: attentionOnly ?? this.attentionOnly,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDecision: reviewDecision ?? this.reviewDecision,
      coverageHealth: coverageHealth ?? this.coverageHealth,
      coverageScore: coverageScore ?? this.coverageScore,
      ownerName: ownerName ?? this.ownerName,
      actionType: actionType ?? this.actionType,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      actionPlan: actionPlan ?? this.actionPlan,
      escalationPath: escalationPath ?? this.escalationPath,
      resolutionEvidence: resolutionEvidence ?? this.resolutionEvidence,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          coverageReviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          reviewDecision != null,
          coverageHealth != null,
          actionType != null,
          status != null,
          dueDate != null,
          actionPlan.trim().length >= 12,
          escalationPath.trim().length >= 12,
          resolutionEvidence.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(coverageReviewId, 'a coverage review')
          case final error?)
        error,
      if (validateRequired(ownerName, 'an action owner') case final error?)
        error,
      if (validateReviewDecision(reviewDecision) case final error?) error,
      if (validateCoverageHealth(coverageHealth) case final error?) error,
      if (validateActionType(actionType) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
      if (validateActionPlan(actionPlan) case final error?) error,
      if (validateEscalationPath(escalationPath) case final error?) error,
      if (validateResolutionEvidence(resolutionEvidence) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionCoverageAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionCoverageAction(
      id: id,
      coverageReviewId: coverageReviewId,
      scopeLabel: scopeLabel.trim(),
      departmentScope: departmentScope.trim(),
      attentionOnly: attentionOnly,
      reviewerName: reviewerName.trim(),
      reviewDecision: reviewDecision!,
      coverageHealth: coverageHealth!,
      coverageScore: coverageScore,
      ownerName: ownerName.trim(),
      actionType: actionType!,
      status: status!,
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      escalationPath: escalationPath.trim(),
      resolutionEvidence: resolutionEvidence.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateReviewDecision(
    IncomingTalentSuccessionCoverageReviewDecision? value,
  ) {
    if (value == null) return 'Select coverage review decision';
    return null;
  }

  static String? validateCoverageHealth(
    IncomingTalentSuccessionCoverageHealth? value,
  ) {
    if (value == null) return 'Refresh coverage review snapshot';
    return null;
  }

  static String? validateActionType(
    IncomingTalentSuccessionCoverageActionType? value,
  ) {
    if (value == null) return 'Select action type';
    return null;
  }

  static String? validateStatus(
    IncomingTalentSuccessionCoverageActionStatus? value,
  ) {
    if (value == null) return 'Select action status';
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select due date';
    if (coverageActionDateOnly(
      value,
    ).isBefore(coverageActionDateOnly(asOfDate))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static String? validateActionPlan(String? value) {
    return coverageActionLongTextError(value, 'action plan');
  }

  static String? validateEscalationPath(String? value) {
    return coverageActionLongTextError(value, 'escalation path');
  }

  static String? validateResolutionEvidence(String? value) {
    return coverageActionLongTextError(value, 'resolution evidence');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}
