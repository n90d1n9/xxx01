import 'incoming_talent_operating_inbox_owner_digest.dart';

/// Priority tier for cross-HRIS talent owner rebalance recommendations.
enum IncomingTalentOperatingInboxOwnerRebalancePriority {
  critical('Critical'),
  support('Support');

  final String label;

  const IncomingTalentOperatingInboxOwnerRebalancePriority(this.label);
}

/// Recommended relief move for one overloaded talent operating inbox owner.
class IncomingTalentOperatingInboxOwnerRebalanceRecommendation {
  final String sourceOwnerName;
  final String? targetOwnerName;
  final IncomingTalentOperatingInboxOwnerRebalancePriority priority;
  final int suggestedItemCount;
  final int sourceItemCount;
  final int sourceCriticalCount;
  final int sourceOverdueCount;
  final int sourceDueSoonCount;
  final int sourceWorkstreamCount;
  final int reliefCapacity;
  final String reason;
  final String nextAction;

  const IncomingTalentOperatingInboxOwnerRebalanceRecommendation({
    required this.sourceOwnerName,
    required this.targetOwnerName,
    required this.priority,
    required this.suggestedItemCount,
    required this.sourceItemCount,
    required this.sourceCriticalCount,
    required this.sourceOverdueCount,
    required this.sourceDueSoonCount,
    required this.sourceWorkstreamCount,
    required this.reliefCapacity,
    required this.reason,
    required this.nextAction,
  });

  bool get hasTargetOwner => targetOwnerName != null;

  double get pressureRatio {
    if (sourceItemCount == 0) return 0;

    final score =
        (sourceCriticalCount * 2) +
        (sourceOverdueCount * 2) +
        sourceDueSoonCount +
        sourceWorkstreamCount;
    final ratio = score / (sourceItemCount * 4);

    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}

/// Cross-HRIS plan for rebalancing overloaded talent operating inbox owners.
class IncomingTalentOperatingInboxOwnerRebalancePlan {
  final int ownerCount;
  final int ownersNeedingReliefCount;
  final int availableReliefOwnerCount;
  final int reliefCapacity;
  final int suggestedReassignmentCount;
  final int criticalRecommendationCount;
  final String nextAction;
  final List<IncomingTalentOperatingInboxOwnerRebalanceRecommendation>
  recommendations;

  const IncomingTalentOperatingInboxOwnerRebalancePlan({
    required this.ownerCount,
    required this.ownersNeedingReliefCount,
    required this.availableReliefOwnerCount,
    required this.reliefCapacity,
    required this.suggestedReassignmentCount,
    required this.criticalRecommendationCount,
    required this.nextAction,
    required this.recommendations,
  });

