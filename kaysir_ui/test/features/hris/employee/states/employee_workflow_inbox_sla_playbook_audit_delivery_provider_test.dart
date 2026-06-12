import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_action_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_audit_delivery_provider.dart';
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

  test(
    'employee workflow inbox SLA playbook audit delivery records copied exports',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final playbook =
          container.read(employeeWorkflowInboxSlaPlaybookProvider('4'))!;
      final readyStep = playbook.steps.singleWhere(
        (step) =>
            step.type ==
            EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
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
      final deliveryNotifier = container.read(
        employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider('4').notifier,
      );

      final peopleOpsDelivery = deliveryNotifier.recordDelivery(
        preview: export,
        role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations,
        action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyCsv,
        deliveredAt: DateTime(2026, 5, 30, 16),
      );

      expect(peopleOpsDelivery.id, 'EWPA-4-001');
      expect(
        peopleOpsDelivery.fileName,
        'employee-4-workflow-inbox-playbook-audit-full.csv',
      );
      expect(peopleOpsDelivery.rowCountLabel, '2 events');
      expect(peopleOpsDelivery.isRedacted, isFalse);
      expect(peopleOpsDelivery.isCsv, isTrue);

      final managerAccess =
          EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview(
            role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager,
            preview: export,
          );
      final managerDelivery = deliveryNotifier.recordDelivery(
        preview: managerAccess.exportPreview,
        role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager,
        action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyText,
        deliveredAt: DateTime(2026, 5, 30, 17),
      );

      expect(managerDelivery.id, 'EWPA-4-002');
      expect(
        managerDelivery.fileName,
        'employee-4-workflow-inbox-playbook-audit-full-manager-redacted.csv',
      );
      expect(
        managerDelivery.redaction,
        EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.managerSafe,
      );
      expect(managerDelivery.rowCount, 1);
      expect(managerDelivery.isRedacted, isTrue);
      expect(managerDelivery.isCsv, isFalse);

      final profile =
          container.read(
            employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider('4'),
          )!;
      expect(profile.totalCount, 2);
      expect(profile.csvCount, 1);
      expect(profile.textCount, 1);
      expect(profile.redactedCount, 1);
      expect(profile.latestReceipt?.id, 'EWPA-4-002');
      expect(
        profile.nextAction,
        'Latest delivery: Copy text by Manager - 1 event.',
      );
    },
  );

  test(
    'employee workflow inbox SLA playbook audit delivery blocks empty exports',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final export =
          container.read(
            employeeWorkflowInboxSlaPlaybookAuditExportProvider('4'),
          )!;

      expect(
        () => container
            .read(
              employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider(
                '4',
              ).notifier,
            )
            .recordDelivery(
              preview: export,
              role:
                  EmployeeWorkflowInboxSlaPlaybookAuditExportRole
                      .peopleOperations,
              action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyCsv,
            ),
        throwsStateError,
      );
    },
  );

  test(
    'employee workflow inbox SLA playbook audit delivery handles missing employee',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(
          employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider('missing'),
        ),
        isNull,
      );
    },
  );
}
