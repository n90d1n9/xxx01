import 'incoming_talent_mobility_cadence_intervention.dart';

class IncomingTalentMobilityCadenceInterventionSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int blockedCount;
  final int resolvedCount;
  final int urgentCount;
  final int dueSoonCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentMobilityCadenceInterventionSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.resolvedCount,
    required this.urgentCount,
    required this.dueSoonCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentMobilityCadenceInterventionSummary.fromInterventions({
    required List<IncomingTalentMobilityCadenceIntervention> interventions,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countByStatus(
      interventions,
      IncomingTalentMobilityCadenceInterventionStatus.planned,
    );
    final inProgressCount = _countByStatus(
      interventions,
      IncomingTalentMobilityCadenceInterventionStatus.inProgress,
    );
    final blockedCount = _countByStatus(
      interventions,
      IncomingTalentMobilityCadenceInterventionStatus.blocked,
    );
    final resolvedCount = _countByStatus(
      interventions,
      IncomingTalentMobilityCadenceInterventionStatus.resolved,
    );
    final urgentCount =
        interventions
            .where(
              (item) =>
                  item.priority ==
                  IncomingTalentMobilityCadenceInterventionPriority.urgent,
            )
            .length;
    final dueSoonCount =
        interventions.where((item) => item.isDueSoon(asOfDate)).length;
    final attentionCount =
        interventions.where((item) => item.needsAttention).length;

    return IncomingTalentMobilityCadenceInterventionSummary(
      totalCount: interventions.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      blockedCount: blockedCount,
      resolvedCount: resolvedCount,
      urgentCount: urgentCount,
      dueSoonCount: dueSoonCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: interventions.length,
        blockedCount: blockedCount,
        urgentCount: urgentCount,
        dueSoonCount: dueSoonCount,
        attentionCount: attentionCount,
        plannedCount: plannedCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentMobilityCadenceIntervention> interventions,
  IncomingTalentMobilityCadenceInterventionStatus status,
) {
  return interventions.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int urgentCount,
  required int dueSoonCount,
  required int attentionCount,
  required int plannedCount,
}) {
  if (totalCount == 0) return 'Open interventions for risky mobility cadence.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount mobility interventions.';
  }
  if (urgentCount > 0) {
    return 'Resolve $urgentCount urgent mobility interventions.';
  }
  if (dueSoonCount > 0) return 'Review $dueSoonCount interventions due soon.';
  if (attentionCount > 0) {
    return 'Follow up $attentionCount mobility intervention risks.';
  }
  if (plannedCount > 0) return 'Start $plannedCount planned interventions.';
  return 'Mobility interventions are current.';
}
