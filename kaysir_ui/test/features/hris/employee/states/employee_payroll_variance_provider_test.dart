import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_variance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_variance_provider.dart';

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

  test('employee payroll variance aggregates pay-impact signals', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePayrollVarianceProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.baselineGrossPay, 28000000);
    expect(profile.lines.length, 6);
    expect(profile.varianceRiskCount, 6);
    expect(profile.approvalRequiredCount, 6);
    expect(profile.attentionCount, 6);
    expect(profile.isWithinTolerance, isFalse);
    expect(
      profile.lines.map((line) => line.id),
      containsAll([
        'variance-payroll-profile',
        'variance-overtime-premium',
        'variance-reimbursement',
        'variance-cutoff-blockers',
      ]),
    );
    expect(profile.nextAction, 'Review 6 high-risk payroll variance items.');
  });

  test('employee payroll variance manual adjustment progresses workflow', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeePayrollVarianceAdjustmentDraftProvider('3').notifier,
    );
    draftNotifier
      ..setTitle('Retro deduction')
      ..setAmount(-250000)
      ..setOwner('Payroll Operations')
      ..setReason('Retro deduction for unpaid payroll correction.');

    final draft =
        container.read(employeePayrollVarianceAdjustmentDraftProvider('3'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeePayrollVarianceProvider('3').notifier,
    );
    final line = notifier.addAdjustment(draft);

    expect(line.id, 'EPV-3-001');
    expect(line.status, EmployeePayrollVarianceStatus.open);
    expect(line.amount, -250000);

    var profile = container.read(employeePayrollVarianceProvider('3'))!;
    expect(profile.manualAdjustmentCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.projectedGrossPay, profile.baselineGrossPay - 250000);

    notifier.reviewLine(line.id);
    var stored = container
        .read(employeePayrollVarianceProvider('3'))!
        .lines
        .singleWhere((item) => item.id == line.id);
    expect(stored.status, EmployeePayrollVarianceStatus.reviewed);

    notifier.approveLine(line.id);
    profile = container.read(employeePayrollVarianceProvider('3'))!;
    stored = profile.lines.singleWhere((item) => item.id == line.id);
    expect(stored.status, EmployeePayrollVarianceStatus.approved);
    expect(profile.attentionCount, 0);
  });

  test('employee payroll variance returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeePayrollVarianceProvider('missing')), isNull);
    expect(
      container.read(employeePayrollVarianceAdjustmentDraftProvider('missing')),
      isNull,
    );
  });
}
