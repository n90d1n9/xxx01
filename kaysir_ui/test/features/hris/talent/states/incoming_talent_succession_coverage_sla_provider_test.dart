import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_sla_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('coverage SLA dashboard ranks active work and summarizes', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      reviews: [_review(asOfDate, scope: 'Finance', nextReviewOffset: -1)],
      actions: [
        _action(
          asOfDate,
          scope: 'Operations',
          status: IncomingTalentSuccessionCoverageActionStatus.blocked,
          dueOffset: 10,
        ),
      ],
      outcomeActions: [
        _action(
          asOfDate,
          scope: 'Engineering',
          status: IncomingTalentSuccessionCoverageActionStatus.resolved,
          dueOffset: 2,
        ),
      ],
      agendaItems: [_agendaItem(asOfDate, scope: 'Finance', councilOffset: 0)],
      decisions: [
        _decision(
          asOfDate,
          scope: 'People',
          outcome:
              IncomingTalentSuccessionCoverageCouncilDecisionOutcome
                  .escalateToPeopleBoard,
          followUpOffset: 7,
        ),
      ],
      followUps: [
        _followUp(
          asOfDate,
          scope: 'Product',
          status: IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned,
          dueOffset: 5,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentSuccessionCoverageSlaItemsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageSlaSummaryProvider,
    );

    expect(items.map((item) => item.status).take(3), [
      IncomingTalentSuccessionCoverageSlaStatus.blocked,
      IncomingTalentSuccessionCoverageSlaStatus.escalated,
      IncomingTalentSuccessionCoverageSlaStatus.overdue,
    ]);
    expect(summary.totalCount, 6);
    expect(summary.blockedCount, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.dueSoonCount, 3);
    expect(summary.waitingCouncilCount, 1);
    expect(summary.waitingFollowUpCount, 2);
    expect(summary.nextAction, 'Unblock 1 coverage SLA items.');
  });

  test('coverage SLA dashboard follows department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      actions: [
        _action(
          asOfDate,
          scope: 'Engineering',
          status: IncomingTalentSuccessionCoverageActionStatus.blocked,
          dueOffset: 1,
        ),
      ],
      agendaItems: [_agendaItem(asOfDate, scope: 'Finance', councilOffset: 0)],
      followUps: [
        _followUp(
          asOfDate,
          scope: 'Finance',
          status: IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned,
          dueOffset: 20,
          priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.watch,
          riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.low,
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final items = container.read(
      incomingTalentSuccessionCoverageSlaItemsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageSlaSummaryProvider,
    );

    expect(items.map((item) => item.source), [
      IncomingTalentSuccessionCoverageSlaSource.councilDecision,
    ]);
    expect(summary.totalCount, 1);
    expect(summary.waitingCouncilCount, 1);
    expect(summary.nextAction, 'Close 1 SLA items due soon.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentSuccessionCoverageReview> reviews = const [],
  List<IncomingTalentSuccessionCoverageAction> actions = const [],
  List<IncomingTalentSuccessionCoverageAction> outcomeActions = const [],
  List<IncomingTalentSuccessionCoverageCouncilAgendaItem> agendaItems =
      const [],
  List<IncomingTalentSuccessionCoverageCouncilDecision> decisions = const [],
  List<IncomingTalentSuccessionCoverageCouncilFollowUp> followUps = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      actionReadySuccessionCoverageReviewsProvider.overrideWithValue(reviews),
      filteredIncomingTalentSuccessionCoverageActionsProvider.overrideWithValue(
        actions,
      ),
      outcomeReadySuccessionCoverageActionsProvider.overrideWithValue(
        outcomeActions,
      ),
      decisionReadyCoverageCouncilAgendaItemsProvider.overrideWithValue(
        agendaItems,
      ),
      followUpReadyCoverageCouncilDecisionsProvider.overrideWithValue(
        decisions,
      ),
      filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider
          .overrideWithValue(followUps),
    ],
  );
}

IncomingTalentSuccessionCoverageReview _review(
  DateTime asOfDate, {
  required String scope,
  required int nextReviewOffset,
}) {
  return IncomingTalentSuccessionCoverageReview(
    id: 'review-$scope',
    scopeLabel: scope,
    departmentScope: scope,
    attentionOnly: false,
    reviewerName: '$scope Reviewer',
    reviewDate: asOfDate.subtract(const Duration(days: 3)),
    decision: IncomingTalentSuccessionCoverageReviewDecision.rework,
    coverageHealth: IncomingTalentSuccessionCoverageHealth.watch,
    coverageScore: 52,
    totalCandidates: 4,
    readyCoverageCount: 1,
    attentionSignalCount: 2,
    openBenchActionCount: 1,
    reviewSummary: '$scope review needs recovery action.',
    executiveCommitment: '$scope owner must restore ready-now coverage.',
    nextReviewDate: asOfDate.add(Duration(days: nextReviewOffset)),
    createdAt: asOfDate,
  );
}

