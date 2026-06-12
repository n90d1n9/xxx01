import 'candidate_development_check_in.dart';
import 'candidate_development_objective.dart';

class CandidateDevelopmentCheckInDraft {
  final String objectiveId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String ownerName;
  final String mentorName;
  final String confidenceText;
  final String progressNote;
  final String blockerNote;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const CandidateDevelopmentCheckInDraft({
    required this.objectiveId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.ownerName,
    required this.mentorName,
    required this.confidenceText,
    required this.progressNote,
    required this.blockerNote,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory CandidateDevelopmentCheckInDraft.empty(DateTime asOfDate) {
    return CandidateDevelopmentCheckInDraft(
      objectiveId: '',
      candidateName: '',
      role: '',
      department: '',
      objectiveTitle: '',
      ownerName: '',
      mentorName: '',
      confidenceText: '3',
      progressNote: '',
      blockerNote: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory CandidateDevelopmentCheckInDraft.fromObjective({
    required CandidateDevelopmentObjective objective,
    required DateTime asOfDate,
  }) {
    return CandidateDevelopmentCheckInDraft(
      objectiveId: objective.id,
      candidateName: objective.candidateName,
      role: objective.role,
      department: objective.department,
      objectiveTitle: objective.objectiveTitle,
      ownerName: objective.ownerName,
      mentorName: objective.mentorName,
      confidenceText:
          objective.status == CandidateDevelopmentObjectiveStatus.active
              ? '4'
              : '3',
      progressNote: 'First checkpoint aligned to ${objective.skillFocus}.',
      blockerNote: '',
      nextReviewDate: asOfDate.add(const Duration(days: 14)),
      asOfDate: asOfDate,
    );
  }

  CandidateDevelopmentCheckInDraft copyWith({
    String? objectiveId,
    String? candidateName,
    String? role,
    String? department,
    String? objectiveTitle,
    String? ownerName,
    String? mentorName,
    String? confidenceText,
    String? progressNote,
    String? blockerNote,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
    bool clearNextReviewDate = false,
  }) {
    return CandidateDevelopmentCheckInDraft(
      objectiveId: objectiveId ?? this.objectiveId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      objectiveTitle: objectiveTitle ?? this.objectiveTitle,
      ownerName: ownerName ?? this.ownerName,
      mentorName: mentorName ?? this.mentorName,
      confidenceText: confidenceText ?? this.confidenceText,
      progressNote: progressNote ?? this.progressNote,
      blockerNote: blockerNote ?? this.blockerNote,
      nextReviewDate:
          clearNextReviewDate ? null : nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  int? get confidenceLevel => int.tryParse(confidenceText.trim());

  CandidateDevelopmentCheckInStatus get status {
    final confidence = confidenceLevel ?? 0;
    if (blockerNote.trim().isNotEmpty || confidence <= 2) {
      return CandidateDevelopmentCheckInStatus.blocked;
    }
    if (confidence == 3) return CandidateDevelopmentCheckInStatus.watch;
    return CandidateDevelopmentCheckInStatus.onTrack;
  }

  double get completionRatio {
    final completed =
        [
          objectiveId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          confidenceLevel != null,
          progressNote.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 6;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(objectiveId, 'an objective') case final error?)
        error,
      if (validateRequired(ownerName, 'an owner') case final error?) error,
      if (validateRequired(mentorName, 'a mentor') case final error?) error,
      if (validateConfidence(confidenceText) case final error?) error,
      if (validateProgressNote(progressNote) case final error?) error,
      if (validateNextReviewDate(nextReviewDate, asOfDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateDevelopmentCheckIn toCheckIn({
    required String id,
    required DateTime createdAt,
  }) {
    if (!isReadyToSubmit) {
      throw StateError('Complete development check-in before saving.');
    }
    return CandidateDevelopmentCheckIn(
      id: id,
      objectiveId: objectiveId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      objectiveTitle: objectiveTitle.trim(),
      ownerName: ownerName.trim(),
      mentorName: mentorName.trim(),
      confidenceLevel: confidenceLevel!,
      progressNote: progressNote.trim(),
      blockerNote: blockerNote.trim(),
      nextReviewDate: nextReviewDate!,
      status: status,
      createdAt: createdAt,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateConfidence(String? value) {
    final confidence = int.tryParse(value?.trim() ?? '');
    if (confidence == null || confidence < 1 || confidence > 5) {
      return 'Select confidence from 1 to 5';
    }
    return null;
  }

  static String? validateProgressNote(String? value) {
    final requiredError = validateRequired(value, 'a progress note');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 12) {
      return 'Progress note must be at least 12 characters';
    }
    return null;
  }

  static String? validateNextReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Please select a next review date';

    final review = DateTime(value.year, value.month, value.day);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    if (review.isBefore(today)) {
      return 'Next review date cannot be in the past';
    }
    return null;
  }
}
