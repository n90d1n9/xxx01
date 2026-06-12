import 'incoming_talent_activation_checkpoint_models.dart';
import 'incoming_talent_activation_follow_up.dart';

class IncomingTalentActivationFollowUpDraft {
  final String checkpointId;
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final IncomingTalentActivationFollowUpType? actionType;
  final DateTime? dueDate;
  final String action;
  final String successCriteria;
  final DateTime asOfDate;

  const IncomingTalentActivationFollowUpDraft({
    required this.checkpointId,
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.acceptedProgramMilestoneCount,
    required this.roleReadyProgramCompletionCount,
    required this.programCompletionExtensionCount,
    required this.actionType,
    required this.dueDate,
    required this.action,
    required this.successCriteria,
    required this.asOfDate,
  });

  factory IncomingTalentActivationFollowUpDraft.empty(DateTime asOfDate) {
    return IncomingTalentActivationFollowUpDraft(
      checkpointId: '',
      activationPlanId: '',
      handoffId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      ownerName: '',
      acceptedProgramMilestoneCount: 0,
      roleReadyProgramCompletionCount: 0,
      programCompletionExtensionCount: 0,
      actionType: null,
      dueDate: null,
      action: '',
      successCriteria: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentActivationFollowUpDraft.fromCheckpoint({
    required IncomingTalentActivationCheckpoint checkpoint,
    required DateTime asOfDate,
  }) {
    final actionType = _defaultActionType(checkpoint);
    return IncomingTalentActivationFollowUpDraft(
      checkpointId: checkpoint.id,
      activationPlanId: checkpoint.activationPlanId,
      handoffId: checkpoint.handoffId,
      candidateId: checkpoint.candidateId,
      candidateName: checkpoint.candidateName,
      role: checkpoint.role,
      department: checkpoint.department,
      ownerName: checkpoint.reviewerName,
      acceptedProgramMilestoneCount: checkpoint.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          checkpoint.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          checkpoint.programCompletionExtensionCount,
      actionType: actionType,
      dueDate: _safeDueDate(
        checkpoint.reviewDate.add(Duration(days: checkpoint.isBlocked ? 3 : 7)),
        asOfDate,
      ),
      action: _defaultAction(checkpoint, actionType),
      successCriteria: _defaultSuccessCriteria(checkpoint),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentActivationFollowUpDraft copyWith({
    String? checkpointId,
    String? activationPlanId,
    String? handoffId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? ownerName,
    int? acceptedProgramMilestoneCount,
    int? roleReadyProgramCompletionCount,
    int? programCompletionExtensionCount,
    IncomingTalentActivationFollowUpType? actionType,
    DateTime? dueDate,
    String? action,
    String? successCriteria,
    DateTime? asOfDate,
  }) {
    return IncomingTalentActivationFollowUpDraft(
      checkpointId: checkpointId ?? this.checkpointId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      handoffId: handoffId ?? this.handoffId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      ownerName: ownerName ?? this.ownerName,
      acceptedProgramMilestoneCount:
          acceptedProgramMilestoneCount ?? this.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          roleReadyProgramCompletionCount ??
          this.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          programCompletionExtensionCount ??
          this.programCompletionExtensionCount,
      actionType: actionType ?? this.actionType,
      dueDate: dueDate ?? this.dueDate,
      action: action ?? this.action,
      successCriteria: successCriteria ?? this.successCriteria,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          checkpointId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          actionType != null,
          dueDate != null,
          action.trim().length >= 12,
          successCriteria.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 6;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(checkpointId, 'a checkpoint') case final error?)
        error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateActionType(actionType) case final error?) error,
      if (validateDueDate(dueDate, asOfDate) case final error?) error,
      if (validateAction(action) case final error?) error,
      if (validateSuccessCriteria(successCriteria) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentActivationFollowUpAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentActivationFollowUpAction(
      id: id,
      checkpointId: checkpointId,
      activationPlanId: activationPlanId,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      ownerName: ownerName.trim(),
      acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      actionType: actionType!,
      status: IncomingTalentActivationFollowUpStatus.planned,
      dueDate: dueDate!,
      action: action.trim(),
      successCriteria: successCriteria.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateActionType(
    IncomingTalentActivationFollowUpType? value,
  ) {
    if (value == null) return 'Select a follow-up type';
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
    final requiredError = validateRequired(value, 'a follow-up action');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Follow-up action must be at least 12 characters';
    }
    return null;
  }

  static String? validateSuccessCriteria(String? value) {
    final requiredError = validateRequired(value, 'success criteria');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Success criteria must be at least 12 characters';
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

IncomingTalentActivationFollowUpType _defaultActionType(
  IncomingTalentActivationCheckpoint checkpoint,
) {
  if (checkpoint.programCompletionExtensionCount > 0) {
    return IncomingTalentActivationFollowUpType.learningAdjustment;
  }
  if (checkpoint.isBlocked) {
    return IncomingTalentActivationFollowUpType.managerAlignment;
  }
  if (checkpoint.confidenceScore <= 2) {
    return IncomingTalentActivationFollowUpType.coaching;
  }
  if (checkpoint.confidenceScore == 3) {
    return IncomingTalentActivationFollowUpType.learningAdjustment;
  }
  return IncomingTalentActivationFollowUpType.mentorCapacity;
}

String _defaultAction(
  IncomingTalentActivationCheckpoint checkpoint,
  IncomingTalentActivationFollowUpType actionType,
) {
  if (checkpoint.programCompletionExtensionCount > 0) {
    final decisionLabel =
        checkpoint.programCompletionExtensionCount == 1
            ? 'decision'
            : 'decisions';
    return '${actionType.label}: resolve '
        '${checkpoint.programCompletionExtensionCount} program extension '
        '$decisionLabel before next activation review.';
  }
  final signal =
      checkpoint.blockerNote.trim().isNotEmpty
          ? checkpoint.blockerNote.trim()
          : checkpoint.nextStep.trim();
  return '${actionType.label}: $signal';
}

String _defaultSuccessCriteria(IncomingTalentActivationCheckpoint checkpoint) {
  if (checkpoint.programCompletionExtensionCount > 0) {
    return 'Close program extension decisions and restore activation confidence to 4/5.';
  }
  return 'Restore activation confidence to 4/5 or better before next review.';
}

DateTime _safeDueDate(DateTime dueDate, DateTime asOfDate) {
  if (_dateOnly(dueDate).isBefore(_dateOnly(asOfDate))) return asOfDate;
  return dueDate;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
