import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_action_activity_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_action_activity_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

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

  test('employee action activity seeds system entries for workflow tasks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeActionActivityProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.activeTasks, isNotEmpty);
    expect(profile.entries, isNotEmpty);
    expect(
      profile.entries.map((entry) => entry.type),
      everyElement(EmployeeActionActivityType.system),
    );
    expect(profile.nextAction, contains('Add collaboration notes'));
  });

  test('employee action activity adds and acknowledges blocker updates', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeActionActivityDraftProvider('4').notifier,
    );
    draftNotifier.setType(EmployeeActionActivityType.blocker);
    draftNotifier.setBody('Waiting on payroll manager confirmation.');

    final draft = container.read(employeeActionActivityDraftProvider('4'))!;
    expect(draft.isReadyToAdd, isTrue);

    final notifier = container.read(
      employeeActionActivityProvider('4').notifier,
    );
    final entry = notifier.addDraft(draft);

    var profile = container.read(employeeActionActivityProvider('4'))!;
    expect(entry.requiresAcknowledgement, isTrue);
    expect(profile.pendingAcknowledgementCount, 1);
    expect(profile.blockerCount, 1);

    notifier.acknowledge(entry.id);
    profile = container.read(employeeActionActivityProvider('4'))!;
    expect(profile.pendingAcknowledgementCount, 0);
  });

  test('employee action activity returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeActionActivityProvider('missing')), isNull);
    expect(
      container.read(employeeActionActivityDraftProvider('missing')),
      isNull,
    );
  });
}
