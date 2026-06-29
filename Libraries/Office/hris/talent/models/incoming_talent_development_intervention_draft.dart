import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_activation_follow_up_models.dart';
import 'incoming_talent_development_check_in_models.dart';
import 'incoming_talent_development_intervention.dart';
import 'incoming_talent_development_intervention_defaults.dart';

class IncomingTalentDevelopmentInterventionDraft {
  final String checkInId;
  final String activationFollowUpId;
  final String roadmapId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final IncomingTalentDevelopmentInterventionType? actionType;
  final IncomingTalentDevelopmentInterventionPriority? priority;
  final IncomingTalentDevelopmentInterventionStatus? status;
  final DateTime? dueDate;
  final String action;
  final String successCriteria;
  final String resolutionNote;
  final IncomingTalentDevelopmentCheckInTrend? sourceTrend;
  final int confidenceScore;
  final IncomingTalentActivationRetentionRisk? retentionRisk;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentInterventionDraft({
    required this.checkInId,
    required this.activationFollowUpId,
    required this.roadmapId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.acceptedProgramMilestoneCount,
    required this.roleReadyProgramCompletionCount,
    required this.programCompletionExtensionCount,
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.action,
    required this.successCriteria,
    required this.resolutionNote,
    required this.sourceTrend,
    required this.confidenceScore,
    required this.retentionRisk,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentInterventionDraft.empty(DateTime asOfDate) {
    return IncomingTalentDevelopmentInterventionDraft(
      checkInId: '',
      activationFollowUpId: '',
      roadmapId: '',
      outcomeReviewId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      ownerName: '',
      acceptedProgramMilestoneCount: 0,
      roleReadyProgramCompletionCount: 0,
      programCompletionExtensionCount: 0,
      actionType: null,
      priority: null,
      status: null,
      dueDate: null,
      action: '',
      successCriteria: '',
      resolutionNote: '',
      sourceTrend: null,
      confidenceScore: 0,
      retentionRisk: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentInterventionDraft.fromCheckIn({
    required IncomingTalentDevelopmentCheckIn checkIn,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentDevelopmentInterventionDefaults.fromCheckIn(
      checkIn,
    );

    return IncomingTalentDevelopmentInterventionDraft(
      checkInId: checkIn.id,
      activationFollowUpId: '',
      roadmapId: checkIn.roadmapId,
      outcomeReviewId: checkIn.outcomeReviewId,
      candidateId: checkIn.candidateId,
      candidateName: checkIn.candidateName,
      role: checkIn.role,
      department: checkIn.department,
      ownerName: checkIn.reviewerName,
      acceptedProgramMilestoneCount: 0,
      roleReadyProgramCompletionCount: 0,
      programCompletionExtensionCount: 0,
      actionType: defaults.actionType,
      priority: defaults.priority,
      status: IncomingTalentDevelopmentInterventionStatus.open,
      dueDate: asOfDate.add(defaults.dueInterval),
      action: defaults.action,
      successCriteria: defaults.successCriteria,
      resolutionNote: '',
      sourceTrend: checkIn.trend,
      confidenceScore: checkIn.confidenceScore,
      retentionRisk: checkIn.retentionRisk,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentInterventionDraft.fromFollowUp({
    required IncomingTalentActivationFollowUpAction action,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentDevelopmentInterventionDefaults.fromFollowUp(
      action,
    );

    return IncomingTalentDevelopmentInterventionDraft(
      checkInId: '',
      activationFollowUpId: action.id,
      roadmapId: '',
      outcomeReviewId: '',
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      role: action.role,
      department: action.department,
      ownerName: action.ownerName,
      acceptedProgramMilestoneCount: action.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: action.roleReadyProgramCompletionCount,
      programCompletionExtensionCount: action.programCompletionExtensionCount,
      actionType: defaults.actionType,
      priority: defaults.priority,
      status: IncomingTalentDevelopmentInterventionStatus.open,
      dueDate: asOfDate.add(defaults.dueInterval),
      action: defaults.action,
      successCriteria: defaults.successCriteria,
      resolutionNote: '',
      sourceTrend: _sourceTrendFromFollowUp(action),
      confidenceScore: _confidenceScoreFromFollowUp(action),
      retentionRisk: _retentionRiskFromFollowUp(action),
      asOfDate: asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          checkInId.trim().isNotEmpty || activationFollowUpId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          actionType != null,
          priority != null,
          status != null,
          dueDate != null,
          action.trim().length >= 12,
          successCriteria.trim().length >= 12,
          validateResolutionNote(resolutionNote, status) == null,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateSource(
            checkInId: checkInId,
            activationFollowUpId: activationFollowUpId,
          )
          case final error?)
        error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateActionType(actionType) case final error?) error,
      if (validatePriority(priority) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
      if (validateAction(action) case final error?) error,
      if (validateSuccessCriteria(successCriteria) case final error?) error,
      if (validateResolutionNote(resolutionNote, status) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentInterventionAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentInterventionAction(
      id: id,
      checkInId: checkInId,
      activationFollowUpId: activationFollowUpId,
      roadmapId: roadmapId,
      outcomeReviewId: outcomeReviewId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      ownerName: ownerName.trim(),
      acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      actionType: actionType!,
      priority: priority!,
      status: status!,
      dueDate: dueDate!,
      action: action.trim(),
      successCriteria: successCriteria.trim(),
      resolutionNote: resolutionNote.trim(),
      sourceTrend: sourceTrend!,
      confidenceScore: confidenceScore,
      retentionRisk: retentionRisk!,
      createdAt: createdAt,
    );
  }

  static String? validateActionType(
    IncomingTalentDevelopmentInterventionType? value,
  ) {
    if (value == null) return 'Select an action type';
    return null;
  }

  static String? validatePriority(
    IncomingTalentDevelopmentInterventionPriority? value,
  ) {
    if (value == null) return 'Select action priority';
    return null;
  }

  static String? validateStatus(
    IncomingTalentDevelopmentInterventionStatus? value,
  ) {
    if (value == null) return 'Select action status';
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a due date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  static String? validateAction(String? value) {
    return _validateLongText(value, 'action');
  }

  static String? validateSuccessCriteria(String? value) {
    return _validateLongText(value, 'success criteria');
  }

  static String? validateResolutionNote(
    String? value,
    IncomingTalentDevelopmentInterventionStatus? status,
  ) {
    if (status != IncomingTalentDevelopmentInterventionStatus.resolved) {
      return null;
    }
    final requiredError = validateRequired(value, 'a resolution note');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Resolution note must be at least 12 characters';
    }
    return null;
  }

  static String? validateSource({
    required String checkInId,
    required String activationFollowUpId,
  }) {
    if (checkInId.trim().isEmpty && activationFollowUpId.trim().isEmpty) {
      return 'Select a risk source';
    }
    return null;
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
      IncomingTalentDevelopmentInterventionDraft.validateRequired(value, label);
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

IncomingTalentDevelopmentCheckInTrend _sourceTrendFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return IncomingTalentDevelopmentCheckInTrend.blocked;
  }
  if (action.programCompletionExtensionCount > 0) {
    return IncomingTalentDevelopmentCheckInTrend.watch;
  }
  if (action.status == IncomingTalentActivationFollowUpStatus.inProgress) {
    return IncomingTalentDevelopmentCheckInTrend.improving;
  }
  return IncomingTalentDevelopmentCheckInTrend.steady;
}

int _confidenceScoreFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return 2;
  }
  if (action.programCompletionExtensionCount > 0) {
    return 3;
  }
  return 4;
}

IncomingTalentActivationRetentionRisk _retentionRiskFromFollowUp(
  IncomingTalentActivationFollowUpAction action,
) {
  if (action.status == IncomingTalentActivationFollowUpStatus.blocked) {
    return IncomingTalentActivationRetentionRisk.high;
  }
  if (action.programCompletionExtensionCount > 0) {
    return IncomingTalentActivationRetentionRisk.medium;
  }
  return IncomingTalentActivationRetentionRisk.low;
}
