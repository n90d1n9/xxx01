import '../data/project_domain_registry.dart';
import '../models/project_custom_attribute.dart';
import '../models/project_portfolio_item.dart';

class ProjectTableCustomColumn {
  const ProjectTableCustomColumn({
    required this.key,
    required this.label,
    required this.type,
    required this.applicableProjectIds,
    required this.filledProjectIds,
    required this.pinnedProjectIds,
    required this.requiredProjectIds,
    required this.recommendedProjectIds,
    required this.riskWatchedProjectIds,
  });

  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final Set<String> applicableProjectIds;
  final Set<String> filledProjectIds;
  final Set<String> pinnedProjectIds;
  final Set<String> requiredProjectIds;
  final Set<String> recommendedProjectIds;
  final Set<String> riskWatchedProjectIds;

  int get applicableProjectCount => applicableProjectIds.length;
  int get filledProjectCount => filledProjectIds.length;
  int get pinnedProjectCount => pinnedProjectIds.length;
  int get requiredProjectCount => requiredProjectIds.length;
  int get recommendedProjectCount => recommendedProjectIds.length;
  int get riskWatchedProjectCount => riskWatchedProjectIds.length;
  Set<String> get missingProjectIds =>
      Set.unmodifiable(applicableProjectIds.difference(filledProjectIds));
  Set<String> get missingRequiredProjectIds =>
      Set.unmodifiable(requiredProjectIds.difference(filledProjectIds));
  Set<String> get missingRecommendedProjectIds =>
      Set.unmodifiable(recommendedProjectIds.difference(filledProjectIds));
  Set<String> get missingRiskSignalProjectIds =>
      Set.unmodifiable(riskWatchedProjectIds.difference(filledProjectIds));
  int get missingProjectCount => missingProjectIds.length;
  int get missingRequiredProjectCount => missingRequiredProjectIds.length;
  int get missingRecommendedProjectCount => missingRecommendedProjectIds.length;
  int get missingRiskSignalProjectCount => missingRiskSignalProjectIds.length;
  int get coveragePercent =>
      applicableProjectCount == 0
          ? 0
          : (filledProjectCount / applicableProjectCount * 100).round();
  String get coverageLabel =>
      '$filledProjectCount/$applicableProjectCount filled';

  String get sourceLabel {
    if (requiredProjectCount > 0) return 'Required';
    if (recommendedProjectCount > 0) return 'Recommended';
    return 'Custom';
  }

  String get summaryLabel {
    final details = <String>[
      '$filledProjectCount/$applicableProjectCount filled',
      sourceLabel,
    ];
    if (riskWatchedProjectCount > 0) {
      details.add('Risk signal in $riskWatchedProjectCount');
    }
    return details.join(' - ');
  }

  String get gapSummaryLabel {
    if (missingRequiredProjectCount > 0) {
      return _countLabel(missingRequiredProjectCount, 'required gap');
    }
    if (missingRecommendedProjectCount > 0) {
      return _countLabel(missingRecommendedProjectCount, 'recommended gap');
    }
    if (missingRiskSignalProjectCount > 0) {
      return _countLabel(missingRiskSignalProjectCount, 'risk signal gap');
    }
    if (missingProjectCount > 0) {
      return _countLabel(missingProjectCount, 'gap');
    }
    return 'Complete';
  }

  bool hasValueFor(ProjectPortfolioItem project) {
    return _attributeFor(project)?.hasValue ?? false;
  }

  bool isRequiredFor(ProjectPortfolioItem project) {
    return requiredProjectIds.contains(project.id);
  }

  bool isRecommendedFor(ProjectPortfolioItem project) {
    return recommendedProjectIds.contains(project.id);
  }

  bool isRiskWatchedFor(ProjectPortfolioItem project) {
    return riskWatchedProjectIds.contains(project.id);
  }

  String valueFor(ProjectPortfolioItem project) {
    return _attributeFor(project)?.displayValue ?? 'Not set';
  }

  String displayValueFor(ProjectPortfolioItem project) {
    if (hasValueFor(project)) return valueFor(project);
    if (isRequiredFor(project)) return 'Missing required';
    if (isRecommendedFor(project)) return 'Missing recommended';
    if (isRiskWatchedFor(project)) return 'Missing signal';
    return 'Not set';
  }

  String tooltipFor(ProjectPortfolioItem project) {
    return '$label: ${displayValueFor(project)}';
  }

  ProjectCustomAttribute? _attributeFor(ProjectPortfolioItem project) {
    for (final attribute in project.customAttributes) {
      if (normalizeProjectCustomAttributeKey(attribute.key) == key) {
        return attribute;
      }
    }
    return null;
  }
}

String _countLabel(int count, String singularLabel) {
  final label = count == 1 ? singularLabel : '${singularLabel}s';
  return '$count $label';
}

