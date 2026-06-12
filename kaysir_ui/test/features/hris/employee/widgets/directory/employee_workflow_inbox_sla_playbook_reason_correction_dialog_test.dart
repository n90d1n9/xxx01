import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_action_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_workflow_inbox_sla_playbook_reason_correction_dialog.dart';

void main() {
  testWidgets('reason correction dialog validates changed reason', (
    tester,
  ) async {
    String? correctedReason;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => FilledButton(
                  onPressed: () async {
                    correctedReason =
                        await showEmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog(
                          context,
                          receipt: _buildReceipt(),
                        );
                  },
                  child: const Text('Open correction'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open correction'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-dialog',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Recovery started to prevent SLA drift'), findsWidgets);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-save-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change the reason before saving'), findsOneWidget);

    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-field',
        ),
      ),
      'Recovery owner changed to HR lead',
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-save-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(correctedReason, 'Recovery owner changed to HR lead');
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-dialog',
        ),
      ),
      findsNothing,
    );
  });
}

EmployeeWorkflowInboxSlaPlaybookActionReceipt _buildReceipt() {
  return EmployeeWorkflowInboxSlaPlaybookActionReceipt(
    id: 'EWP-4-001',
    employeeId: '4',
    employeeName: 'David Kim',
    stepId: 'ready',
    stepTitle: 'Clear ready inbox actions',
    stepType: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
    actor: 'People Operations',
    owner: 'People Operations',
    itemCount: 2,
    sources: const [EmployeeWorkflowInboxSource.profileChange],
    reason: 'Recovery started to prevent SLA drift',
    decidedAt: DateTime(2026, 6, 1),
  );
}
