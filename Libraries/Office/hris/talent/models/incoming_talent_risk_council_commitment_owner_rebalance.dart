import 'incoming_talent_risk_council_commitment_owner_workload_item.dart';

/// Priority band for owner workload rebalance recommendations.
enum IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority {
  critical('Critical'),
  support('Support');

  final String label;

  const IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority(this.label);
}

/// Recommended reassignment move for one overloaded council commitment owner.
class IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation {
  final String sourceOwnerName;
  final String? targetOwnerName;
  final IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority priority;
  final int suggestedActionCount;
  final int sourceOpenCount;
  final int sourceBlockedCount;
  final int sourceOverdueCount;
  final int sourceWaitingEvidenceCount;
  final int reliefCapacity;
  final String reason;
  final String nextAction;

  const IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation({
    required this.sourceOwnerName,
    required this.targetOwnerName,
    required this.priority,
    required this.suggestedActionCount,
    required this.sourceOpenCount,
    required this.sourceBlockedCount,
    required this.sourceOverdueCount,
    required this.sourceWaitingEvidenceCount,
    required this.reliefCapacity,
    required this.reason,
    required this.nextAction,
  });

  bool get hasTargetOwner => targetOwnerName != null;

  double get pressureRatio {
    if (sourceOpenCount == 0) return 0;

    final score =
        (sourceBlockedCount * 2) +
        (sourceOverdueCount * 2) +
        sourceWaitingEvidenceCount +
        suggestedActionCount;
    final ratio = score / (sourceOpenCount * 3);

    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}

/// Owner workload rebalance plan for council commitment actions.
class IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan {
  final int ownerCount;
  final int ownersNeedingReliefCount;
  final int availableReliefOwnerCount;
  final int reliefCapacity;
  final int suggestedReassignmentCount;
  final int criticalRecommendationCount;
  final String nextAction;
  final List<IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation>
  recommendations;

  const IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan({
    required this.ownerCount,
    required this.ownersNeedingReliefCount,
    required this.availableReliefOwnerCount,
    required this.reliefCapacity,
    required this.suggestedReassignmentCount,
    required this.criticalRecommendationCount,
    required this.nextAction,
    required this.recommendations,
  });

