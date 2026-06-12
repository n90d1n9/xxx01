import '../models/project_portfolio_item.dart';
import 'project_table_custom_column_service.dart';

enum ProjectDomainGapRepairPriority {
  requiredField,
  riskSignal,
  recommended,
  coverageGap,
}

class ProjectDomainGapRepairTarget {
  const ProjectDomainGapRepairTarget({
    required this.project,
    required this.column,
    required this.priority,
  });

  final ProjectPortfolioItem project;
  final ProjectTableCustomColumn column;
  final ProjectDomainGapRepairPriority priority;

  String get fieldLabel => column.label;
  String get projectLabel => project.name;
  String get priorityLabel {
    switch (priority) {
      case ProjectDomainGapRepairPriority.requiredField:
        return 'Required';
      case ProjectDomainGapRepairPriority.riskSignal:
        return 'Risk signal';
      case ProjectDomainGapRepairPriority.recommended:
        return 'Recommended';
      case ProjectDomainGapRepairPriority.coverageGap:
        return 'Coverage gap';
    }
  }

  String get contextLabel =>
      '${project.businessDomain} - ${project.health.label}';
  String get repairLabel => 'Fix ${column.label}';
}

class ProjectDomainGapRepairPlan {
  const ProjectDomainGapRepairPlan({
    required this.visibleTargets,
    required this.allTargets,
    required this.totalTargetCount,
    required this.requiredTargetCount,
    required this.riskSignalTargetCount,
    required this.recommendedTargetCount,
    required this.coverageGapTargetCount,
  });

  factory ProjectDomainGapRepairPlan.empty() {
    return const ProjectDomainGapRepairPlan(
      visibleTargets: [],
      allTargets: [],
      totalTargetCount: 0,
      requiredTargetCount: 0,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );
  }

  factory ProjectDomainGapRepairPlan.fromTargets(
    List<ProjectDomainGapRepairTarget> targets,
  ) {
    return ProjectDomainGapRepairPlan(
      visibleTargets: List.unmodifiable(targets),
      allTargets: List.unmodifiable(targets),
      totalTargetCount: targets.length,
      requiredTargetCount:
          targets
              .where(
                (target) =>
                    target.priority ==
                    ProjectDomainGapRepairPriority.requiredField,
              )
              .length,
      riskSignalTargetCount:
          targets
              .where(
                (target) =>
                    target.priority ==
                    ProjectDomainGapRepairPriority.riskSignal,
              )
              .length,
      recommendedTargetCount:
          targets
              .where(
                (target) =>
                    target.priority ==
                    ProjectDomainGapRepairPriority.recommended,
              )
              .length,
      coverageGapTargetCount:
          targets
              .where(
                (target) =>
                    target.priority ==
                    ProjectDomainGapRepairPriority.coverageGap,
              )
              .length,
    );
  }

  final List<ProjectDomainGapRepairTarget> visibleTargets;
  final List<ProjectDomainGapRepairTarget> allTargets;
  final int totalTargetCount;
  final int requiredTargetCount;
  final int riskSignalTargetCount;
  final int recommendedTargetCount;
  final int coverageGapTargetCount;

  bool get isEmpty => allTargets.isEmpty;
  bool get hasHiddenTargets => hiddenTargetCount > 0;
  int get visibleTargetCount => visibleTargets.length;
  int get hiddenTargetCount => totalTargetCount - visibleTargetCount;
}

List<ProjectDomainGapRepairTarget> buildProjectDomainGapRepairTargets({
  required List<ProjectPortfolioItem> projects,
  required List<ProjectTableCustomColumn> columns,
  required Set<String> editableProjectIds,
  int maxTargets = 4,
}) {
  return buildProjectDomainGapRepairPlan(
    projects: projects,
    columns: columns,
    editableProjectIds: editableProjectIds,
    maxTargets: maxTargets,
  ).visibleTargets;
}

