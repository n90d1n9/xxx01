import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_action_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_action_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_audit_export_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_provider.dart';

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

  test('employee workflow inbox SLA playbook audit export packages receipts', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final playbook =
        container.read(employeeWorkflowInboxSlaPlaybookProvider('4'))!;
    final readyStep = playbook.steps.singleWhere(
      (step) =>
          step.type == EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    );

    final actionReceipt = container
        .read(employeeWorkflowInboxSlaPlaybookActionProvider('4').notifier)
        .recordAction(
          readyStep,
          actor: 'HR Lead',
          reason: 'Ready queue needs closure',
        );
    container
        .read(employeeWorkflowInboxSlaPlaybookActionProvider('4').notifier)
        .correctReason(
          actionReceipt.id,
          actor: 'HR Auditor',
          reason: 'Ready queue assigned to HR lead for same-day closure',
        );

    final export =
        container.read(
          employeeWorkflowInboxSlaPlaybookAuditExportProvider('4'),
        )!;

    expect(
      export.status,
      EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.ready,
    );
    expect(
      export.fileName,
      'employee-4-workflow-inbox-playbook-audit-full.csv',
    );
    expect(export.rowCountLabel, '2 events');
    expect(
      export.countFor(EmployeeWorkflowInboxSlaPlaybookAuditExportScope.actions),
      1,
    );
    expect(
      export.countFor(
        EmployeeWorkflowInboxSlaPlaybookAuditExportScope.corrections,
      ),
      1,
    );
    expect(export.manifestItems.map((item) => item.label), contains('Sources'));
    expect(
      export.csvContent,
      contains('receipt_id,employee_id,employee_name,event_kind,action'),
    );
    expect(export.csvContent, contains('EWP-4-001,4,David Kim,Action'));
    expect(
      export.csvContent,
      contains('EWP-4-002,4,David Kim,Reason correction'),
    );
    expect(export.plainTextContent, contains('Playbook audit package'));
    expect(export.plainTextContent, contains('Corrects: EWP-4-001'));
    expect(
      export.plainTextContent,
      contains('Previous: Ready queue needs closure'),
    );

    final correctionExport = export.copyWith(
      scope: EmployeeWorkflowInboxSlaPlaybookAuditExportScope.corrections,
    );
    expect(correctionExport.rowCount, 1);
    expect(
      correctionExport.fileName,
      'employee-4-workflow-inbox-playbook-audit-corrections.csv',
    );

    final emptyCorrectionExport =
        EmployeeWorkflowInboxSlaPlaybookAuditExportPreview(
          profile: EmployeeWorkflowInboxSlaPlaybookActionProfile(
            employeeId: '4',
            employeeName: 'David Kim',
            asOfDate: DateTime(2026, 5, 30),
            receipts: [actionReceipt],
          ),
          generatedAt: DateTime(2026, 5, 30),
          scope: EmployeeWorkflowInboxSlaPlaybookAuditExportScope.corrections,
        );
    expect(
      emptyCorrectionExport.status,
      EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.empty,
    );
    expect(
      emptyCorrectionExport.exportActionLabel,
      'No corrections match this audit scope',
    );

    final peopleOpsAccess =
        EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview(
          role:
              EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations,
          preview: export,
        );
    expect(peopleOpsAccess.copyCsvPermission.allowed, isTrue);
    expect(peopleOpsAccess.copyTextPermission.allowed, isTrue);
    expect(peopleOpsAccess.statusLabel, 'Copy ready');

    final auditorAccess =
        EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview(
          role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.hrAuditor,
          preview: export,
        );
    expect(auditorAccess.copyCsvPermission.allowed, isFalse);
    expect(auditorAccess.copyTextPermission.allowed, isFalse);
    expect(
      auditorAccess.copyCsvPermission.reason,
      'HR auditor can review playbook audit packages but cannot copy CSV files.',
    );

    final managerFullAccess =
        EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview(
          role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager,
          preview: export,
        );
    expect(managerFullAccess.copyCsvPermission.allowed, isTrue);
    expect(managerFullAccess.copyTextPermission.allowed, isTrue);
    expect(
      managerFullAccess.exportPreview.redaction,
      EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.managerSafe,
    );
    expect(
      managerFullAccess.exportPreview.fileName,
      'employee-4-workflow-inbox-playbook-audit-full-manager-redacted.csv',
    );
    expect(managerFullAccess.exportPreview.rowCount, 1);
    expect(
      managerFullAccess.exportPreview.csvContent,
      isNot(contains('Reason correction')),
    );
    expect(
      managerFullAccess.exportPreview.plainTextContent,
      isNot(contains('Previous: Ready queue needs closure')),
    );
    expect(
      managerFullAccess.copyCsvPermission.reason,
      'Manager can copy this redacted playbook audit CSV.',
    );

    final managerCorrectionAccess =
        EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview(
          role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager,
          preview: export.copyWith(
            scope: EmployeeWorkflowInboxSlaPlaybookAuditExportScope.corrections,
          ),
        );
    expect(managerCorrectionAccess.copyCsvPermission.allowed, isFalse);
    expect(
      managerCorrectionAccess.copyCsvPermission.reason,
      'No redacted events match this audit scope',
    );
  });

  test(
    'employee workflow inbox SLA playbook audit export handles missing employee',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(
          employeeWorkflowInboxSlaPlaybookAuditExportProvider('missing'),
        ),
        isNull,
      );
    },
  );
}
