import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent escalation board combines operating signals by urgency', () {
    final asOfDate = DateTime(2026, 6, 11);
    final overdueInboxItem = _item(
      id: 'risk-overdue',
      source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
      priority: IncomingTalentOperatingInboxPriority.critical,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
    );
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        incomingTalentOperatingInboxItemsProvider.overrideWithValue([
          overdueInboxItem,
        ]),
        incomingTalentOperatingCadenceBucketsProvider.overrideWithValue([
          _overdueBucket,
          _todayBucket,
        ]),
        incomingTalentOperatingInboxOwnerRebalancePlanProvider
            .overrideWithValue(_rebalancePlan),
        incomingTalentOperatingWorkstreamPressuresProvider.overrideWithValue([
          _criticalPressure,
        ]),
      ],
    );
    addTearDown(container.dispose);

    final escalations = container.read(
      incomingTalentOperatingEscalationsProvider,
    );
    final summary = container.read(
      incomingTalentOperatingEscalationSummaryProvider,
    );

    expect(escalations, hasLength(5));
    expect(
      escalations.first.severity,
      IncomingTalentOperatingEscalationSeverity.critical,
    );
    expect(
      escalations.map((item) => item.source),
      containsAll([
        IncomingTalentOperatingEscalationSource.cadence,
        IncomingTalentOperatingEscalationSource.ownerRebalance,
        IncomingTalentOperatingEscalationSource.workstreamPressure,
        IncomingTalentOperatingEscalationSource.inbox,
      ]),
    );
    expect(summary.totalCount, 5);
    expect(summary.criticalCount, 4);
    expect(summary.highCount, 1);
    expect(summary.overdueCount, 3);
    expect(summary.dueTodayCount, 1);
    expect(summary.cadenceCount, 2);
    expect(summary.ownerReliefCount, 1);
    expect(summary.workstreamPressureCount, 1);
    expect(summary.inboxItemCount, 1);
    expect(summary.nextAction, 'Clear 4 critical talent escalations.');
  });
}

IncomingTalentOperatingInboxItem _item({
  required String id,
  required IncomingTalentOperatingInboxSource source,
  required IncomingTalentOperatingInboxPriority priority,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingInboxItem(
    id: id,
    source: source,
    priority: priority,
    title: 'Risk council recovery',
    subjectName: 'Ari Talent',
    department: 'People Operations',
    ownerName: 'People Operations Talent Partner',
    statusLabel: 'Blocked',
    nextAction: 'Recover the risk council follow-up.',
    dueDate: dueDate,
  );
}

final _overdueBucket = IncomingTalentOperatingCadenceBucket(
  window: IncomingTalentOperatingCadenceWindow.overdue,
  risk: IncomingTalentOperatingCadenceRisk.critical,
  totalCount: 2,
  criticalCount: 1,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 2,
  dueTodayCount: 0,
  ownerCount: 2,
  workstreamCount: 2,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 2 overdue talent cadence items.',
  itemIds: const ['risk-overdue', 'career-overdue'],
);

final _todayBucket = IncomingTalentOperatingCadenceBucket(
  window: IncomingTalentOperatingCadenceWindow.dueToday,
  risk: IncomingTalentOperatingCadenceRisk.watch,
  totalCount: 1,
  criticalCount: 0,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 0,
  dueTodayCount: 1,
  ownerCount: 1,
  workstreamCount: 1,
  earliestDueDate: DateTime(2026, 6, 11),
  nextAction: 'Close 1 talent cadence item due today.',
  itemIds: const ['training-today'],
);

const _rebalanceRecommendation =
    IncomingTalentOperatingInboxOwnerRebalanceRecommendation(
      sourceOwnerName: 'People Operations Talent Partner',
      targetOwnerName: 'Engineering HRBP',
      priority: IncomingTalentOperatingInboxOwnerRebalancePriority.critical,
      suggestedItemCount: 2,
      sourceItemCount: 4,
      sourceCriticalCount: 2,
      sourceOverdueCount: 1,
      sourceDueSoonCount: 1,
      sourceWorkstreamCount: 2,
      reliefCapacity: 1,
      reason: '1 overdue talent inbox item',
      nextAction:
          'Move 2 urgent talent items from People Operations Talent Partner to Engineering HRBP.',
    );

const _rebalancePlan = IncomingTalentOperatingInboxOwnerRebalancePlan(
  ownerCount: 4,
  ownersNeedingReliefCount: 1,
  availableReliefOwnerCount: 2,
  reliefCapacity: 4,
  suggestedReassignmentCount: 2,
  criticalRecommendationCount: 1,
  nextAction: 'Reassign 2 urgent talent inbox items from critical owners.',
  recommendations: [_rebalanceRecommendation],
);

final _criticalPressure = IncomingTalentOperatingWorkstreamPressure(
  workstream: IncomingTalentOperatingWorkstream.riskCouncil,
  level: IncomingTalentOperatingWorkstreamPressureLevel.critical,
  totalCount: 4,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  ownerCount: 2,
  overloadedOwnerCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 1 overdue risk council item.',
  itemIds: const ['risk-overdue', 'risk-follow-up'],
);