  factory IncomingTalentOperatingInboxOwnerRebalancePlan.fromDigests(
    List<IncomingTalentOperatingInboxOwnerDigest> digests,
  ) {
    final reliefOwners = _reliefOwners(digests);
    final reliefCapacityByOwner = {
      for (final owner in reliefOwners) owner.ownerName: _reliefCapacity(owner),
    };
    final overloadedOwners =
        digests.where(_needsRelief).toList()..sort(_compareOverloadedOwners);
    final recommendations =
        <IncomingTalentOperatingInboxOwnerRebalanceRecommendation>[];

    for (final owner in overloadedOwners) {
      final suggestedItemCount = _suggestedItemCount(owner);
      final targetOwnerName = _nextReliefOwnerName(
        reliefCapacityByOwner,
        excludeOwnerName: owner.ownerName,
      );

      if (targetOwnerName != null) {
        reliefCapacityByOwner[targetOwnerName] =
            reliefCapacityByOwner[targetOwnerName]! - suggestedItemCount;
      }

      recommendations.add(
        IncomingTalentOperatingInboxOwnerRebalanceRecommendation(
          sourceOwnerName: owner.ownerName,
          targetOwnerName: targetOwnerName,
          priority:
              owner.load == IncomingTalentOperatingInboxOwnerLoad.critical
                  ? IncomingTalentOperatingInboxOwnerRebalancePriority.critical
                  : IncomingTalentOperatingInboxOwnerRebalancePriority.support,
          suggestedItemCount: suggestedItemCount,
          sourceItemCount: owner.totalCount,
          sourceCriticalCount: owner.criticalCount,
          sourceOverdueCount: owner.overdueCount,
          sourceDueSoonCount: owner.dueSoonCount,
          sourceWorkstreamCount: owner.sourceCount,
          reliefCapacity:
              targetOwnerName == null
                  ? 0
                  : reliefCapacityByOwner[targetOwnerName] ?? 0,
          reason: _reason(owner),
          nextAction: _recommendationAction(
            sourceOwnerName: owner.ownerName,
            targetOwnerName: targetOwnerName,
            suggestedItemCount: suggestedItemCount,
            owner: owner,
          ),
        ),
      );
    }

    final suggestedReassignmentCount = recommendations.fold<int>(
      0,
      (total, recommendation) =>
          total +
          (recommendation.hasTargetOwner
              ? recommendation.suggestedItemCount
              : 0),
    );
    final criticalRecommendationCount =
        recommendations
            .where(
              (recommendation) =>
                  recommendation.priority ==
                  IncomingTalentOperatingInboxOwnerRebalancePriority.critical,
            )
            .length;

    return IncomingTalentOperatingInboxOwnerRebalancePlan(
      ownerCount: digests.length,
      ownersNeedingReliefCount: overloadedOwners.length,
      availableReliefOwnerCount: reliefOwners.length,
      reliefCapacity: reliefOwners.fold<int>(
        0,
        (total, owner) => total + _reliefCapacity(owner),
      ),
      suggestedReassignmentCount: suggestedReassignmentCount,
      criticalRecommendationCount: criticalRecommendationCount,
      nextAction: _planAction(
        ownerCount: digests.length,
        ownersNeedingReliefCount: overloadedOwners.length,
        availableReliefOwnerCount: reliefOwners.length,
        criticalRecommendationCount: criticalRecommendationCount,
        suggestedReassignmentCount: suggestedReassignmentCount,
      ),
      recommendations: recommendations,
    );
  }
}

bool _needsRelief(IncomingTalentOperatingInboxOwnerDigest owner) {
  return owner.load == IncomingTalentOperatingInboxOwnerLoad.critical ||
      owner.load == IncomingTalentOperatingInboxOwnerLoad.stretched;
}

List<IncomingTalentOperatingInboxOwnerDigest> _reliefOwners(
  List<IncomingTalentOperatingInboxOwnerDigest> digests,
) {
  return digests.where((owner) => _reliefCapacity(owner) > 0).toList()
    ..sort(_compareReliefOwners);
}

int _reliefCapacity(IncomingTalentOperatingInboxOwnerDigest owner) {
  return switch (owner.load) {
    IncomingTalentOperatingInboxOwnerLoad.clear => 3,
    IncomingTalentOperatingInboxOwnerLoad.balanced =>
      owner.totalCount <= 1 ? 2 : 1,
    IncomingTalentOperatingInboxOwnerLoad.stretched => 0,
    IncomingTalentOperatingInboxOwnerLoad.critical => 0,
  };
}

int _suggestedItemCount(IncomingTalentOperatingInboxOwnerDigest owner) {
  if (owner.overdueCount > 0 && owner.criticalCount > 0) return 2;
  if (owner.criticalCount >= 2) return 2;
  if (owner.totalCount >= 4) return 2;
  return 1;
}

String? _nextReliefOwnerName(
  Map<String, int> reliefCapacityByOwner, {
  required String excludeOwnerName,
}) {
  for (final entry in reliefCapacityByOwner.entries) {
    if (entry.key == excludeOwnerName) continue;
    if (entry.value > 0) return entry.key;
  }
  return null;
}

String _reason(IncomingTalentOperatingInboxOwnerDigest owner) {
  if (owner.overdueCount > 0) {
    return '${owner.overdueCount} overdue talent inbox ${_plural(owner.overdueCount, 'item')}';
  }
  if (owner.criticalCount > 0) {
    return '${owner.criticalCount} critical talent inbox ${_plural(owner.criticalCount, 'item')}';
  }
  if (owner.dueSoonCount > 0) {
    return '${owner.dueSoonCount} talent inbox ${_plural(owner.dueSoonCount, 'item')} due soon';
  }
  return '${owner.totalCount} active talent inbox ${_plural(owner.totalCount, 'item')}';
}

String _recommendationAction({
  required String sourceOwnerName,
  required String? targetOwnerName,
  required int suggestedItemCount,
  required IncomingTalentOperatingInboxOwnerDigest owner,
}) {
  if (targetOwnerName == null) {
    return 'Assign relief capacity for $sourceOwnerName before the next talent review.';
  }

  final workloadLabel =
      owner.criticalCount > 0 || owner.overdueCount > 0 ? 'urgent' : 'active';
  return 'Move $suggestedItemCount $workloadLabel talent ${_plural(suggestedItemCount, 'item')} from $sourceOwnerName to $targetOwnerName.';
}

String _planAction({
  required int ownerCount,
  required int ownersNeedingReliefCount,
  required int availableReliefOwnerCount,
  required int criticalRecommendationCount,
  required int suggestedReassignmentCount,
}) {
  if (ownerCount == 0) {
    return 'Talent owner rebalance is clear.';
  }
  if (ownersNeedingReliefCount == 0) {
    return 'Talent operating inbox ownership is balanced.';
  }
  if (availableReliefOwnerCount == 0) {
    return 'Add relief capacity for $ownersNeedingReliefCount overloaded talent ${_plural(ownersNeedingReliefCount, 'owner')}.';
  }
  if (criticalRecommendationCount > 0) {
    return 'Reassign $suggestedReassignmentCount urgent talent inbox ${_plural(suggestedReassignmentCount, 'item')} from critical owners.';
  }
  return 'Rebalance $suggestedReassignmentCount talent inbox ${_plural(suggestedReassignmentCount, 'item')} across stretched owners.';
}

int _compareOverloadedOwners(
  IncomingTalentOperatingInboxOwnerDigest left,
  IncomingTalentOperatingInboxOwnerDigest right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final critical = right.criticalCount.compareTo(left.criticalCount);
  if (critical != 0) return critical;

  final overdue = right.overdueCount.compareTo(left.overdueCount);
  if (overdue != 0) return overdue;

  final total = right.totalCount.compareTo(left.totalCount);
  if (total != 0) return total;

  return left.ownerName.compareTo(right.ownerName);
}

int _compareReliefOwners(
  IncomingTalentOperatingInboxOwnerDigest left,
  IncomingTalentOperatingInboxOwnerDigest right,
) {
  final load = right.urgencyRank.compareTo(left.urgencyRank);
  if (load != 0) return load;

  final capacity = _reliefCapacity(right).compareTo(_reliefCapacity(left));
  if (capacity != 0) return capacity;

  final total = left.totalCount.compareTo(right.totalCount);
  if (total != 0) return total;

  return left.ownerName.compareTo(right.ownerName);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
