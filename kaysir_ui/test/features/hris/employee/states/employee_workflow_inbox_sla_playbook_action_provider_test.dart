import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_action_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_action_provider.dart';
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

  test('employee workflow inbox SLA playbook records action receipts', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final playbook =
        container.read(employeeWorkflowInboxSlaPlaybookProvider('4'))!;
    final readyStep = playbook.steps.singleWhere(
      (step) =>
          step.type == EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    );

    final receipt = container
        .read(employeeWorkflowInboxSlaPlaybookActionProvider('4').notifier)
        .recordAction(
          readyStep,
          actor: 'HR Lead',
          reason: '  Ready queue   needs closure  ',
        );
    final profile =
        container.read(employeeWorkflowInboxSlaPlaybookActionProvider('4'))!;

    expect(receipt.id, 'EWP-4-001');
    expect(receipt.employeeName, 'David Kim');
    expect(
      receipt.actionType,
      EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
    );
    expect(receipt.actor, 'HR Lead');
    expect(receipt.hasReason, isTrue);
    expect(receipt.reasonLabel, 'Ready queue needs closure');
    expect(
      receipt.summaryLabel,
      'Start recovery recorded for ready clearance.',
    );
    expect(profile.latestForStep(readyStep.id), receipt);
    expect(profile.hasReceipts, isTrue);
    expect(profile.totalCount, 1);
    expect(profile.reasonedCount, 1);
    expect(profile.reasonCoverageLabel, '1/1 with reason');
    expect(profile.nextAction, '1 playbook action recorded.');
    expect(profile.ownerCoverageLabel, readyStep.owner);
    expect(profile.latestActionLabel, 'Start recovery by HR Lead.');
    expect(
      profile.auditSummary,
      '1 event logged across ${readyStep.owner} with no escalations.',
    );

    final secondReceipt = container
        .read(employeeWorkflowInboxSlaPlaybookActionProvider('4').notifier)
        .recordAction(readyStep, actor: ' ');
    final updated =
        container.read(employeeWorkflowInboxSlaPlaybookActionProvider('4'))!;

    expect(secondReceipt.id, 'EWP-4-002');
    expect(secondReceipt.actor, 'People Operations');
    expect(secondReceipt.hasReason, isFalse);
    expect(secondReceipt.reasonLabel, 'No reason provided');
    expect(updated.latestReceipts.map((receipt) => receipt.id), [
      'EWP-4-002',
      'EWP-4-001',
    ]);
    expect(updated.reasonedCount, 1);
    expect(updated.reasonCoverageLabel, '1/2 with reason');
    expect(updated.latestActionLabel, 'Start recovery by People Operations.');
    expect(
      updated.auditSummary,
      '2 events logged across ${readyStep.owner} with no escalations.',
    );

    final activeFilter = EmployeeWorkflowInboxSlaPlaybookActionAuditFilter(
      actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
      owner: readyStep.owner,
    );
    expect(updated.actionTypes, [
      EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
    ]);
    expect(
      updated.receiptsForFilter(activeFilter).map((receipt) => receipt.id),
      ['EWP-4-002', 'EWP-4-001'],
    );
    expect(
      updated.receiptsForFilter(activeFilter.withOwner('Unassigned')),
      isEmpty,
    );

    final correction = container
        .read(employeeWorkflowInboxSlaPlaybookActionProvider('4').notifier)
        .correctReason(
          receipt.id,
          actor: 'HR Auditor',
          reason: 'Ready queue assigned to HR lead for same-day closure',
        );
    final corrected =
        container.read(employeeWorkflowInboxSlaPlaybookActionProvider('4'))!;

    expect(correction.id, 'EWP-4-003');
    expect(
      correction.receiptKind,
      EmployeeWorkflowInboxSlaPlaybookActionReceiptKind.reasonCorrection,
    );
    expect(correction.actionLabel, 'Reason correction');
    expect(correction.correctedReceiptId, receipt.id);
    expect(correction.actor, 'HR Auditor');
    expect(correction.previousReasonLabel, 'Ready queue needs closure');
    expect(
      correction.reasonLabel,
      'Ready queue assigned to HR lead for same-day closure',
    );
    expect(
      correction.summaryLabel,
      'Reason correction recorded for ready clearance.',
    );
    expect(corrected.correctionCount, 1);
    expect(corrected.reasonCoverageLabel, '2/3 with reason');
    expect(corrected.latestReceipts.map((receipt) => receipt.id), [
      'EWP-4-003',
      'EWP-4-002',
      'EWP-4-001',
    ]);
  });

  test('employee workflow inbox SLA playbook action mapping is role aware', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final playbook =
        container.read(employeeWorkflowInboxSlaPlaybookProvider('4'))!;
    final rebalanceStep = playbook.steps.singleWhere(
      (step) =>
          step.type == EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance,
      orElse:
          () => EmployeeWorkflowInboxSlaPlaybookStep(
            id: 'rebalance-preview',
            type: EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance,
            urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.medium,
            title: 'Balance owner workload',
            detail: 'Move work away from an overloaded queue.',
            owner: 'People Operations',
            signalIds: const [],
            sources: const [],
            dueDate: DateTime(2026, 5, 30),
          ),
    );

    expect(
      employeeWorkflowInboxSlaPlaybookActionForStep(rebalanceStep),
      EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup,
    );
  });

  test(
    'employee workflow inbox SLA playbook actions return null for missing employee',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(
          employeeWorkflowInboxSlaPlaybookActionProvider('missing'),
        ),
        isNull,
      );
    },
  );
}
