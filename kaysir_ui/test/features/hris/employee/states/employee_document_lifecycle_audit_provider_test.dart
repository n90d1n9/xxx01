import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_vault_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_lifecycle_audit_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_request_provider.dart';
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

  test(
    'employee document lifecycle audit records request and vault events',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final coverage =
          container.read(employeeDocumentVaultCoverageProvider('4'))!;
      final payrollGap = coverage.items.singleWhere(
        (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
      );
      final requestNotifier = container.read(
        employeeDocumentRequestProfileProvider('4').notifier,
      );
      final vaultNotifier = container.read(
        employeeDocumentVaultProfileProvider('4').notifier,
      );
      final auditNotifier = container.read(
        employeeDocumentLifecycleAuditProvider('4').notifier,
      );

      final request = requestNotifier.submitCoverageRequest(payrollGap);
      auditNotifier.recordRequest(
        request: request,
        type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
      );

      requestNotifier.issueRequest(request.id);
      final issued = container
          .read(employeeDocumentRequestProfileProvider('4'))!
          .requests
          .singleWhere((item) => item.id == request.id);
      auditNotifier.recordRequest(
        request: issued,
        type: EmployeeDocumentLifecycleAuditEventType.requestIssued,
      );

      final fulfilled = vaultNotifier.fulfillCoverageRequest(issued);
      auditNotifier.recordVault(
        record: fulfilled,
        type: EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
      );

      final audit =
          container.read(employeeDocumentLifecycleAuditProvider('4'))!;
      expect(audit.totalCount, 3);
      expect(audit.requestCount, 2);
      expect(audit.vaultCount, 0);
      expect(audit.fulfillmentCount, 1);
      expect(audit.latestEntries.first.typeLabel, 'Vault fulfilled');
      expect(
        audit.nextAction,
        'Latest document event: Vault fulfilled for Payroll and tax evidence.',
      );
    },
  );

  test('employee document lifecycle audit handles missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeDocumentLifecycleAuditProvider('missing')),
      isNull,
    );
  });
}
