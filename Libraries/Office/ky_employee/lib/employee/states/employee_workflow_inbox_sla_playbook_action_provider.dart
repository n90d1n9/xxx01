import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../models/employee_workflow_inbox_sla_playbook_models.dart';
import 'employee_workflow_inbox_sla_playbook_provider.dart';

/// Stores action receipts created from workflow inbox SLA playbook steps.
final employeeWorkflowInboxSlaPlaybookActionProvider =
    StateNotifierProvider.family<
      EmployeeWorkflowInboxSlaPlaybookActionNotifier,
      EmployeeWorkflowInboxSlaPlaybookActionProfile?,
      String
    >((ref, employeeId) {
      final playbook = ref.read(
        employeeWorkflowInboxSlaPlaybookProvider(employeeId),
      );
      if (playbook == null) {
        return EmployeeWorkflowInboxSlaPlaybookActionNotifier(null);
      }

      return EmployeeWorkflowInboxSlaPlaybookActionNotifier(
        EmployeeWorkflowInboxSlaPlaybookActionProfile(
          employeeId: playbook.employeeId,
          employeeName: playbook.employeeName,
          asOfDate: playbook.asOfDate,
          receipts: const [],
        ),
      );
    });

/// Mutates local playbook action receipts for one employee.
class EmployeeWorkflowInboxSlaPlaybookActionNotifier
    extends StateNotifier<EmployeeWorkflowInboxSlaPlaybookActionProfile?> {
  EmployeeWorkflowInboxSlaPlaybookActionNotifier(super.state);

  EmployeeWorkflowInboxSlaPlaybookActionReceipt recordAction(
    EmployeeWorkflowInboxSlaPlaybookStep step, {
    String actor = 'People Operations',
    String reason = '',
  }) {
    final profile = state;
    if (profile == null) {
      throw StateError('Workflow inbox SLA playbook actions are unavailable');
    }

    final receipt = EmployeeWorkflowInboxSlaPlaybookActionReceipt(
      id: _nextReceiptId(profile),
      employeeId: profile.employeeId,
      employeeName: profile.employeeName,
      stepId: step.id,
      stepTitle: step.title,
      stepType: step.type,
      actionType: employeeWorkflowInboxSlaPlaybookActionForStep(step),
      actor: _normalizeActor(actor),
      owner: step.owner,
      itemCount: step.itemCount,
      sources: step.sources,
      reason: _normalizeReason(reason),
      decidedAt: profile.asOfDate,
    );

    state = profile.copyWith(receipts: [receipt, ...profile.receipts]);
    return receipt;
  }

  EmployeeWorkflowInboxSlaPlaybookActionReceipt correctReason(
    String receiptId, {
    String actor = 'People Operations',
    required String reason,
  }) {
    final profile = state;
    if (profile == null) {
      throw StateError('Workflow inbox SLA playbook actions are unavailable');
    }

    EmployeeWorkflowInboxSlaPlaybookActionReceipt? sourceReceipt;
    for (final receipt in profile.receipts) {
      if (receipt.id == receiptId) {
        sourceReceipt = receipt;
        break;
      }
    }
    if (sourceReceipt == null) {
      throw StateError('Workflow inbox SLA playbook action receipt not found');
    }

    final normalizedReason = _normalizeReason(reason);
    if (normalizedReason.isEmpty) {
      throw StateError('Workflow inbox SLA playbook reason is required');
    }
    if (normalizedReason == sourceReceipt.reasonLabel) {
      throw StateError('Workflow inbox SLA playbook reason is unchanged');
    }

    final receipt = EmployeeWorkflowInboxSlaPlaybookActionReceipt(
      id: _nextReceiptId(profile),
      receiptKind:
          EmployeeWorkflowInboxSlaPlaybookActionReceiptKind.reasonCorrection,
      employeeId: profile.employeeId,
      employeeName: profile.employeeName,
      stepId: sourceReceipt.stepId,
      stepTitle: sourceReceipt.stepTitle,
      stepType: sourceReceipt.stepType,
      actionType: sourceReceipt.actionType,
      actor: _normalizeActor(actor),
      owner: sourceReceipt.owner,
      itemCount: sourceReceipt.itemCount,
      sources: sourceReceipt.sources,
      reason: normalizedReason,
      previousReason: sourceReceipt.reasonLabel,
      correctedReceiptId: sourceReceipt.id,
      decidedAt: profile.asOfDate,
    );

    state = profile.copyWith(receipts: [receipt, ...profile.receipts]);
    return receipt;
  }

  String _nextReceiptId(EmployeeWorkflowInboxSlaPlaybookActionProfile profile) {
    var index = profile.receipts.length + 1;
    while (true) {
      final id =
          'EWP-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.receipts.any((receipt) => receipt.id == id)) {
        return id;
      }
      index++;
    }
  }

  String _normalizeReason(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeActor(String value) {
    final actor = value.trim();
    return actor.isEmpty ? 'People Operations' : actor;
  }
}