  factory IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan.fromWorkloads(
    List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem> workloads,
  ) {
    final reliefOwners = _reliefOwners(workloads);
    final reliefCapacityByOwner = {
      for (final owner in reliefOwners) owner.ownerName: _reliefCapacity(owner),
    };
    final overloadedOwners =
        workloads.where(_needsRebalance).toList()
          ..sort(_compareOverloadedOwners);
    final recommendations =
        <IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation>[];

    for (final owner in overloadedOwners) {
      final suggestedActionCount = _suggestedActionCount(owner);
      final targetOwnerName = _nextReliefOwnerName(
        reliefCapacityByOwner,
        excludeOwnerName: owner.ownerName,
      );

      if (targetOwnerName != null) {
        reliefCapacityByOwner[targetOwnerName] =
            reliefCapacityByOwner[targetOwnerName]! - suggestedActionCount;
      }

      recommendations.add(
        IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation(
          sourceOwnerName: owner.ownerName,
          targetOwnerName: targetOwnerName,
          priority:
              owner.load ==
                      IncomingTalentRiskCouncilCommitmentOwnerLoad.critical
                  ? IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority
                      .critical
                  : IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority
                      .support,
          suggestedActionCount: suggestedActionCount,
          sourceOpenCount: owner.openCount,
          sourceBlockedCount: owner.blockedCount,
          sourceOverdueCount: owner.overdueCount,
          sourceWaitingEvidenceCount: owner.waitingEvidenceCount,
          reliefCapacity:
              targetOwnerName == null
                  ? 0
                  : reliefCapacityByOwner[targetOwnerName] ?? 0,
          reason: _reason(owner),
          nextAction: _recommendationAction(
            sourceOwnerName: owner.ownerName,
            targetOwnerName: targetOwnerName,
            suggestedActionCount: suggestedActionCount,
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
              ? recommendation.suggestedActionCount
              : 0),
    );
    final criticalRecommendationCount =
        recommendations
            .where(
              (recommendation) =>
                  recommendation.priority ==
                  IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority
                      .critical,
            )
            .length;

    return IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan(
      ownerCount: workloads.length,
      ownersNeedingReliefCount: overloadedOwners.length,
      availableReliefOwnerCount: reliefOwners.length,
      reliefCapacity: reliefOwners.fold<int>(
        0,
        (total, owner) => total + _reliefCapacity(owner),
      ),
      suggestedReassignmentCount: suggestedReassignmentCount,
      criticalRecommendationCount: criticalRecommendationCount,
      nextAction: _planAction(
        ownerCount: workloads.length,
        criticalRecommendationCount: criticalRecommendationCount,
        ownersNeedingReliefCount: overloadedOwners.length,
        availableReliefOwnerCount: reliefOwners.length,
        suggestedReassignmentCount: suggestedReassignmentCount,
      ),
      recommendations: recommendations,
    );
  }
}

bool _needsRebalance(
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem owner,
) {
  if (owner.openCount == 0) return false;
  return owner.load == IncomingTalentRiskCouncilCommitmentOwnerLoad.critical ||
      owner.load == IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched;
}

List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem> _reliefOwners(
  List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem> workloads,
) {
  return workloads.where((owner) => _reliefCapacity(owner) > 0).toList()
    ..sort(_compareReliefOwners);
}

int _reliefCapacity(
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem owner,
) {
  return switch (owner.load) {
    IncomingTalentRiskCouncilCommitmentOwnerLoad.clear => 3,
    IncomingTalentRiskCouncilCommitmentOwnerLoad.balanced =>
      owner.openCount <= 1 ? 2 : 1,
    IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched => 0,
    IncomingTalentRiskCouncilCommitmentOwnerLoad.critical => 0,
  };
}

int _suggestedActionCount(
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem owner,
) {
  if (owner.blockedCount + owner.overdueCount > 1) return 2;
  if (owner.openCount >= 4) return 2;
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

String _reason(IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem owner) {
  if (owner.blockedCount > 0) {
    return '${owner.blockedCount} blocked commitment ${_plural(owner.blockedCount, 'action')}';
  }
  if (owner.overdueCount > 0) {
    return '${owner.overdueCount} overdue commitment ${_plural(owner.overdueCount, 'action')}';
  }
  if (owner.waitingEvidenceCount > 0) {
    return '${owner.waitingEvidenceCount} evidence-dependent ${_plural(owner.waitingEvidenceCount, 'action')}';
  }
  return '${owner.openCount} open commitment ${_plural(owner.openCount, 'action')}';
}

String _recommendationAction({
  required String sourceOwnerName,
  required String? targetOwnerName,
  required int suggestedActionCount,
  required IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem owner,
}) {
  if (targetOwnerName == null) {
    return 'Assign relief capacity for $sourceOwnerName before next council.';
  }

  final workloadLabel =
      owner.blockedCount > 0 || owner.overdueCount > 0 ? 'urgent' : 'open';
  return 'Move $suggestedActionCount $workloadLabel ${_plural(suggestedActionCount, 'action')} from $sourceOwnerName to $targetOwnerName.';
}

String _planAction({
  required int ownerCount,
  required int criticalRecommendationCount,
  required int ownersNeedingReliefCount,
  required int availableReliefOwnerCount,
  required int suggestedReassignmentCount,
}) {
  if (ownerCount == 0) {
    return 'Create council commitment actions before balancing ownership.';
  }
  if (ownersNeedingReliefCount == 0) {
    return 'Council commitment ownership is balanced.';
  }
  if (availableReliefOwnerCount == 0) {
    return 'Add relief capacity for $ownersNeedingReliefCount overloaded ${_plural(ownersNeedingReliefCount, 'owner')}.';
  }
  if (criticalRecommendationCount > 0) {
    return 'Reassign $suggestedReassignmentCount urgent commitment ${_plural(suggestedReassignmentCount, 'action')} from critical owners.';
  }
  return 'Rebalance $suggestedReassignmentCount commitment ${_plural(suggestedReassignmentCount, 'action')} across stretched owners.';
}

int _compareOverloadedOwners(
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem left,
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final attention = right.attentionCount.compareTo(left.attentionCount);
  if (attention != 0) return attention;

  final open = right.openCount.compareTo(left.openCount);
  if (open != 0) return open;

  return left.ownerName.compareTo(right.ownerName);
}

int _compareReliefOwners(
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem left,
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem right,
) {
  final load = right.urgencyRank.compareTo(left.urgencyRank);
  if (load != 0) return load;

  final capacity = _reliefCapacity(right).compareTo(_reliefCapacity(left));
  if (capacity != 0) return capacity;

  final open = left.openCount.compareTo(right.openCount);
  if (open != 0) return open;

  return left.ownerName.compareTo(right.ownerName);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
