import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_review_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_review_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_training_session_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_training_session_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent operating inbox aggregates and ranks actionable work', () {
    final asOfDate = DateTime(2026, 6, 11);
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        decisionReadyTalentRiskCouncilQueueItemsProvider.overrideWithValue([
          _riskQueueItem(asOfDate),
        ]),
        followUpReadyTalentRiskCouncilDecisionsProvider.overrideWithValue([
          _riskDecision(asOfDate),
        ]),
        filteredIncomingTalentRiskCouncilFollowUpsProvider.overrideWithValue([
          _riskFollowUp(asOfDate),
        ]),
        filteredIncomingTalentTrainingSessionsProvider.overrideWithValue([
          _trainingSession(asOfDate),
        ]),
        filteredIncomingTalentCareerPathReviewsProvider.overrideWithValue([
          _careerReview(asOfDate),
        ]),
        filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider
            .overrideWithValue([_successionFollowUp(asOfDate)]),
        filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider
            .overrideWithValue([_promotionAction(asOfDate)]),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentOperatingInboxItemsProvider);
    final summary = container.read(incomingTalentOperatingInboxSummaryProvider);

    expect(items, hasLength(7));
    expect(
      items.first.source,
      IncomingTalentOperatingInboxSource.riskCouncilDecision,
    );
    expect(items.first.priority, IncomingTalentOperatingInboxPriority.critical);
    expect(items.first.isOverdue(asOfDate), isTrue);
    expect(
      items.map((item) => item.source),
      containsAll([
        IncomingTalentOperatingInboxSource.riskCouncilDecision,
        IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
        IncomingTalentOperatingInboxSource.trainingSession,
        IncomingTalentOperatingInboxSource.careerPathReview,
        IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
        IncomingTalentOperatingInboxSource.promotionStabilization,
      ]),
    );
    expect(summary.totalCount, 7);
    expect(summary.criticalCount, 6);
    expect(summary.watchCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.dueSoonCount, 4);
    expect(summary.riskCouncilCount, 3);
    expect(summary.developmentCount, 2);
    expect(summary.successionCount, 1);
    expect(summary.promotionCount, 1);
    expect(summary.nextAction, 'Resolve 6 critical talent inbox items.');
  });
}

IncomingTalentRiskCouncilQueueItem _riskQueueItem(DateTime asOfDate) {
  return IncomingTalentRiskCouncilQueueItem(
    id: 'risk-queue',
    candidateId: 'candidate-risk',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    severity: IncomingTalentRiskCouncilQueueSeverity.critical,
    title: 'Risk council decision required',
    detail: 'Promotion resolution evidence needs council decision.',
    recommendedAction: 'Decide owner, follow-up, and council minutes.',
    dueDate: asOfDate.subtract(const Duration(days: 1)),
    signalCount: 3,
    source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  );
}

IncomingTalentRiskCouncilDecision _riskDecision(DateTime asOfDate) {
  return IncomingTalentRiskCouncilDecision(
    id: 'decision-risk',
    queueItemId: 'risk-queue',
    candidateId: 'candidate-risk',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.critical,
    source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    decisionMakerName: 'Talent Council',
    ownerName: 'Finance Talent Partner',
    decisionDate: asOfDate,
    outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    commitmentSummary: 'Create follow-up for promotion stabilization risk.',
    minutesNote: 'Council noted residual role-risk evidence.',
    followUpDate: asOfDate.add(const Duration(days: 3)),
    createdAt: asOfDate,
    signalCount: 3,
  );
}

IncomingTalentRiskCouncilFollowUp _riskFollowUp(DateTime asOfDate) {
  return IncomingTalentRiskCouncilFollowUp(
    id: 'follow-up-risk',
    decisionId: 'decision-risk',
    queueItemId: 'risk-queue',
    candidateId: 'candidate-risk',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    decisionMakerName: 'Talent Council',
    followUpOwnerName: 'Finance Talent Partner',
    outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.critical,
    source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    followUpType: IncomingTalentRiskCouncilFollowUpType.monitoringReview,
    status: IncomingTalentRiskCouncilFollowUpStatus.inProgress,
    dueDate: asOfDate.add(const Duration(days: 9)),
    actionPlan: 'Review role-risk evidence before next council.',
    successCriteria: 'Evidence is reviewed and disposition is recorded.',
    blockerNote: '',
    escalationReason: '',
    createdAt: asOfDate,
    signalCount: 1,
  );
}

