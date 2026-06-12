import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_inbox_owner_digest_panel.dart';

void main() {
  testWidgets('talent owner workload panel exposes owner pressure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingInboxOwnerDigestsProvider.overrideWithValue([
            _criticalDigest,
            _stretchedDigest,
          ]),
          incomingTalentOperatingInboxOwnerDigestSummaryProvider
              .overrideWithValue(
                IncomingTalentOperatingInboxOwnerDigestSummary.fromDigests([
                  _criticalDigest,
                  _stretchedDigest,
                ]),
              ),
        ],
        child: _shell(const IncomingTalentOperatingInboxOwnerDigestPanel()),
      ),
    );

    expect(find.text('Talent owner workload'), findsOneWidget);
    expect(find.text('People Operations Talent Partner'), findsOneWidget);
    expect(find.text('Engineering HRBP'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('2 workstreams'), findsOneWidget);
    expect(
      find.text(
        'Recover 1 overdue talent inbox item with People Operations Talent Partner.',
      ),
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

final _criticalDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'People Operations Talent Partner',
  load: IncomingTalentOperatingInboxOwnerLoad.critical,
  totalCount: 3,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 1,
  dueSoonCount: 1,
  riskCouncilCount: 2,
  developmentCount: 0,
  successionCount: 0,
  promotionCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction:
      'Recover 1 overdue talent inbox item with People Operations Talent Partner.',
  itemIds: const ['risk-follow-up:preview', 'promotion-action:preview'],
);

final _stretchedDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'Engineering HRBP',
  load: IncomingTalentOperatingInboxOwnerLoad.stretched,
  totalCount: 2,
  criticalCount: 0,
  watchCount: 2,
  routineCount: 0,
  overdueCount: 0,
  dueSoonCount: 2,
  riskCouncilCount: 0,
  developmentCount: 2,
  successionCount: 0,
  promotionCount: 0,
  earliestDueDate: DateTime(2026, 6, 13),
  nextAction: 'Close 2 talent inbox items due soon with Engineering HRBP.',
  itemIds: const ['training-session:preview', 'career-review:preview'],
);
