import 'project_domain_extension_readiness_service.dart';

enum ProjectDomainExtensionIntakeLaneKind {
  requiredContext,
  riskWatch,
  recommendedContext,
  customContext,
}

class ProjectDomainExtensionIntakePlan {
  const ProjectDomainExtensionIntakePlan({
    required this.businessDomain,
    required this.openFieldCount,
    required this.lanes,
  });

  final String businessDomain;
  final int openFieldCount;
  final List<ProjectDomainExtensionIntakeLane> lanes;

  ProjectDomainExtensionIntakeLane lane(
    ProjectDomainExtensionIntakeLaneKind kind,
  ) {
    return lanes.firstWhere((lane) => lane.kind == kind);
  }

  bool get hasMissingFields => openFieldCount > 0;
}

class ProjectDomainExtensionIntakeLane {
  const ProjectDomainExtensionIntakeLane({
    required this.kind,
    required this.title,
    required this.metricLabel,
    required this.detail,
    required this.completedCount,
    required this.totalCount,
    required this.missingCount,
    this.focusFieldKey,
  });

  final ProjectDomainExtensionIntakeLaneKind kind;
  final String title;
  final String metricLabel;
  final String detail;
  final int completedCount;
  final int totalCount;
  final int missingCount;
  final String? focusFieldKey;

  String get id {
    switch (kind) {
      case ProjectDomainExtensionIntakeLaneKind.requiredContext:
        return 'required-context';
      case ProjectDomainExtensionIntakeLaneKind.riskWatch:
        return 'risk-watch';
      case ProjectDomainExtensionIntakeLaneKind.recommendedContext:
        return 'recommended-context';
      case ProjectDomainExtensionIntakeLaneKind.customContext:
        return 'custom-context';
    }
  }

  bool get hasGaps => missingCount > 0;
  bool get canFocusField => focusFieldKey != null && focusFieldKey!.isNotEmpty;

  double get completionRatio {
    if (totalCount <= 0) return 1;
    return completedCount.clamp(0, totalCount) / totalCount;
  }
}

class ProjectDomainExtensionIntakePlanService {
  const ProjectDomainExtensionIntakePlanService();

  ProjectDomainExtensionIntakePlan build({
    required ProjectDomainExtensionReadinessSummary summary,
  }) {
    final requiredMissingKeys = {
      for (final field in summary.missingRequiredFields) field.key,
    };
    final watchedFocusField = _firstFieldOutsideKeys(
      fields: summary.missingWatchedFields,
      skippedKeys: requiredMissingKeys,
    );
    final watchedMissingCount = summary.missingWatchedFields.length;

    return ProjectDomainExtensionIntakePlan(
      businessDomain: summary.businessDomain,
      openFieldCount: summary.missingTemplateFields.length,
      lanes: List.unmodifiable([
        ProjectDomainExtensionIntakeLane(
          kind: ProjectDomainExtensionIntakeLaneKind.requiredContext,
          title: 'Required',
          metricLabel:
              '${summary.completedRequiredFieldCount}/${summary.requiredFieldCount} required',
          detail: _gapDetail(
            summary.missingRequiredFields.length,
            singular: 'required gap',
            complete: 'Required context complete',
          ),
          completedCount: summary.completedRequiredFieldCount,
          totalCount: summary.requiredFieldCount,
          missingCount: summary.missingRequiredFields.length,
          focusFieldKey: _firstField(summary.missingRequiredFields)?.key,
        ),
        ProjectDomainExtensionIntakeLane(
          kind: ProjectDomainExtensionIntakeLaneKind.riskWatch,
          title: 'Risk Watch',
          metricLabel:
              '${_completedCount(summary.watchedFieldCount, watchedMissingCount)}/${summary.watchedFieldCount} watched',
          detail: _gapDetail(
            watchedMissingCount,
            singular: 'risk signal gap',
            complete: 'Watched fields covered',
          ),
          completedCount: _completedCount(
            summary.watchedFieldCount,
            watchedMissingCount,
          ),
          totalCount: summary.watchedFieldCount,
          missingCount: watchedMissingCount,
          focusFieldKey:
              watchedFocusField?.key ??
              _firstField(summary.missingWatchedFields)?.key,
        ),
        ProjectDomainExtensionIntakeLane(
          kind: ProjectDomainExtensionIntakeLaneKind.recommendedContext,
          title: 'Recommended',
          metricLabel:
              '${summary.completedRecommendedFieldCount}/${summary.recommendedFieldCount} recommended',
          detail: _gapDetail(
            summary.missingRecommendedFields.length,
            singular: 'recommended gap',
            complete: 'Recommended context covered',
          ),
          completedCount: summary.completedRecommendedFieldCount,
          totalCount: summary.recommendedFieldCount,
          missingCount: summary.missingRecommendedFields.length,
          focusFieldKey: _firstField(summary.missingRecommendedFields)?.key,
        ),
        ProjectDomainExtensionIntakeLane(
          kind: ProjectDomainExtensionIntakeLaneKind.customContext,
          title: 'Custom',
          metricLabel:
              '${summary.filledCustomFieldCount} custom ${summary.filledCustomFieldCount == 1 ? 'field' : 'fields'}',
          detail:
              summary.filledCustomFieldCount == 0
                  ? 'No extra context captured'
                  : 'Extra domain context captured',
          completedCount: summary.filledCustomFieldCount,
          totalCount: summary.filledCustomFieldCount,
          missingCount: 0,
        ),
      ]),
    );
  }

  int _completedCount(int totalCount, int missingCount) {
    final completed = totalCount - missingCount;
    if (completed < 0) return 0;
    return completed;
  }

  ProjectDomainExtensionFieldSignal? _firstFieldOutsideKeys({
    required Iterable<ProjectDomainExtensionFieldSignal> fields,
    required Set<String> skippedKeys,
  }) {
    for (final field in fields) {
      if (!skippedKeys.contains(field.key)) return field;
    }
    return null;
  }

  ProjectDomainExtensionFieldSignal? _firstField(
    Iterable<ProjectDomainExtensionFieldSignal> fields,
  ) {
    for (final field in fields) {
      return field;
    }
    return null;
  }

  String _gapDetail(
    int missingCount, {
    required String singular,
    required String complete,
  }) {
    if (missingCount == 0) return complete;
    final plural =
        singular.endsWith('gap')
            ? singular.replaceFirst('gap', 'gaps')
            : '${singular}s';
    return '$missingCount ${missingCount == 1 ? singular : plural}';
  }
}
