import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_escalation_board_panel.dart';

void main() {
  testWidgets('talent escalation board panel exposes escalation actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingEscalationsProvider.overrideWithValue(
            _escalations,
          ),
          incomingTalentOperatingEscalationSummaryProvider.overrideWithValue(
            IncomingTalentOperatingEscalationSummary.fromItems(_escalations),
          ),
        ],
        child: _shell(const IncomingTalentOperatingEscalationBoardPanel()),
      ),
    );

    expect(find.text('Talent escalation board'), findsOneWidget);
    expect(find.text('Escalations'), findsOneWidget);
    expect(find.text('Overdue talent cadence'), findsOneWidget);
    expect(
      find.text('Relieve People Operations Talent Partner'),
      findsOneWidget,
    );
    expect(find.text('Clear 1 critical talent escalation.'), findsOneWidget);
    expect(find.text('Owner relief'), findsOneWidget);
    expect(
      find.text('Recover 2 overdue talent cadence items.'),
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

final _escalations = [
  IncomingTalentOperatingEscalationItem(
    source: IncomingTalentOperatingEscalationSource.cadence,
    severity: IncomingTalentOperatingEscalationSeverity.critical,
    title: 'Overdue talent cadence',
    detail: '2 items across 2 owners and 2 workstreams',
    nextAction: 'Recover 2 overdue talent cadence items.',
    signalCount: 4,
    dueDate: DateTime(2026, 6, 10),
    overdue: true,
    dueToday: false,
    ownerName: null,
    workstreamLabel: null,
    pressureRatio: 0.75,
    referenceIds: const ['risk-overdue', 'career-overdue'],
  ),
  const IncomingTalentOperatingEscalationItem(
    source: IncomingTalentOperatingEscalationSource.ownerRebalance,
    severity: IncomingTalentOperatingEscalationSeverity.high,
    title: 'Relieve People Operations Talent Partner',
    detail: 'Move 2 items to Engineering HRBP',
    nextAction:
        'Move 2 urgent talent items from People Operations Talent Partner to Engineering HRBP.',
    signalCount: 3,
    dueDate: null,
    overdue: false,
    dueToday: false,
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: null,
    pressureRatio: 0.62,
    referenceIds: [],
  ),
];
