import 'incoming_talent_succession_activation_check_in.dart';
import 'incoming_talent_succession_activation_escalation.dart';

class IncomingTalentSuccessionActivationEscalationDraft {
  final String checkInId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionActivationCheckInTrend? checkInTrend;
  final int confidenceScore;
  final IncomingTalentSuccessionActivationEscalationPriority? priority;
  final DateTime? dueDate;
  final String escalationReason;
  final String decisionNeeded;
  final String sponsorCommitment;
  final String successCriteria;
  final DateTime asOfDate;

  const IncomingTalentSuccessionActivationEscalationDraft({
    required this.checkInId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.checkInTrend,
    required this.confidenceScore,
    required this.priority,
    required this.dueDate,
    required this.escalationReason,
    required this.decisionNeeded,
    required this.sponsorCommitment,
    required this.successCriteria,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionActivationEscalationDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionActivationEscalationDraft(
      checkInId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      ownerName: '',
      checkInTrend: null,
      confidenceScore: 0,
      priority: null,
      dueDate: null,
      escalationReason: '',
      decisionNeeded: '',
      sponsorCommitment: '',
      successCriteria: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionActivationEscalationDraft.fromCheckIn({
    required IncomingTalentSuccessionActivationCheckIn checkIn,
    required DateTime asOfDate,
  }) {
    final priority = _defaultPriority(checkIn);

    return IncomingTalentSuccessionActivationEscalationDraft(
      checkInId: checkIn.id,
      activationPlanId: checkIn.activationPlanId,
      decisionId: checkIn.decisionId,
      candidateId: checkIn.candidateId,
      candidateName: checkIn.candidateName,
      role: checkIn.role,
      department: checkIn.department,
      targetRole: checkIn.targetRole,
      ownerName: checkIn.reviewerName,
      checkInTrend: checkIn.trend,
      confidenceScore: checkIn.confidenceScore,
      priority: priority,
      dueDate: _dueDateForPriority(priority, asOfDate),
      escalationReason: _defaultReason(checkIn),
      decisionNeeded:
          'Confirm sponsor decision for the ${checkIn.targetRole.toLowerCase()} transition blocker.',
      sponsorCommitment: checkIn.sponsorAction,
      successCriteria:
          'Restore transition confidence to 4/5 before the next check-in.',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionActivationEscalationDraft copyWith({
    String? checkInId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? ownerName,
    IncomingTalentSuccessionActivationCheckInTrend? checkInTrend,
    int? confidenceScore,
    IncomingTalentSuccessionActivationEscalationPriority? priority,
    DateTime? dueDate,
    String? escalationReason,
    String? decisionNeeded,
    String? sponsorCommitment,
    String? successCriteria,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionActivationEscalationDraft(
      checkInId: checkInId ?? this.checkInId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      checkInTrend: checkInTrend ?? this.checkInTrend,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      escalationReason: escalationReason ?? this.escalationReason,
      decisionNeeded: decisionNeeded ?? this.decisionNeeded,
      sponsorCommitment: sponsorCommitment ?? this.sponsorCommitment,
      successCriteria: successCriteria ?? this.successCriteria,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          checkInId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          checkInTrend != null,
          validateConfidenceScore(confidenceScore) == null,
          priority != null,
          dueDate != null,
          escalationReason.trim().length >= 12,
          decisionNeeded.trim().length >= 12,
          sponsorCommitment.trim().length >= 12,
          successCriteria.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(checkInId, 'an attention check-in')
          case final error?)
        error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateCheckInTrend(checkInTrend) case final error?) error,
      if (validateConfidenceScore(confidenceScore) case final error?) error,
      if (validatePriority(priority) case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
      if (validateEscalationReason(escalationReason) case final error?) error,
      if (validateDecisionNeeded(decisionNeeded) case final error?) error,
      if (validateSponsorCommitment(sponsorCommitment) case final error?) error,
      if (validateSuccessCriteria(successCriteria) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionActivationEscalation toEscalation({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionActivationEscalation(
      id: id,
      checkInId: checkInId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      checkInTrend: checkInTrend!,
      confidenceScore: confidenceScore,
      priority: priority!,
      status: IncomingTalentSuccessionActivationEscalationStatus.opened,
      dueDate: dueDate!,
      escalationReason: escalationReason.trim(),
      decisionNeeded: decisionNeeded.trim(),
      sponsorCommitment: sponsorCommitment.trim(),
      successCriteria: successCriteria.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateCheckInTrend(
    IncomingTalentSuccessionActivationCheckInTrend? value,
  ) {
    if (value == null) return 'Select check-in trend';
    return null;
  }

  static String? validateConfidenceScore(int value) {
    if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
    return null;
  }

  static String? validatePriority(
    IncomingTalentSuccessionActivationEscalationPriority? value,
  ) {
    if (value == null) return 'Select escalation priority';
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a due date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static String? validateEscalationReason(String? value) {
    return _validateLongText(value, 'escalation reason');
  }

  static String? validateDecisionNeeded(String? value) {
    return _validateLongText(value, 'decision needed');
  }

  static String? validateSponsorCommitment(String? value) {
    return _validateLongText(value, 'sponsor commitment');
  }

  static String? validateSuccessCriteria(String? value) {
    return _validateLongText(value, 'success criteria');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionActivationEscalationPriority _defaultPriority(
  IncomingTalentSuccessionActivationCheckIn checkIn,
) {
  if (checkIn.trend == IncomingTalentSuccessionActivationCheckInTrend.blocked) {
    return IncomingTalentSuccessionActivationEscalationPriority.executive;
  }
  if (checkIn.trend == IncomingTalentSuccessionActivationCheckInTrend.watch ||
      checkIn.confidenceScore <= 3) {
    return IncomingTalentSuccessionActivationEscalationPriority.urgent;
  }
  return IncomingTalentSuccessionActivationEscalationPriority.standard;
}

DateTime _dueDateForPriority(
  IncomingTalentSuccessionActivationEscalationPriority priority,
  DateTime asOfDate,
) {
  final days = switch (priority) {
    IncomingTalentSuccessionActivationEscalationPriority.executive => 3,
    IncomingTalentSuccessionActivationEscalationPriority.urgent => 7,
    IncomingTalentSuccessionActivationEscalationPriority.standard => 14,
  };
  return asOfDate.add(Duration(days: days));
}

String _defaultReason(IncomingTalentSuccessionActivationCheckIn checkIn) {
  if (checkIn.blockerNote.trim().isNotEmpty) {
    return checkIn.blockerNote.trim();
  }
  return checkIn.nextStep.trim();
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionActivationEscalationDraft.validateRequired(
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
