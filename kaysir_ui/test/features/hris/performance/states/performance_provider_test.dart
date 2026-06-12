import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/performance/states/performance_provider.dart';

void main() {
  test('performance summary aggregates performance signals', () {
    final container = ProviderContainer(
      overrides: [
        performanceAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(performanceSummaryProvider);

    expect(summary.activeGoals, 3);
    expect(summary.reviewsDue, 11);
    expect(summary.calibrationFlags, 2);
    expect(summary.successorsReady, 1);
    expect(summary.highRetentionRisks, 1);
  });

  test('attention filter focuses operations performance exceptions', () {
    final container = ProviderContainer(
      overrides: [
        performanceAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(performanceDepartmentProvider.notifier).state = 'Operations';
    container.read(performanceAttentionOnlyProvider.notifier).state = true;

    final summary = container.read(performanceSummaryProvider);
    final goals = container.read(filteredGoalProgressProvider);
    final calibration = container.read(filteredCalibrationItemsProvider);

    expect(goals.map((item) => item.employeeName), ['Rizky Pratama']);
    expect(calibration.map((item) => item.employeeName), [
      'Rizky Pratama',
      'Casey Johnson',
    ]);
    expect(summary.activeGoals, 1);
    expect(summary.reviewsDue, 7);
    expect(summary.calibrationFlags, 2);
    expect(summary.successorsReady, 0);
    expect(summary.highRetentionRisks, 1);
  });

  test('performance risk summary aggregates urgent talent signals', () {
    final container = ProviderContainer(
      overrides: [
        performanceAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(performanceRiskSummaryProvider);

    expect(risks.atRiskGoals, 1);
    expect(risks.overdueReviews, 1);
    expect(risks.calibrationExceptions, 2);
    expect(risks.developingSuccessors, 2);
    expect(risks.highRetentionRisks, 1);
    expect(risks.dueWithinFourteenDays, 7);
    expect(risks.totalRisks, 7);
  });

  test('performance date override drives generated due dates', () {
    final container = ProviderContainer(
      overrides: [
        performanceAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final goals = container.read(goalProgressProvider);
    final reviews = container.read(reviewCyclesProvider);
    final retention = container.read(retentionRisksProvider);

    expect(goals.first.dueDate, DateTime(2026, 7, 28));
    expect(reviews.first.dueDate, DateTime(2026, 7, 15));
    expect(retention.first.reviewDate, DateTime(2026, 7, 12));
  });
}
