import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_owner_workload_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_execution_owner_workload_panel.dart';

void main() {
  testWidgets('talent governance owner workload exposes owner pressure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceExecutionOwnerWorkloadItemsProvider
              .overrideWithValue(_items),
          incomingTalentGovernanceExecutionOwnerWorkloadSummaryProvider
              .overrideWithValue(
                IncomingTalentGovernanceExecutionOwnerWorkloadSummary.fromItems(
                  _items,
                ),
              ),
        ],
        child: _shell(
          const IncomingTalentGovernanceExecutionOwnerWorkloadPanel(),
        ),
      ),
    );

    expect(find.text('Talent governance owner workload'), findsOneWidget);
    expect(find.text('Owners'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('35% owner progress'), findsOneWidget);
    expect(find.text('People Risk and Assurance'), findsOneWidget);
    expect(
      find.text(
        'Rebalance 1 overdue governance execution action from People Risk and Assurance.',
      ),
      findsOneWidget,
    );
    expect(find.text('Jun 11'), findsOneWidget);
    expect(find.text('12 active signals'), findsOneWidget);
    expect(find.text('9 governance decisions'), findsOneWidget);
    expect(
      find.text('Rebalance 1 overdue governance execution action.'),
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
  IncomingTalentGovernanceExecutionOwnerWorkloadItem(
    ownerName: 'People Risk and Assurance',
    load: IncomingTalentGovernanceExecutionOwnerLoad.critical,
    actionCount: 2,
    criticalActionCount: 1,
    highActionCount: 1,
    standardActionCount: 0,
    overdueActionCount: 1,
    signalCount: 9,
    decisionCount: 6,
    readinessTaskCount: 2,
    earliestDueDate: DateTime(2026, 6, 11),
    averageProgressRatio: 0.25,
    nextAction:
        'Rebalance 1 overdue governance execution action from People Risk and Assurance.',
    actionIds: const [
      'talent-governance-execution-action:assurance-overdue',
      'talent-governance-execution-action:assurance-evidence',
    ],
  ),
  IncomingTalentGovernanceExecutionOwnerWorkloadItem(
    ownerName: 'Talent Operations',
    load: IncomingTalentGovernanceExecutionOwnerLoad.stretched,
    actionCount: 1,
    criticalActionCount: 0,
    highActionCount: 1,
    standardActionCount: 0,
    overdueActionCount: 0,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    earliestDueDate: DateTime(2026, 6, 15),
    averageProgressRatio: 0.45,
    nextAction:
        'Support Talent Operations on 1 high-priority governance execution action.',
    actionIds: const ['talent-governance-execution-action:action-sla'],
  ),
];
