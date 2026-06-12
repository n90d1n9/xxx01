import 'candidate_development_calibration_profile.dart';
import 'candidate_development_calibration_review.dart';

class CandidateDevelopmentCalibrationDraft {
  final String objectiveId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateDevelopmentCalibrationStatus? status;
  final CandidateDevelopmentCalibrationOutcome? outcome;
  final int readinessScore;
  final String ownerName;
  final DateTime? reviewDate;
  final String note;
  final String nextAction;
  final DateTime asOfDate;

  const CandidateDevelopmentCalibrationDraft({
    required this.objectiveId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.status,
    required this.outcome,
    required this.readinessScore,
    required this.ownerName,
    required this.reviewDate,
    required this.note,
    required this.nextAction,
    required this.asOfDate,
  });

  factory CandidateDevelopmentCalibrationDraft.empty(DateTime asOfDate) {
    return CandidateDevelopmentCalibrationDraft(
      objectiveId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      status: null,
      outcome: null,
      readinessScore: 0,
      ownerName: '',
      reviewDate: null,
      note: '',
      nextAction: '',
      asOfDate: asOfDate,
    );
  }

  factory CandidateDevelopmentCalibrationDraft.fromProfile({
    required CandidateDevelopmentCalibrationProfile profile,
    required DateTime asOfDate,
  }) {
    return CandidateDevelopmentCalibrationDraft(
      objectiveId: profile.objectiveId,
      candidateId: profile.candidateId,
      candidateName: profile.candidateName,
      role: profile.role,
      department: profile.department,
      status: profile.status,
      outcome: _defaultOutcome(profile.status),
      readinessScore: profile.readinessScore,
      ownerName: profile.ownerName,
      reviewDate: asOfDate.add(const Duration(days: 7)),
      note: profile.nextAction,
      nextAction: profile.nextAction,
      asOfDate: asOfDate,
    );
  }

  CandidateDevelopmentCalibrationDraft copyWith({
    String? objectiveId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    CandidateDevelopmentCalibrationStatus? status,
    CandidateDevelopmentCalibrationOutcome? outcome,
    int? readinessScore,
    String? ownerName,
    DateTime? reviewDate,
    String? note,
    String? nextAction,
    DateTime? asOfDate,
  }) {
    return CandidateDevelopmentCalibrationDraft(
      objectiveId: objectiveId ?? this.objectiveId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      status: status ?? this.status,
      outcome: outcome ?? this.outcome,
      readinessScore: readinessScore ?? this.readinessScore,
      ownerName: ownerName ?? this.ownerName,
      reviewDate: reviewDate ?? this.reviewDate,
      note: note ?? this.note,
      nextAction: nextAction ?? this.nextAction,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          objectiveId.trim().isNotEmpty,
          status != null,
          outcome != null,
          ownerName.trim().isNotEmpty,
          reviewDate != null,
          note.trim().length >= 12,
          nextAction.trim().length >= 8,
        ].where((item) => item).length;

    return completed / 7;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(objectiveId, 'a calibration profile')
          case final error?)
        error,
      if (validateStatus(status) case final error?) error,
      if (validateOutcome(outcome) case final error?) error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateNote(note) case final error?) error,
      if (validateNextAction(nextAction) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateDevelopmentCalibrationReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return CandidateDevelopmentCalibrationReview(
      id: id,
      objectiveId: objectiveId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      status: status!,
      outcome: outcome!,
      readinessScore: readinessScore,
      ownerName: ownerName.trim(),
      reviewDate: reviewDate!,
      note: note.trim(),
      nextAction: nextAction.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateStatus(CandidateDevelopmentCalibrationStatus? value) {
    if (value == null) return 'Select a calibration status';
    return null;
  }

  static String? validateOutcome(
    CandidateDevelopmentCalibrationOutcome? value,
  ) {
    if (value == null) return 'Select a calibration outcome';
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateNote(String? value) {
    final requiredError = validateRequired(value, 'calibration notes');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Calibration notes must be at least 12 characters';
    }
    return null;
  }

  static String? validateNextAction(String? value) {
    final requiredError = validateRequired(value, 'a next action');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 8) {
      return 'Next action must be at least 8 characters';
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

CandidateDevelopmentCalibrationOutcome _defaultOutcome(
  CandidateDevelopmentCalibrationStatus status,
) {
  return switch (status) {
    CandidateDevelopmentCalibrationStatus.ready =>
      CandidateDevelopmentCalibrationOutcome.confirmReady,
    CandidateDevelopmentCalibrationStatus.monitor =>
      CandidateDevelopmentCalibrationOutcome.continuePlan,
    CandidateDevelopmentCalibrationStatus.blocked =>
      CandidateDevelopmentCalibrationOutcome.escalate,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
