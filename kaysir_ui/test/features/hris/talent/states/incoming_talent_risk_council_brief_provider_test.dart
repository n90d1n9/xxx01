import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_brief_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_sla_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_brief_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_sla_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('risk council brief prioritizes leadership pressure', () {
    final asOfDate = DateTime(2026, 6, 6);
    final queueItem = _queueItem(
      asOfDate,
      candidateName: 'Mira Lestari',
      severity: IncomingTalentRiskCouncilQueueSeverity.critical,
    );
    final decision = _decision(asOfDate);
    final completedFollowUp = _followUp(
      asOfDate,
      status: IncomingTalentRiskCouncilFollowUpStatus.completed,
    );
    final openFollowUp = _followUp(
      asOfDate,
      id: 'open',
      status: IncomingTalentRiskCouncilFollowUpStatus.blocked,
    );
    final container = _container(
      asOfDate,
      queueItems: [queueItem],
      decisions: [decision],
      followUps: [completedFollowUp, openFollowUp],
      slaItems: [
        _slaItem(
          asOfDate,
          id: 'blocked',
          status: IncomingTalentRiskCouncilSlaStatus.blocked,
          source: IncomingTalentRiskCouncilSlaSource.followUpExecution,
        ),
        _slaItem(
          asOfDate,
          id: 'escalated',
          status: IncomingTalentRiskCouncilSlaStatus.escalated,
          source: IncomingTalentRiskCouncilSlaSource.councilFollowUp,
        ),
        _slaItem(
          asOfDate,
          id: 'due-soon',
          status: IncomingTalentRiskCouncilSlaStatus.dueSoon,
          source: IncomingTalentRiskCouncilSlaSource.councilDecision,
        ),
      ],
    );
    addTearDown(container.dispose);

    final brief = container.read(incomingTalentRiskCouncilBriefProvider);

    expect(brief.status, IncomingTalentRiskCouncilBriefStatus.critical);
    expect(brief.pendingDecisionCount, 1);
    expect(brief.criticalDecisionCount, 1);
    expect(brief.decisionCount, 1);
    expect(brief.openFollowUpCount, 1);
    expect(brief.completedFollowUpCount, 1);
    expect(brief.blockedSlaCount, 1);
    expect(brief.escalatedSlaCount, 1);
    expect(brief.dueSoonSlaCount, 1);
    expect(brief.waitingFollowUpCount, 1);
    expect(brief.activeFollowUpCount, 1);
    expect(brief.readinessRatio, closeTo(0.25, 0.001));
    expect(brief.nextAction, 'Unblock 1 talent risk SLA item before council.');
    expect(
      brief.insights.first.type,
      IncomingTalentRiskCouncilBriefInsightType.leadershipAttention,
    );
    expect(
      brief.insights.map((insight) => insight.type),
      contains(IncomingTalentRiskCouncilBriefInsightType.decisionQueue),
    );
  });

  test('risk council brief clears with no active signals', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final brief = container.read(incomingTalentRiskCouncilBriefProvider);

    expect(brief.status, IncomingTalentRiskCouncilBriefStatus.clear);
    expect(brief.readinessRatio, 1);
    expect(brief.nextAction, 'Talent risk council brief is clear.');
    expect(
      brief.insights.single.type,
      IncomingTalentRiskCouncilBriefInsightType.clear,
    );
    expect(
      brief.insights.single.detail,
      'No active talent risk council signals need leadership attention.',
    );
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentRiskCouncilQueueItem> queueItems = const [],
  List<IncomingTalentRiskCouncilDecision> decisions = const [],
  List<IncomingTalentRiskCouncilFollowUp> followUps = const [],
  List<IncomingTalentRiskCouncilSlaItem> slaItems = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      decisionReadyTalentRiskCouncilQueueItemsProvider.overrideWithValue(
        queueItems,
      ),
      filteredIncomingTalentRiskCouncilDecisionsProvider.overrideWithValue(
        decisions,
      ),
      filteredIncomingTalentRiskCouncilFollowUpsProvider.overrideWithValue(
        followUps,
      ),
      incomingTalentRiskCouncilSlaItemsProvider.overrideWithValue(slaItems),
    ],
  );
}

IncomingTalentRiskCouncilQueueItem _queueItem(
  DateTime asOfDate, {
  required String candidateName,
  required IncomingTalentRiskCouncilQueueSeverity severity,
}) {
  return IncomingTalentRiskCouncilQueueItem(
    id: 'risk-queue:$candidateName',
    candidateId: 'candidate-$candidateName',
    candidateName: candidateName,
    role: 'Senior Analyst',
    department: 'Finance',
    category: IncomingTalentRiskCouncilQueueCategory.followUp,
    severity: severity,
    title: '$candidateName needs council decision',
    detail:
        'Council has enough risk evidence to determine the next accountable action.',
    recommendedAction:
        'Confirm council decision, owner, follow-up date, and minutes note.',
    dueDate: asOfDate,
    signalCount:
        severity == IncomingTalentRiskCouncilQueueSeverity.critical ? 3 : 1,
  );
}

IncomingTalentRiskCouncilDecision _decision(DateTime asOfDate) {
  return IncomingTalentRiskCouncilDecision(
    id: 'decision:mira',
    queueItemId: 'risk-queue:mira',
    candidateId: 'candidate-mira',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    category: IncomingTalentRiskCouncilQueueCategory.followUp,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.critical,
    decisionMakerName: 'Talent Council',
    ownerName: 'Finance Talent Partner',
    decisionDate: asOfDate,
    outcome: IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
    commitmentSummary: 'Mira council commitment is ready for follow-up.',
    minutesNote: 'Mira council minutes are ready.',
    followUpDate: asOfDate.add(const Duration(days: 7)),
    createdAt: asOfDate,
    signalCount: 3,
  );
}

IncomingTalentRiskCouncilFollowUp _followUp(
  DateTime asOfDate, {
  String id = 'closed',
  required IncomingTalentRiskCouncilFollowUpStatus status,
}) {
  return IncomingTalentRiskCouncilFollowUp(
    id: 'follow-up:$id',
    decisionId: 'decision:$id',
    queueItemId: 'risk-queue:$id',
    candidateId: 'candidate-$id',
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    decisionMakerName: 'Talent Council',
    followUpOwnerName: 'Finance Talent Partner',
    outcome: IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
    category: IncomingTalentRiskCouncilQueueCategory.followUp,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.critical,
    followUpType: IncomingTalentRiskCouncilFollowUpType.actionCheckpoint,
    status: status,
    dueDate: asOfDate.add(const Duration(days: 7)),
    actionPlan: 'Mira follow-up action plan is active.',
    successCriteria: 'Mira success criteria is measurable.',
    blockerNote: '',
    escalationReason: '',
    createdAt: asOfDate,
    signalCount: 3,
  );
}

IncomingTalentRiskCouncilSlaItem _slaItem(
  DateTime asOfDate, {
  required String id,
  required IncomingTalentRiskCouncilSlaStatus status,
  required IncomingTalentRiskCouncilSlaSource source,
}) {
  return IncomingTalentRiskCouncilSlaItem(
    id: 'sla:$id',
    source: source,
    status: status,
    candidateName: 'Mira Lestari',
    role: 'Senior Analyst',
    department: 'Finance',
    ownerName: 'Finance Talent Partner',
    title: 'Council work',
    nextAction: 'Prepare talent risk council work.',
    dueDate: asOfDate.add(const Duration(days: 3)),
    requiresAttention: status != IncomingTalentRiskCouncilSlaStatus.onTrack,
  );
}
