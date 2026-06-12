import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/people_ops/states/people_ops_provider.dart';

void main() {
  test('people ops summary aggregates operational signals', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(peopleOpsSummaryProvider);

    expect(summary.openRoles, 3);
    expect(summary.hiresNeeded, 5);
    expect(summary.onboardingTasksDue, 10);
    expect(summary.complianceRisks, 3);
    expect(summary.averagePulseScore, 78);
  });

  test('risk view focuses operations people risks', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(peopleOpsDepartmentProvider.notifier).state = 'Operations';
    container.read(peopleOpsRiskOnlyProvider.notifier).state = true;

    final summary = container.read(peopleOpsSummaryProvider);
    final workforce = container.read(filteredWorkforcePlansProvider);
    final onboarding = container.read(filteredOnboardingMilestonesProvider);
    final compliance = container.read(filteredComplianceItemsProvider);
    final pulses = container.read(filteredEngagementPulsesProvider);

    expect(workforce.map((item) => item.role), ['Store Operations Lead']);
    expect(onboarding.map((item) => item.employeeName), ['Rizky Pratama']);
    expect(compliance.map((item) => item.title), ['Contract renewal packet']);
    expect(pulses.map((item) => item.department), ['Operations']);
    expect(summary.openRoles, 1);
    expect(summary.hiresNeeded, 2);
    expect(summary.onboardingTasksDue, 7);
    expect(summary.complianceRisks, 1);
    expect(summary.averagePulseScore, 68);
  });

  test('people ops risk summary aggregates urgent operations signals', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(peopleOpsRiskSummaryProvider);

    expect(risks.highPriorityHiringPlans, 2);
    expect(risks.blockedOnboarding, 1);
    expect(risks.overdueCompliance, 1);
    expect(risks.dueSoonCompliance, 2);
    expect(risks.lowEngagementPulses, 1);
    expect(risks.dueWithinFourteenDays, 6);
    expect(risks.totalRisks, 7);
  });

  test('people ops date override drives generated due dates', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final workforce = container.read(workforcePlansProvider);
    final onboarding = container.read(onboardingMilestonesProvider);
    final compliance = container.read(complianceItemsProvider);

    expect(workforce.first.targetDate, DateTime(2026, 7, 31));
    expect(onboarding.first.startDate, DateTime(2026, 7, 13));
    expect(compliance.first.dueDate, DateTime(2026, 7, 12));
  });
}
