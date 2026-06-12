import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';

void main() {
  test('talent owner rebalance recommends relief for overloaded owner', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentOperatingInboxOwnerDigestsProvider.overrideWithValue([
          _criticalDigest,
          _reliefDigest,
          _secondaryReliefDigest,
        ]),
      ],
    );
    addTearDown(container.dispose);

    final plan = container.read(
      incomingTalentOperatingInboxOwnerRebalancePlanProvider,
    );

    expect(plan.ownerCount, 3);
    expect(plan.ownersNeedingReliefCount, 1);
    expect(plan.availableReliefOwnerCount, 2);
    expect(plan.reliefCapacity, 3);
    expect(plan.suggestedReassignmentCount, 2);
    expect(plan.criticalRecommendationCount, 1);
    expect(
      plan.nextAction,
      'Reassign 2 urgent talent inbox items from critical owners.',
    );
    expect(plan.recommendations, hasLength(1));

    final recommendation = plan.recommendations.single;
    expect(recommendation.sourceOwnerName, 'Ari Talent Partner');
    expect(recommendation.targetOwnerName, 'Bima HRBP');
    expect(
      recommendation.priority,
      IncomingTalentOperatingInboxOwnerRebalancePriority.critical,
    );
    expect(recommendation.suggestedItemCount, 2);
    expect(recommendation.sourceItemCount, 4);
    expect(recommendation.sourceCriticalCount, 2);
    expect(recommendation.sourceOverdueCount, 1);
    expect(recommendation.sourceWorkstreamCount, 2);
    expect(recommendation.reliefCapacity, 0);
    expect(recommendation.reason, '1 overdue talent inbox item');
    expect(
      recommendation.nextAction,
      'Move 2 urgent talent items from Ari Talent Partner to Bima HRBP.',
    );
  });
}

final _criticalDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'Ari Talent Partner',
  load: IncomingTalentOperatingInboxOwnerLoad.critical,
  totalCount: 4,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  riskCouncilCount: 2,
  developmentCount: 0,
  successionCount: 0,
  promotionCount: 2,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 1 overdue talent inbox item with Ari Talent Partner.',
  itemIds: const ['risk-overdue', 'risk-critical', 'promotion-one'],
);

final _reliefDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'Bima HRBP',
  load: IncomingTalentOperatingInboxOwnerLoad.balanced,
  totalCount: 1,
  criticalCount: 0,
  watchCount: 0,
  routineCount: 1,
  overdueCount: 0,
  dueSoonCount: 0,
  riskCouncilCount: 0,
  developmentCount: 1,
  successionCount: 0,
  promotionCount: 0,
  earliestDueDate: DateTime(2026, 6, 18),
  nextAction: 'Track 1 assigned talent inbox item with Bima HRBP.',
  itemIds: const ['training-routine'],
);

final _secondaryReliefDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'Citra HRBP',
  load: IncomingTalentOperatingInboxOwnerLoad.balanced,
  totalCount: 2,
  criticalCount: 0,
  watchCount: 0,
  routineCount: 2,
  overdueCount: 0,
  dueSoonCount: 0,
  riskCouncilCount: 0,
  developmentCount: 0,
  successionCount: 2,
  promotionCount: 0,
  earliestDueDate: DateTime(2026, 6, 20),
  nextAction: 'Track 2 assigned talent inbox items with Citra HRBP.',
  itemIds: const ['succession-one', 'succession-two'],
);
