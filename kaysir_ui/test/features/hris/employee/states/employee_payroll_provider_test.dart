import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_provider.dart';

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

  test('employee payroll profile highlights setup gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePayrollProfileProvider('5'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'Olivia Wilson');
    expect(profile.bankAttentionCount, 1);
    expect(profile.taxAttentionCount, 1);
    expect(profile.submittedChangeCount, 1);
    expect(profile.attentionCount, 3);
    expect(profile.nextAction, 'Verify payroll bank account.');
  });

  test('employee payroll change draft validates and submits', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeePayrollChangeDraftProvider('3').notifier,
    );
    draftNotifier
      ..setType(EmployeePayrollChangeType.taxWithholding)
      ..setTitle('Update payroll tax profile')
      ..setDetail('Employee submitted updated payroll tax withholding form.');

    final draft = container.read(employeePayrollChangeDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);

    final profileNotifier = container.read(
      employeePayrollProfileProvider('3').notifier,
    );
    final request = profileNotifier.submitDraft(draft);
    final profile = container.read(employeePayrollProfileProvider('3'))!;

    expect(request.id, 'EPC-3-001');
    expect(request.status, EmployeePayrollChangeStatus.submitted);
    expect(profile.submittedChangeCount, 1);
    expect(profile.changes.first.detail, contains('tax withholding'));
  });

  test('employee payroll actions verify records and apply changes', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeePayrollProfileProvider('4').notifier,
    );

    notifier.markBankVerified();
    notifier.markTaxCurrent();

    var profile = container.read(employeePayrollProfileProvider('4'))!;
    expect(profile.bankAttentionCount, 0);
    expect(profile.taxAttentionCount, 0);
    expect(profile.submittedChangeCount, 1);

    notifier.approveChange('EPC-4-001');
    profile = container.read(employeePayrollProfileProvider('4'))!;
    expect(profile.submittedChangeCount, 0);
    expect(profile.approvedChangeCount, 1);

    notifier.applyChange('EPC-4-001');
    profile = container.read(employeePayrollProfileProvider('4'))!;
    expect(profile.attentionCount, 0);
    expect(profile.changes.first.status, EmployeePayrollChangeStatus.applied);
    expect(profile.taxProfile.status, EmployeeTaxFormStatus.current);
    expect(profile.nextAction, 'Payroll profile is current.');
  });
}
