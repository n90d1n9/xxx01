import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_path.dart';

/// Aggregates career framework levels into coverage and governance metrics.
class IncomingTalentCareerFrameworkLevelSummary {
  final int totalCount;
  final int familyCount;
  final int activeCount;
  final int draftCount;
  final int reviewCount;
  final int archivedCount;
  final int attentionCount;
  final int mappedCareerPathCount;
  final int unmappedCareerPathCount;
  final double mappingRatio;
  final String nextAction;

  const IncomingTalentCareerFrameworkLevelSummary({
    required this.totalCount,
    required this.familyCount,
    required this.activeCount,
    required this.draftCount,
    required this.reviewCount,
    required this.archivedCount,
    required this.attentionCount,
    required this.mappedCareerPathCount,
    required this.unmappedCareerPathCount,
    required this.mappingRatio,
    required this.nextAction,
  });

  factory IncomingTalentCareerFrameworkLevelSummary.fromLevels({
    required List<IncomingTalentCareerFrameworkLevel> levels,
    required List<IncomingTalentCareerPath> careerPaths,
  }) {
    final draftCount = _countStatus(
      levels,
      IncomingTalentCareerFrameworkLevelStatus.draft,
    );
    final activeCount = _countStatus(
      levels,
      IncomingTalentCareerFrameworkLevelStatus.active,
    );
    final reviewCount = _countStatus(
      levels,
      IncomingTalentCareerFrameworkLevelStatus.review,
    );
    final archivedCount = _countStatus(
      levels,
      IncomingTalentCareerFrameworkLevelStatus.archived,
    );
    final attentionCount = levels.where((level) => level.needsAttention).length;
    final mappedCareerPathCount =
        careerPaths
            .where(
              (careerPath) =>
                  levels.any((level) => level.matchesCareerPath(careerPath)),
            )
            .length;
    final unmappedCareerPathCount = careerPaths.length - mappedCareerPathCount;

    return IncomingTalentCareerFrameworkLevelSummary(
      totalCount: levels.length,
      familyCount: levels.map((level) => level.familyKey).toSet().length,
      activeCount: activeCount,
      draftCount: draftCount,
      reviewCount: reviewCount,
      archivedCount: archivedCount,
      attentionCount: attentionCount,
      mappedCareerPathCount: mappedCareerPathCount,
      unmappedCareerPathCount: unmappedCareerPathCount,
      mappingRatio:
          careerPaths.isEmpty ? 0 : mappedCareerPathCount / careerPaths.length,
      nextAction: _nextAction(
        totalCount: levels.length,
        attentionCount: attentionCount,
        unmappedCareerPathCount: unmappedCareerPathCount,
      ),
    );
  }
}

extension _IncomingTalentCareerFrameworkLevelFamilyKey
    on IncomingTalentCareerFrameworkLevel {
  String get familyKey {
    return '${department.trim().toLowerCase()}|${familyName.trim().toLowerCase()}';
  }
}

int _countStatus(
  List<IncomingTalentCareerFrameworkLevel> levels,
  IncomingTalentCareerFrameworkLevelStatus status,
) {
  return levels.where((level) => level.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int attentionCount,
  required int unmappedCareerPathCount,
}) {
  if (totalCount == 0) {
    return 'Create framework levels for active career paths.';
  }
  if (unmappedCareerPathCount > 0) {
    return 'Map $unmappedCareerPathCount career paths to framework levels.';
  }
  if (attentionCount > 0) {
    return 'Review $attentionCount framework levels needing calibration.';
  }
  return 'Keep role ladders aligned to career paths.';
}
