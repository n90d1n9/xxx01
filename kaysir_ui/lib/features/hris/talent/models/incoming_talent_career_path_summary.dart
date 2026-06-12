import 'incoming_talent_career_path.dart';

class IncomingTalentCareerPathSummary {
  final int totalCount;
  final int draftCount;
  final int activeCount;
  final int blockedCount;
  final int achievedCount;
  final int criticalCount;
  final int dueSoonCount;
  final double averageGap;
  final String nextAction;

  const IncomingTalentCareerPathSummary({
    required this.totalCount,
    required this.draftCount,
    required this.activeCount,
    required this.blockedCount,
    required this.achievedCount,
    required this.criticalCount,
    required this.dueSoonCount,
    required this.averageGap,
    required this.nextAction,
  });

  factory IncomingTalentCareerPathSummary.fromCareerPaths({
    required List<IncomingTalentCareerPath> careerPaths,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final draftCount = _countStatus(
      careerPaths,
      IncomingTalentCareerPathStatus.draft,
    );
    final activeCount = _countStatus(
      careerPaths,
      IncomingTalentCareerPathStatus.active,
    );
    final blockedCount = _countStatus(
      careerPaths,
      IncomingTalentCareerPathStatus.blocked,
    );
    final achievedCount = _countStatus(
      careerPaths,
      IncomingTalentCareerPathStatus.achieved,
    );
    final criticalCount =
        careerPaths
            .where(
              (careerPath) =>
                  careerPath.priority ==
                  IncomingTalentCareerPathPriority.critical,
            )
            .length;
    final dueSoonCount =
        careerPaths
            .where(
              (careerPath) =>
                  careerPath.status !=
                      IncomingTalentCareerPathStatus.achieved &&
                  !careerPath.reviewDate.isAfter(dueThreshold),
            )
            .length;
    final gapTotal = careerPaths.fold<int>(
      0,
      (total, careerPath) => total + careerPath.levelGap,
    );

    return IncomingTalentCareerPathSummary(
      totalCount: careerPaths.length,
      draftCount: draftCount,
      activeCount: activeCount,
      blockedCount: blockedCount,
      achievedCount: achievedCount,
      criticalCount: criticalCount,
      dueSoonCount: dueSoonCount,
      averageGap: careerPaths.isEmpty ? 0 : gapTotal / careerPaths.length,
      nextAction: _nextAction(
        totalCount: careerPaths.length,
        draftCount: draftCount,
        blockedCount: blockedCount,
        criticalCount: criticalCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentCareerPath> careerPaths,
  IncomingTalentCareerPathStatus status,
) {
  return careerPaths.where((careerPath) => careerPath.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int draftCount,
  required int blockedCount,
  required int criticalCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Create career paths from IDP portfolios.';
  if (blockedCount > 0 || criticalCount > 0) {
    return 'Unblock $blockedCount critical career paths.';
  }
  if (dueSoonCount > 0) {
    return 'Review $dueSoonCount career paths due soon.';
  }
  if (draftCount > 0) {
    return 'Activate $draftCount drafted career paths.';
  }
  return 'Keep career paths aligned to target roles.';
}
