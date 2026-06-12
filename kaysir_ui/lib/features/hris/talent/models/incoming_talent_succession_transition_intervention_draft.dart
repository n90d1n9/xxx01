import 'incoming_talent_succession_activation_closure.dart';
import 'incoming_talent_succession_transition_intervention.dart';
import 'incoming_talent_succession_transition_pulse.dart';

class IncomingTalentSuccessionTransitionInterventionDraft {
  final String pulseId;
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
  final IncomingTalentSuccessionTransitionPulseWindow? pulseWindow;
  final IncomingTalentSuccessionTransitionPulseHealth? pulseHealth;
  final IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk;
  final IncomingTalentSuccessionTransitionInterventionType? interventionType;
  final DateTime? dueDate;
  final String interventionPlan;
  final String sponsorSupport;
  final String successMetric;
  final DateTime asOfDate;

  const IncomingTalentSuccessionTransitionInterventionDraft({
    required this.pulseId,
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
    required this.pulseWindow,
    required this.pulseHealth,
    required this.retentionRisk,
    required this.interventionType,
    required this.dueDate,
    required this.interventionPlan,
    required this.sponsorSupport,
    required this.successMetric,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionTransitionInterventionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionTransitionInterventionDraft(
      pulseId: '',
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
      pulseWindow: null,
      pulseHealth: null,
      retentionRisk: null,
      interventionType: null,
      dueDate: null,
      interventionPlan: '',
      sponsorSupport: '',
      successMetric: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionTransitionInterventionDraft.fromPulse({
    required IncomingTalentSuccessionTransitionPulse pulse,
    required DateTime asOfDate,
  }) {
    final type = _defaultType(pulse);

    return IncomingTalentSuccessionTransitionInterventionDraft(
      pulseId: pulse.id,
      closureId: pulse.closureId,
      resolutionReviewId: pulse.resolutionReviewId,
      activationPlanId: pulse.activationPlanId,
      decisionId: pulse.decisionId,
      candidateId: pulse.candidateId,
      candidateName: pulse.candidateName,
      role: pulse.role,
      department: pulse.department,
      targetRole: pulse.targetRole,
      ownerName: pulse.ownerName,
      closureType: pulse.closureType,
      pulseWindow: pulse.pulseWindow,
      pulseHealth: pulse.health,
      retentionRisk: pulse.retentionRisk,
      interventionType: type,
      dueDate: _dueDateForPulse(pulse, asOfDate),
      interventionPlan: '${type.label}: ${pulse.nextAction}',
      sponsorSupport:
          'Sponsor reviews ${pulse.targetRole.toLowerCase()} adoption blockers and removes transition friction.',
      successMetric:
          'Restore adoption and manager confidence to 4/5 before next pulse.',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionTransitionInterventionDraft copyWith({
    String? pulseId,
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
    IncomingTalentSuccessionTransitionPulseWindow? pulseWindow,
    IncomingTalentSuccessionTransitionPulseHealth? pulseHealth,
    IncomingTalentSuccessionTransitionRetentionRisk? retentionRisk,
    IncomingTalentSuccessionTransitionInterventionType? interventionType,
    DateTime? dueDate,
    String? interventionPlan,
    String? sponsorSupport,
    String? successMetric,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionTransitionInterventionDraft(
      pulseId: pulseId ?? this.pulseId,
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
      pulseWindow: pulseWindow ?? this.pulseWindow,
      pulseHealth: pulseHealth ?? this.pulseHealth,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      interventionType: interventionType ?? this.interventionType,
      dueDate: dueDate ?? this.dueDate,
      interventionPlan: interventionPlan ?? this.interventionPlan,
      sponsorSupport: sponsorSupport ?? this.sponsorSupport,
      successMetric: successMetric ?? this.successMetric,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          pulseId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          closureType != null,
          pulseWindow != null,
          pulseHealth != null,
          retentionRisk != null,
          interventionType != null,
          dueDate != null,
          interventionPlan.trim().length >= 12,
          sponsorSupport.trim().length >= 12,
          successMetric.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(pulseId, 'an attention pulse') case final error?)
        error,
      if (validateRequired(ownerName, 'an intervention owner')
          case final error?)
        error,
      if (validateClosureType(closureType) case final error?) error,
      if (validatePulseWindow(pulseWindow) case final error?) error,
      if (validatePulseHealth(pulseHealth) case final error?) error,
      if (validateRetentionRisk(retentionRisk) case final error?) error,
      if (validateInterventionType(interventionType) case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
      if (validateInterventionPlan(interventionPlan) case final error?) error,
      if (validateSponsorSupport(sponsorSupport) case final error?) error,
      if (validateSuccessMetric(successMetric) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionTransitionIntervention toIntervention({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionTransitionIntervention(
      id: id,
      pulseId: pulseId,
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
      pulseWindow: pulseWindow!,
      pulseHealth: pulseHealth!,
      retentionRisk: retentionRisk!,
      interventionType: interventionType!,
      status: IncomingTalentSuccessionTransitionInterventionStatus.planned,
      dueDate: dueDate!,
      interventionPlan: interventionPlan.trim(),
      sponsorSupport: sponsorSupport.trim(),
      successMetric: successMetric.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateClosureType(
    IncomingTalentSuccessionActivationClosureType? value,
  ) {
    if (value == null) return 'Select closure type';
    return null;
  }

  static String? validatePulseWindow(
    IncomingTalentSuccessionTransitionPulseWindow? value,
  ) {
    if (value == null) return 'Select pulse window';
    return null;
  }

  static String? validatePulseHealth(
    IncomingTalentSuccessionTransitionPulseHealth? value,
  ) {
    if (value == null) return 'Select pulse health';
    return null;
  }

  static String? validateRetentionRisk(
    IncomingTalentSuccessionTransitionRetentionRisk? value,
  ) {
    if (value == null) return 'Select retention risk';
    return null;
  }

  static String? validateInterventionType(
    IncomingTalentSuccessionTransitionInterventionType? value,
  ) {
    if (value == null) return 'Select intervention type';
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select due date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static String? validateInterventionPlan(String? value) {
    return _validateLongText(value, 'intervention plan');
  }

  static String? validateSponsorSupport(String? value) {
    return _validateLongText(value, 'sponsor support');
  }

  static String? validateSuccessMetric(String? value) {
    return _validateLongText(value, 'success metric');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionTransitionInterventionType _defaultType(
  IncomingTalentSuccessionTransitionPulse pulse,
) {
  if (pulse.retentionRisk ==
      IncomingTalentSuccessionTransitionRetentionRisk.high) {
    return IncomingTalentSuccessionTransitionInterventionType.retentionPlan;
  }
  if (pulse.health ==
      IncomingTalentSuccessionTransitionPulseHealth.intervention) {
    return IncomingTalentSuccessionTransitionInterventionType.managerAlignment;
  }
  if (pulse.managerConfidenceScore <= 3) {
    return IncomingTalentSuccessionTransitionInterventionType.coaching;
  }
  if (pulse.adoptionScore <= 3) {
    return IncomingTalentSuccessionTransitionInterventionType.stakeholderReset;
  }
  return IncomingTalentSuccessionTransitionInterventionType.roleClarity;
}

DateTime _dueDateForPulse(
  IncomingTalentSuccessionTransitionPulse pulse,
  DateTime asOfDate,
) {
  final days =
      pulse.retentionRisk ==
                  IncomingTalentSuccessionTransitionRetentionRisk.high ||
              pulse.health ==
                  IncomingTalentSuccessionTransitionPulseHealth.intervention
          ? 7
          : 14;
  return asOfDate.add(Duration(days: days));
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionTransitionInterventionDraft.validateRequired(
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
