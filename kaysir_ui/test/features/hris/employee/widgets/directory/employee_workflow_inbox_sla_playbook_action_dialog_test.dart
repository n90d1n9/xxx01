import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_workflow_inbox_sla_playbook_action_dialog.dart';

void main() {
  testWidgets('playbook action dialog validates and returns a reason', (
    tester,
  ) async {
    String? capturedReason;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => FilledButton(
                  onPressed: () async {
                    capturedReason =
                        await showEmployeeWorkflowInboxSlaPlaybookActionDialog(
                          context,
                          step: _buildStep(),
                        );
                  },
                  child: const Text('Open action'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open action'));
    await tester.pumpAndSettle();

    expect(find.text('Record playbook action'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-record-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Add a reason before recording this action'),
      findsOneWidget,
    );

    final suggestion = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-action-reason-suggestion-recovery-started-to-prevent-sla-drift',
      ),
    );
    await tester.tap(suggestion);
    await tester.pump();

    await tester.tap(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-record-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(capturedReason, 'Recovery started to prevent SLA drift');
    expect(find.text('Record playbook action'), findsNothing);
  });
}

EmployeeWorkflowInboxSlaPlaybookStep _buildStep() {
  return EmployeeWorkflowInboxSlaPlaybookStep(
    id: 'ready',
    type: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.high,
    title: 'Clear ready inbox actions',
    detail: 'Run ready workflow actions before the SLA queue drifts.',
    owner: 'People Operations',
    signalIds: const ['profile-change-EPC-4-001'],
    sources: const [EmployeeWorkflowInboxSource.profileChange],
    dueDate: DateTime(2026, 6, 1),
  );
}
