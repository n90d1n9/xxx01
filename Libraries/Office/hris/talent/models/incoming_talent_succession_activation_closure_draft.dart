import 'incoming_talent_succession_activation_closure.dart';
import 'incoming_talent_succession_activation_resolution_review.dart';

class IncomingTalentSuccessionActivationClosureDraft {
  final String resolutionReviewId;
  final String escalationId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionActivationResolutionOutcome? resolutionOutcome;
  final IncomingTalentSuccessionActivationResidualRisk? residualRisk;
  final IncomingTalentSuccessionActivationClosureType? closureType;
  final IncomingTalentSuccessionActivationClosureStatus? status;
  final DateTime? effectiveDate;
  final String handoverOwner;
  final String hrPartnerName;
  final String communicationPlan;
  final String accessReadiness;
  final String compensationNote;
  final String governanceNote;
  final DateTime asOfDate;

  const IncomingTalentSuccessionActivationClosureDraft({
    required this.resolutionReviewId,
    required this.escalationId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.resolutionOutcome,
    required this.residualRisk,
    required this.closureType,
    required this.status,
    required this.effectiveDate,
    required this.handoverOwner,
    required this.hrPartnerName,
    required this.communicationPlan,
    required this.accessReadiness,
    required this.compensationNote,
    required this.governanceNote,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionActivationClosureDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionActivationClosureDraft(
      resolutionReviewId: '',
      escalationId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      ownerName: '',
      resolutionOutcome: null,
      residualRisk: null,
      closureType: null,
      status: null,
      effectiveDate: null,
      handoverOwner: '',
      hrPartnerName: '',
      communicationPlan: '',
      accessReadiness: '',
      compensationNote: '',
      governanceNote: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionActivationClosureDraft.fromReview({
    required IncomingTalentSuccessionActivationResolutionReview review,
    required DateTime asOfDate,
  }) {
    return IncomingTalentSuccessionActivationClosureDraft(
      resolutionReviewId: review.id,
      escalationId: review.escalationId,
      activationPlanId: review.activationPlanId,
      decisionId: review.decisionId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      role: review.role,
      department: review.department,
      targetRole: review.targetRole,
      ownerName: review.reviewerName,
      resolutionOutcome: review.outcome,
      residualRisk: review.residualRisk,
      closureType: _defaultClosureType(review),
      status: IncomingTalentSuccessionActivationClosureStatus.scheduled,
      effectiveDate: _safeEffectiveDate(review.nextReviewDate, asOfDate),
      handoverOwner: '${review.department} transition owner',
      hrPartnerName: '${review.department} HR partner',
      communicationPlan:
          'Notify stakeholders and publish ${review.targetRole.toLowerCase()} transition plan.',
      accessReadiness:
          'Confirm systems, approval paths, reporting line, and workspace access.',
      compensationNote:
          'HR partner validates compensation, grade, and payroll timing.',
      governanceNote: review.nextGovernanceStep,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionActivationClosureDraft copyWith({
    String? resolutionReviewId,
    String? escalationId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? ownerName,
    IncomingTalentSuccessionActivationResolutionOutcome? resolutionOutcome,
    IncomingTalentSuccessionActivationResidualRisk? residualRisk,
    IncomingTalentSuccessionActivationClosureType? closureType,
    IncomingTalentSuccessionActivationClosureStatus? status,
    DateTime? effectiveDate,
    String? handoverOwner,
    String? hrPartnerName,
    String? communicationPlan,
    String? accessReadiness,
    String? compensationNote,
    String? governanceNote,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionActivationClosureDraft(
      resolutionReviewId: resolutionReviewId ?? this.resolutionReviewId,
      escalationId: escalationId ?? this.escalationId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      resolutionOutcome: resolutionOutcome ?? this.resolutionOutcome,
      residualRisk: residualRisk ?? this.residualRisk,
      closureType: closureType ?? this.closureType,
      status: status ?? this.status,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      handoverOwner: handoverOwner ?? this.handoverOwner,
      hrPartnerName: hrPartnerName ?? this.hrPartnerName,
      communicationPlan: communicationPlan ?? this.communicationPlan,
      accessReadiness: accessReadiness ?? this.accessReadiness,
      compensationNote: compensationNote ?? this.compensationNote,
      governanceNote: governanceNote ?? this.governanceNote,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          resolutionReviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          validateResolutionOutcome(resolutionOutcome) == null,
          validateResidualRisk(residualRisk) == null,
          closureType != null,
          status != null,
          effectiveDate != null,
          handoverOwner.trim().isNotEmpty,
          hrPartnerName.trim().isNotEmpty,
          communicationPlan.trim().length >= 12,
          accessReadiness.trim().length >= 12,
          compensationNote.trim().length >= 12,
          governanceNote.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 13;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(resolutionReviewId, 'a cleared resolution review')
          case final error?)
        error,
      if (validateRequired(ownerName, 'a closure owner') case final error?)
        error,
      if (validateResolutionOutcome(resolutionOutcome) case final error?) error,
      if (validateResidualRisk(residualRisk) case final error?) error,
      if (validateClosureType(closureType) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateEffectiveDate(effectiveDate, asOfDate) case final error?)
        error,
      if (validateRequired(handoverOwner, 'a handover owner') case final error?)
        error,
      if (validateRequired(hrPartnerName, 'an HR partner') case final error?)
        error,
      if (validateCommunicationPlan(communicationPlan) case final error?) error,
      if (validateAccessReadiness(accessReadiness) case final error?) error,
      if (validateCompensationNote(compensationNote) case final error?) error,
      if (validateGovernanceNote(governanceNote) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionActivationClosure toClosure({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionActivationClosure(
      id: id,
      resolutionReviewId: resolutionReviewId,
      escalationId: escalationId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      resolutionOutcome: resolutionOutcome!,
      residualRisk: residualRisk!,
      closureType: closureType!,
      status: status!,
      effectiveDate: effectiveDate!,
      handoverOwner: handoverOwner.trim(),
      hrPartnerName: hrPartnerName.trim(),
      communicationPlan: communicationPlan.trim(),
      accessReadiness: accessReadiness.trim(),
      compensationNote: compensationNote.trim(),
      governanceNote: governanceNote.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateResolutionOutcome(
    IncomingTalentSuccessionActivationResolutionOutcome? value,
  ) {
    if (value == null) return 'Select resolution outcome';
    if (value !=
        IncomingTalentSuccessionActivationResolutionOutcome.transitionCleared) {
      return 'Resolution must be cleared before closure';
    }
    return null;
  }

  static String? validateResidualRisk(
    IncomingTalentSuccessionActivationResidualRisk? value,
  ) {
    if (value == null) return 'Select residual risk';
    if (value != IncomingTalentSuccessionActivationResidualRisk.low) {
      return 'Residual risk must be low before closure';
    }
    return null;
  }

  static String? validateClosureType(
    IncomingTalentSuccessionActivationClosureType? value,
  ) {
    if (value == null) return 'Select closure type';
    return null;
  }

  static String? validateStatus(
    IncomingTalentSuccessionActivationClosureStatus? value,
  ) {
    if (value == null) return 'Select closure status';
    return null;
  }

  static String? validateEffectiveDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select effective date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Effective date cannot be in the past';
    }
    return null;
  }

  static String? validateCommunicationPlan(String? value) {
    return _validateLongText(value, 'communication plan');
  }

  static String? validateAccessReadiness(String? value) {
    return _validateLongText(value, 'access readiness');
  }

  static String? validateCompensationNote(String? value) {
    return _validateLongText(value, 'compensation note');
  }

  static String? validateGovernanceNote(String? value) {
    return _validateLongText(value, 'governance note');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionActivationClosureType _defaultClosureType(
  IncomingTalentSuccessionActivationResolutionReview review,
) {
  final target = review.targetRole.toLowerCase();
  if (target.contains('lead') || target.contains('manager')) {
    return IncomingTalentSuccessionActivationClosureType.promotion;
  }
  return IncomingTalentSuccessionActivationClosureType.successionMove;
}

DateTime _safeEffectiveDate(DateTime date, DateTime asOfDate) {
  if (_dateOnly(date).isBefore(_dateOnly(asOfDate))) {
    return asOfDate.add(const Duration(days: 14));
  }
  return date;
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionActivationClosureDraft.validateRequired(
        value,
        label,
      );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 12) {
    return '${_capitalize(label)} must be at least 12 characters';
  }
  return null;
}

String _capitalize(String value) {
  return value.isEmpty
      ? value
      : '${value[0].toUpperCase()}${value.substring(1)}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
