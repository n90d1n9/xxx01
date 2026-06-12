import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/workforce_planning/states/workforce_planning_provider.dart';

void main() {
  test('workforce planning summary aggregates planning signals', () {
    final container = ProviderContainer(
      overrides: [
        workforcePlanningAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(workforcePlanningSummaryProvider);

    expect(summary.totalPlanned, 180);
    expect(summary.totalActual, 172);
    expect(summary.forecastGap, 4);
    expect(summary.openPositions, 7);
    expect(summary.pendingApprovals, 1);
    expect(summary.highRisks, 1);
    expect(summary.budgetAtRisk, 810000);
  });

  test('attention filter keeps only actionable operations planning items', () {
    final container = ProviderContainer(
      overrides: [
        workforcePlanningAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(workforcePlanningDepartmentProvider.notifier).state =
        'Operations';
    container.read(workforcePlanningAttentionOnlyProvider.notifier).state =
        true;

    final summary = container.read(workforcePlanningSummaryProvider);
    final scenarios = container.read(filteredWorkforceScenariosProvider);

    expect(summary.totalPlanned, 96);
    expect(summary.totalActual, 88);
    expect(summary.forecastGap, 4);
    expect(summary.openPositions, 3);
    expect(summary.pendingApprovals, 1);
    expect(summary.highRisks, 1);
    expect(summary.budgetAtRisk, 612000);
    expect(scenarios.map((item) => item.name), ['Holiday coverage lift']);
  });

  test(
    'workforce planning risk summary aggregates urgent planning signals',
    () {
      final container = ProviderContainer(
        overrides: [
          workforcePlanningAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
      );
      addTearDown(container.dispose);

      final risks = container.read(workforcePlanningRiskSummaryProvider);

      expect(risks.planExceptions, 3);
      expect(risks.blockedRequests, 1);
      expect(risks.pendingApprovals, 1);
      expect(risks.highCapacityRisks, 1);
      expect(risks.lowConfidenceScenarios, 1);
      expect(risks.startsWithinThirtyDays, 2);
      expect(risks.totalRisks, 7);
    },
  );

  test('workforce planning date override drives target start dates', () {
    final container = ProviderContainer(
      overrides: [
        workforcePlanningAsOfDateProvider.overrideWithValue(
          DateTime(2026, 7, 10),
        ),
      ],
    );
    addTearDown(container.dispose);

    final positions = container.read(positionRequestsProvider);

    expect(positions.first.targetStartDate, DateTime(2026, 7, 31));
    expect(positions[2].targetStartDate, DateTime(2026, 7, 24));
  });
}
