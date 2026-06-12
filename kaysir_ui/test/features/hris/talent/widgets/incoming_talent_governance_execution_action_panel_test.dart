import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_action_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_execution_action_panel.dart';

void main() {
  testWidgets('talent governance action board exposes owner playbooks', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceExecutionActionsProvider.overrideWithValue(
            _actions,
          ),
          incomingTalentGovernanceExecutionActionSummaryProvider
              .overrideWithValue(
                IncomingTalentGovernanceExecutionActionSummary.fromActions(
                  _actions,
                ),
              ),
        ],
        child: _shell(const IncomingTalentGovernanceExecutionActionPanel()),
      ),
    );

    expect(find.text('Talent governance action board'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('28% average execution progress'), findsOneWidget);
    expect(
      find.text('People Risk and Assurance - recover overdue'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
      ),
      findsOneWidget,
    );
    expect(find.text('Jun 11'), findsOneWidget);
    expect(find.text('6 governance decisions'), findsOneWidget);
    expect(
      find.text('Close 1 critical governance execution action.'),
      findsOneWidget,
    );
  });
}

Widget _shell(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

final _actions = [
  IncomingTalentGovernanceExecutionAction(
    id:
        'talent-governance-execution-action:talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    trackId:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    priority: IncomingTalentGovernanceExecutionActionPriority.critical,
    title: 'People Risk and Assurance - recover overdue',
    detail: 'Execute assurance approval decision',
    nextAction:
        'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
    playbook:
        'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
    evidenceExpectation:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    progressRatio: 0.1,
    signalCount: 5,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: true,
  ),
  IncomingTalentGovernanceExecutionAction(
    id:
        'talent-governance-execution-action:talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    trackId:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    type: IncomingTalentGovernanceExecutionActionType.attachEvidence,
    priority: IncomingTalentGovernanceExecutionActionPriority.high,
    title: 'Talent Operations - attach evidence',
    detail: 'Execute action SLA unblock decision',
    nextAction:
        'Ask Talent Operations to attach execution evidence for execute action SLA unblock decision.',
    playbook:
        'Attach evidence, refresh notes, and make the audit trail reviewable.',
    evidenceExpectation:
        'Keep action SLA on weekly governance watch and confirm the accountable owner. Evidence: SLAs 8 with 3 active signals.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 14),
    progressRatio: 0.45,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: false,
  ),
];
