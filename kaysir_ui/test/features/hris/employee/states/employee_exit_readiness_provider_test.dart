import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_exit_readiness_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_exit_readiness_provider.dart';

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

  test('employee exit readiness highlights blocked offboarding work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeExitReadinessProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.exitType, EmployeeExitType.involuntary);
    expect(profile.finalWorkday, DateTime(2026, 6, 9));
    expect(profile.blockedCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.highRiskOpenCount, 4);
    expect(profile.attentionCount, 4);
    expect(profile.isExitImminent, isTrue);
    expect(profile.nextAction, 'Clear 1 blocked exit clearance item.');
  });

  test('employee exit readiness adds completes and waives clearance items', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeExitClearanceDraftProvider('2').notifier,
    );
    draftNotifier.setTitle('Recover production signing certificate');
    draftNotifier.setOwner('IT Security');
    draftNotifier.setCategory(EmployeeExitClearanceCategory.access);
    draftNotifier.setRisk(EmployeeExitRisk.high);
    draftNotifier.setDueDate(DateTime(2026, 6, 3));
    draftNotifier.setNote('Coordinate with Engineering Operations.');

    final draft = container.read(employeeExitClearanceDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final readinessNotifier = container.read(
      employeeExitReadinessProvider('2').notifier,
    );
    final item = readinessNotifier.addItem(draft);

    expect(item.id, 'EXIT-2-004');
    expect(item.title, 'Recover production signing certificate');
    expect(item.status, EmployeeExitClearanceStatus.open);

    readinessNotifier.updateItemStatus(
      item.id,
      EmployeeExitClearanceStatus.complete,
    );
    var profile = container.read(employeeExitReadinessProvider('2'))!;

    expect(
      profile.items.singleWhere((entry) => entry.id == item.id).isComplete,
      isTrue,
    );

    readinessNotifier.waiveItem('2-exit-transfer-access');
    profile = container.read(employeeExitReadinessProvider('2'))!;

    expect(profile.waivedCount, 1);
    expect(
      profile.items
          .singleWhere((entry) => entry.id == '2-exit-transfer-access')
          .status,
      EmployeeExitClearanceStatus.waived,
    );
  });

  test('employee exit readiness returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeExitReadinessProvider('missing')), isNull);
    expect(
      container.read(employeeExitClearanceDraftProvider('missing')),
      isNull,
    );
  });
}
