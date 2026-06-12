import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';
import 'employee_workflow_inbox_sla_playbook_action_provider.dart';

/// Builds an export preview for one employee's SLA playbook audit receipts.
final employeeWorkflowInboxSlaPlaybookAuditExportProvider = Provider.family<
  EmployeeWorkflowInboxSlaPlaybookAuditExportPreview?,
  String
>((ref, employeeId) {
  final profile = ref.watch(
    employeeWorkflowInboxSlaPlaybookActionProvider(employeeId),
  );
  if (profile == null) return null;

  return EmployeeWorkflowInboxSlaPlaybookAuditExportPreview(
    profile: profile,
    generatedAt: profile.asOfDate,
  );
});
