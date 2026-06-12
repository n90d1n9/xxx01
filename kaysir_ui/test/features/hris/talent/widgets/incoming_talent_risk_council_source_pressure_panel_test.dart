import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_source_pressure.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_pressure_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_risk_council_source_pressure_panel.dart';

void main() {
  testWidgets('source pressure panel exposes ranked council pressure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentRiskCouncilSourcePressureProvider.overrideWithValue(
            const [_pressure],
          ),
        ],
        child: _shell(const IncomingTalentRiskCouncilSourcePressurePanel()),
      ),
    );

    expect(find.text('Council source pressure'), findsOneWidget);
    expect(find.text('Promotion resolution review'), findsOneWidget);
    expect(find.text('2 active SLA items'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(
      find.text('Track 1 escalated promotion resolution review SLA item.'),
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

const _pressure = IncomingTalentRiskCouncilSourcePressure(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  level: IncomingTalentRiskCouncilSourcePressureLevel.critical,
  totalCount: 2,
  candidateCount: 2,
  blockedCount: 0,
  escalatedCount: 1,
  overdueCount: 0,
  dueSoonCount: 1,
  waitingDecisionCount: 0,
  waitingFollowUpCount: 1,
  activeFollowUpCount: 1,
  nextAction: 'Track 1 escalated promotion resolution review SLA item.',
);
