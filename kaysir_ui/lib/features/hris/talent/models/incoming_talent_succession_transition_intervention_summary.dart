import 'incoming_talent_succession_transition_intervention.dart';

class IncomingTalentSuccessionTransitionInterventionSummary {
  final int totalInterventions;
  final int plannedCount;
  final int inProgressCount;
  final int completedCount;
  final int blockedCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionTransitionInterventionSummary({
    required this.totalInterventions,
    required this.plannedCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.blockedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionTransitionInterventionSummary.fromInterventions({
    required List<IncomingTalentSuccessionTransitionIntervention> interventions,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        interventions
            .where(
              (intervention) =>
                  intervention.status ==
                  IncomingTalentSuccessionTransitionInterventionStatus.planned,
            )
            .length;
    final inProgressCount =
        interventions
            .where(
              (intervention) =>
                  intervention.status ==
                  IncomingTalentSuccessionTransitionInterventionStatus
                      .inProgress,
            )
            .length;
    final completedCount =
        interventions
            .where(
              (intervention) =>
                  intervention.status ==
                  IncomingTalentSuccessionTransitionInterventionStatus
                      .completed,
            )
            .length;
    final blockedCount =
        interventions
            .where(
              (intervention) =>
                  intervention.status ==
                  IncomingTalentSuccessionTransitionInterventionStatus.blocked,
            )
            .length;
    final dueSoonCount =
        interventions
            .where((intervention) => intervention.isDueSoon(asOfDate))
            .length;
    final overdueCount =
        interventions
            .where((intervention) => intervention.isOverdue(asOfDate))
            .length;

    return IncomingTalentSuccessionTransitionInterventionSummary(
      totalInterventions: interventions.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      completedCount: completedCount,
      blockedCount: blockedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _nextAction(
        totalInterventions: interventions.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _nextAction({
  required int totalInterventions,
  required int plannedCount,
  required int inProgressCount,
  required int blockedCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalInterventions == 0) {
    return 'Create interventions from watched transition pulses.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount transition interventions.';
  }
  if (overdueCount > 0) {
    return 'Close $overdueCount overdue interventions.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount interventions due soon.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned interventions.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount interventions in progress.';
  }
  return 'Transition interventions are complete.';
}
