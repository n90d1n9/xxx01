import 'candidate_development_calibration_models.dart';
import 'candidate_talent_handoff.dart';
import 'candidate_talent_handoff_defaults.dart';

class CandidateTalentHandoffDraft {
  final String calibrationReviewId;
  final String objectiveId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateTalentHandoffType? type;
  final CandidateTalentHandoffStatus? status;
  final int readinessScore;
  final String ownerName;
  final String receivingManagerName;
  final DateTime? targetStartDate;
  final DateTime? firstCheckpointDate;
  final String talentFocus;
  final String handoffNote;
  final DateTime asOfDate;

  const CandidateTalentHandoffDraft({
    required this.calibrationReviewId,
    required this.objectiveId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.type,
    required this.status,
    required this.readinessScore,
    required this.ownerName,
    required this.receivingManagerName,
    required this.targetStartDate,
    required this.firstCheckpointDate,
    required this.talentFocus,
    required this.handoffNote,
    required this.asOfDate,
  });

  factory CandidateTalentHandoffDraft.empty(DateTime asOfDate) {
    return CandidateTalentHandoffDraft(
      calibrationReviewId: '',
      objectiveId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      type: null,
      status: null,
      readinessScore: 0,
      ownerName: '',
      receivingManagerName: '',
      targetStartDate: null,
      firstCheckpointDate: null,
      talentFocus: '',
      handoffNote: '',
      asOfDate: asOfDate,
    );
  }

  factory CandidateTalentHandoffDraft.fromCalibrationReview({
    required CandidateDevelopmentCalibrationReview review,
    required DateTime asOfDate,
  }) {
    final targetStartDate = asOfDate.add(
      CandidateTalentHandoffDefaults.targetOffset(review.outcome),
    );
    return CandidateTalentHandoffDraft(
      calibrationReviewId: review.id,
      objectiveId: review.objectiveId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      role: review.role,
      department: review.department,
      type: CandidateTalentHandoffDefaults.typeFromOutcome(review.outcome),
      status: CandidateTalentHandoffDefaults.statusFromReview(review),
      readinessScore: review.readinessScore,
      ownerName: review.ownerName,
      receivingManagerName: CandidateTalentHandoffDefaults.managerForDepartment(
        review.department,
      ),
      targetStartDate: targetStartDate,
      firstCheckpointDate: targetStartDate.add(const Duration(days: 14)),
      talentFocus: review.nextAction,
      handoffNote: review.note,
      asOfDate: asOfDate,
    );
  }

  CandidateTalentHandoffDraft copyWith({
    String? calibrationReviewId,
    String? objectiveId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    CandidateTalentHandoffType? type,
    CandidateTalentHandoffStatus? status,
    int? readinessScore,
    String? ownerName,
    String? receivingManagerName,
    DateTime? targetStartDate,
    DateTime? firstCheckpointDate,
    String? talentFocus,
    String? handoffNote,
    DateTime? asOfDate,
  }) {
    return CandidateTalentHandoffDraft(
      calibrationReviewId: calibrationReviewId ?? this.calibrationReviewId,
      objectiveId: objectiveId ?? this.objectiveId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      type: type ?? this.type,
      status: status ?? this.status,
      readinessScore: readinessScore ?? this.readinessScore,
      ownerName: ownerName ?? this.ownerName,
      receivingManagerName: receivingManagerName ?? this.receivingManagerName,
      targetStartDate: targetStartDate ?? this.targetStartDate,
      firstCheckpointDate: firstCheckpointDate ?? this.firstCheckpointDate,
      talentFocus: talentFocus ?? this.talentFocus,
      handoffNote: handoffNote ?? this.handoffNote,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          calibrationReviewId.trim().isNotEmpty,
          type != null,
          status != null,
          ownerName.trim().isNotEmpty,
          receivingManagerName.trim().isNotEmpty,
          targetStartDate != null,
          firstCheckpointDate != null,
          talentFocus.trim().length >= 8,
          handoffNote.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(calibrationReviewId, 'a calibration review')
          case final error?)
        error,
      if (validateType(type) case final error?) error,
      if (validateStatus(status) case final error?) error,
      if (validateRequired(ownerName, 'a handoff owner') case final error?)
        error,
      if (validateRequired(receivingManagerName, 'a receiving manager')
          case final error?)
        error,
      if (validateTargetStartDate(targetStartDate, asOfDate) case final error?)
        error,
      if (validateFirstCheckpointDate(
            firstCheckpointDate,
            targetStartDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateTalentFocus(talentFocus) case final error?) error,
      if (validateHandoffNote(handoffNote) case final error?) error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateTalentHandoff toHandoff({
    required String id,
    required DateTime createdAt,
  }) {
    return CandidateTalentHandoff(
      id: id,
      calibrationReviewId: calibrationReviewId,
      objectiveId: objectiveId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      type: type!,
      status: status!,
      readinessScore: readinessScore,
      ownerName: ownerName.trim(),
      receivingManagerName: receivingManagerName.trim(),
      targetStartDate: targetStartDate!,
      firstCheckpointDate: firstCheckpointDate!,
      talentFocus: talentFocus.trim(),
      handoffNote: handoffNote.trim(),
      createdAt: createdAt,
    );
  }

  static String? validateType(CandidateTalentHandoffType? value) {
    if (value == null) return 'Select a handoff type';
    return null;
  }

  static String? validateStatus(CandidateTalentHandoffStatus? value) {
    if (value == null) return 'Select a handoff status';
    return null;
  }

  static String? validateTargetStartDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a target start date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Target start date cannot be in the past';
    }
    return null;
  }

  static String? validateFirstCheckpointDate(
    DateTime? value,
    DateTime? targetStartDate,
    DateTime asOfDate,
  ) {
    if (value == null) return 'Select a first checkpoint date';
    final firstAllowed = targetStartDate ?? asOfDate;
    if (_dateOnly(value).isBefore(_dateOnly(firstAllowed))) {
      return 'First checkpoint cannot be before target start';
    }
    return null;
  }

  static String? validateTalentFocus(String? value) {
    final requiredError = validateRequired(value, 'a talent focus');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 8) {
      return 'Talent focus must be at least 8 characters';
    }
    return null;
  }

  static String? validateHandoffNote(String? value) {
    final requiredError = validateRequired(value, 'handoff notes');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Handoff notes must be at least 12 characters';
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
