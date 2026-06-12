import 'candidate_decision_models.dart';
import 'candidate_decision_review_models.dart';
import 'recruitment_models.dart';

class CandidateDecisionReviewDraft {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateDecisionOutcome? outcome;
  final CandidateDecisionRecommendation? recommendation;
  final String ownerName;
  final DateTime? dueDate;
  final String nextStep;
  final String notes;
  final int blockerCount;
  final DateTime asOfDate;

  const CandidateDecisionReviewDraft({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.outcome,
    required this.recommendation,
    required this.ownerName,
    required this.dueDate,
    required this.nextStep,
    required this.notes,
    required this.blockerCount,
    required this.asOfDate,
  });

  factory CandidateDecisionReviewDraft.empty(DateTime asOfDate) {
    return CandidateDecisionReviewDraft(
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      outcome: null,
      recommendation: null,
      ownerName: '',
      dueDate: null,
      nextStep: '',
      notes: '',
      blockerCount: 0,
      asOfDate: asOfDate,
    );
  }

  factory CandidateDecisionReviewDraft.fromPacket({
    required CandidateDecisionPacket packet,
    required DateTime asOfDate,
  }) {
    return CandidateDecisionReviewDraft(
      candidateId: packet.candidateId,
      candidateName: packet.candidateName,
      role: packet.role,
      department: packet.department,
      outcome: _defaultOutcome(packet),
      recommendation: packet.recommendation,
      ownerName: 'Hiring Committee',
      dueDate: packet.decisionDueDate,
      nextStep: packet.nextAction,
      notes: _defaultNotes(packet),
      blockerCount: packet.blockers.length,
      asOfDate: asOfDate,
    );
  }

  CandidateDecisionReviewDraft copyWith({
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    CandidateDecisionOutcome? outcome,
    CandidateDecisionRecommendation? recommendation,
    String? ownerName,
    DateTime? dueDate,
    String? nextStep,
    String? notes,
    int? blockerCount,
    DateTime? asOfDate,
  }) {
    return CandidateDecisionReviewDraft(
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      outcome: outcome ?? this.outcome,
      recommendation: recommendation ?? this.recommendation,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      nextStep: nextStep ?? this.nextStep,
      notes: notes ?? this.notes,
      blockerCount: blockerCount ?? this.blockerCount,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          candidateId.trim().isNotEmpty,
          outcome != null,
          ownerName.trim().isNotEmpty,
          dueDate != null,
          nextStep.trim().length >= 8,
          notes.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 6;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final validations = [
      validateCandidate(candidateId),
      validateOutcome(outcome),
      validateRequired(ownerName, 'a decision owner'),
      validateDueDate(dueDate, asOfDate),
      validateNextStep(nextStep),
      validateNotes(notes),
    ];

    for (final validation in validations) {
      if (validation != null) errors.add(validation);
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  CandidateDecisionReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return CandidateDecisionReview(
      id: id,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      outcome: outcome!,
      recommendation: recommendation!,
      ownerName: ownerName.trim(),
      dueDate: dueDate!,
      nextStep: nextStep.trim(),
      notes: notes.trim(),
      blockerCount: blockerCount,
      createdAt: createdAt,
    );
  }

  static String? validateCandidate(String? value) {
    return validateRequired(value, 'a candidate decision packet');
  }

  static String? validateOutcome(CandidateDecisionOutcome? value) {
    if (value == null) return 'Select a decision outcome';
    return null;
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select a decision due date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Decision due date cannot be in the past';
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

  static String? validateNotes(String? value) {
    final requiredError = validateRequired(value, 'decision notes');
    if (requiredError != null) return requiredError;

    if (value!.trim().length < 12) {
      return 'Decision notes must be at least 12 characters';
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

CandidateDecisionOutcome _defaultOutcome(CandidateDecisionPacket packet) {
  return switch (packet.recommendation) {
    CandidateDecisionRecommendation.approve =>
      packet.stage == CandidateStage.offer
          ? CandidateDecisionOutcome.offerReady
          : CandidateDecisionOutcome.advance,
    CandidateDecisionRecommendation.conditional =>
      CandidateDecisionOutcome.advanceWithConditions,
    CandidateDecisionRecommendation.hold => CandidateDecisionOutcome.hold,
  };
}

String _defaultNotes(CandidateDecisionPacket packet) {
  if (packet.blockers.isNotEmpty) return packet.blockers.join('; ');
  return packet.handoffItems.join('; ');
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
