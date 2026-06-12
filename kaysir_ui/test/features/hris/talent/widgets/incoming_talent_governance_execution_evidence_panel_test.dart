import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_evidence_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_execution_evidence_panel.dart';

void main() {
  testWidgets('governance execution evidence panel exposes audit readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceExecutionEvidenceItemsProvider
              .overrideWithValue(_items),
          incomingTalentGovernanceExecutionEvidenceSummaryProvider
              .overrideWithValue(
                IncomingTalentGovernanceExecutionEvidenceSummary.fromItems(
                  _items,
                ),
              ),
        ],
        child: _shell(const IncomingTalentGovernanceExecutionEvidencePanel()),
      ),
    );

    expect(find.text('Talent governance evidence register'), findsOneWidget);
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('Missing'), findsWidgets);
    expect(find.text('45% evidence readiness'), findsOneWidget);
    expect(find.text('Talent Operations - attach evidence'), findsOneWidget);
    expect(find.text('Attach action SLA recovery notes.'), findsOneWidget);
    expect(find.text('Due Jun 15'), findsOneWidget);
    expect(find.text('8 active signals'), findsOneWidget);
    expect(find.text('6 governance decisions'), findsOneWidget);
    expect(
      find.text('Attach evidence for 1 governance execution action.'),
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

final _items = [
  IncomingTalentGovernanceExecutionEvidenceItem(
    id: 'talent-governance-execution-evidence:action-sla',
    actionId: 'talent-governance-execution-action:action-sla',
    trackId: 'talent-governance-execution:action-sla',
    status: IncomingTalentGovernanceExecutionEvidenceStatus.missing,
    title: 'Talent Operations - attach evidence',
    evidenceRequirement: 'Attach action SLA recovery notes.',
    evidenceSummary: '',
    ownerConfirmationNote: '',
    ownerName: 'Talent Operations',
    reviewerName: '',
    dueDate: DateTime(2026, 6, 15),
    closureDate: null,
    nextReviewDate: null,
    residualRiskCount: 0,
    signalCount: 3,
    decisionCount: 3,
    readinessRatio: 0.2,
  ),
  IncomingTalentGovernanceExecutionEvidenceItem(
    id: 'talent-governance-execution-evidence:assurance',
    actionId: 'talent-governance-execution-action:assurance',
    trackId: 'talent-governance-execution:assurance',
    status: IncomingTalentGovernanceExecutionEvidenceStatus.monitor,
    title: 'People Risk and Assurance - recover overdue',
    evidenceRequirement:
        'Attach assurance approval evidence, owner confirmation, and recovery note.',
    evidenceSummary:
        'Closure evidence confirms assurance approval follow-through is attached.',
    ownerConfirmationNote:
        'Owner confirms recovery evidence and governance cadence.',
    ownerName: 'People Risk and Assurance',
    reviewerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    closureDate: DateTime(2026, 6, 12),
    nextReviewDate: DateTime(2026, 6, 26),
    residualRiskCount: 1,
    signalCount: 5,
    decisionCount: 3,
    readinessRatio: 0.7,
  ),
];
