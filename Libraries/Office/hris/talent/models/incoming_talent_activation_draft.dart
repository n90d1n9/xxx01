import 'incoming_talent_activation_plan.dart';
import 'incoming_talent_readiness.dart';

class IncomingTalentActivationDraft {
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String managerName;
  final IncomingTalentReadinessStatus? readinessStatus;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final String mentorName;
  final String learningPlanTitle;
  final String activationOwner;
  final DateTime? kickoffDate;
  final DateTime? firstCheckpointDate;
  final String successMeasure;
  final String notes;
  final DateTime asOfDate;

  const IncomingTalentActivationDraft({
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.managerName,
    required this.readinessStatus,
    required this.acceptedProgramMilestoneCount,
    required this.roleReadyProgramCompletionCount,
    required this.programCompletionExtensionCount,
    required this.mentorName,
    required this.learningPlanTitle,
    required this.activationOwner,
    required this.kickoffDate,
    required this.firstCheckpointDate,
    required this.successMeasure,
    required this.notes,
    required this.asOfDate,
  });

  factory IncomingTalentActivationDraft.empty(DateTime asOfDate) {
    return IncomingTalentActivationDraft(
      handoffId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      managerName: '',
      readinessStatus: null,
      acceptedProgramMilestoneCount: 0,
      roleReadyProgramCompletionCount: 0,
      programCompletionExtensionCount: 0,
      mentorName: '',
      learningPlanTitle: '',
      activationOwner: '',
      kickoffDate: null,
      firstCheckpointDate: null,
      successMeasure: '',
      notes: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentActivationDraft.fromReadiness({
    required IncomingTalentReadiness readiness,
    required DateTime asOfDate,
  }) {
    return IncomingTalentActivationDraft(
      handoffId: readiness.handoffId,
      candidateId: readiness.candidateId,
      candidateName: readiness.candidateName,
      role: readiness.role,
      department: readiness.department,
      managerName: readiness.managerName,
      readinessStatus: readiness.status,
      acceptedProgramMilestoneCount: readiness.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          readiness.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          readiness.programCompletionExtensionCount,
      mentorName: '${readiness.department} mentor',
      learningPlanTitle: '${readiness.role} first 30-day learning path',
      activationOwner: readiness.ownerName,
      kickoffDate: readiness.targetStartDate,
      firstCheckpointDate: readiness.firstCheckpointDate,
      successMeasure:
          'Confirm ${readiness.role} ramp readiness with '
          '${readiness.managerName}.',
      notes: readiness.talentFocus,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentActivationDraft copyWith({
    String? handoffId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? managerName,
    IncomingTalentReadinessStatus? readinessStatus,
    int? acceptedProgramMilestoneCount,
    int? roleReadyProgramCompletionCount,
    int? programCompletionExtensionCount,
    String? mentorName,
    String? learningPlanTitle,
    String? activationOwner,
    DateTime? kickoffDate,
    DateTime? firstCheckpointDate,
    String? successMeasure,
    String? notes,
    DateTime? asOfDate,
  }) {
    return IncomingTalentActivationDraft(
      handoffId: handoffId ?? this.handoffId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      managerName: managerName ?? this.managerName,
      readinessStatus: readinessStatus ?? this.readinessStatus,
      acceptedProgramMilestoneCount:
          acceptedProgramMilestoneCount ?? this.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          roleReadyProgramCompletionCount ??
          this.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          programCompletionExtensionCount ??
          this.programCompletionExtensionCount,
      mentorName: mentorName ?? this.mentorName,
      learningPlanTitle: learningPlanTitle ?? this.learningPlanTitle,
      activationOwner: activationOwner ?? this.activationOwner,
      kickoffDate: kickoffDate ?? this.kickoffDate,
      firstCheckpointDate: firstCheckpointDate ?? this.firstCheckpointDate,
      successMeasure: successMeasure ?? this.successMeasure,
      notes: notes ?? this.notes,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          handoffId.trim().isNotEmpty,
          readinessStatus == IncomingTalentReadinessStatus.ready,
          programCompletionExtensionCount == 0,
          mentorName.trim().isNotEmpty,
          learningPlanTitle.trim().isNotEmpty,
          activationOwner.trim().isNotEmpty,
          kickoffDate != null,
          firstCheckpointDate != null,
          successMeasure.trim().length >= 12,
          notes.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(handoffId, 'an incoming handoff') case final error?)
        error,
      if (validateReadinessStatus(readinessStatus) case final error?) error,
      if (validateProgramCompletionExtensions(programCompletionExtensionCount)
          case final error?)
        error,
      if (validateRequired(mentorName, 'a mentor') case final error?) error,
      if (validateRequired(learningPlanTitle, 'a learning plan')
          case final error?)
        error,
      if (validateRequired(activationOwner, 'an activation owner')
          case final error?)
        error,
      if (validateKickoffDate(kickoffDate, asOfDate) case final error?) error,
      if (validateFirstCheckpointDate(firstCheckpointDate, kickoffDate)
          case final error?)
        error,
      if (validateSuccessMeasure(successMeasure) case final error?) error,
      if (validateNotes(notes) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentActivationPlan toPlan({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentActivationPlan(
      id: id,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      managerName: managerName.trim(),
      acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      mentorName: mentorName.trim(),
      learningPlanTitle: learningPlanTitle.trim(),
      activationOwner: activationOwner.trim(),
      kickoffDate: kickoffDate!,
      firstCheckpointDate: firstCheckpointDate!,
      successMeasure: successMeasure.trim(),
      notes: notes.trim(),
      status: IncomingTalentActivationStatus.planned,
      createdAt: createdAt,
    );
  }

  static String? validateReadinessStatus(
    IncomingTalentReadinessStatus? status,
  ) {
    if (status == IncomingTalentReadinessStatus.ready) return null;
    return 'Incoming handoff must be ready before activation';
  }

  static String? validateProgramCompletionExtensions(int count) {
    if (count <= 0) return null;
    return 'Resolve program extension decisions before activation';
  }

  static String? validateKickoffDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select a kickoff date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Kickoff date cannot be in the past';
    }
    return null;
  }

  static String? validateFirstCheckpointDate(
    DateTime? firstCheckpointDate,
    DateTime? kickoffDate,
  ) {
    if (firstCheckpointDate == null) {
      return 'Please select a first checkpoint date';
    }
    if (kickoffDate == null) return null;
    if (_dateOnly(firstCheckpointDate).isBefore(_dateOnly(kickoffDate))) {
      return 'First checkpoint cannot be before kickoff';
    }
    return null;
  }

  static String? validateSuccessMeasure(String? value) {
    final requiredError = validateRequired(value, 'a success measure');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Success measure must be at least 12 characters';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    final requiredError = validateRequired(value, 'activation notes');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Activation notes must be at least 12 characters';
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
