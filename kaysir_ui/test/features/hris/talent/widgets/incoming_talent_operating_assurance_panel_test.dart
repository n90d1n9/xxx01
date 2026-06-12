import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_assurance_panel.dart';

void main() {
  testWidgets('talent assurance panel exposes workstream audit exposure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingAssuranceWorkstreamsProvider.overrideWithValue(
            _workstreams,
          ),
          incomingTalentOperatingAssuranceSummaryProvider.overrideWithValue(
            IncomingTalentOperatingAssuranceSummary.fromWorkstreams(
              _workstreams,
            ),
          ),
        ],
        child: _shell(const IncomingTalentOperatingAssurancePanel()),
      ),
    );

    expect(find.text('Talent assurance board'), findsOneWidget);
    expect(find.text('Workstreams'), findsOneWidget);
    expect(find.text('Risk council'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('Exposed'), findsWidgets);
    expect(find.text('Guarded'), findsOneWidget);
    expect(find.text('3 linked escalations'), findsOneWidget);
    expect(
      find.text('Stabilize 1 audit-exposed talent workstream.'),
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

final _workstreams = [
  IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: 'Risk council',
    level: IncomingTalentOperatingAssuranceLevel.exposed,
    gapCount: 2,
    criticalGapCount: 1,
    highGapCount: 1,
    watchGapCount: 0,
    overdueGapCount: 1,
    dueTodayGapCount: 0,
    linkedEscalationCount: 3,
    ownerCount: 2,
    nextDueDate: DateTime(2026, 6, 10),
    nextAction: 'Recover 1 overdue risk council evidence gap.',
    gapIds: const ['evidence-risk-overdue', 'evidence-risk-today'],
  ),
  IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: 'Development',
    level: IncomingTalentOperatingAssuranceLevel.guarded,
    gapCount: 1,
    criticalGapCount: 0,
    highGapCount: 1,
    watchGapCount: 0,
    overdueGapCount: 0,
    dueTodayGapCount: 1,
    linkedEscalationCount: 1,
    ownerCount: 1,
    nextDueDate: DateTime(2026, 6, 11),
    nextAction: 'Close 1 development evidence gap due today.',
    gapIds: const ['evidence-training-today'],
  ),
  const IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: 'Succession',
    level: IncomingTalentOperatingAssuranceLevel.ready,
    gapCount: 0,
    criticalGapCount: 0,
    highGapCount: 0,
    watchGapCount: 0,
    overdueGapCount: 0,
    dueTodayGapCount: 0,
    linkedEscalationCount: 0,
    ownerCount: 0,
    nextDueDate: null,
    nextAction: 'Succession assurance is ready.',
    gapIds: [],
  ),
];
