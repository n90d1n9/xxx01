import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_performance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_performance_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee performance plan highlights watchlist goal risk', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final plan = container.read(employeePerformancePlanProvider('4'));

    expect(plan, isNotNull);
    expect(plan!.employeeName, 'David Kim');
    expect(plan.cycleStatus, EmployeePerformanceCycleStatus.attention);
    expect(plan.atRiskGoalCount, 2);
    expect(plan.nextAction, 'Coach 2 at-risk goals.');
  });

  test('employee performance goal updates can make a review ready', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeePerformancePlanProvider('4').notifier,
    );
    final plan = container.read(employeePerformancePlanProvider('4'))!;

    for (final goal in plan.goals) {
      notifier.updateGoalStatus(
        goal.id,
        EmployeePerformanceGoalStatus.complete,
      );
    }

    final updatedPlan = container.read(employeePerformancePlanProvider('4'))!;

    expect(updatedPlan.completeGoalCount, 3);
    expect(updatedPlan.weightedProgress, 1);
    expect(
      updatedPlan.cycleStatus,
      EmployeePerformanceCycleStatus.readyForReview,
    );
    expect(updatedPlan.nextAction, 'Prepare calibration notes for review.');
  });

  test('employee performance check-in draft validates and appends note', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeePerformanceCheckInDraftProvider('1').notifier,
    );
    draftNotifier.setSentiment(EmployeePerformanceCheckInSentiment.positive);
    draftNotifier.setSummary(
      'Manager confirmed strong design delivery momentum.',
    );
    draftNotifier.setNextStep('Prepare calibration examples.');

    final draft = container.read(employeePerformanceCheckInDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final planNotifier = container.read(
      employeePerformancePlanProvider('1').notifier,
    );
    final checkIn = planNotifier.addCheckIn(draft);

    expect(checkIn.id, 'EPI-1-002');
    expect(checkIn.sentiment, EmployeePerformanceCheckInSentiment.positive);
    expect(
      container.read(employeePerformancePlanProvider('1'))!.checkIns.length,
      2,
    );
  });
}
