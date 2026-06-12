import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_inbox_owner_rebalance_panel.dart';

void main() {
  testWidgets('talent owner rebalance panel exposes relief recommendation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingInboxOwnerRebalancePlanProvider
              .overrideWithValue(_plan),
        ],
        child: _shell(const IncomingTalentOperatingInboxOwnerRebalancePanel()),
      ),
    );

    expect(find.text('Talent owner rebalance'), findsOneWidget);
    expect(find.text('Ari Talent Partner'), findsOneWidget);
    expect(find.text('Relief: Bima HRBP'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('1 overdue talent inbox item'), findsOneWidget);
    expect(
      find.text(
        'Move 2 urgent talent items from Ari Talent Partner to Bima HRBP.',
      ),
      findsWidgets,
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

const _recommendation =
    IncomingTalentOperatingInboxOwnerRebalanceRecommendation(
      sourceOwnerName: 'Ari Talent Partner',
      targetOwnerName: 'Bima HRBP',
      priority: IncomingTalentOperatingInboxOwnerRebalancePriority.critical,
      suggestedItemCount: 2,
      sourceItemCount: 4,
      sourceCriticalCount: 2,
      sourceOverdueCount: 1,
      sourceDueSoonCount: 1,
      sourceWorkstreamCount: 2,
      reliefCapacity: 0,
      reason: '1 overdue talent inbox item',
      nextAction:
          'Move 2 urgent talent items from Ari Talent Partner to Bima HRBP.',
    );

const _plan = IncomingTalentOperatingInboxOwnerRebalancePlan(
  ownerCount: 3,
  ownersNeedingReliefCount: 1,
  availableReliefOwnerCount: 2,
  reliefCapacity: 3,
  suggestedReassignmentCount: 2,
  criticalRecommendationCount: 1,
  nextAction: 'Reassign 2 urgent talent inbox items from critical owners.',
  recommendations: [_recommendation],
);
