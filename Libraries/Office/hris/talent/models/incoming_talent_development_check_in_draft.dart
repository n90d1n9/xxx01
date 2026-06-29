import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_check_in.dart';
import 'incoming_talent_development_check_in_defaults.dart';
import 'incoming_talent_development_roadmap_models.dart';

class IncomingTalentDevelopmentCheckInDraft {
  final String roadmapId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final DateTime? checkInDate;
  final IncomingTalentDevelopmentCheckInTrend? trend;
  final int confidenceScore;
  final String blockerNote;
  final String nextAction;
  final String managerCommitment;
  final DateTime? nextReviewDate;
  final IncomingTalentDevelopmentRoadmapStatus? roadmapStatus;
  final IncomingTalentActivationRetentionRisk? retentionRisk;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentCheckInDraft({
    required this.roadmapId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.checkInDate,
    required this.trend,
    required this.confidenceScore,
    required this.blockerNote,
    required this.nextAction,
    required this.managerCommitment,
    required this.nextReviewDate,
    required this.roadmapStatus,
    required this.retentionRisk,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentCheckInDraft.empty(DateTime asOfDate) {
    return IncomingTalentDevelopmentCheckInDraft(
      roadmapId: '',
      outcomeReviewId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      reviewerName: '',
      checkInDate: null,
      trend: null,
      confidenceScore: 0,
      blockerNote: '',
      nextAction: '',
      managerCommitment: '',
      nextReviewDate: null,
      roadmapStatus: null,
      retentionRisk: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentCheckInDraft.fromRoadmap({
    required IncomingTalentDevelopmentRoadmap roadmap,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentDevelopmentCheckInDefaults.fromRoadmap(
      roadmap,
    );

    return IncomingTalentDevelopmentCheckInDraft(
      roadmapId: roadmap.id,
      outcomeReviewId: roadmap.outcomeReviewId,
      candidateId: roadmap.candidateId,
      candidateName: roadmap.candidateName,
      role: roadmap.role,
      department: roadmap.department,
      reviewerName: roadmap.ownerName,
      checkInDate: asOfDate,
      trend: defaults.trend,
      confidenceScore: defaults.confidenceScore,
      blockerNote: defaults.blockerNote,
      nextAction: defaults.nextAction,
      managerCommitment: defaults.managerCommitment,
      nextReviewDate: asOfDate.add(defaults.nextReviewInterval),
      roadmapStatus: roadmap.status,
      retentionRisk: roadmap.retentionRisk,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentDevelopmentCheckInDraft copyWith({
    String? roadmapId,
    String? outcomeReviewId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? reviewerName,
    DateTime? checkInDate,
    IncomingTalentDevelopmentCheckInTrend? trend,
    int? confidenceScore,
    String? blockerNote,
    String? nextAction,
    String? managerCommitment,
    DateTime? nextReviewDate,
    IncomingTalentDevelopmentRoadmapStatus? roadmapStatus,
    IncomingTalentActivationRetentionRisk? retentionRisk,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentCheckInDraft(
      roadmapId: roadmapId ?? this.roadmapId,
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      reviewerName: reviewerName ?? this.reviewerName,
      checkInDate: checkInDate ?? this.checkInDate,
      trend: trend ?? this.trend,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      blockerNote: blockerNote ?? this.blockerNote,
      nextAction: nextAction ?? this.nextAction,
      managerCommitment: managerCommitment ?? this.managerCommitment,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      roadmapStatus: roadmapStatus ?? this.roadmapStatus,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          roadmapId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          checkInDate != null,
          trend != null,
          confidenceScore >= 1 && confidenceScore <= 5,
          validateBlockerNote(blockerNote, trend) == null,
          nextAction.trim().length >= 12,
          managerCommitment.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(roadmapId, 'a development roadmap')
          case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateCheckInDate(checkInDate, asOfDate) case final error?) error,
      if (validateTrend(trend) case final error?) error,
      if (validateConfidenceScore(confidenceScore) case final error?) error,
      if (validateBlockerNote(blockerNote, trend) case final error?) error,
      if (validateNextAction(nextAction) case final error?) error,
      if (validateManagerCommitment(managerCommitment) case final error?) error,
      if (validateNextReviewDate(checkInDate, nextReviewDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentCheckIn toCheckIn({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentCheckIn(
      id: id,
      roadmapId: roadmapId,
      outcomeReviewId: outcomeReviewId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      reviewerName: reviewerName.trim(),
      checkInDate: checkInDate!,
      trend: trend!,
      confidenceScore: confidenceScore,
      blockerNote: blockerNote.trim(),
      nextAction: nextAction.trim(),
      managerCommitment: managerCommitment.trim(),
      nextReviewDate: nextReviewDate!,
      roadmapStatus: roadmapStatus!,
      retentionRisk: retentionRisk!,
      createdAt: createdAt,
    );
  }

  static String? validateTrend(IncomingTalentDevelopmentCheckInTrend? value) {
    if (value == null) return 'Select a progress trend';
    return null;
  }

  static String? validateCheckInDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a check-in date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Check-in date cannot be in the past';
    }
    return null;
  }

  static String? validateConfidenceScore(int value) {
    if (value < 1 || value > 5) {
      return 'Confidence score must be between 1 and 5';
    }
    return null;
  }

  static String? validateBlockerNote(
    String? value,
    IncomingTalentDevelopmentCheckInTrend? trend,
  ) {
    if (trend != IncomingTalentDevelopmentCheckInTrend.blocked) return null;
    final requiredError = validateRequired(value, 'blocker notes');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Blocker notes must be at least 12 characters';
    }
    return null;
  }

  static String? validateNextAction(String? value) {
    return _validateLongText(value, 'next action');
  }

  static String? validateManagerCommitment(String? value) {
    return _validateLongText(value, 'manager commitment');
  }

  static String? validateNextReviewDate(
    DateTime? checkInDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select a next review date';
    if (checkInDate == null) return null;
    if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(checkInDate))) {
      return 'Next review must be after the check-in date';
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
  final requiredError = IncomingTalentDevelopmentCheckInDraft.validateRequired(
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
