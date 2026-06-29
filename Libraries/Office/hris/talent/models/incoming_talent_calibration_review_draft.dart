import 'incoming_talent_calibration_packet.dart';
import 'incoming_talent_calibration_review.dart';

class IncomingTalentCalibrationReviewDraft {
  final String packetId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentCalibrationDecision? decision;
  final IncomingTalentCalibrationPotential? potential;
  final String talentTrack;
  final String evidenceSummary;
  final String decisionNote;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentCalibrationReviewDraft({
    required this.packetId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.potential,
    required this.talentTrack,
    required this.evidenceSummary,
    required this.decisionNote,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentCalibrationReviewDraft.empty(DateTime asOfDate) {
    return IncomingTalentCalibrationReviewDraft(
      packetId: '',
      outcomeReviewId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      reviewerName: '',
      reviewDate: null,
      decision: null,
      potential: null,
      talentTrack: '',
      evidenceSummary: '',
      decisionNote: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentCalibrationReviewDraft.fromPacket({
    required IncomingTalentCalibrationPacket packet,
    required DateTime asOfDate,
  }) {
    return IncomingTalentCalibrationReviewDraft(
      packetId: packet.id,
      outcomeReviewId: packet.outcomeReviewId,
      candidateId: packet.candidateId,
      candidateName: packet.candidateName,
      role: packet.role,
      department: packet.department,
      reviewerName: '${packet.department} People Partner',
      reviewDate: asOfDate,
      decision: _decisionFromRecommendation(packet.recommendation),
      potential: packet.potential,
      talentTrack: _trackFromPacket(packet),
      evidenceSummary: packet.evidenceSummary,
      decisionNote: _decisionNoteFromPacket(packet),
      nextReviewDate: packet.reviewDueDate,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentCalibrationReviewDraft copyWith({
    String? packetId,
    String? outcomeReviewId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentCalibrationDecision? decision,
    IncomingTalentCalibrationPotential? potential,
    String? talentTrack,
    String? evidenceSummary,
    String? decisionNote,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentCalibrationReviewDraft(
      packetId: packetId ?? this.packetId,
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      decision: decision ?? this.decision,
      potential: potential ?? this.potential,
      talentTrack: talentTrack ?? this.talentTrack,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      decisionNote: decisionNote ?? this.decisionNote,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          packetId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          decision != null,
          potential != null,
          talentTrack.trim().length >= 8,
          evidenceSummary.trim().length >= 12,
          decisionNote.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;
    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(packetId, 'a calibration packet') case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateDecision(decision) case final error?) error,
      if (validatePotential(potential) case final error?) error,
      if (validateTalentTrack(talentTrack) case final error?) error,
      if (validateEvidenceSummary(evidenceSummary) case final error?) error,
      if (validateDecisionNote(decisionNote) case final error?) error,
      if (validateNextReviewDate(reviewDate, nextReviewDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentCalibrationReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentCalibrationReview(
      id: id,
      packetId: packetId,
      outcomeReviewId: outcomeReviewId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      decision: decision!,
      potential: potential!,
      talentTrack: talentTrack.trim(),
      evidenceSummary: evidenceSummary.trim(),
      decisionNote: decisionNote.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }

  static String? validateDecision(IncomingTalentCalibrationDecision? value) {
    if (value == null) return 'Select a calibration decision';
    return null;
  }

  static String? validatePotential(IncomingTalentCalibrationPotential? value) {
    if (value == null) return 'Select talent potential';
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Review date cannot be in the past';
    }
    return null;
  }

  static String? validateNextReviewDate(
    DateTime? reviewDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select the next review date';
    if (reviewDate == null) return null;
    if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
      return 'Next review must be after the review date';
    }
    return null;
  }

  static String? validateTalentTrack(String? value) {
    return _validateLongText(value, 'talent track');
  }

  static String? validateEvidenceSummary(String? value) {
    return _validateLongText(value, 'evidence summary');
  }

  static String? validateDecisionNote(String? value) {
    return _validateLongText(value, 'decision note');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

IncomingTalentCalibrationDecision _decisionFromRecommendation(
  IncomingTalentCalibrationRecommendation recommendation,
) {
  return switch (recommendation) {
    IncomingTalentCalibrationRecommendation.accelerate =>
      IncomingTalentCalibrationDecision.accelerateGrowth,
    IncomingTalentCalibrationRecommendation.maintainCadence =>
      IncomingTalentCalibrationDecision.maintainTrack,
    IncomingTalentCalibrationRecommendation.coach =>
      IncomingTalentCalibrationDecision.coachingPlan,
    IncomingTalentCalibrationRecommendation.escalate =>
      IncomingTalentCalibrationDecision.retentionEscalation,
  };
}

String _trackFromPacket(IncomingTalentCalibrationPacket packet) {
  return switch (packet.recommendation) {
    IncomingTalentCalibrationRecommendation.accelerate =>
      '${packet.role} acceleration track',
    IncomingTalentCalibrationRecommendation.maintainCadence =>
      '${packet.role} performance cadence',
    IncomingTalentCalibrationRecommendation.coach =>
      '${packet.role} coaching track',
    IncomingTalentCalibrationRecommendation.escalate =>
      '${packet.role} retention recovery track',
  };
}

String _decisionNoteFromPacket(IncomingTalentCalibrationPacket packet) {
  return 'Calibrate ${packet.candidateName} as ${packet.potential.label.toLowerCase()} with ${packet.recommendation.label.toLowerCase()} recommendation.';
}

String? _validateLongText(String? value, String label) {
  final requiredError = IncomingTalentCalibrationReviewDraft.validateRequired(
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
