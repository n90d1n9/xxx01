import 'incoming_talent_succession_activation_closure.dart';
import 'incoming_talent_succession_transition_pulse.dart';

class IncomingTalentSuccessionTransitionPulseDraft {
  final String closureId;
  final String resolutionReviewId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionActivationClosureType? closureType;
  final IncomingTalentSuccessionActivationClosureStatus? closureStatus;
  final DateTime? effectiveDate;
  final IncomingTalentSuccessionTransitionPulseWindow? pulseWindow;
  final DateTime? pulseDate;
  final IncomingTalentSuccessionTransitionPulseHealth? health;
  final int adoptionScore;
  final int managerConfidenceScore;
  final IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk;
  final String outcomeEvidence;
  final String employeeSignal;
  final String managerSignal;
  final String stakeholderSentiment;
  final String nextAction;
  final DateTime? nextPulseDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionTransitionPulseDraft({
    required this.closureId,
    required this.resolutionReviewId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.closureType,
    required this.closureStatus,
    required this.effectiveDate,
    required this.pulseWindow,
    required this.pulseDate,
    required this.health,
    required this.adoptionScore,
    required this.managerConfidenceScore,
    required this.retentionRisk,
    required this.outcomeEvidence,
    required this.employeeSignal,
    required this.managerSignal,
    required this.stakeholderSentiment,
    required this.nextAction,
    required this.nextPulseDate,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionTransitionPulseDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionTransitionPulseDraft(
      closureId: '',
      resolutionReviewId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      ownerName: '',
      closureType: null,
      closureStatus: null,
      effectiveDate: null,
      pulseWindow: null,
      pulseDate: null,
      health: null,
      adoptionScore: 0,
      managerConfidenceScore: 0,
      retentionRisk: null,
      outcomeEvidence: '',
      employeeSignal: '',
      managerSignal: '',
      stakeholderSentiment: '',
      nextAction: '',
      nextPulseDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionTransitionPulseDraft.fromClosure({
    required IncomingTalentSuccessionActivationClosure closure,
    required DateTime asOfDate,
    IncomingTalentSuccessionTransitionPulseWindow pulseWindow =
        IncomingTalentSuccessionTransitionPulseWindow.thirtyDay,
  }) {
    return IncomingTalentSuccessionTransitionPulseDraft(
      closureId: closure.id,
      resolutionReviewId: closure.resolutionReviewId,
      activationPlanId: closure.activationPlanId,
      decisionId: closure.decisionId,
      candidateId: closure.candidateId,
      candidateName: closure.candidateName,
      role: closure.role,
      department: closure.department,
      targetRole: closure.targetRole,
      ownerName: closure.ownerName,
      closureType: closure.closureType,
      closureStatus: closure.status,
      effectiveDate: closure.effectiveDate,
      pulseWindow: pulseWindow,
      pulseDate: asOfDate,
      health: IncomingTalentSuccessionTransitionPulseHealth.stable,
      adoptionScore: 4,
      managerConfidenceScore: 4,
      retentionRisk: IncomingTalentSuccessionTransitionRetentionRisk.low,
      outcomeEvidence:
          'Transition evidence confirms ${closure.targetRole.toLowerCase()} ownership is operating.',
      employeeSignal:
          'Employee confirms role clarity, support, and handover confidence.',
      managerSignal:
          'Manager confirms delivery ownership and stakeholder adoption.',
      stakeholderSentiment:
          'Stakeholders report stable handover and role accountability.',
      nextAction:
          'Continue transition support and capture the next pulse window.',
      nextPulseDate: asOfDate.add(const Duration(days: 30)),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionTransitionPulseDraft copyWith({
    String? closureId,
    String? resolutionReviewId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? ownerName,
    IncomingTalentSuccessionActivationClosureType? closureType,
    IncomingTalentSuccessionActivationClosureStatus? closureStatus,
    DateTime? effectiveDate,
    IncomingTalentSuccessionTransitionPulseWindow? pulseWindow,
    DateTime? pulseDate,
    IncomingTalentSuccessionTransitionPulseHealth? health,
    int? adoptionScore,
    int? managerConfidenceScore,
    IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk,
    String? outcomeEvidence,
    String? employeeSignal,
    String? managerSignal,
    String? stakeholderSentiment,
    String? nextAction,
    DateTime? nextPulseDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionTransitionPulseDraft(
      closureId: closureId ?? this.closureId,
      resolutionReviewId: resolutionReviewId ?? this.resolutionReviewId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      closureType: closureType ?? this.closureType,
      closureStatus: closureStatus ?? this.closureStatus,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      pulseWindow: pulseWindow ?? this.pulseWindow,
      pulseDate: pulseDate ?? this.pulseDate,
      health: health ?? this.health,
      adoptionScore: adoptionScore ?? this.adoptionScore,
      managerConfidenceScore:
          managerConfidenceScore ?? this.managerConfidenceScore,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      outcomeEvidence: outcomeEvidence ?? this.outcomeEvidence,
      employeeSignal: employeeSignal ?? this.employeeSignal,
      managerSignal: managerSignal ?? this.managerSignal,
      stakeholderSentiment: stakeholderSentiment ?? this.stakeholderSentiment,
      nextAction: nextAction ?? this.nextAction,
      nextPulseDate: nextPulseDate ?? this.nextPulseDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          closureId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          closureType != null,
          closureStatus ==
              IncomingTalentSuccessionActivationClosureStatus.completed,
          effectiveDate != null,
          pulseWindow != null,
          pulseDate != null,
          health != null,
          validateScore(adoptionScore, 'Adoption') == null,
          validateScore(managerConfidenceScore, 'Manager confidence') == null,
          retentionRisk != null,
          outcomeEvidence.trim().length >= 12,
          employeeSignal.trim().length >= 12,
          managerSignal.trim().length >= 12,
          stakeholderSentiment.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextPulseDate != null,
        ].where((item) => item).length;

    return completed / 17;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(closureId, 'a completed closure') case final error?)
        error,
      if (validateRequired(ownerName, 'a pulse owner') case final error?) error,
      if (validateClosureType(closureType) case final error?) error,
      if (validateClosureStatus(closureStatus) case final error?) error,
      if (validateEffectiveDate(effectiveDate) case final error?) error,
      if (validatePulseWindow(pulseWindow) case final error?) error,
      if (validatePulseDate(pulseDate, asOfDate) case final error?) error,
      if (validateHealth(health) case final error?) error,
      if (validateScore(adoptionScore, 'Adoption') case final error?) error,
      if (validateScore(managerConfidenceScore, 'Manager confidence')
          case final error?)
        error,
      if (validateRetentionRisk(retentionRisk) case final error?) error,
      if (validateOutcomeEvidence(outcomeEvidence) case final error?) error,
      if (validateEmployeeSignal(employeeSignal) case final error?) error,
      if (validateManagerSignal(managerSignal) case final error?) error,
      if (validateStakeholderSentiment(stakeholderSentiment) case final error?)
        error,
      if (validateNextAction(nextAction) case final error?) error,
      if (validateNextPulseDate(pulseDate, nextPulseDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionTransitionPulse toPulse({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionTransitionPulse(
      id: id,
      closureId: closureId,
      resolutionReviewId: resolutionReviewId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      closureType: closureType!,
      effectiveDate: effectiveDate!,
      pulseWindow: pulseWindow!,
      pulseDate: pulseDate!,
      health: health!,
      adoptionScore: adoptionScore,
      managerConfidenceScore: managerConfidenceScore,
      retentionRisk: retentionRisk!,
      outcomeEvidence: outcomeEvidence.trim(),
      employeeSignal: employeeSignal.trim(),
      managerSignal: managerSignal.trim(),
      stakeholderSentiment: stakeholderSentiment.trim(),
      nextAction: nextAction.trim(),
      nextPulseDate: nextPulseDate!,
      createdAt: createdAt,
    );
  }

  static String? validateClosureType(
    IncomingTalentSuccessionActivationClosureType? value,
  ) {
    if (value == null) return 'Select closure type';
    return null;
  }

  static String? validateClosureStatus(
    IncomingTalentSuccessionActivationClosureStatus? value,
  ) {
    if (value == null) return 'Select closure status';
    if (value != IncomingTalentSuccessionActivationClosureStatus.completed) {
      return 'Closure must be completed before pulse';
    }
    return null;
  }

  static String? validateEffectiveDate(DateTime? value) {
    if (value == null) return 'Select effective date';
    return null;
  }

  static String? validatePulseWindow(
    IncomingTalentSuccessionTransitionPulseWindow? value,
  ) {
    if (value == null) return 'Select pulse window';
    return null;
  }

  static String? validatePulseDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select pulse date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Pulse date cannot be in the past';
    }
    return null;
  }

  static String? validateHealth(
    IncomingTalentSuccessionTransitionPulseHealth? value,
  ) {
    if (value == null) return 'Select pulse health';
    return null;
  }

  static String? validateScore(int value, String label) {
    if (value < 1 || value > 5) return '$label score must be between 1 and 5';
    return null;
  }

  static String? validateRetentionRisk(
    IncomingTalentSuccessionTransitionRetentionRisk? value,
  ) {
    if (value == null) return 'Select retention risk';
    return null;
  }

  static String? validateNextPulseDate(
    DateTime? pulseDate,
    DateTime? nextPulseDate,
  ) {
    if (nextPulseDate == null) return 'Select next pulse date';
    if (pulseDate == null) return null;
    if (!_dateOnly(nextPulseDate).isAfter(_dateOnly(pulseDate))) {
      return 'Next pulse must be after pulse date';
    }
    return null;
  }

  static String? validateOutcomeEvidence(String? value) {
    return _validateLongText(value, 'outcome evidence');
  }

  static String? validateEmployeeSignal(String? value) {
    return _validateLongText(value, 'employee signal');
  }

  static String? validateManagerSignal(String? value) {
    return _validateLongText(value, 'manager signal');
  }

  static String? validateStakeholderSentiment(String? value) {
    return _validateLongText(value, 'stakeholder sentiment');
  }

  static String? validateNextAction(String? value) {
    return _validateLongText(value, 'next action');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionTransitionPulseDraft.validateRequired(
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