IncomingTalentTrainingSession _trainingSession(DateTime asOfDate) {
  return IncomingTalentTrainingSession(
    id: 'training',
    programId: 'program',
    programTitle: 'Finance growth accelerator',
    department: 'Finance',
    trainerName: 'Rani Prasetya',
    format: IncomingTalentTrainingSessionFormat.hybrid,
    status: IncomingTalentTrainingSessionStatus.scheduled,
    location: 'Finance training room',
    prerequisite: 'Complete pre-work.',
    outcomeCheckpoint: 'Confirm manager evidence after training.',
    capacity: 16,
    reservedSeats: 0,
    sessionDate: asOfDate.add(const Duration(days: 4)),
    followUpDate: asOfDate.add(const Duration(days: 18)),
    sourceProgramTrack: IncomingTalentDevelopmentProgramTrack.leadership,
    sourceProgramIntensity: IncomingTalentDevelopmentProgramIntensity.standard,
    createdAt: asOfDate,
  );
}

IncomingTalentCareerPathReview _careerReview(DateTime asOfDate) {
  return IncomingTalentCareerPathReview(
    id: 'career-review',
    careerPathId: 'career-path',
    portfolioId: 'portfolio',
    roadmapId: 'roadmap',
    candidateId: 'candidate-career',
    candidateName: 'Fajar Nugroho',
    department: 'Engineering',
    currentRole: 'Engineer',
    targetRole: 'Senior Engineer',
    competencyName: 'Architecture',
    reviewerName: 'Engineering HRBP',
    reviewDate: asOfDate,
    decision: IncomingTalentCareerPathReviewDecision.blocked,
    previousLevel: 2,
    reviewedLevel: 2,
    targetLevel: 4,
    evidenceNote: 'Evidence is incomplete.',
    blockerNote: 'Architecture proof is missing.',
    nextAction: 'Schedule architecture evidence review.',
    nextReviewDate: asOfDate.add(const Duration(days: 5)),
    sourceStatus: IncomingTalentCareerPathStatus.blocked,
    sourcePriority: IncomingTalentCareerPathPriority.critical,
    createdAt: asOfDate,
  );
}

IncomingTalentSuccessionCoverageCouncilFollowUp _successionFollowUp(
  DateTime asOfDate,
) {
  return IncomingTalentSuccessionCoverageCouncilFollowUp(
    id: 'succession-follow-up',
    decisionId: 'succession-decision',
    agendaItemId: 'succession-agenda',
    governanceRecordId: 'governance',
    scopeLabel: 'Finance leadership bench',
    departmentScope: 'Finance',
    councilOwnerName: 'Talent Council',
    followUpOwnerName: 'Finance HRBP',
    executiveSponsorName: 'Finance Director',
    outcome:
        IncomingTalentSuccessionCoverageCouncilDecisionOutcome
            .assignExecutiveSponsor,
    priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
    riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
    followUpType:
        IncomingTalentSuccessionCoverageCouncilFollowUpType.recoveryCheckpoint,
    status: IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned,
    dueDate: asOfDate.add(const Duration(days: 6)),
    actionPlan: 'Confirm sponsor recovery evidence.',
    successCriteria: 'Coverage recovery evidence is approved.',
    blockerNote: '',
    escalationReason: '',
    createdAt: asOfDate,
  );
}

IncomingTalentPromotionStabilizationFollowUpAction _promotionAction(
  DateTime asOfDate,
) {
  return IncomingTalentPromotionStabilizationFollowUpAction(
    id: 'promotion-action',
    reviewId: 'promotion-review',
    implementationId: 'promotion-implementation',
    decisionId: 'promotion-decision',
    candidateId: 'candidate-promotion',
    candidateName: 'Alya Maheswari',
    department: 'People Operations',
    currentRole: 'People Partner',
    newRole: 'Senior People Partner',
    frameworkLevelCode: 'P4',
    ownerName: 'People Ops HRBP',
    actionType:
        IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
    priority: IncomingTalentPromotionStabilizationFollowUpPriority.high,
    status: IncomingTalentPromotionStabilizationFollowUpStatus.inProgress,
    dueDate: asOfDate.add(const Duration(days: 8)),
    actionPlan: 'Coach manager on role stabilization evidence.',
    successCriteria: 'Manager checkpoint and evidence are recorded.',
    escalationNote: '',
    resolutionNote: '',
    sourceOutcome:
        IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
    sourceReviewStatus:
        IncomingTalentPromotionStabilizationStatus.followUpRequired,
    sourceConfidenceScore: 3,
    createdAt: asOfDate,
  );
}
