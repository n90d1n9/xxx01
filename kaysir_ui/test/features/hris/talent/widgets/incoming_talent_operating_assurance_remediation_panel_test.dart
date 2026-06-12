import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_assurance_remediation_panel.dart';

void main() {
  testWidgets('talent assurance remediation panel exposes owner actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingAssuranceRemediationActionsProvider
              .overrideWithValue(_actions),
          incomingTalentOperatingAssuranceRemediationSummaryProvider
              .overrideWithValue(
                IncomingTalentOperatingAssuranceRemediationSummary.fromActions(
                  _actions,
                ),
              ),
        ],
        child: _shell(const IncomingTalentOperatingAssuranceRemediationPanel()),
      ),
    );

    expect(find.text('Talent assurance remediation'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(
      find.text('People Operations Talent Partner - Risk council evidence'),
      findsOneWidget,
    );
    expect(
      find.text('Learning Partner - Development evidence'),
      findsOneWidget,
    );
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('3 linked escalations'), findsOneWidget);
    expect(
      find.text('Complete 1 critical assurance remediation action.'),
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
  IncomingTalentOperatingAssuranceRemediationAction(
    id: 'assurance-remediation-people-operations-talent-partner-risk-council',
    type:
        IncomingTalentOperatingAssuranceRemediationType.recoverOverdueEvidence,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
    assuranceLevel: IncomingTalentOperatingAssuranceLevel.exposed,
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Risk council',
    title: 'People Operations Talent Partner - Risk council evidence',
    detail: '2 assurance gaps in risk council',
    nextAction:
        'Ask People Operations Talent Partner to recover 1 overdue risk council evidence gap.',
    gapCount: 2,
    criticalGapCount: 1,
    highGapCount: 1,
    overdueGapCount: 1,
    dueTodayGapCount: 0,
    linkedEscalationCount: 3,
    nextDueDate: DateTime(2026, 6, 10),
    pressureRatio: 0.78,
    evidenceRequests: const ['Attach operating evidence.'],
    gapIds: const ['evidence-risk-overdue', 'evidence-risk-linked'],
  ),
  IncomingTalentOperatingAssuranceRemediationAction(
    id: 'assurance-remediation-learning-partner-development',
    type: IncomingTalentOperatingAssuranceRemediationType.closeDueToday,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.high,
    assuranceLevel: IncomingTalentOperatingAssuranceLevel.guarded,
    ownerName: 'Learning Partner',
    workstreamLabel: 'Development',
    title: 'Learning Partner - Development evidence',
    detail: '1 assurance gap in development',
    nextAction:
        'Ask Learning Partner to close 1 development evidence gap due today.',
    gapCount: 1,
    criticalGapCount: 0,
    highGapCount: 1,
    overdueGapCount: 0,
    dueTodayGapCount: 1,
    linkedEscalationCount: 0,
    nextDueDate: DateTime(2026, 6, 11),
    pressureRatio: 0.46,
    evidenceRequests: const ['Attach learning evidence.'],
    gapIds: const ['evidence-development-today'],
  ),
];
