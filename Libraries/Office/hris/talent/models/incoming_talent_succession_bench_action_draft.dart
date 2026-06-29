import 'incoming_talent_succession_bench_action.dart';
import 'incoming_talent_succession_bench_check_in.dart';
import 'incoming_talent_succession_bench_replenishment.dart';

class IncomingTalentSuccessionBenchActionDraft {
  final String checkInId;
  final String benchReplenishmentId;
  final String outcomeReviewId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionBenchReplenishmentPriority? priority;
  final IncomingTalentSuccessionBenchCheckInHealth? checkInHealth;
  final IncomingTalentSuccessionBenchActionType? actionType;
  final IncomingTalentSuccessionBenchActionStatus? status;
  final DateTime? dueDate;
  final String actionPlan;
  final String escalationPath;
  final String resolutionEvidence;
  final DateTime asOfDate;

  const IncomingTalentSuccessionBenchActionDraft({
    required this.checkInId,
    required this.benchReplenishmentId,
    required this.outcomeReviewId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.priority,
    required this.checkInHealth,
    required this.actionType,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.escalationPath,
    required this.resolutionEvidence,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionBenchActionDraft.empty(DateTime asOfDate) {
    return IncomingTalentSuccessionBenchActionDraft(
      checkInId: '',
      benchReplenishmentId: '',
      outcomeReviewId: '',
      activationPlanId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      targetRole: '',
      ownerName: '',
      priority: null,
      checkInHealth: null,
      actionType: null,
      status: null,
      dueDate: null,
      actionPlan: '',
      escalationPath: '',
      resolutionEvidence: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionBenchActionDraft.fromCheckIn({
    required IncomingTalentSuccessionBenchCheckIn checkIn,
    required DateTime asOfDate,
  }) {
    final actionType = _defaultActionType(checkIn);

    return IncomingTalentSuccessionBenchActionDraft(
      checkInId: checkIn.id,
      benchReplenishmentId: checkIn.benchReplenishmentId,
      outcomeReviewId: checkIn.outcomeReviewId,
      activationPlanId: checkIn.activationPlanId,
      decisionId: checkIn.decisionId,
      candidateId: checkIn.candidateId,
      candidateName: checkIn.candidateName,
      role: checkIn.role,
      department: checkIn.department,
      targetRole: checkIn.targetRole,
      ownerName: checkIn.ownerName,
      priority: checkIn.priority,
      checkInHealth: checkIn.health,
      actionType: actionType,
      status: IncomingTalentSuccessionBenchActionStatus.planned,
      dueDate: _dueDate(checkIn, asOfDate),
      actionPlan: '${actionType.label}: ${checkIn.nextAction}',
      escalationPath: _defaultEscalationPath(checkIn),
      resolutionEvidence:
          'Confirm ready-now coverage improves and blocker evidence is closed.',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionBenchActionDraft copyWith({
    String? checkInId,
    String? benchReplenishmentId,
    String? outcomeReviewId,
    String? activationPlanId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? targetRole,
    String? ownerName,
    IncomingTalentSuccessionBenchReplenishmentPriority? priority,
    IncomingTalentSuccessionBenchCheckInHealth? checkInHealth,
    IncomingTalentSuccessionBenchActionType? actionType,
    IncomingTalentSuccessionBenchActionStatus? status,
    DateTime? dueDate,
    String? actionPlan,
    String? escalationPath,
    String? resolutionEvidence,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionBenchActionDraft(
      checkInId: checkInId ?? this.checkInId,
      benchReplenishmentId: benchReplenishmentId ?? this.benchReplenishmentId,
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      priority: priority ?? this.priority,
      checkInHealth: checkInHealth ?? this.checkInHealth,
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
          checkInId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          priority != null,
          checkInHealth != null,
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
      if (validateRequired(checkInId, 'an attention check-in')
          case final error?)
        error,
      if (validateRequired(ownerName, 'an action owner') case final error?)
        error,
      if (validatePriority(priority) case final error?) error,
      if (validateCheckInHealth(checkInHealth) case final error?) error,
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

  IncomingTalentSuccessionBenchAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionBenchAction(
      id: id,
      checkInId: checkInId,
      benchReplenishmentId: benchReplenishmentId,
      outcomeReviewId: outcomeReviewId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      ownerName: ownerName.trim(),
      priority: priority!,
      checkInHealth: checkInHealth!,
      actionType: actionType!,
      status: status!,
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      escalationPath: escalationPath.trim(),
      resolutionEvidence: resolutionEvidence.trim(),
      createdAt: createdAt,
    );
  }

  static String? validatePriority(
    IncomingTalentSuccessionBenchReplenishmentPriority? value,
  ) {
    if (value == null) return 'Select bench priority';
    return null;
  }

  static String? validateCheckInHealth(
    IncomingTalentSuccessionBenchCheckInHealth? value,
  ) {
    if (value == null) return 'Select check-in health';
    return null;
  }

  static String? validateActionType(
    IncomingTalentSuccessionBenchActionType? value,
  ) {
    if (value == null) return 'Select action type';
    return null;
  }

  static String? validateStatus(
    IncomingTalentSuccessionBenchActionStatus? value,
  ) {
    if (value == null) return 'Select action status';
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select due date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static String? validateActionPlan(String? value) {
    return _validateLongText(value, 'action plan');
  }

  static String? validateEscalationPath(String? value) {
    return _validateLongText(value, 'escalation path');
  }

  static String? validateResolutionEvidence(String? value) {
    return _validateLongText(value, 'resolution evidence');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentSuccessionBenchActionType _defaultActionType(
  IncomingTalentSuccessionBenchCheckIn checkIn,
) {
  if (checkIn.health == IncomingTalentSuccessionBenchCheckInHealth.blocked) {
    return IncomingTalentSuccessionBenchActionType.leadership;
  }
  if (checkIn.readyNowCount == 0) {
    return IncomingTalentSuccessionBenchActionType.sourcing;
  }
  if (checkIn.readinessScore <= 3) {
    return IncomingTalentSuccessionBenchActionType.development;
  }
  if (checkIn.priority ==
      IncomingTalentSuccessionBenchReplenishmentPriority.critical) {
    return IncomingTalentSuccessionBenchActionType.externalSearch;
  }
  return IncomingTalentSuccessionBenchActionType.mobility;
}

DateTime _dueDate(
  IncomingTalentSuccessionBenchCheckIn checkIn,
  DateTime asOfDate,
) {
  final days =
      checkIn.health == IncomingTalentSuccessionBenchCheckInHealth.blocked ||
              checkIn.health ==
                  IncomingTalentSuccessionBenchCheckInHealth.atRisk ||
              checkIn.priority ==
                  IncomingTalentSuccessionBenchReplenishmentPriority.critical
          ? 7
          : checkIn.health == IncomingTalentSuccessionBenchCheckInHealth.watch
          ? 14
          : 30;
  return asOfDate.add(Duration(days: days));
}

String _defaultEscalationPath(IncomingTalentSuccessionBenchCheckIn checkIn) {
  if (checkIn.health == IncomingTalentSuccessionBenchCheckInHealth.blocked) {
    return 'Escalate to HR leadership and department sponsor for blocker removal.';
  }
  if (checkIn.priority ==
      IncomingTalentSuccessionBenchReplenishmentPriority.critical) {
    return 'Route to succession sponsor and recruiting lead for weekly recovery.';
  }
  return 'Escalate through talent partner if next check-in remains off track.';
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentSuccessionBenchActionDraft.validateRequired(value, label);
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
