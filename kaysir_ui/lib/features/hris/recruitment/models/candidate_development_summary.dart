import 'candidate_development_objective.dart';

class CandidateDevelopmentObjectiveSummary {
  final int totalCount;
  final int plannedCount;
  final int activeCount;
  final int completedCount;
  final int dueSoonCount;
  final String nextAction;

  const CandidateDevelopmentObjectiveSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.activeCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.nextAction,
  });

  factory CandidateDevelopmentObjectiveSummary.fromObjectives({
    required List<CandidateDevelopmentObjective> objectives,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        objectives
            .where(
              (item) =>
                  item.status == CandidateDevelopmentObjectiveStatus.planned,
            )
            .length;
    final activeCount =
        objectives
            .where(
              (item) =>
                  item.status == CandidateDevelopmentObjectiveStatus.active,
            )
            .length;
    final completedCount =
        objectives
            .where(
              (item) =>
                  item.status == CandidateDevelopmentObjectiveStatus.completed,
            )
            .length;
    final dueSoonCount =
        objectives.where((item) => item.isDueSoon(asOfDate)).length;

    return CandidateDevelopmentObjectiveSummary(
      totalCount: objectives.length,
      plannedCount: plannedCount,
      activeCount: activeCount,
      completedCount: completedCount,
      dueSoonCount: dueSoonCount,
      nextAction: _summaryNextAction(
        totalCount: objectives.length,
        plannedCount: plannedCount,
        activeCount: activeCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int plannedCount,
  required int activeCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) {
    return 'No candidate development objectives submitted yet.';
  }
  if (dueSoonCount > 0) {
    return 'Review $dueSoonCount development objectives due soon.';
  }
  if (plannedCount > 0) {
    return 'Activate $plannedCount planned development objectives.';
  }
  if (activeCount > 0) {
    return 'Track active candidate development progress.';
  }
  return 'Candidate development objectives are complete.';
}
