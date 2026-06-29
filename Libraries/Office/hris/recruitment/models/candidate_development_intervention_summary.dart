import 'candidate_development_intervention.dart';

class CandidateDevelopmentInterventionSummary {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int escalationCount;
  final int dueSoonCount;
  final String nextAction;

  const CandidateDevelopmentInterventionSummary({
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.escalationCount,
    required this.dueSoonCount,
    required this.nextAction,
  });

  factory CandidateDevelopmentInterventionSummary.fromInterventions({
    required List<CandidateDevelopmentIntervention> interventions,
    required DateTime asOfDate,
  }) {
    final openCount =
        interventions
            .where(
              (item) =>
                  item.status == CandidateDevelopmentInterventionStatus.open,
            )
            .length;
    final inProgressCount =
        interventions
            .where(
              (item) =>
                  item.status ==
                  CandidateDevelopmentInterventionStatus.inProgress,
            )
            .length;
    final resolvedCount =
        interventions
            .where(
              (item) =>
                  item.status ==
                  CandidateDevelopmentInterventionStatus.resolved,
            )
            .length;
    final escalationCount =
        interventions
            .where((item) => item.isOpen && item.escalationRequired)
            .length;
    final dueSoonCount =
        interventions.where((item) => item.isDueSoon(asOfDate)).length;

    return CandidateDevelopmentInterventionSummary(
      totalCount: interventions.length,
      openCount: openCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
      escalationCount: escalationCount,
      dueSoonCount: dueSoonCount,
      nextAction: _summaryNextAction(
        totalCount: interventions.length,
        escalationCount: escalationCount,
        openCount: openCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int escalationCount,
  required int openCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'No interventions submitted yet.';
  if (escalationCount > 0) {
    return 'Escalate $escalationCount development blockers.';
  }
  if (openCount > 0) return 'Start $openCount open interventions.';
  if (dueSoonCount > 0) return 'Close $dueSoonCount interventions due soon.';
  return 'Development interventions are progressing.';
}
