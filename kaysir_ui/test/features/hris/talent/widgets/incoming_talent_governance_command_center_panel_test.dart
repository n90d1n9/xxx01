import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_command_center_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_command_center_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_command_center_panel.dart';

void main() {
  testWidgets('talent governance command center exposes executive lanes', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceCommandCenterProvider.overrideWithValue(
            _commandCenter,
          ),
        ],
        child: _shell(const IncomingTalentGovernanceCommandCenterPanel()),
      ),
    );

    expect(find.text('Talent governance command center'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Decisions'), findsOneWidget);
    expect(find.text('64% governance readiness'), findsOneWidget);
    expect(find.text('Assurance'), findsOneWidget);
    expect(find.text('Action SLA'), findsOneWidget);
    expect(
      find.text('Unblock 1 assurance remediation execution track.'),
      findsOneWidget,
    );
    expect(find.text('Gaps: 4'), findsOneWidget);
    expect(find.text('8 pending governance decisions'), findsOneWidget);
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

const _lanes = [
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-assurance',
    type: IncomingTalentGovernanceCommandLaneType.assurance,
    status: IncomingTalentGovernanceCommandStatus.critical,
    title: 'Assurance',
    detail: '4 evidence gaps, 3 remediation actions, 2 execution tracks.',
    metricLabel: 'Gaps',
    metricValue: '4',
    nextAction: 'Unblock 1 assurance remediation execution track.',
    pressureRatio: 0.74,
    signalCount: 5,
    decisionCount: 3,
  ),
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-action-sla',
    type: IncomingTalentGovernanceCommandLaneType.actionSla,
    status: IncomingTalentGovernanceCommandStatus.watch,
    title: 'Action SLA',
    detail: '0 overdue, 1 today, 2 at risk across 5 sources.',
    metricLabel: 'SLAs',
    metricValue: '8',
    nextAction: 'Close 1 talent operating SLA item due today.',
    pressureRatio: 0.42,
    signalCount: 3,
    decisionCount: 3,
  ),
];

const _commandCenter = IncomingTalentGovernanceCommandCenter(
  status: IncomingTalentGovernanceCommandStatus.critical,
  governanceScore: 64,
  laneCount: 7,
  criticalLaneCount: 1,
  watchLaneCount: 3,
  stableLaneCount: 3,
  totalSignalCount: 12,
  decisionCount: 8,
  nextAction:
      'Run governance review for 1 critical talent lane: Unblock 1 assurance remediation execution track.',
  lanes: _lanes,
);
