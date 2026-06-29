import 'incoming_talent_development_intervention_outcome_models.dart';

enum IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus {
  open('Open'),
  inProgress('In progress'),
  completed('Completed'),
  escalated('Escalated');

  final String label;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus(this.label);
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUp {
  final String id;
  final String outcomeId;
  final String interventionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String reviewerName;
  final DateTime outcomeReviewDate;
  final DateTime dueDate;
  final IncomingTalentDevelopmentInterventionOutcomeDecision sourceDecision;
  final int confidenceAfter;
  final int remainingReleaseRiskCount;
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus status;
  final String action;
  final String successCriteria;
  final String resolutionNote;
  final DateTime? completedAt;
  final DateTime createdAt;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUp({
    required this.id,
    required this.outcomeId,
    required this.interventionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.reviewerName,
    required this.outcomeReviewDate,
    required this.dueDate,
    required this.sourceDecision,
    required this.confidenceAfter,
    required this.remainingReleaseRiskCount,
    required this.status,
    required this.action,
    required this.successCriteria,
    required this.resolutionNote,
    required this.completedAt,
    required this.createdAt,
  });

  bool get isClosed {
    return status ==
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .completed ||
        status ==
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .escalated;
  }

  bool isOverdue(DateTime asOfDate) {
    return !isClosed && dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool isDueSoon(DateTime asOfDate) {
    final currentDate = _dateOnly(asOfDate);
    final dueSoonDate = currentDate.add(const Duration(days: 7));
    return !isClosed &&
        (dueDate.isAtSameMomentAs(currentDate) ||
            dueDate.isAfter(currentDate)) &&
        !dueDate.isAfter(dueSoonDate);
  }

  bool needsAttention(DateTime asOfDate) {
    if (status ==
        IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed) {
      return false;
    }
    return status ==
            IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
                .escalated ||
        isOverdue(asOfDate) ||
        isDueSoon(asOfDate) ||
        remainingReleaseRiskCount > 0 ||
        sourceDecision ==
            IncomingTalentDevelopmentInterventionOutcomeDecision.escalate;
  }

  double get confidenceRatio => confidenceAfter / 5;

  IncomingTalentDevelopmentInterventionOutcomeFollowUp copyWith({
    IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus? status,
    String? resolutionNote,
    DateTime? completedAt,
  }) {
    return IncomingTalentDevelopmentInterventionOutcomeFollowUp(
      id: id,
      outcomeId: outcomeId,
      interventionId: interventionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      ownerName: ownerName,
      reviewerName: reviewerName,
      outcomeReviewDate: outcomeReviewDate,
      dueDate: dueDate,
      sourceDecision: sourceDecision,
      confidenceAfter: confidenceAfter,
      remainingReleaseRiskCount: remainingReleaseRiskCount,
      status: status ?? this.status,
      action: action,
      successCriteria: successCriteria,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
