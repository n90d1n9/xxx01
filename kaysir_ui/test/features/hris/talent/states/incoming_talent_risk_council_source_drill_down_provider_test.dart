import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_sla_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_source_pressure.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_sla_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_drill_down_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_filter_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_pressure_provider.dart';

void main() {
  test('source drill-down auto-focuses highest pressure source', () {
    final container = _container();
    addTearDown(container.dispose);

    final drillDown = container.read(
      incomingTalentRiskCouncilSourceDrillDownProvider,
    );

    expect(
      drillDown.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(drillDown.isAutoFocused, isTrue);
    expect(drillDown.activeSlaCount, 1);
    expect(drillDown.urgentSlaCount, 1);
    expect(drillDown.queueItems, hasLength(1));
    expect(drillDown.decisions, hasLength(1));
    expect(drillDown.followUps, hasLength(1));
    expect(drillDown.totalWorkCount, 3);
    expect(
      drillDown.nextAction,
      'Track 1 escalated promotion resolution review SLA item.',
    );
  });

  test('source drill-down follows selected council source', () {
    final container = _container();
    addTearDown(container.dispose);

    container
        .read(incomingTalentRiskCouncilSourceFilterProvider.notifier)
        .state = IncomingTalentRiskCouncilQueueSource.developmentFollowUp;

    final drillDown = container.read(
      incomingTalentRiskCouncilSourceDrillDownProvider,
    );

    expect(
      drillDown.source,
      IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
    );
    expect(drillDown.isAutoFocused, isFalse);
    expect(drillDown.activeSlaCount, 1);
    expect(drillDown.urgentSlaCount, 0);
    expect(drillDown.queueItems, isEmpty);
    expect(drillDown.decisions, isEmpty);
    expect(drillDown.followUps, hasLength(1));
    expect(
      drillDown.nextAction,
      'Close 1 development follow-up SLA item due soon.',
    );
  });
}

ProviderContainer _container() {
  final promotionSla = _slaItem(
    id: 'promotion',
    councilSource:
        IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    status: IncomingTalentRiskCouncilSlaStatus.escalated,
    slaSource: IncomingTalentRiskCouncilSlaSource.councilFollowUp,
  );
  final developmentSla = _slaItem(
    id: 'development',
    councilSource: IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
    status: IncomingTalentRiskCouncilSlaStatus.dueSoon,
    slaSource: IncomingTalentRiskCouncilSlaSource.followUpExecution,
  );

  return ProviderContainer(
    overrides: [
      incomingTalentRiskCouncilSourcePressureProvider.overrideWithValue([
        IncomingTalentRiskCouncilSourcePressure.fromItems(
          source:
              IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
          items: [promotionSla],
        ),
        IncomingTalentRiskCouncilSourcePressure.fromItems(
          source: IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
          items: [developmentSla],
        ),
      ]),
      decisionReadyTalentRiskCouncilQueueItemsProvider.overrideWithValue([
        _queueItem(
          id: 'promotion',
          source:
              IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
        ),
        _queueItem(
          id: 'development',
          source: IncomingTalentRiskCouncilQueueSource.developmentIntervention,
        ),
      ]),
      followUpReadyTalentRiskCouncilDecisionsProvider.overrideWithValue([
        _decision(
          id: 'promotion',
          source:
              IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
        ),
      ]),
      filteredIncomingTalentRiskCouncilFollowUpsProvider.overrideWithValue([
        _followUp(
          id: 'promotion',
          source:
              IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
        ),
        _followUp(
          id: 'development',
          source: IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
          status: IncomingTalentRiskCouncilFollowUpStatus.planned,
        ),
      ]),
      incomingTalentRiskCouncilSlaItemsProvider.overrideWithValue([
        promotionSla,
        developmentSla,
      ]),
    ],
  );
}

IncomingTalentRiskCouncilSlaItem _slaItem({
  required String id,
  required IncomingTalentRiskCouncilQueueSource councilSource,
  required IncomingTalentRiskCouncilSlaStatus status,
  required IncomingTalentRiskCouncilSlaSource slaSource,
}) {
  return IncomingTalentRiskCouncilSlaItem(
    id: 'sla:$id',
    source: slaSource,
    councilSource: councilSource,
    status: status,
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    ownerName: 'Finance Talent Partner',
    title: 'Council work',
    nextAction: 'Prepare talent risk council work.',
    dueDate: DateTime(2026, 6, 12),
    requiresAttention: status != IncomingTalentRiskCouncilSlaStatus.onTrack,
  );
}

IncomingTalentRiskCouncilQueueItem _queueItem({
  required String id,
  required IncomingTalentRiskCouncilQueueSource source,
}) {
  return IncomingTalentRiskCouncilQueueItem(
    id: 'risk-council:$id',
    candidateId: 'candidate-$id',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    severity: IncomingTalentRiskCouncilQueueSeverity.watch,
    title: 'Mira needs council decision',
    detail: 'Council has enough evidence to decide the follow-up path.',
    recommendedAction: 'Confirm owner, decision outcome, and follow-up date.',
    dueDate: DateTime(2026, 6, 12),
    signalCount: 1,
    source: source,
  );
}

IncomingTalentRiskCouncilDecision _decision({
  required String id,
  required IncomingTalentRiskCouncilQueueSource source,
}) {
  return IncomingTalentRiskCouncilDecision(
    id: 'decision:$id',
    queueItemId: 'risk-council:$id',
    candidateId: 'candidate-$id',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
    source: source,
    decisionMakerName: 'Talent Council',
    ownerName: 'Finance Talent Partner',
    decisionDate: DateTime(2026, 6, 10),
    outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    commitmentSummary: 'Council will monitor this risk.',
    minutesNote: 'Residual evidence needs follow-up.',
    followUpDate: DateTime(2026, 6, 17),
    createdAt: DateTime(2026, 6, 10),
    signalCount: 1,
  );
}

IncomingTalentRiskCouncilFollowUp _followUp({
  required String id,
  required IncomingTalentRiskCouncilQueueSource source,
  IncomingTalentRiskCouncilFollowUpStatus status =
      IncomingTalentRiskCouncilFollowUpStatus.inProgress,
}) {
  return IncomingTalentRiskCouncilFollowUp(
    id: 'follow-up:$id',
    decisionId: 'decision:$id',
    queueItemId: 'risk-council:$id',
    candidateId: 'candidate-$id',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    decisionMakerName: 'Talent Council',
    followUpOwnerName: 'Finance Talent Partner',
    outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
    source: source,
    followUpType: IncomingTalentRiskCouncilFollowUpType.monitoringReview,
    status: status,
    dueDate: DateTime(2026, 6, 17),
    actionPlan: 'Review stabilization evidence.',
    successCriteria: 'Evidence is recorded and accepted.',
    blockerNote: '',
    escalationReason: '',
    createdAt: DateTime(2026, 6, 10),
    signalCount: 1,
  );
}
