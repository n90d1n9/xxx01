import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_council_agenda_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_governance_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('coverage council agenda prioritizes critical overdue records', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(
      asOfDate,
      records: [
        _record(
          id: 'critical',
          scopeLabel: 'Finance',
          stage: IncomingTalentSuccessionCoverageGovernanceStage.actionRequired,
          riskLevel:
              IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
          dueDate: asOfDate.subtract(const Duration(days: 1)),
          coverageScore: 38,
        ),
      ],
    );
    addTearDown(container.dispose);

    final item =
        container
            .read(incomingTalentSuccessionCoverageCouncilAgendaItemsProvider)
            .single;
    final summary = container.read(
      incomingTalentSuccessionCoverageCouncilAgendaSummaryProvider,
    );

    expect(item.scopeLabel, 'Finance');
    expect(
      item.priority,
      IncomingTalentSuccessionCoverageCouncilAgendaPriority.urgent,
    );
    expect(
      item.lane,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.executiveDecision,
    );
    expect(item.councilDate, asOfDate);
    expect(item.isOverdue(asOfDate), isTrue);
    expect(summary.totalItems, 1);
    expect(summary.urgentCount, 1);
    expect(summary.executiveDecisionCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.nextAction, 'Open 1 urgent coverage council decisions.');
  });

  test('coverage council agenda excludes closed low-risk records', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(
      asOfDate,
      records: [
        _record(
          id: 'closed',
          scopeLabel: 'Engineering',
          stage: IncomingTalentSuccessionCoverageGovernanceStage.closed,
          riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.low,
          dueDate: asOfDate.add(const Duration(days: 60)),
          coverageScore: 92,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentSuccessionCoverageCouncilAgendaItemsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageCouncilAgendaSummaryProvider,
    );

    expect(items, isEmpty);
    expect(summary.totalItems, 0);
    expect(
      summary.nextAction,
      'No coverage council items are ready for discussion.',
    );
  });

  test('coverage council agenda sorts and summarizes lanes', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(
      asOfDate,
      records: [
        _record(
          id: 'outcome-watch',
          scopeLabel: 'Operations',
          stage: IncomingTalentSuccessionCoverageGovernanceStage.outcomeWatch,
          riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.high,
          dueDate: asOfDate.add(const Duration(days: 20)),
          coverageScore: 64,
        ),
        _record(
          id: 'action-open',
          scopeLabel: 'Engineering',
          stage: IncomingTalentSuccessionCoverageGovernanceStage.actionOpen,
          riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium,
          dueDate: asOfDate.add(const Duration(days: 2)),
          coverageScore: 72,
        ),
        _record(
          id: 'outcome-review',
          scopeLabel: 'Product',
          stage: IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview,
          riskLevel: IncomingTalentSuccessionCoverageGovernanceRiskLevel.low,
          dueDate: asOfDate.add(const Duration(days: 14)),
          coverageScore: 82,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentSuccessionCoverageCouncilAgendaItemsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageCouncilAgendaSummaryProvider,
    );

    expect(items.map((item) => item.scopeLabel), [
      'Engineering',
      'Operations',
      'Product',
    ]);
    expect(
      items.first.priority,
      IncomingTalentSuccessionCoverageCouncilAgendaPriority.high,
    );
    expect(
      items.first.lane,
      IncomingTalentSuccessionCoverageCouncilAgendaLane.actionFollowUp,
    );
    expect(summary.highCount, 2);
    expect(summary.actionFollowUpCount, 1);
    expect(summary.validationCount, 1);
    expect(summary.monitoringCount, 1);
    expect(summary.averageCoverageScore, closeTo(72.67, 0.01));
    expect(summary.nextAction, 'Review 2 high-priority coverage items.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentSuccessionCoverageGovernanceRecord> records,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentSuccessionCoverageGovernanceRecordsProvider
          .overrideWithValue(records),
    ],
  );
}

IncomingTalentSuccessionCoverageGovernanceRecord _record({
  required String id,
  required String scopeLabel,
  required IncomingTalentSuccessionCoverageGovernanceStage stage,
  required IncomingTalentSuccessionCoverageGovernanceRiskLevel riskLevel,
  required DateTime dueDate,
  required int coverageScore,
}) {
  return IncomingTalentSuccessionCoverageGovernanceRecord(
    id: 'coverage-governance:$id',
    reviewId: 'review-$id',
    actionId: 'action-$id',
    outcomeId:
        stage == IncomingTalentSuccessionCoverageGovernanceStage.closed
            ? 'outcome-$id'
            : null,
    scopeLabel: scopeLabel,
    departmentScope: scopeLabel,
    attentionOnly: false,
    ownerName: '$scopeLabel Owner',
    stage: stage,
    riskLevel: riskLevel,
    reviewDecision: IncomingTalentSuccessionCoverageReviewDecision.watch,
    coverageHealth:
        riskLevel ==
                IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical
            ? IncomingTalentSuccessionCoverageHealth.critical
            : IncomingTalentSuccessionCoverageHealth.watch,
    coverageScore: coverageScore,
    actionType: IncomingTalentSuccessionCoverageActionType.slateRework,
    actionStatus: IncomingTalentSuccessionCoverageActionStatus.inProgress,
    outcomeDecision: null,
    residualRisk: null,
    openedAt: DateTime(2026, 6, 1),
    dueDate: dueDate,
    nextAction: 'Resolve $scopeLabel succession coverage risk.',
    evidenceSummary:
        '$scopeLabel coverage evidence shows successor readiness gaps.',
  );
}
