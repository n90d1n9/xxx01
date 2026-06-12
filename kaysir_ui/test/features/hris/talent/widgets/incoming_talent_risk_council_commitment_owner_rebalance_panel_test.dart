import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_owner_workload_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_commitment_owner_workload_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_risk_council_commitment_owner_rebalance_panel.dart';

void main() {
  testWidgets('owner rebalance panel exposes relief recommendation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentRiskCouncilCommitmentOwnerRebalancePlanProvider
              .overrideWithValue(_plan),
        ],
        child: _shell(
          const IncomingTalentRiskCouncilCommitmentOwnerRebalancePanel(),
        ),
      ),
    );

    expect(find.text('Council owner rebalance'), findsOneWidget);
    expect(find.text('Ari Talent Partner'), findsOneWidget);
    expect(find.text('Relief: Citra HRBP'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(
      find.text('Move 2 urgent actions from Ari Talent Partner to Citra HRBP.'),
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
    IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation(
      sourceOwnerName: 'Ari Talent Partner',
      targetOwnerName: 'Citra HRBP',
      priority:
          IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.critical,
      suggestedActionCount: 2,
      sourceOpenCount: 4,
      sourceBlockedCount: 1,
      sourceOverdueCount: 1,
      sourceWaitingEvidenceCount: 1,
      reliefCapacity: 1,
      reason: '1 blocked commitment action',
      nextAction:
          'Move 2 urgent actions from Ari Talent Partner to Citra HRBP.',
    );

const _plan = IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan(
  ownerCount: 3,
  ownersNeedingReliefCount: 1,
  availableReliefOwnerCount: 2,
  reliefCapacity: 5,
  suggestedReassignmentCount: 2,
  criticalRecommendationCount: 1,
  nextAction: 'Reassign 2 urgent commitment actions from critical owners.',
  recommendations: [_recommendation],
);
