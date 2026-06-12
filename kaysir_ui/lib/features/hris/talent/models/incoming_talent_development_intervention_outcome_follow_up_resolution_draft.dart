import 'incoming_talent_development_intervention_outcome_follow_up.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution.dart';
import 'incoming_talent_development_intervention_outcome_models.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft {
  final String followUpId;
  final String outcomeId;
  final String interventionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String reviewerName;
  final DateTime? followUpDueDate;
  final DateTime? reviewDate;
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus?
  sourceStatus;
  final IncomingTalentDevelopmentInterventionOutcomeDecision? sourceDecision;
  final int confidenceBefore;
  final int confidenceAfter;
  final int remainingReleaseRiskCount;
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision?
  decision;
  final String evidenceSummary;
  final String managerNote;
  final String nextAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft({
    required this.followUpId,
    required this.outcomeId,
    required this.interventionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.reviewerName,
    required this.followUpDueDate,
    required this.reviewDate,
    required this.sourceStatus,
    required this.sourceDecision,
    required this.confidenceBefore,
    required this.confidenceAfter,
    required this.remainingReleaseRiskCount,
    required this.decision,
    required this.evidenceSummary,
    required this.managerNote,
    required this.nextAction,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft(
      followUpId: '',
      outcomeId: '',
      interventionId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      ownerName: '',
      reviewerName: '',
      followUpDueDate: null,
      reviewDate: null,
      sourceStatus: null,
      sourceDecision: null,
      confidenceBefore: 0,
      confidenceAfter: 0,
      remainingReleaseRiskCount: 0,
      decision: null,
      evidenceSummary: '',
      managerNote: '',
      nextAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.fromFollowUp({
    required IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
    required DateTime asOfDate,
  }) {
    final remainingReleaseRiskCount = _defaultRemainingReleaseRiskCount(
      followUp,
    );
    final confidenceAfter = _defaultConfidenceAfter(followUp);
    final decision = _defaultDecision(
      followUp: followUp,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
    );

    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft(
      followUpId: followUp.id,
      outcomeId: followUp.outcomeId,
      interventionId: followUp.interventionId,
      candidateId: followUp.candidateId,
      candidateName: followUp.candidateName,
      role: followUp.role,
      department: followUp.department,
      ownerName: followUp.ownerName,
      reviewerName:
          followUp.reviewerName.isEmpty
              ? followUp.ownerName
              : followUp.reviewerName,
      followUpDueDate: followUp.dueDate,
      reviewDate: asOfDate,
      sourceStatus: followUp.status,
      sourceDecision: followUp.sourceDecision,
      confidenceBefore: followUp.confidenceAfter,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
      decision: decision,
      evidenceSummary: _defaultEvidenceSummary(followUp),
      managerNote: _defaultManagerNote(followUp),
      nextAction:
          defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextAction(
            decision,
          ),
      nextReviewDate:
          defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextReviewDate(
            decision: decision,
            reviewDate: asOfDate,
          ),
      asOfDate: asOfDate,
    );
  }

  double get completionRatio {
    final checks =
        [
          followUpId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          sourceStatus ==
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                      .completed ||
              sourceStatus ==
                  IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                      .escalated,
          reviewDate != null,
          decision != null,
          validateConfidenceAfter(confidenceAfter) == null,
          evidenceSummary.trim().length >= 12,
          managerNote.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return checks / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateRequired(followUpId, 'a closed follow-up') case final error?)
        error,
      if (validateRequired(reviewerName, 'a reviewer') case final error?) error,
      if (validateSourceStatus(sourceStatus) case final error?) error,
      if (validateReviewDate(reviewDate, asOfDate) case final error?) error,
      if (validateDecision(decision) case final error?) error,
      if (validateConfidenceAfter(confidenceAfter) case final error?) error,
      if (validateEvidenceSummary(evidenceSummary) case final error?) error,
      if (validateManagerNote(managerNote) case final error?) error,
      if (validateNextAction(nextAction) case final error?) error,
      if (validateNextReviewDate(reviewDate, nextReviewDate) case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft copyWith({
    String? followUpId,
    String? outcomeId,
    String? interventionId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? ownerName,
    String? reviewerName,
    DateTime? followUpDueDate,
    DateTime? reviewDate,
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus? sourceStatus,
    IncomingTalentDevelopmentInterventionOutcomeDecision? sourceDecision,
    int? confidenceBefore,
    int? confidenceAfter,
    int? remainingReleaseRiskCount,
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision?
    decision,
    String? evidenceSummary,
    String? managerNote,
    String? nextAction,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft(
      followUpId: followUpId ?? this.followUpId,
      outcomeId: outcomeId ?? this.outcomeId,
      interventionId: interventionId ?? this.interventionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      ownerName: ownerName ?? this.ownerName,
      reviewerName: reviewerName ?? this.reviewerName,
      followUpDueDate: followUpDueDate ?? this.followUpDueDate,
      reviewDate: reviewDate ?? this.reviewDate,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      sourceDecision: sourceDecision ?? this.sourceDecision,
      confidenceBefore: confidenceBefore ?? this.confidenceBefore,
      confidenceAfter: confidenceAfter ?? this.confidenceAfter,
      remainingReleaseRiskCount:
          remainingReleaseRiskCount ?? this.remainingReleaseRiskCount,
      decision: decision ?? this.decision,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      managerNote: managerNote ?? this.managerNote,
      nextAction: nextAction ?? this.nextAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution toResolution({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution(
      id: id,
      followUpId: followUpId,
      outcomeId: outcomeId,
      interventionId: interventionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      ownerName: ownerName.trim(),
      reviewerName: reviewerName.trim(),
      followUpDueDate: followUpDueDate!,
      reviewDate: reviewDate!,
      sourceStatus: sourceStatus!,
      sourceDecision: sourceDecision!,
      confidenceBefore: confidenceBefore,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
      decision: decision!,
      evidenceSummary: evidenceSummary.trim(),
      managerNote: managerNote.trim(),
      nextAction: nextAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }

  static String? validateSourceStatus(
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus? value,
  ) {
    if (value == null) return 'Select a closed follow-up';
    if (value !=
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .completed &&
        value !=
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .escalated) {
      return 'Follow-up must be completed or escalated before resolution review';
    }
    return null;
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    if (value == null) return 'Select resolution review date';
    if (_dateOnly(value).isBefore(_dateOnly(asOfDate))) {
      return 'Resolution review date cannot be in the past';
    }
    return null;
  }

  static String? validateDecision(
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision?
    value,
  ) {
    if (value == null) return 'Select resolution decision';
    return null;
  }

  static String? validateConfidenceAfter(int value) {
    if (value < 1 || value > 5) return 'Confidence must be between 1 and 5';
    return null;
  }

  static String? validateNextReviewDate(
    DateTime? reviewDate,
    DateTime? nextReviewDate,
  ) {
    if (nextReviewDate == null) return 'Select next review date';
    if (reviewDate == null) return null;
    if (!_dateOnly(nextReviewDate).isAfter(_dateOnly(reviewDate))) {
      return 'Next review must be after resolution review date';
    }
    return null;
  }

  static String? validateEvidenceSummary(String? value) {
    return _validateLongText(value, 'evidence summary');
  }

  static String? validateManagerNote(String? value) {
    return _validateLongText(value, 'manager note');
  }

  static String? validateNextAction(String? value) {
    return _validateLongText(value, 'next action');
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

String
defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextAction(
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
  decision,
) {
  return switch (decision) {
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .closed =>
      'Archive follow-up evidence and return to the standard development cadence.',
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .sustained =>
      'Keep manager pulse in the next development checkpoint.',
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .monitor =>
      'Monitor remaining release risk with the owner and manager.',
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .escalate =>
      'Escalate residual development risk to HR and manager council.',
  };
}

DateTime
defaultIncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionNextReviewDate({
  required IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
  decision,
  required DateTime reviewDate,
}) {
  final offset = switch (decision) {
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .closed =>
      const Duration(days: 45),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .sustained =>
      const Duration(days: 45),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .monitor =>
      const Duration(days: 14),
    IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .escalate =>
      const Duration(days: 7),
  };
  return reviewDate.add(offset);
}

int _defaultRemainingReleaseRiskCount(
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  if (followUp.status ==
          IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
              .completed &&
      followUp.sourceDecision !=
          IncomingTalentDevelopmentInterventionOutcomeDecision.escalate) {
    return 0;
  }
  return followUp.remainingReleaseRiskCount;
}

int _defaultConfidenceAfter(
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  if (followUp.status ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed) {
    return (followUp.confidenceAfter + 1).clamp(1, 5);
  }
  if (followUp.status ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated) {
    return (followUp.confidenceAfter - 1).clamp(1, 5);
  }
  return followUp.confidenceAfter.clamp(1, 5);
}

IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
_defaultDecision({
  required IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
  required int confidenceAfter,
  required int remainingReleaseRiskCount,
}) {
  if (followUp.status ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .escalate;
  }
  if (remainingReleaseRiskCount > 0 || confidenceAfter <= 3) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .monitor;
  }
  if (followUp.sourceDecision ==
      IncomingTalentDevelopmentInterventionOutcomeDecision.improved) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
        .closed;
  }
  return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
      .sustained;
}

String _defaultEvidenceSummary(
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  if (followUp.resolutionNote.trim().isNotEmpty) {
    return 'Follow-up resolution evidence: ${followUp.resolutionNote.trim()}';
  }
  return 'Follow-up evidence confirms ${followUp.successCriteria.toLowerCase()}';
}

String _defaultManagerNote(
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  return 'Manager confirms ${followUp.action.toLowerCase()}';
}

String? _validateLongText(String? value, String label) {
  final requiredError =
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraft.validateRequired(
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
