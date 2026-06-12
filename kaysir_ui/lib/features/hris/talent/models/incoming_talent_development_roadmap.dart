import 'incoming_talent_activation_outcome_models.dart';

enum IncomingTalentDevelopmentRoadmapCadence {
  weekly('Weekly'),
  biweekly('Biweekly'),
  monthly('Monthly');

  final String label;

  const IncomingTalentDevelopmentRoadmapCadence(this.label);
}

enum IncomingTalentDevelopmentRoadmapStatus {
  planned('Planned'),
  active('Active'),
  atRisk('At risk'),
  completed('Completed');

  final String label;

  const IncomingTalentDevelopmentRoadmapStatus(this.label);
}

class IncomingTalentDevelopmentRoadmap {
  final String id;
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
  final IncomingTalentDevelopmentRoadmapCadence cadence;
  final IncomingTalentDevelopmentRoadmapStatus status;
  final DateTime startDate;
  final DateTime targetCompletionDate;
  final IncomingTalentActivationOutcomeDecision sourceDecision;
  final IncomingTalentActivationRetentionRisk retentionRisk;
  final int readinessScore;
  final DateTime createdAt;

  const IncomingTalentDevelopmentRoadmap({
    required this.id,
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
    required this.createdAt,
  });

  bool get needsAttention {
    return status == IncomingTalentDevelopmentRoadmapStatus.atRisk ||
        retentionRisk == IncomingTalentActivationRetentionRisk.high ||
        sourceDecision == IncomingTalentActivationOutcomeDecision.escalateRisk;
  }

  double get readinessRatio => readinessScore / 100;

  int get durationDays {
    final days = targetCompletionDate.difference(startDate).inDays;
    return days < 0 ? 0 : days;
  }
}
