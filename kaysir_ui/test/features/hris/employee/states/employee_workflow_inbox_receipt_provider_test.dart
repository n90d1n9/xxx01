import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_next_action_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_receipt_export_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_receipt_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_receipt_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_receipt_export_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_receipt_provider.dart';

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

  test('employee workflow inbox receipt records completed action context', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final item = container
        .read(employeeWorkflowInboxProvider('4'))!
        .items
        .singleWhere(
          (item) => item.source == EmployeeWorkflowInboxSource.profileChange,
        );

    final receipt = container
        .read(employeeWorkflowInboxReceiptProvider('4').notifier)
        .recordAction(item, actor: 'HR Operations');

    expect(receipt.id, 'EWI-4-001');
    expect(receipt.workflowItemId, item.id);
    expect(receipt.sourceRecordId, 'EPC-4-seed-001');
    expect(receipt.action, EmployeeWorkflowInboxAction.apply);
    expect(receipt.previousStatus, 'Scheduled');
    expect(receipt.summaryLabel, 'Apply completed from Profile change.');
    expect(receipt.ownershipLabel, 'HR Operations for People Operations');

    final profile = container.read(employeeWorkflowInboxReceiptProvider('4'))!;
    expect(profile.totalCount, 1);
    expect(profile.governedCount, 1);
    expect(profile.latestReceipt, receipt);
    expect(profile.nextAction, 'Latest receipt: Apply Manager change.');

    final export =
        container.read(employeeWorkflowInboxReceiptExportProvider('4'))!;
    expect(export.status, EmployeeWorkflowInboxReceiptExportStatus.ready);
    expect(export.fileName, 'employee-4-workflow-inbox-receipts-all.csv');
    expect(export.rowCountLabel, '1 receipt');
    expect(
      export.countFor(EmployeeWorkflowInboxReceiptExportScope.profileChange),
      1,
    );
    expect(export.countFor(EmployeeWorkflowInboxReceiptExportScope.payroll), 0);
    expect(export.manifestItems.map((item) => item.label), contains('Rows'));
    expect(
      export.csvContent,
      contains(
        'receipt_id,employee_id,employee_name,workflow_item_id,source_record_id',
      ),
    );
    expect(export.csvContent, contains('EWI-4-001,4,David Kim'));

    final payrollExport = export.copyWith(
      scope: EmployeeWorkflowInboxReceiptExportScope.payroll,
    );
    expect(
      payrollExport.status,
      EmployeeWorkflowInboxReceiptExportStatus.empty,
    );
    expect(payrollExport.rowCount, 0);
    expect(
      payrollExport.exportActionLabel,
      'No payroll receipts match this export scope',
    );

    final peopleOpsAccess = EmployeeWorkflowInboxReceiptExportAccessReview(
      role: EmployeeWorkflowInboxReceiptExportRole.peopleOperations,
      preview: export,
    );
    expect(peopleOpsAccess.copyCsvPermission.allowed, isTrue);
    expect(peopleOpsAccess.statusLabel, 'Copy ready');

    final payrollAccess = EmployeeWorkflowInboxReceiptExportAccessReview(
      role: EmployeeWorkflowInboxReceiptExportRole.payrollOfficer,
      preview: export,
    );
    expect(payrollAccess.copyCsvPermission.allowed, isFalse);
    expect(
      payrollAccess.copyCsvPermission.reason,
      'Switch to Payroll receipts to copy as payroll officer.',
    );

    final auditorAccess = EmployeeWorkflowInboxReceiptExportAccessReview(
      role: EmployeeWorkflowInboxReceiptExportRole.hrAuditor,
      preview: export,
    );
    expect(auditorAccess.copyCsvPermission.allowed, isFalse);
    expect(auditorAccess.statusLabel, 'View only');
  });

  test('employee workflow inbox receipt returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeWorkflowInboxReceiptProvider('missing')),
      isNull,
    );
  });

  test(
    'employee workflow inbox receipt export access gates sensitive scopes',
    () {
      final profile = EmployeeWorkflowInboxReceiptProfile(
        employeeId: '4',
        employeeName: 'David Kim',
        asOfDate: DateTime(2026, 5, 30),
        receipts: [
          _receipt(
            id: 'payroll',
            source: EmployeeWorkflowInboxSource.actionWorkflow,
            action: EmployeeWorkflowInboxAction.complete,
            area: EmployeeNextActionArea.pay,
          ),
          _receipt(
            id: 'correction',
            source: EmployeeWorkflowInboxSource.dataCorrection,
            action: EmployeeWorkflowInboxAction.apply,
            area: EmployeeNextActionArea.profile,
          ),
        ],
      );
      final preview = EmployeeWorkflowInboxReceiptExportPreview(
        profile: profile,
        generatedAt: DateTime(2026, 5, 30),
      );

      final payrollAccess = EmployeeWorkflowInboxReceiptExportAccessReview(
        role: EmployeeWorkflowInboxReceiptExportRole.payrollOfficer,
        preview: preview.copyWith(
          scope: EmployeeWorkflowInboxReceiptExportScope.payroll,
        ),
      );
      expect(payrollAccess.copyCsvPermission.allowed, isTrue);

      final managerAllAccess = EmployeeWorkflowInboxReceiptExportAccessReview(
        role: EmployeeWorkflowInboxReceiptExportRole.manager,
        preview: preview,
      );
      expect(managerAllAccess.copyCsvPermission.allowed, isFalse);
      expect(
        managerAllAccess.copyCsvPermission.reason,
        'Manager cannot copy exports that include payroll data.',
      );

      final managerCorrectionAccess =
          EmployeeWorkflowInboxReceiptExportAccessReview(
            role: EmployeeWorkflowInboxReceiptExportRole.manager,
            preview: preview.copyWith(
              scope: EmployeeWorkflowInboxReceiptExportScope.dataCorrection,
            ),
          );
      expect(managerCorrectionAccess.copyCsvPermission.allowed, isFalse);
      expect(
        managerCorrectionAccess.copyCsvPermission.reason,
        'Manager cannot copy data correction receipt exports.',
      );
    },
  );
}

EmployeeWorkflowInboxActionReceipt _receipt({
  required String id,
  required EmployeeWorkflowInboxSource source,
  required EmployeeWorkflowInboxAction action,
  required EmployeeNextActionArea area,
}) {
  return EmployeeWorkflowInboxActionReceipt(
    id: 'EWI-4-$id',
    employeeId: '4',
    employeeName: 'David Kim',
    workflowItemId: '$id-item',
    sourceRecordId: '$id-source',
    title: '$id receipt',
    source: source,
    action: action,
    area: area,
    actor: 'People Operations',
    owner: 'People Operations',
    previousStatus: 'Open',
    decidedAt: DateTime(2026, 5, 30),
  );
}
