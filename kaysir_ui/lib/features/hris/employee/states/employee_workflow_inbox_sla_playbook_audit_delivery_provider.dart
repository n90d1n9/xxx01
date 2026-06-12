import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_workflow_inbox_sla_playbook_audit_delivery_models.dart';
import '../models/employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import '../models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';
import 'employee_workflow_inbox_sla_playbook_action_provider.dart';

/// Stores delivery receipts for copied workflow inbox SLA playbook audit exports.
final employeeWorkflowInboxSlaPlaybookAuditDeliveryProvider =
    StateNotifierProvider.family<
      EmployeeWorkflowInboxSlaPlaybookAuditDeliveryNotifier,
      EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile?,
      String
    >((ref, employeeId) {
      final profile = ref.read(
        employeeWorkflowInboxSlaPlaybookActionProvider(employeeId),
      );
      if (profile == null) {
        return EmployeeWorkflowInboxSlaPlaybookAuditDeliveryNotifier(null);
      }

      return EmployeeWorkflowInboxSlaPlaybookAuditDeliveryNotifier(
        EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile(
          employeeId: profile.employeeId,
          employeeName: profile.employeeName,
          asOfDate: profile.asOfDate,
          deliveries: const [],
        ),
      );
    });

/// Mutates the local delivery history when playbook audit exports are copied.
class EmployeeWorkflowInboxSlaPlaybookAuditDeliveryNotifier
    extends
        StateNotifier<EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile?> {
  EmployeeWorkflowInboxSlaPlaybookAuditDeliveryNotifier(super.state);

  EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt recordDelivery({
    required EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview,
    required EmployeeWorkflowInboxSlaPlaybookAuditExportRole role,
    required EmployeeWorkflowInboxSlaPlaybookAuditExportAction action,
    DateTime? deliveredAt,
  }) {
    final profile = state;
    if (profile == null) {
      throw StateError('Playbook audit export delivery history is unavailable');
    }
    if (!preview.isReady) {
      throw StateError('Playbook audit export package is not ready');
    }

    final receipt = EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt(
      id: _nextDeliveryId(profile),
      employeeId: preview.profile.employeeId,
      employeeName: preview.profile.employeeName,
      role: role,
      action: action,
      scope: preview.scope,
      redaction: preview.redaction,
      status: EmployeeWorkflowInboxSlaPlaybookAuditDeliveryStatus.copied,
      fileName: preview.fileName,
      rowCount: preview.rowCount,
      generatedAt: preview.generatedAt,
      deliveredAt: deliveredAt ?? profile.asOfDate,
    );

    state = profile.copyWith(deliveries: [receipt, ...profile.deliveries]);
    return receipt;
  }

  String _nextDeliveryId(
    EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile profile,
  ) {
    var index = profile.deliveries.length + 1;
    while (true) {
      final id =
          'EWPA-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.deliveries.any((delivery) => delivery.id == id)) {
        return id;
      }
      index++;
    }
  }
}
