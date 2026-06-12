import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_brief_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_readiness_checklist_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_sla_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_brief_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_readiness_checklist_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_sla_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('risk council readiness checklist creates prep tasks from brief', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      brief: _brief(
        status: IncomingTalentRiskCouncilBriefStatus.critical,
        pendingDecisionCount: 2,
        criticalDecisionCount: 1,
        decisionCount: 3,
        openFollowUpCount: 3,
        completedFollowUpCount: 1,
        blockedSlaCount: 1,
        escalatedSlaCount: 1,
        overdueSlaCount: 1,
        dueSoonSlaCount: 2,
        waitingFollowUpCount: 1,
        activeFollowUpCount: 3,
      ),
      slaItems: [
        _slaItem(
          asOfDate,
          id: 'blocked',
          source: IncomingTalentRiskCouncilSlaSource.followUpExecution,
          status: IncomingTalentRiskCouncilSlaStatus.blocked,
          dueOffset: 3,
        ),
        _slaItem(
          asOfDate,
          id: 'overdue',
          source: IncomingTalentRiskCouncilSlaSource.followUpExecution,
          status: IncomingTalentRiskCouncilSlaStatus.overdue,
          dueOffset: -2,
        ),
        _slaItem(
          asOfDate,
          id: 'escalated',
          source: IncomingTalentRiskCouncilSlaSource.councilFollowUp,
          status: IncomingTalentRiskCouncilSlaStatus.escalated,
          dueOffset: 1,
        ),
        _slaItem(
          asOfDate,
          id: 'decision',
          source: IncomingTalentRiskCouncilSlaSource.councilDecision,
          status: IncomingTalentRiskCouncilSlaStatus.dueSoon,
          dueOffset: 0,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentRiskCouncilReadinessChecklistItemsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilReadinessChecklistSummaryProvider,
    );

    expect(items.map((item) => item.status).take(3), [
      IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
      IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
      IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
    ]);
    expect(items, hasLength(7));
    expect(
      items.map((item) => item.category),
      contains(
        IncomingTalentRiskCouncilReadinessChecklistCategory.decisionPrep,
      ),
    );
    expect(items.first.title, 'Unblock council-critical SLA work');
    expect(summary.totalCount, 7);
    expect(summary.readyCount, 0);
    expect(summary.needsPrepCount, 5);
    expect(summary.blockedCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.attentionCount, 7);
    expect(summary.readinessRatio, 0);
    expect(summary.nextAction, 'Unblock 1 council readiness task.');
  });

  test('risk council readiness checklist clears when brief is clear', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      brief: _brief(status: IncomingTalentRiskCouncilBriefStatus.clear),
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentRiskCouncilReadinessChecklistItemsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilReadinessChecklistSummaryProvider,
    );

    expect(items, hasLength(1));
    expect(
      items.single.status,
      IncomingTalentRiskCouncilReadinessChecklistStatus.ready,
    );
    expect(items.single.title, 'Council pack is ready');
    expect(summary.totalCount, 1);
    expect(summary.readyCount, 1);
    expect(summary.attentionCount, 0);
    expect(summary.readinessRatio, 1);
    expect(summary.nextAction, 'Council readiness checklist is clear.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required IncomingTalentRiskCouncilBrief brief,
  List<IncomingTalentRiskCouncilSlaItem> slaItems = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentRiskCouncilBriefProvider.overrideWithValue(brief),
      incomingTalentRiskCouncilSlaItemsProvider.overrideWithValue(slaItems),
    ],
  );
}

IncomingTalentRiskCouncilBrief _brief({
  required IncomingTalentRiskCouncilBriefStatus status,
  int pendingDecisionCount = 0,
  int criticalDecisionCount = 0,
  int decisionCount = 0,
  int openFollowUpCount = 0,
  int completedFollowUpCount = 0,
  int blockedSlaCount = 0,
  int escalatedSlaCount = 0,
  int overdueSlaCount = 0,
  int dueSoonSlaCount = 0,
  int waitingFollowUpCount = 0,
  int activeFollowUpCount = 0,
}) {
  return IncomingTalentRiskCouncilBrief(
    status: status,
    pendingDecisionCount: pendingDecisionCount,
    criticalDecisionCount: criticalDecisionCount,
    decisionCount: decisionCount,
    openFollowUpCount: openFollowUpCount,
    completedFollowUpCount: completedFollowUpCount,
    blockedSlaCount: blockedSlaCount,
    escalatedSlaCount: escalatedSlaCount,
    overdueSlaCount: overdueSlaCount,
    dueSoonSlaCount: dueSoonSlaCount,
    waitingFollowUpCount: waitingFollowUpCount,
    activeFollowUpCount: activeFollowUpCount,
    readinessRatio: 1,
    nextAction: 'Brief next action.',
    insights: const [],
  );
}

IncomingTalentRiskCouncilSlaItem _slaItem(
  DateTime asOfDate, {
  required String id,
  required IncomingTalentRiskCouncilSlaSource source,
  required IncomingTalentRiskCouncilSlaStatus status,
  required int dueOffset,
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
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    requiresAttention: status != IncomingTalentRiskCouncilSlaStatus.onTrack,
  );
}
