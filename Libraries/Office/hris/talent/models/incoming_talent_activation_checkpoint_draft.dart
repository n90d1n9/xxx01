import 'incoming_talent_activation_checkpoint.dart';
import 'incoming_talent_activation_plan.dart';

class IncomingTalentActivationCheckpointDraft {
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String managerName;
  final String mentorName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentActivationCheckpointHealth? health;
  final int confidenceScore;
  final String managerFeedback;
  final String blockerNote;
  final String nextStep;
  final DateTime asOfDate;

  const IncomingTalentActivationCheckpointDraft({
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.managerName,
    required this.mentorName,
    required this.acceptedProgramMilestoneCount,
    required this.roleReadyProgramCompletionCount,
    required this.programCompletionExtensionCount,
    required this.reviewerName,
    required this.reviewDate,
    required this.health,
    required this.confidenceScore,
    required this.managerFeedback,
    required this.blockerNote,
    required this.nextStep,
    required this.asOfDate,
  });

  factory IncomingTalentActivationCheckpointDraft.empty(DateTime asOfDate) {
    return IncomingTalentActivationCheckpointDraft(
      activationPlanId: '',
      handoffId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      managerName: '',
      mentorName: '',
      acceptedProgramMilestoneCount: 0,
      roleReadyProgramCompletionCount: 0,
      programCompletionExtensionCount: 0,
      reviewerName: '',
      reviewDate: null,
      health: null,
      confidenceScore: 0,
      managerFeedback: '',
      blockerNote: '',
      nextStep: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentActivationCheckpointDraft.fromPlan({
    required IncomingTalentActivationPlan plan,
    required DateTime asOfDate,
  }) {
    final health = defaultCheckpointHealth(plan);
    return IncomingTalentActivationCheckpointDraft(
      activationPlanId: plan.id,
      handoffId: plan.handoffId,
      candidateId: plan.candidateId,
      candidateName: plan.candidateName,
      role: plan.role,
      department: plan.department,
      managerName: plan.managerName,
      mentorName: plan.mentorName,
      acceptedProgramMilestoneCount: plan.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: plan.roleReadyProgramCompletionCount,
      programCompletionExtensionCount: plan.programCompletionExtensionCount,
      reviewerName: plan.managerName,
      reviewDate: _safeReviewDate(plan.firstCheckpointDate, asOfDate),
      health: health,
      confidenceScore: defaultCheckpointConfidence(plan),
      managerFeedback: plan.successMeasure,
      blockerNote:
          health == IncomingTalentActivationCheckpointHealth.blocked
              ? plan.notes
              : '',
      nextStep: 'Continue ${plan.learningPlanTitle} with ${plan.mentorName}.',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentActivationCheckpointDraft copyWith({
    String? activationPlanId,
    String? handoffId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? managerName,
    String? mentorName,
    int? acceptedProgramMilestoneCount,
    int? roleReadyProgramCompletionCount,
    int? programCompletionExtensionCount,
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentActivationCheckpointHealth? health,
    int? confidenceScore,
    String? managerFeedback,
    String? blockerNote,
    String? nextStep,
    DateTime? asOfDate,
  }) {
    return IncomingTalentActivationCheckpointDraft(
      activationPlanId: activationPlanId ?? this.activationPlanId,
      handoffId: handoffId ?? this.handoffId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      managerName: managerName ?? this.managerName,
      mentorName: mentorName ?? this.mentorName,
      acceptedProgramMilestoneCount:
          acceptedProgramMilestoneCount ?? this.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          roleReadyProgramCompletionCount ??
          this.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          programCompletionExtensionCount ??
          this.programCompletionExtensionCount,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      health: health ?? this.health,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      managerFeedback: managerFeedback ?? this.managerFeedback,
      blockerNote: blockerNote ?? this.blockerNote,
      nextStep: nextStep ?? this.nextStep,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          activationPlanId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          health != null,
          confidenceScore >= 1 && confidenceScore <= 5,
          managerFeedback.trim().length >= 12,
          nextStep.trim().length >= 8,
          !requiresBlockerNote || blockerNote.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 8;
  }

  bool get requiresBlockerNote {
    return health == IncomingTalentActivationCheckpointHealth.blocked ||
        confidenceScore <= 2;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(activationPlanId, 'an activation plan')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateHealth(health) case final error?) error,
      if (validateConfidence(confidenceScore) case final error?) error,
      if (validateManagerFeedback(managerFeedback) case final error?) error,
      if (validateBlockerNote(blockerNote, requiresBlockerNote)
          case final error?)
        error,
      if (validateNextStep(nextStep) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentActivationCheckpoint toCheckpoint({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentActivationCheckpoint(
      id: id,
      activationPlanId: activationPlanId,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      managerName: managerName.trim(),
      mentorName: mentorName.trim(),
      acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      health: health!,
      confidenceScore: confidenceScore,
      managerFeedback: managerFeedback.trim(),
      blockerNote: blockerNote.trim(),
      nextStep: nextStep.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateHealth(
    IncomingTalentActivationCheckpointHealth? health,
  ) {
    if (health == null) return 'Select checkpoint health';
    return null;
  }

  static String? validateConfidence(int value) {
    if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateManagerFeedback(String? value) {
    final requiredError = validateRequired(value, 'manager feedback');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Manager feedback must be at least 12 characters';
    }
    return null;
  }

  static String? validateBlockerNote(String? value, bool required) {
    if (!required) return null;
    final requiredError = validateRequired(value, 'a blocker note');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Blocker note must be at least 12 characters';
    }
    return null;
  }

  static String? validateNextStep(String? value) {
    final requiredError = validateRequired(value, 'a next step');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 8) {
      return 'Next step must be at least 8 characters';
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

DateTime _safeReviewDate(DateTime reviewDate, DateTime asOfDate) {
  if (_dateOnly(reviewDate).isBefore(_dateOnly(asOfDate))) return asOfDate;
  return reviewDate;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