ProjectDomainGapRepairPlan buildProjectDomainGapRepairPlan({
  required List<ProjectPortfolioItem> projects,
  required List<ProjectTableCustomColumn> columns,
  required Set<String> editableProjectIds,
  int maxTargets = 4,
}) {
  if (projects.isEmpty ||
      columns.isEmpty ||
      editableProjectIds.isEmpty ||
      maxTargets <= 0) {
    return ProjectDomainGapRepairPlan.empty();
  }

  final targets = <ProjectDomainGapRepairTarget>[];

  for (final project in projects) {
    if (!editableProjectIds.contains(project.id)) continue;

    for (final column in columns) {
      if (!column.applicableProjectIds.contains(project.id) ||
          column.hasValueFor(project)) {
        continue;
      }

      targets.add(
        ProjectDomainGapRepairTarget(
          project: project,
          column: column,
          priority: _priorityFor(project: project, column: column),
        ),
      );
    }
  }

  targets.sort(_compareRepairTargets);
  return ProjectDomainGapRepairPlan(
    visibleTargets: List.unmodifiable(targets.take(maxTargets)),
    allTargets: List.unmodifiable(targets),
    totalTargetCount: targets.length,
    requiredTargetCount: _countTargets(
      targets,
      ProjectDomainGapRepairPriority.requiredField,
    ),
    riskSignalTargetCount: _countTargets(
      targets,
      ProjectDomainGapRepairPriority.riskSignal,
    ),
    recommendedTargetCount: _countTargets(
      targets,
      ProjectDomainGapRepairPriority.recommended,
    ),
    coverageGapTargetCount: _countTargets(
      targets,
      ProjectDomainGapRepairPriority.coverageGap,
    ),
  );
}

ProjectDomainGapRepairPriority _priorityFor({
  required ProjectPortfolioItem project,
  required ProjectTableCustomColumn column,
}) {
  if (column.isRequiredFor(project)) {
    return ProjectDomainGapRepairPriority.requiredField;
  }
  if (column.isRiskWatchedFor(project)) {
    return ProjectDomainGapRepairPriority.riskSignal;
  }
  if (column.isRecommendedFor(project)) {
    return ProjectDomainGapRepairPriority.recommended;
  }
  return ProjectDomainGapRepairPriority.coverageGap;
}

int _compareRepairTargets(
  ProjectDomainGapRepairTarget first,
  ProjectDomainGapRepairTarget second,
) {
  final priorityCompare = _priorityRank(
    first.priority,
  ).compareTo(_priorityRank(second.priority));
  if (priorityCompare != 0) return priorityCompare;

  final healthCompare = _healthRank(
    first.project.health,
  ).compareTo(_healthRank(second.project.health));
  if (healthCompare != 0) return healthCompare;

  final dueCompare = first.project.endDate.compareTo(second.project.endDate);
  if (dueCompare != 0) return dueCompare;

  final projectCompare = first.project.name.compareTo(second.project.name);
  if (projectCompare != 0) return projectCompare;

  return first.column.label.compareTo(second.column.label);
}

int _priorityRank(ProjectDomainGapRepairPriority priority) {
  switch (priority) {
    case ProjectDomainGapRepairPriority.requiredField:
      return 0;
    case ProjectDomainGapRepairPriority.riskSignal:
      return 1;
    case ProjectDomainGapRepairPriority.recommended:
      return 2;
    case ProjectDomainGapRepairPriority.coverageGap:
      return 3;
  }
}

int _healthRank(ProjectHealth health) {
  switch (health) {
    case ProjectHealth.blocked:
      return 0;
    case ProjectHealth.atRisk:
      return 1;
    case ProjectHealth.onTrack:
      return 2;
  }
}

int _countTargets(
  Iterable<ProjectDomainGapRepairTarget> targets,
  ProjectDomainGapRepairPriority priority,
) {
  return targets.where((target) => target.priority == priority).length;
}
