import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_sla_panel.dart';

void main() {
  testWidgets('talent operating SLA panel exposes action health', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingSlaItemsProvider.overrideWithValue(_items),
          incomingTalentOperatingSlaSummaryProvider.overrideWithValue(
            IncomingTalentOperatingSlaSummary.fromItems(_items),
          ),
        ],
        child: _shell(const IncomingTalentOperatingSlaPanel()),
      ),
    );

    expect(find.text('Talent action SLA monitor'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('At risk'), findsWidgets);
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
    expect(find.text('Assurance - Risk council'), findsWidgets);
    expect(find.text('3 proofs'), findsOneWidget);
    expect(
      find.text('Recover 1 overdue talent operating SLA item.'),
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
  IncomingTalentOperatingSlaItem(
    id: 'operating-sla-assurance-preview',
    referenceId: 'assurance-execution-preview',
    source: IncomingTalentOperatingSlaSource.assurance,
    status: IncomingTalentOperatingSlaStatus.overdue,
    title: 'People Operations Talent Partner execution - Risk council',
    subjectName: 'Risk council',
    department: 'Talent assurance',
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Assurance - Risk council',
    priorityLabel: 'Critical',
    nextAction:
        'Unblock linked risk council escalations with People Operations Talent Partner.',
    dueDate: DateTime(2026, 6, 10),
    daysUntilDue: -1,
    slaPressureRatio: 0.82,
    evidenceCount: 3,
    referenceIds: const ['evidence-risk-overdue', 'evidence-risk-linked'],
  ),
  IncomingTalentOperatingSlaItem(
    id: 'operating-sla-training-preview',
    referenceId: 'training-session-preview',
    source: IncomingTalentOperatingSlaSource.training,
    status: IncomingTalentOperatingSlaStatus.dueToday,
    title: 'Confirm training session evidence',
    subjectName: 'Ari Talent',
    department: 'People Operations',
    ownerName: 'Learning Partner',
    workstreamLabel: 'Training',
    priorityLabel: 'Watch',
    nextAction: 'Close due-today training evidence before HRIS cut-off.',
    dueDate: DateTime(2026, 6, 11),
    daysUntilDue: 0,
    slaPressureRatio: 0.58,
    evidenceCount: 0,
    referenceIds: const ['training-session-preview'],
  ),
  IncomingTalentOperatingSlaItem(
    id: 'operating-sla-career-preview',
    referenceId: 'career-review-preview',
    source: IncomingTalentOperatingSlaSource.careerPath,
    status: IncomingTalentOperatingSlaStatus.atRisk,
    title: 'Review career path block',
    subjectName: 'Raka Talent',
    department: 'People Operations',
    ownerName: 'Career Partner',
    workstreamLabel: 'Career path',
    priorityLabel: 'Watch',
    nextAction: 'Prepare career path review evidence.',
    dueDate: DateTime(2026, 6, 15),
    daysUntilDue: 4,
    slaPressureRatio: 0.44,
    evidenceCount: 0,
    referenceIds: const ['career-review-preview'],
  ),
];
