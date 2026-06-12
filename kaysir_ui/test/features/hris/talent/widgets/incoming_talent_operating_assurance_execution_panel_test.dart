import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_assurance_execution_panel.dart';

void main() {
  testWidgets('talent assurance execution panel exposes remediation progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingAssuranceExecutionTracksProvider
              .overrideWithValue(_tracks),
          incomingTalentOperatingAssuranceExecutionSummaryProvider
              .overrideWithValue(
                IncomingTalentOperatingAssuranceExecutionSummary.fromTracks(
                  _tracks,
                ),
              ),
        ],
        child: _shell(const IncomingTalentOperatingAssuranceExecutionPanel()),
      ),
    );

    expect(find.text('Talent remediation execution'), findsOneWidget);
    expect(find.text('Tracks'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(
      find.text('People Operations Talent Partner execution - Risk council'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Unblock linked risk council escalations with People Operations Talent Partner.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        '3 linked escalations must be cleared before assurance closure.',
      ),
      findsOneWidget,
    );
    expect(find.text('3 proofs'), findsWidgets);
    expect(
      find.text('Unblock 1 assurance remediation execution track.'),
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

final _tracks = [
  IncomingTalentOperatingAssuranceExecutionTrack(
    id: 'assurance-execution-assurance-remediation-people-operations-risk',
    remediationActionId: 'assurance-remediation-people-operations-risk',
    status: IncomingTalentOperatingAssuranceExecutionStatus.blocked,
    dueHealth: IncomingTalentOperatingAssuranceExecutionDueHealth.overdue,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Risk council',
    title: 'People Operations Talent Partner execution - Risk council',
    detail: '2 open gaps with 3 completion proofs required',
    blocker: '3 linked escalations must be cleared before assurance closure.',
    nextStep:
        'Unblock linked risk council escalations with People Operations Talent Partner.',
    dueDate: DateTime(2026, 6, 10),
    executionRatio: 0.26,
    openGapCount: 2,
    overdueGapCount: 1,
    dueTodayGapCount: 0,
    linkedEscalationCount: 3,
    completionEvidence: [
      'Attach decision notes, owner commitment, and follow-up acceptance.',
      'Owner confirmation for 2 gaps.',
      'HRIS closure note for risk council assurance.',
    ],
    gapIds: ['evidence-risk-overdue', 'evidence-risk-linked'],
  ),
  IncomingTalentOperatingAssuranceExecutionTrack(
    id: 'assurance-execution-assurance-remediation-learning-development',
    remediationActionId: 'assurance-remediation-learning-development',
    status: IncomingTalentOperatingAssuranceExecutionStatus.dueToday,
    dueHealth: IncomingTalentOperatingAssuranceExecutionDueHealth.dueToday,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.high,
    ownerName: 'Learning Partner',
    workstreamLabel: 'Development',
    title: 'Learning Partner execution - Development',
    detail: '1 open gap with 3 completion proofs required',
    blocker: '1 due-today gap needs same-day proof.',
    nextStep: 'Close due-today development evidence before the HRIS cut-off.',
    dueDate: DateTime(2026, 6, 11),
    executionRatio: 0.62,
    openGapCount: 1,
    overdueGapCount: 0,
    dueTodayGapCount: 1,
    linkedEscalationCount: 0,
    completionEvidence: [
      'Attach attendance, completion proof, and learner feedback.',
      'Owner confirmation for 1 gap.',
      'HRIS closure note for development assurance.',
    ],
    gapIds: ['evidence-training-today'],
  ),
];
