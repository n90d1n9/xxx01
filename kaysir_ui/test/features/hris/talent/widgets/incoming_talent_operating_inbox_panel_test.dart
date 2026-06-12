import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_inbox_panel.dart';

void main() {
  testWidgets('talent operating inbox panel exposes urgent items', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingInboxItemsProvider.overrideWithValue([
            _criticalItem,
            _watchItem,
          ]),
          incomingTalentOperatingInboxSummaryProvider.overrideWithValue(
            IncomingTalentOperatingInboxSummary.fromItems(
              items: [_criticalItem, _watchItem],
              asOfDate: DateTime(2026, 6, 11),
            ),
          ),
          talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
        ],
        child: _shell(const IncomingTalentOperatingInboxPanel()),
      ),
    );

    expect(find.text('Talent operating inbox'), findsOneWidget);
    expect(find.text('Create risk council follow-up'), findsOneWidget);
    expect(find.text('Engineering growth accelerator'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Risk council follow-up'), findsOneWidget);
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

final _criticalItem = IncomingTalentOperatingInboxItem(
  id: 'risk-follow-up:preview',
  source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
  priority: IncomingTalentOperatingInboxPriority.critical,
  title: 'Create risk council follow-up',
  subjectName: 'Alya Maheswari',
  department: 'People Operations',
  ownerName: 'People Operations Talent Partner',
  statusLabel: 'Escalated',
  nextAction:
      'Create the owner follow-up and capture council commitment evidence.',
  dueDate: DateTime(2026, 6, 10),
);

final _watchItem = IncomingTalentOperatingInboxItem(
  id: 'training-session:preview',
  source: IncomingTalentOperatingInboxSource.trainingSession,
  priority: IncomingTalentOperatingInboxPriority.watch,
  title: 'Engineering growth accelerator',
  subjectName: 'Leadership',
  department: 'Engineering',
  ownerName: 'Rani Prasetya',
  statusLabel: 'Scheduled',
  nextAction: 'Confirm manager evidence checkpoint after session.',
  dueDate: DateTime(2026, 6, 14),
);
