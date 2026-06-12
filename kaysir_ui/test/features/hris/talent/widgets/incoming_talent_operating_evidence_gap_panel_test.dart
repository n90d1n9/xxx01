import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_evidence_gap_panel.dart';

void main() {
  testWidgets('talent evidence gap panel exposes audit gaps', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingEvidenceGapsProvider.overrideWithValue(_gaps),
          incomingTalentOperatingEvidenceGapSummaryProvider.overrideWithValue(
            IncomingTalentOperatingEvidenceGapSummary.fromItems(_gaps),
          ),
        ],
        child: _shell(const IncomingTalentOperatingEvidenceGapPanel()),
      ),
    );

    expect(find.text('Talent evidence gaps'), findsOneWidget);
    expect(find.text('Gaps'), findsOneWidget);
    expect(find.text('Risk council evidence: Ari Talent'), findsOneWidget);
    expect(find.text('Learning evidence: Bima Talent'), findsOneWidget);
    expect(find.text('2 linked escalations'), findsOneWidget);
    expect(
      find.text('Recover overdue risk council evidence for Ari Talent.'),
      findsOneWidget,
    );
    expect(find.text('Close 1 critical talent evidence gap.'), findsOneWidget);
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

final _gaps = [
  IncomingTalentOperatingEvidenceGap(
    id: 'evidence-risk-overdue',
    type: IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence,
    risk: IncomingTalentOperatingEvidenceGapRisk.critical,
    title: 'Risk council evidence: Ari Talent',
    subjectName: 'Ari Talent',
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Risk council',
    statusLabel: 'Blocked',
    evidenceRequest:
        'Attach decision notes, owner commitment, and follow-up acceptance.',
    nextAction: 'Recover overdue risk council evidence for Ari Talent.',
    dueDate: DateTime(2026, 6, 10),
    daysUntilDue: -1,
    overdue: true,
    dueToday: false,
    linkedEscalationCount: 2,
    pressureRatio: 0.91,
    referenceIds: const ['risk-overdue'],
  ),
  IncomingTalentOperatingEvidenceGap(
    id: 'evidence-training-today',
    type: IncomingTalentOperatingEvidenceGapType.learningEvidence,
    risk: IncomingTalentOperatingEvidenceGapRisk.high,
    title: 'Learning evidence: Bima Talent',
    subjectName: 'Bima Talent',
    ownerName: 'Learning Partner',
    workstreamLabel: 'Development',
    statusLabel: 'Pending proof',
    evidenceRequest:
        'Attach attendance, completion proof, and learner feedback.',
    nextAction: 'Close learning evidence for Bima Talent today.',
    dueDate: DateTime(2026, 6, 11),
    daysUntilDue: 0,
    overdue: false,
    dueToday: true,
    linkedEscalationCount: 1,
    pressureRatio: 0.73,
    referenceIds: const ['training-today'],
  ),
];
