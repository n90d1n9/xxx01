import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_activation_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_roadmap_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

ProviderContainer calibrationTestContainer(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentCalibrationPacket seedRiskCalibrationPacket(
  ProviderContainer container,
  DateTime asOfDate, {
  IncomingTalentActivationOutcomeReview? outcome,
}) {
  final submittedOutcome = submitCalibrationOutcome(
    container,
    outcome ??
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.escalateRisk,
          risk: IncomingTalentActivationRetentionRisk.high,
          readinessScore: 48,
        ),
  );
  final roadmap = submitCalibrationRoadmap(
    container,
    calibrationRoadmap(
      asOfDate,
      submittedOutcome,
      status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
    ),
  );
  final checkIn = submitCalibrationCheckIn(
    container,
    calibrationCheckIn(
      asOfDate,
      roadmap,
      trend: IncomingTalentDevelopmentCheckInTrend.blocked,
      confidenceScore: 2,
    ),
  );
  submitCalibrationIntervention(container, checkIn);
  return container
      .read(incomingTalentCalibrationPacketsProvider)
      .firstWhere((packet) => packet.outcomeReviewId == submittedOutcome.id);
}

IncomingTalentActivationOutcomeReview submitCalibrationOutcome(
  ProviderContainer container,
  IncomingTalentActivationOutcomeReview outcome,
) {
  return container
      .read(incomingTalentActivationOutcomeReviewsProvider.notifier)
      .submitDraft(
        IncomingTalentActivationOutcomeDraft(
          activationPlanId: outcome.activationPlanId,
          handoffId: outcome.handoffId,
          candidateId: outcome.candidateId,
          candidateName: outcome.candidateName,
          role: outcome.role,
          department: outcome.department,
          reviewerName: outcome.reviewerName,
          reviewDate: outcome.reviewDate,
          decision: outcome.decision,
          retentionRisk: outcome.retentionRisk,
          readinessScore: outcome.readinessScore,
          nextDevelopmentTrack: outcome.nextDevelopmentTrack,
          evidenceNote: outcome.evidenceNote,
          decisionNote: outcome.decisionNote,
          asOfDate: outcome.createdAt,
        ),
      );
}

IncomingTalentDevelopmentRoadmap submitCalibrationRoadmap(
  ProviderContainer container,
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  return container
      .read(incomingTalentDevelopmentRoadmapsProvider.notifier)
      .submitDraft(
        IncomingTalentDevelopmentRoadmapDraft(
          outcomeReviewId: roadmap.outcomeReviewId,
          activationPlanId: roadmap.activationPlanId,
          handoffId: roadmap.handoffId,
          candidateId: roadmap.candidateId,
          candidateName: roadmap.candidateName,
          role: roadmap.role,
          department: roadmap.department,
          ownerName: roadmap.ownerName,
          mentorName: roadmap.mentorName,
          focusArea: roadmap.focusArea,
          learningObjective: roadmap.learningObjective,
          firstMilestone: roadmap.firstMilestone,
          successMetric: roadmap.successMetric,
          cadence: roadmap.cadence,
          status: roadmap.status,
          startDate: roadmap.startDate,
          targetCompletionDate: roadmap.targetCompletionDate,
          sourceDecision: roadmap.sourceDecision,
          retentionRisk: roadmap.retentionRisk,
          readinessScore: roadmap.readinessScore,
          asOfDate: roadmap.createdAt,
        ),
      );
}

IncomingTalentDevelopmentCheckIn submitCalibrationCheckIn(
  ProviderContainer container,
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  return container
      .read(incomingTalentDevelopmentCheckInsProvider.notifier)
      .submitDraft(
        IncomingTalentDevelopmentCheckInDraft(
          roadmapId: checkIn.roadmapId,
          outcomeReviewId: checkIn.outcomeReviewId,
          candidateId: checkIn.candidateId,
          candidateName: checkIn.candidateName,
          role: checkIn.role,
          department: checkIn.department,
          reviewerName: checkIn.reviewerName,
          checkInDate: checkIn.checkInDate,
          trend: checkIn.trend,
          confidenceScore: checkIn.confidenceScore,
          blockerNote: checkIn.blockerNote,
          nextAction: checkIn.nextAction,
          managerCommitment: checkIn.managerCommitment,
          nextReviewDate: checkIn.nextReviewDate,
          roadmapStatus: checkIn.roadmapStatus,
          retentionRisk: checkIn.retentionRisk,
          asOfDate: checkIn.createdAt,
        ),
      );
}

