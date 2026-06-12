import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_action_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_workflow_inbox_sla_playbook_action_timeline.dart';

void main() {
  testWidgets('playbook action timeline filters audit history', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeeWorkflowInboxSlaPlaybookActionTimeline(
              profile: _buildProfile(),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-002',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-001',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Showing 2 of 2 audit events'), findsOneWidget);
    expect(find.text('2/2 with reason'), findsOneWidget);
    expect(find.text('Recovery started to prevent SLA drift'), findsOneWidget);
    expect(find.text('Backup reviewer needed to protect SLA'), findsOneWidget);

    final ownerFilter = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-owner-filter-hr-business-partner',
      ),
    );
    await tester.ensureVisible(ownerFilter);
    await tester.tap(ownerFilter);
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-002',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-001',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Showing 1 of 2 audit events'), findsOneWidget);

    final startRecoveryFilter = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-action-filter-startRecovery',
      ),
    );
    await tester.ensureVisible(startRecoveryFilter);
    await tester.tap(startRecoveryFilter);
    await tester.pumpAndSettle();

    expect(
      find.text('No playbook audit events match these filters'),
      findsOneWidget,
    );
    expect(find.text('Showing 0 of 2 audit events'), findsOneWidget);

    final allOwnersFilter = find.byKey(
      const ValueKey('employee-workflow-inbox-sla-playbook-owner-filter-all'),
    );
    await tester.ensureVisible(allOwnersFilter);
    await tester.tap(allOwnersFilter);
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-002',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-001',
        ),
      ),
      findsNothing,
    );
    expect(find.text('Showing 1 of 2 audit events'), findsOneWidget);

    final clearFilter = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-action-filter-clear',
      ),
    );
    await tester.ensureVisible(clearFilter);
    await tester.tap(clearFilter);
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-002',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-001',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Showing 2 of 2 audit events'), findsOneWidget);
  });

  testWidgets('playbook action timeline renders correction receipts', (
    tester,
  ) async {
    String? selectedReceiptId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeeWorkflowInboxSlaPlaybookActionTimeline(
              profile: _buildCorrectedProfile(),
              onCorrectReason: (receipt) => selectedReceiptId = receipt.id,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Reason correction'), findsOneWidget);
    expect(find.text('1 correction'), findsOneWidget);
    expect(
      find.text('Ready queue assigned to HR lead for same-day closure'),
      findsOneWidget,
    );
    expect(
      find.text('Previous: Recovery started to prevent SLA drift'),
      findsOneWidget,
    );

    final correctionButton = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-correct-reason-EWP-4-003',
      ),
    );
    await tester.ensureVisible(correctionButton);
    await tester.tap(correctionButton);
    await tester.pump();

    expect(selectedReceiptId, 'EWP-4-003');
  });
}

EmployeeWorkflowInboxSlaPlaybookActionProfile _buildProfile() {
  return EmployeeWorkflowInboxSlaPlaybookActionProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-002',
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
      ),
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'rebalance',
        stepTitle: 'Balance inbox owner load',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup,
        actor: 'HR Lead',
        owner: 'HR Business Partner',
        itemCount: 3,
        sources: const [
          EmployeeWorkflowInboxSource.actionWorkflow,
          EmployeeWorkflowInboxSource.jobAssignment,
        ],
        reason: 'Backup reviewer needed to protect SLA',
        decidedAt: DateTime(2026, 5, 31),
      ),
    ],
  );
}

EmployeeWorkflowInboxSlaPlaybookActionProfile _buildCorrectedProfile() {
  return EmployeeWorkflowInboxSlaPlaybookActionProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-003',
        receiptKind:
            EmployeeWorkflowInboxSlaPlaybookActionReceiptKind.reasonCorrection,
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'ready',
        stepTitle: 'Clear ready inbox actions',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
        actor: 'HR Auditor',
        owner: 'People Operations',
        itemCount: 2,
        sources: const [EmployeeWorkflowInboxSource.profileChange],
        reason: 'Ready queue assigned to HR lead for same-day closure',
        previousReason: 'Recovery started to prevent SLA drift',
        correctedReceiptId: 'EWP-4-002',
        decidedAt: DateTime(2026, 6, 1),
      ),
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-002',
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
      ),
    ],
  );
}
