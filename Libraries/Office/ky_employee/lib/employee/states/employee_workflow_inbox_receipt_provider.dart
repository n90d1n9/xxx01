import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_workflow_inbox_models.dart';
import '../models/employee_workflow_inbox_receipt_models.dart';
import 'employee_workflow_inbox_provider.dart';

/// Stores immutable HR workflow inbox action receipts for one employee.
final employeeWorkflowInboxReceiptProvider = StateNotifierProvider.family<
  EmployeeWorkflowInboxReceiptNotifier,
  EmployeeWorkflowInboxReceiptProfile?,
  String
>((ref, employeeId) {
  final inbox = ref.read(employeeWorkflowInboxProvider(employeeId));
  if (inbox == null) {
    return EmployeeWorkflowInboxReceiptNotifier(null);
  }

  return EmployeeWorkflowInboxReceiptNotifier(
    EmployeeWorkflowInboxReceiptProfile(
      employeeId: inbox.employeeId,
      employeeName: inbox.employeeName,
      asOfDate: inbox.asOfDate,
      receipts: const [],
    ),
  );
});

/// Mutates the local receipt stream when inbox actions are executed.
class EmployeeWorkflowInboxReceiptNotifier
    extends StateNotifier<EmployeeWorkflowInboxReceiptProfile?> {
  EmployeeWorkflowInboxReceiptNotifier(super.state);

  EmployeeWorkflowInboxActionReceipt recordAction(
    EmployeeWorkflowInboxItem item, {
    String actor = 'People Operations',
  }) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee workflow inbox receipts are unavailable');
    }
    if (!item.hasPrimaryAction) {
      throw StateError('Workflow inbox item does not have an action');
    }

    final receipt = EmployeeWorkflowInboxActionReceipt(
      id: _nextReceiptId(profile),
      employeeId: item.employeeId,
      employeeName: item.employeeName,
      workflowItemId: item.id,
      sourceRecordId: item.sourceRecordId,
      title: item.title,
      source: item.source,
      action: item.primaryAction,
      area: item.area,
      actor: actor.trim().isEmpty ? 'People Operations' : actor.trim(),
      owner: item.owner,
      previousStatus: item.statusLabel,
      decidedAt: profile.asOfDate,
    );

    state = profile.copyWith(receipts: [receipt, ...profile.receipts]);
    return receipt;
  }

  String _nextReceiptId(EmployeeWorkflowInboxReceiptProfile profile) {
    var index = profile.receipts.length + 1;
    while (true) {
      final id =
          'EWI-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.receipts.any((receipt) => receipt.id == id)) {
        return id;
      }
      index++;
    }
  }
}