IncomingTalentSuccessionCoverageAction _action(
  DateTime asOfDate, {
  required String scope,
  required IncomingTalentSuccessionCoverageActionStatus status,
  required int dueOffset,
}) {
  return IncomingTalentSuccessionCoverageAction(
    id: 'action-$scope-$status',
    coverageReviewId: 'review-$scope',
    scopeLabel: scope,
    departmentScope: scope,
    attentionOnly: false,
    reviewerName: '$scope Reviewer',
    reviewDecision: IncomingTalentSuccessionCoverageReviewDecision.rework,
    coverageHealth: IncomingTalentSuccessionCoverageHealth.watch,
    coverageScore: 58,
    ownerName: '$scope Owner',
    actionType: IncomingTalentSuccessionCoverageActionType.executiveSponsor,
    status: status,
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    actionPlan: '$scope owner confirms recovery action plan.',
    escalationPath: '$scope escalation path is ready.',
    resolutionEvidence: '$scope resolution evidence needs review.',
    createdAt: asOfDate,
  );
}

IncomingTalentSuccessionCoverageCouncilAgendaItem _agendaItem(
  DateTime asOfDate, {
  required String scope,
  required int councilOffset,
}) {
  return IncomingTalentSuccessionCoverageCouncilAgendaItem(
    id: 'agenda-$scope',
    governanceRecordId: 'governance-$scope',
    scopeLabel: scope,
    departmentScope: scope,
    ownerName: '$scope Owner',
    lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision,
    priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
    stage: IncomingTalentSuccessionCoverageGovernanceStage.actionRequired,
    riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
    coverageScore: 42,
    dueDate: asOfDate,
    councilDate: asOfDate.add(Duration(days: councilOffset)),
    decisionQuestion: 'What decision restores $scope coverage?',
    discussionPrompt: '$scope discussion prompt is ready.',
    preReadSummary: '$scope pre-read summary is ready.',
  );
}

IncomingTalentSuccessionCoverageCouncilDecision _decision(
  DateTime asOfDate, {
  required String scope,
  required IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome,
  required int followUpOffset,
}) {
  return IncomingTalentSuccessionCoverageCouncilDecision(
    id: 'decision-$scope',
    agendaItemId: 'agenda-$scope',
    governanceRecordId: 'governance-$scope',
    scopeLabel: scope,
    departmentScope: scope,
    ownerName: '$scope Owner',
    decisionMakerName: 'Talent Council',
    executiveSponsorName: '$scope Sponsor',
    lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision,
    priority: IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
    riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
    coverageScore: 45,
    decisionDate: asOfDate,
    outcome: outcome,
    commitmentSummary: '$scope council commitment is ready.',
    minutesNote: '$scope council minutes are ready.',
    followUpDate: asOfDate.add(Duration(days: followUpOffset)),
    createdAt: asOfDate,
  );
}

IncomingTalentSuccessionCoverageCouncilFollowUp _followUp(
  DateTime asOfDate, {
  required String scope,
  required IncomingTalentSuccessionCoverageCouncilFollowUpStatus status,
  required int dueOffset,
  IncomingTalentSuccessionCoverageCouncilAgendaPriority priority =
      IncomingTalentSuccessionCoverageCouncilAgendaPriority.normal,
  IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel =
      IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium,
}) {
  return IncomingTalentSuccessionCoverageCouncilFollowUp(
    id: 'follow-up-$scope',
    decisionId: 'decision-$scope',
    agendaItemId: 'agenda-$scope',
    governanceRecordId: 'governance-$scope',
    scopeLabel: scope,
    departmentScope: scope,
    councilOwnerName: '$scope Owner',
    followUpOwnerName: '$scope Follow-up Owner',
    executiveSponsorName: '$scope Sponsor',
    outcome:
        IncomingTalentSuccessionCoverageCouncilDecisionOutcome
            .approveRecoveryPlan,
    priority: priority,
    riskLevel: riskLevel,
    followUpType:
        IncomingTalentSuccessionCoverageCouncilFollowUpType.recoveryCheckpoint,
    status: status,
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    actionPlan: '$scope follow-up action plan is active.',
    successCriteria: '$scope success criteria is measurable.',
    blockerNote: '',
    escalationReason: '',
    createdAt: asOfDate,
  );
}