List<ProjectTableCustomColumn> buildProjectTableCustomColumns({
  required List<ProjectPortfolioItem> projects,
  int maxColumns = 3,
}) {
  if (maxColumns <= 0 || projects.isEmpty) return const [];

  final statsByKey = <String, _ProjectTableCustomColumnStats>{};
  var firstSeenIndex = 0;

  for (final project in projects) {
    final pack = projectDomainPackForBusinessDomain(project.businessDomain);
    final watchedKeys = {
      for (final rule in pack.riskRules)
        normalizeProjectCustomAttributeKey(rule.attributeKey),
    };
    final attributesByKey = {
      for (final attribute in project.customAttributes)
        normalizeProjectCustomAttributeKey(attribute.key): attribute,
    };
    final registeredKeys = <String>{};

    for (final template in pack.customAttributeTemplates) {
      final key = normalizeProjectCustomAttributeKey(template.key);
      final attribute = attributesByKey[key];
      final shouldShow =
          template.importance != ProjectCustomAttributeImportance.optional ||
          watchedKeys.contains(key) ||
          (attribute?.hasValue ?? false);
      if (!shouldShow || !registeredKeys.add(key)) continue;

      final stats = statsByKey.putIfAbsent(
        key,
        () => _ProjectTableCustomColumnStats(
          key: key,
          label: template.label,
          type: template.type,
          firstSeenIndex: firstSeenIndex++,
        ),
      );
      stats.register(
        projectId: project.id,
        attribute: attribute,
        importance: template.importance,
        isRiskWatched: watchedKeys.contains(key),
      );
    }

    for (final attribute in project.customAttributes) {
      final key = normalizeProjectCustomAttributeKey(attribute.key);
      if (!attribute.hasValue || !registeredKeys.add(key)) continue;

      final stats = statsByKey.putIfAbsent(
        key,
        () => _ProjectTableCustomColumnStats(
          key: key,
          label: attribute.label,
          type: attribute.type,
          firstSeenIndex: firstSeenIndex++,
        ),
      );
      stats.register(projectId: project.id, attribute: attribute);
    }
  }

  final stats =
      statsByKey.values.toList()..sort((first, second) {
        final requiredCompare = second.requiredProjectCount.compareTo(
          first.requiredProjectCount,
        );
        if (requiredCompare != 0) return requiredCompare;

        final recommendedCompare = second.recommendedProjectCount.compareTo(
          first.recommendedProjectCount,
        );
        if (recommendedCompare != 0) return recommendedCompare;

        final pinnedCompare = second.pinnedProjectCount.compareTo(
          first.pinnedProjectCount,
        );
        if (pinnedCompare != 0) return pinnedCompare;

        final filledCompare = second.filledProjectCount.compareTo(
          first.filledProjectCount,
        );
        if (filledCompare != 0) return filledCompare;

        final riskCompare = second.riskWatchedProjectCount.compareTo(
          first.riskWatchedProjectCount,
        );
        if (riskCompare != 0) return riskCompare;

        final applicableCompare = second.applicableProjectCount.compareTo(
          first.applicableProjectCount,
        );
        if (applicableCompare != 0) return applicableCompare;

        return first.firstSeenIndex.compareTo(second.firstSeenIndex);
      });

  return List.unmodifiable(
    stats.take(maxColumns).map((stats) => stats.toColumn()),
  );
}

class _ProjectTableCustomColumnStats {
  _ProjectTableCustomColumnStats({
    required this.key,
    required this.label,
    required this.type,
    required this.firstSeenIndex,
  });

  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final int firstSeenIndex;
  final applicableProjectIds = <String>{};
  final filledProjectIds = <String>{};
  final pinnedProjectIds = <String>{};
  final requiredProjectIds = <String>{};
  final recommendedProjectIds = <String>{};
  final riskWatchedProjectIds = <String>{};

  int get applicableProjectCount => applicableProjectIds.length;
  int get filledProjectCount => filledProjectIds.length;
  int get pinnedProjectCount => pinnedProjectIds.length;
  int get requiredProjectCount => requiredProjectIds.length;
  int get recommendedProjectCount => recommendedProjectIds.length;
  int get riskWatchedProjectCount => riskWatchedProjectIds.length;

  void register({
    required String projectId,
    ProjectCustomAttribute? attribute,
    ProjectCustomAttributeImportance importance =
        ProjectCustomAttributeImportance.optional,
    bool isRiskWatched = false,
  }) {
    applicableProjectIds.add(projectId);
    if (attribute?.hasValue ?? false) filledProjectIds.add(projectId);
    if (attribute?.isPinned ?? false) pinnedProjectIds.add(projectId);

    switch (importance) {
      case ProjectCustomAttributeImportance.requiredField:
        requiredProjectIds.add(projectId);
      case ProjectCustomAttributeImportance.recommended:
        recommendedProjectIds.add(projectId);
      case ProjectCustomAttributeImportance.optional:
        break;
    }

    if (isRiskWatched) riskWatchedProjectIds.add(projectId);
  }

  ProjectTableCustomColumn toColumn() {
    return ProjectTableCustomColumn(
      key: key,
      label: label,
      type: type,
      applicableProjectIds: Set.unmodifiable(applicableProjectIds),
      filledProjectIds: Set.unmodifiable(filledProjectIds),
      pinnedProjectIds: Set.unmodifiable(pinnedProjectIds),
      requiredProjectIds: Set.unmodifiable(requiredProjectIds),
      recommendedProjectIds: Set.unmodifiable(recommendedProjectIds),
      riskWatchedProjectIds: Set.unmodifiable(riskWatchedProjectIds),
    );
  }
}
