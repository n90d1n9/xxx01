import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_workflow_inbox_receipt_export_models.dart';
import 'employee_workflow_inbox_receipt_provider.dart';

/// Builds a CSV export preview for one employee's workflow inbox receipts.
final employeeWorkflowInboxReceiptExportProvider = Provider.family<
  EmployeeWorkflowInboxReceiptExportPreview?,
  String
>((ref, employeeId) {
  final receipts = ref.watch(employeeWorkflowInboxReceiptProvider(employeeId));
  if (receipts == null) return null;

  return EmployeeWorkflowInboxReceiptExportPreview(
    profile: receipts,
    generatedAt: receipts.asOfDate,
  );
});
