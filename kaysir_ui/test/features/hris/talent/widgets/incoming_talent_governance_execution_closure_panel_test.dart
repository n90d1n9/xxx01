import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_closure_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_execution_closure_panel.dart';

void main() {
  testWidgets(
    'governance execution closure panel exposes closure form and record',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            closureReadyTalentGovernanceExecutionActionsProvider
                .overrideWithValue(_actions),
            incomingTalentGovernanceExecutionClosuresProvider.overrideWith(
              (_) => _PreviewClosuresNotifier(_closures),
            ),
            incomingTalentGovernanceExecutionClosureSummaryProvider
                .overrideWithValue(
                  IncomingTalentGovernanceExecutionClosureSummary.fromClosures(
                    _closures,
                  ),
                ),
          ],
          child: _shell(const IncomingTalentGovernanceExecutionClosurePanel()),
        ),
      );

      expect(find.text('Talent governance closure reviews'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Submit closure'), findsOneWidget);
      expect(find.text('Closure reviewer'), findsOneWidget);
      expect(find.text('People Risk and Assurance'), findsOneWidget);
      expect(
        find.text('Monitor closure evidence in the next governance check-in.'),
        findsWidgets,
      );
      expect(find.text('Jun 12'), findsOneWidget);
      expect(find.text('1 residual risks'), findsOneWidget);
      expect(
        find.text('Monitor 1 governance execution closure with residual risk.'),
        findsOneWidget,
      );
    },
  );
}

class _PreviewClosuresNotifier
    extends IncomingTalentGovernanceExecutionClosuresNotifier {
  _PreviewClosuresNotifier(
    List<IncomingTalentGovernanceExecutionClosure> items,
  ) {
    state = items;
  }
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
        'talent-governance-execution-action:talent-governance-execution:assurance-overdue',
    trackId: 'talent-governance-execution:assurance-overdue',
    type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    priority: IncomingTalentGovernanceExecutionActionPriority.critical,
    title: 'People Risk and Assurance - recover overdue',
    detail: 'Execute assurance approval decision',
    nextAction:
        'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
    playbook:
        'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
    evidenceExpectation:
        'Attach assurance approval evidence, owner confirmation, and recovery note.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    progressRatio: 0.1,
    signalCount: 5,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: true,
  ),
];

final _closures = [
  IncomingTalentGovernanceExecutionClosure(
    id: 'talent-governance-execution-closure-001',
    actionId:
        'talent-governance-execution-action:talent-governance-execution:assurance-overdue',
    trackId: 'talent-governance-execution:assurance-overdue',
    ownerName: 'People Risk and Assurance',
    reviewerName: 'People Risk and Assurance',
    actionType: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    actionPriority: IncomingTalentGovernanceExecutionActionPriority.critical,
    actionDueDate: DateTime(2026, 6, 11),
    closureDate: DateTime(2026, 6, 12),
    outcome: IncomingTalentGovernanceExecutionClosureOutcome.monitor,
    residualRiskCount: 1,
    evidenceSummary:
        'Closure evidence confirms assurance approval follow-through is attached.',
    ownerConfirmationNote:
        'Owner confirms recovery evidence and governance cadence.',
    nextAction: 'Monitor closure evidence in the next governance check-in.',
    nextReviewDate: DateTime(2026, 6, 26),
    signalCount: 5,
    decisionCount: 3,
    createdAt: DateTime(2026, 6, 12),
  ),
];
