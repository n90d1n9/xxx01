import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_engagement_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_engagement_provider.dart';

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

  test('employee engagement plan highlights watchlist retention risks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final plan = container.read(employeeEngagementPlanProvider('4'));

    expect(plan, isNotNull);
    expect(plan!.employeeName, 'David Kim');
    expect(plan.status, EmployeeEngagementStatus.critical);
    expect(plan.openSignalCount, 2);
    expect(plan.criticalSignalCount, 1);
    expect(plan.overdueSignalCount, 1);
    expect(plan.nextAction, 'Prioritize 1 critical retention signal.');
  });

  test('employee engagement pulse draft validates and appends pulse', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeEngagementPulseDraftProvider('1').notifier,
    );
    draftNotifier.setSentiment(EmployeeEngagementSentiment.energized);
    draftNotifier.setScore(5);
    draftNotifier.setSummary(
      'Employee feels strong momentum and clear support.',
    );
    draftNotifier.setNextStep('Keep stretch work visible.');

    final draft = container.read(employeeEngagementPulseDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final planNotifier = container.read(
      employeeEngagementPlanProvider('1').notifier,
    );
    final pulse = planNotifier.addPulse(draft);

    expect(pulse.id, 'EEP-1-003');
    expect(pulse.score, 5);
    expect(
      container.read(employeeEngagementPlanProvider('1'))!.pulses.length,
      3,
    );
  });

  test('employee engagement signal resolution updates next action', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeEngagementPlanProvider('4').notifier,
    );

    notifier.resolveSignal('4-signal-growth');
    final updatedPlan = container.read(employeeEngagementPlanProvider('4'))!;

    expect(updatedPlan.criticalSignalCount, 0);
    expect(updatedPlan.openSignalCount, 1);
    expect(updatedPlan.status, EmployeeEngagementStatus.watch);
    expect(
      updatedPlan.nextAction,
      'Follow through on 1 open retention signal.',
    );
  });
}
