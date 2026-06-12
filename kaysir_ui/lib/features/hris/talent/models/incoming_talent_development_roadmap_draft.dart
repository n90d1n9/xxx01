import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_roadmap.dart';
import 'incoming_talent_development_roadmap_defaults.dart';

class IncomingTalentDevelopmentRoadmapDraft {
  final String outcomeReviewId;
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String mentorName;
  final String focusArea;
  final String learningObjective;
  final String firstMilestone;
  final String successMetric;
  final IncomingTalentDevelopmentRoadmapCadence? cadence;
  final IncomingTalentDevelopmentRoadmapStatus? status;
  final DateTime? startDate;
  final DateTime? targetCompletionDate;
  final IncomingTalentActivationOutcomeDecision? sourceDecision;
  final IncomingTalentActivationRetentionRisk? retentionRisk;
  final int readinessScore;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentRoadmapDraft({
    required this.outcomeReviewId,
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.mentorName,
    required this.focusArea,
    required this.learningObjective,
    required this.firstMilestone,
    required this.successMetric,
    required this.cadence,
    required this.status,
    required this.startDate,
    required this.targetCompletionDate,
    required this.sourceDecision,
    required this.retentionRisk,
    required this.readinessScore,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentRoadmapDraft.empty(DateTime asOfDate) {
    return IncomingTalentDevelopmentRoadmapDraft(
      outcomeReviewId: '',
      activationPlanId: '',
      handoffId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      ownerName: '',
      mentorName: '',
      focusArea: '',
      learningObjective: '',
      firstMilestone: '',
      successMetric: '',
      cadence: null,
      status: null,
      startDate: null,
      targetCompletionDate: null,
      sourceDecision: null,
      retentionRisk: null,
      readinessScore: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentRoadmapDraft.fromOutcome({
    required IncomingTalentActivationOutcomeReview review,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentDevelopmentRoadmapDefaults.fromOutcome(
      review,
    );

    return IncomingTalentDevelopmentRoadmapDraft(
      outcomeReviewId: review.id,
      activationPlanId: review.activationPlanId,
      handoffId: review.handoffId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      role: review.role,
      department: review.department,
      ownerName: review.reviewerName,
      mentorName: '${review.department} mentor',
      focusArea: defaults.focusArea,
      learningObjective: defaults.learningObjective,
      firstMilestone: defaults.firstMilestone,
      successMetric: defaults.successMetric,
      cadence: defaults.cadence,
      status: defaults.status,
      startDate: asOfDate,
      targetCompletionDate: asOfDate.add(defaults.duration),
      sourceDecision: review.decision,
      retentionRisk: review.retentionRisk,
      readinessScore: review.readinessScore,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentDevelopmentRoadmapDraft copyWith({
    String? outcomeReviewId,
    String? activationPlanId,
    String? handoffId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? ownerName,
    String? mentorName,
    String? focusArea,
    String? learningObjective,
    String? firstMilestone,
    String? successMetric,
    IncomingTalentDevelopmentRoadmapCadence? cadence,
    IncomingTalentDevelopmentRoadmapStatus? status,
    DateTime? startDate,
    DateTime? targetCompletionDate,
    IncomingTalentActivationOutcomeDecision? sourceDecision,
    IncomingTalentActivationRetentionRisk? retentionRisk,
    int? readinessScore,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentRoadmapDraft(
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      activationPlanId: activationPlanId ?? this.activationPlanId,
      handoffId: handoffId ?? this.handoffId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      ownerName: ownerName ?? this.ownerName,
      mentorName: mentorName ?? this.mentorName,
      focusArea: focusArea ?? this.focusArea,
      learningObjective: learningObjective ?? this.learningObjective,
      firstMilestone: firstMilestone ?? this.firstMilestone,
      successMetric: successMetric ?? this.successMetric,
      cadence: cadence ?? this.cadence,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      sourceDecision: sourceDecision ?? this.sourceDecision,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      readinessScore: readinessScore ?? this.readinessScore,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          outcomeReviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          focusArea.trim().length >= 3,
          learningObjective.trim().length >= 12,
          firstMilestone.trim().length >= 12,
          successMetric.trim().length >= 12,
          cadence != null,
          status != null,
          startDate != null,
          targetCompletionDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(outcomeReviewId, 'an outcome review')
          case final error?)
        error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateRequired(mentorName, 'a mentor') case final error?) error,
      if (validateFocusArea(focusArea) case final error?) error,
      if (validateLearningObjective(learningObjective) case final error?) error,
      if (validateFirstMilestone(firstMilestone) case final error?) error,
      if (validateSuccessMetric(successMetric) case final error?) error,
      if (validateCadence(cadence) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateStartDate(startDate, asOfDate) case final error?) error,
      if (validateTargetCompletionDate(startDate, targetCompletionDate)
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentRoadmap toRoadmap({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentRoadmap(
      id: id,
      outcomeReviewId: outcomeReviewId,
      activationPlanId: activationPlanId,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      ownerName: ownerName.trim(),
      mentorName: mentorName.trim(),
      focusArea: focusArea.trim(),
      learningObjective: learningObjective.trim(),
      firstMilestone: firstMilestone.trim(),
      successMetric: successMetric.trim(),
      cadence: cadence!,
      status: status!,
      startDate: startDate!,
      targetCompletionDate: targetCompletionDate!,
      sourceDecision: sourceDecision!,
      retentionRisk: retentionRisk!,
      readinessScore: readinessScore,
      createdAt: createdAt,
    );
  }

  static String? validateFocusArea(String? value) {
    final requiredError = validateRequired(value, 'a focus area');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 3) return 'Focus area is too short';
    return null;
  }

  static String? validateLearningObjective(String? value) {
    return _validateLongText(value, 'learning objective');
  }

  static String? validateFirstMilestone(String? value) {
    return _validateLongText(value, 'first milestone');
  }

  static String? validateSuccessMetric(String? value) {
    return _validateLongText(value, 'success metric');
  }

  static String? validateCadence(
    IncomingTalentDevelopmentRoadmapCadence? value,
  ) {
    if (value == null) return 'Select a review cadence';
    return null;
  }

  static String? validateStatus(IncomingTalentDevelopmentRoadmapStatus? value) {
    if (value == null) return 'Select roadmap status';
    return null;
  }

  static String? validateStartDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a start date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Start date cannot be in the past';
    }
    return null;
  }

  static String? validateTargetCompletionDate(
    DateTime? startDate,
    DateTime? targetCompletionDate,
  ) {
    if (targetCompletionDate == null) {
      return 'Select a target completion date';
    }
    if (startDate == null) return null;
    if (!_dateOnly(targetCompletionDate).isAfter(_dateOnly(startDate))) {
      return 'Target completion must be after the start date';
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
  final requiredError = IncomingTalentDevelopmentRoadmapDraft.validateRequired(
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
