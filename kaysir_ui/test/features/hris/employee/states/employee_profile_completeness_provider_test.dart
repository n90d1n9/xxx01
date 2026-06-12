import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_profile_completeness_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_profile_completeness_provider.dart';

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

  test('employee profile completeness summarizes module readiness', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeProfileCompletenessProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(
      profile.items,
      hasLength(EmployeeProfileCompletenessArea.values.length),
    );
    expect(profile.score, inInclusiveRange(0, 100));
    expect(profile.actionRequiredCount, greaterThan(0));
    expect(profile.openCount, greaterThan(0));
    expect(profile.nextAction, isNot('Employee profile is complete.'));

    final vaultItem = profile.items.singleWhere(
      (item) => item.area == EmployeeProfileCompletenessArea.documentVault,
    );
    expect(vaultItem.status, EmployeeProfileCompletenessStatus.inProgress);
    expect(vaultItem.nextAction, 'Renew 1 document before expiry.');
  });

  test('employee profile completeness reacts to resolved vault gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final initial = container.read(employeeProfileCompletenessProvider('5'))!;
    final initialVault = initial.items.singleWhere(
      (item) => item.area == EmployeeProfileCompletenessArea.documentVault,
    );
    expect(
      initialVault.status,
      EmployeeProfileCompletenessStatus.actionRequired,
    );

    final vaultNotifier = container.read(
      employeeDocumentVaultProfileProvider('5').notifier,
    );
    vaultNotifier.verify('EDV-5-001');
    vaultNotifier.verify('EDV-5-002');

    final updated = container.read(employeeProfileCompletenessProvider('5'))!;
    final updatedVault = updated.items.singleWhere(
      (item) => item.area == EmployeeProfileCompletenessArea.documentVault,
    );

    expect(updatedVault.status, EmployeeProfileCompletenessStatus.complete);
    expect(updated.score, greaterThan(initial.score));
  });

  test('employee profile completeness returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeProfileCompletenessProvider('missing')),
      isNull,
    );
  });
}
