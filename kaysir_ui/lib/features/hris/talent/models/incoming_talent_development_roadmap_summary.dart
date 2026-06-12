import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_roadmap.dart';

class IncomingTalentDevelopmentRoadmapSummary {
  final int totalCount;
  final int plannedCount;
  final int activeCount;
  final int atRiskCount;
  final int completedCount;
  final int highRiskCount;
  final int dueSoonCount;
  final double averageReadinessScore;
  final String nextAction;

  const IncomingTalentDevelopmentRoadmapSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.activeCount,
    required this.atRiskCount,
    required this.completedCount,
    required this.highRiskCount,
    required this.dueSoonCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentRoadmapSummary.fromRoadmaps({
    required List<IncomingTalentDevelopmentRoadmap> roadmaps,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final plannedCount = _countStatus(
      roadmaps,
      IncomingTalentDevelopmentRoadmapStatus.planned,
    );
    final activeCount = _countStatus(
      roadmaps,
      IncomingTalentDevelopmentRoadmapStatus.active,
    );
    final atRiskCount = _countStatus(
      roadmaps,
      IncomingTalentDevelopmentRoadmapStatus.atRisk,
    );
    final completedCount = _countStatus(
      roadmaps,
      IncomingTalentDevelopmentRoadmapStatus.completed,
    );
    final highRiskCount =
        roadmaps
            .where(
              (roadmap) =>
                  roadmap.retentionRisk ==
                  IncomingTalentActivationRetentionRisk.high,
            )
            .length;
    final dueSoonCount =
        roadmaps
            .where(
              (roadmap) =>
                  roadmap.status !=
                      IncomingTalentDevelopmentRoadmapStatus.completed &&
                  !roadmap.targetCompletionDate.isAfter(dueThreshold),
            )
            .length;
    final readinessTotal = roadmaps.fold<int>(
      0,
      (total, roadmap) => total + roadmap.readinessScore,
    );

    return IncomingTalentDevelopmentRoadmapSummary(
      totalCount: roadmaps.length,
      plannedCount: plannedCount,
      activeCount: activeCount,
      atRiskCount: atRiskCount,
      completedCount: completedCount,
      highRiskCount: highRiskCount,
      dueSoonCount: dueSoonCount,
      averageReadinessScore:
          roadmaps.isEmpty ? 0 : readinessTotal / roadmaps.length,
      nextAction: _nextAction(
        totalCount: roadmaps.length,
        plannedCount: plannedCount,
        activeCount: activeCount,
        atRiskCount: atRiskCount,
        highRiskCount: highRiskCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentDevelopmentRoadmap> roadmaps,
  IncomingTalentDevelopmentRoadmapStatus status,
) {
  return roadmaps.where((roadmap) => roadmap.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int activeCount,
  required int atRiskCount,
  required int highRiskCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Create development roadmaps from outcomes.';
  if (atRiskCount > 0 || highRiskCount > 0) {
    return 'Stabilize $atRiskCount at-risk development roadmaps.';
  }
  if (dueSoonCount > 0) {
    return 'Review $dueSoonCount roadmaps due in the next 14 days.';
  }
  if (plannedCount > 0) {
    return 'Activate $plannedCount planned development roadmaps.';
  }
  return 'Keep $activeCount active roadmaps on cadence.';
}