IncomingTalentDevelopmentInterventionAction submitCalibrationIntervention(
  ProviderContainer container,
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  container
      .read(incomingTalentDevelopmentInterventionDraftProvider.notifier)
      .initializeFromCheckIn(checkIn);
  return container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentInterventionDraftProvider),
      );
}

IncomingTalentActivationOutcomeReview calibrationOutcome(
  DateTime asOfDate, {
  String id = 'outcome-001',
  String activationPlanId = 'activation-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentActivationOutcomeDecision decision,
  required IncomingTalentActivationRetentionRisk risk,
  required int readinessScore,
}) {
  return IncomingTalentActivationOutcomeReview(
    id: id,
    activationPlanId: activationPlanId,
    handoffId: 'handoff-$activationPlanId',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    reviewerName: '$department Manager',
    reviewDate: asOfDate,
    decision: decision,
    retentionRisk: risk,
    readinessScore: readinessScore,
    nextDevelopmentTrack: '$role excellence track',
    evidenceNote: 'Activation evidence confirms current readiness signals.',
    decisionNote: 'Manager and talent partner aligned on calibration signal.',
    createdAt: asOfDate,
  );
}

IncomingTalentDevelopmentRoadmap calibrationRoadmap(
  DateTime asOfDate,
  IncomingTalentActivationOutcomeReview outcome, {
  required IncomingTalentDevelopmentRoadmapStatus status,
}) {
  return IncomingTalentDevelopmentRoadmap(
    id: 'roadmap-${outcome.id}',
    outcomeReviewId: outcome.id,
    activationPlanId: outcome.activationPlanId,
    handoffId: outcome.handoffId,
    candidateId: outcome.candidateId,
    candidateName: outcome.candidateName,
    role: outcome.role,
    department: outcome.department,
    ownerName: outcome.reviewerName,
    mentorName: '${outcome.department} mentor',
    focusArea: '${outcome.role} role excellence',
    learningObjective: 'Strengthen ${outcome.role} delivery capability.',
    firstMilestone: 'Complete first manager-reviewed delivery milestone.',
    successMetric: 'Raise readiness through manager-approved evidence.',
    cadence:
        outcome.retentionRisk == IncomingTalentActivationRetentionRisk.high
            ? IncomingTalentDevelopmentRoadmapCadence.weekly
            : IncomingTalentDevelopmentRoadmapCadence.biweekly,
    status: status,
    startDate: asOfDate,
    targetCompletionDate: asOfDate.add(const Duration(days: 60)),
    sourceDecision: outcome.decision,
    retentionRisk: outcome.retentionRisk,
    readinessScore: outcome.readinessScore,
    createdAt: asOfDate,
  );
}

IncomingTalentDevelopmentCheckIn calibrationCheckIn(
  DateTime asOfDate,
  IncomingTalentDevelopmentRoadmap roadmap, {
  required IncomingTalentDevelopmentCheckInTrend trend,
  required int confidenceScore,
}) {
  return IncomingTalentDevelopmentCheckIn(
    id: 'check-in-${roadmap.id}',
    roadmapId: roadmap.id,
    outcomeReviewId: roadmap.outcomeReviewId,
    candidateId: roadmap.candidateId,
    candidateName: roadmap.candidateName,
    role: roadmap.role,
    department: roadmap.department,
    reviewerName: roadmap.ownerName,
    checkInDate: asOfDate,
    trend: trend,
    confidenceScore: confidenceScore,
    blockerNote:
        trend == IncomingTalentDevelopmentCheckInTrend.blocked
            ? 'Roadmap blockers require immediate manager escalation.'
            : '',
    nextAction: 'Restore progress through manager-owned support.',
    managerCommitment: '${roadmap.ownerName} will confirm support progress.',
    nextReviewDate: asOfDate.add(const Duration(days: 7)),
    roadmapStatus: roadmap.status,
    retentionRisk: roadmap.retentionRisk,
    createdAt: asOfDate,
  );
}
