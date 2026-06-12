import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_manager_change_readiness_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_manager_change_readiness_provider.dart';

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

  test('employee manager change readiness highlights blocked handoff', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeManagerChangeReadinessProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.changeType, EmployeeManagerChangeType.interimManager);
    expect(profile.currentManager, 'Olivia Wilson');
    expect(profile.targetManager, 'Nadia Rahman');
    expect(profile.targetDiffers, isTrue);
    expect(profile.blockedCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.highRiskOpenCount, 2);
    expect(profile.attentionCount, 3);
    expect(profile.isEffectiveSoon, isTrue);
    expect(profile.nextAction, 'Clear 1 blocked manager-change item.');
  });

  test(
    'employee manager change readiness adds updates and waives checklist',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeeManagerChangeChecklistDraftProvider('2').notifier,
      );
      draftNotifier.setType(
        EmployeeManagerChangeChecklistType.approvalCoverage,
      );
      draftNotifier.setTitle('Confirm delegated promotion approvals');
      draftNotifier.setOwner('People Operations');
      draftNotifier.setRisk(EmployeeManagerChangeRisk.high);
      draftNotifier.setDueDate(DateTime(2026, 6, 4));
      draftNotifier.setDetail(
        'Route approvals to the receiving manager group.',
      );

      final draft =
          container.read(employeeManagerChangeChecklistDraftProvider('2'))!;
      expect(draft.isReadyToAdd, isTrue);
      expect(draft.completionRatio, 1);

      final readinessNotifier = container.read(
        employeeManagerChangeReadinessProvider('2').notifier,
      );
      final item = readinessNotifier.addChecklistItem(draft);

      expect(item.id, 'MGR-2-004');
      expect(item.status, EmployeeManagerChangeChecklistStatus.actionRequired);

      readinessNotifier.updateChecklistStatus(
        item.id,
        EmployeeManagerChangeChecklistStatus.ready,
      );
      var profile =
          container.read(employeeManagerChangeReadinessProvider('2'))!;

      expect(
        profile.checklist.singleWhere((entry) => entry.id == item.id).isReady,
        isTrue,
      );

      readinessNotifier.waiveChecklistItem('2-manager-access');
      profile = container.read(employeeManagerChangeReadinessProvider('2'))!;

      expect(profile.waivedCount, 1);
      expect(
        profile.checklist
            .singleWhere((entry) => entry.id == '2-manager-access')
            .status,
        EmployeeManagerChangeChecklistStatus.waived,
      );
    },
  );

  test(
    'employee manager change readiness returns null for missing employee',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(employeeManagerChangeReadinessProvider('missing')),
        isNull,
      );
      expect(
        container.read(employeeManagerChangeChecklistDraftProvider('missing')),
        isNull,
      );
    },
  );
}
