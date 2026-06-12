import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_vault_coverage_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_vault_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_coverage_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_provider.dart';

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

  test('employee document vault coverage detects required gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final coverage =
        container.read(employeeDocumentVaultCoverageProvider('4'))!;

    expect(coverage.employeeName, 'David Kim');
    expect(coverage.requiredCount, 5);
    expect(coverage.completeCount, 2);
    expect(coverage.attentionCount, 3);
    expect(coverage.missingCount, 2);
    expect(coverage.expiringCount, 1);
    expect(coverage.restrictedCount, 1);
    expect(coverage.completionLabel, '40% covered');
    expect(coverage.nextAction, 'Collect 2 required documents.');

    final payroll = coverage.items.singleWhere(
      (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
    );
    expect(payroll.status, EmployeeDocumentVaultCoverageStatus.missing);

    final workAuthorization = coverage.items.singleWhere(
      (item) =>
          item.category == EmployeeDocumentVaultCategory.workAuthorization,
    );
    expect(
      workAuthorization.status,
      EmployeeDocumentVaultCoverageStatus.expiringSoon,
    );
  });

  test('employee document vault coverage follows vault mutations', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDocumentVaultDraftProvider('3').notifier,
    );
    draftNotifier.setCategory(EmployeeDocumentVaultCategory.payrollTax);
    draftNotifier.setAccess(EmployeeDocumentVaultAccess.hrOnly);
    draftNotifier.setTitle('Payroll tax declaration');
    draftNotifier.setOwner('Payroll Operations');
    draftNotifier.setSummary(
      'Payroll tax declaration uploaded for required document coverage.',
    );

    final profileNotifier = container.read(
      employeeDocumentVaultProfileProvider('3').notifier,
    );
    final draft = container.read(employeeDocumentVaultDraftProvider('3'))!;
    final record = profileNotifier.submitDraft(draft);

    var coverage = container.read(employeeDocumentVaultCoverageProvider('3'))!;
    expect(coverage.requiredCount, 4);
    expect(coverage.completeCount, 2);
    expect(coverage.missingCount, 1);
    expect(
      coverage.items
          .singleWhere(
            (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
          )
          .status,
      EmployeeDocumentVaultCoverageStatus.reviewNeeded,
    );

    profileNotifier.verify(record.id);

    coverage = container.read(employeeDocumentVaultCoverageProvider('3'))!;
    expect(coverage.completeCount, 3);
    expect(coverage.missingCount, 1);
    expect(
      coverage.items
          .singleWhere(
            (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
          )
          .status,
      EmployeeDocumentVaultCoverageStatus.complete,
    );
  });

  test('employee document vault coverage handles missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeDocumentVaultCoverageProvider('missing')),
      isNull,
    );
  });
}
