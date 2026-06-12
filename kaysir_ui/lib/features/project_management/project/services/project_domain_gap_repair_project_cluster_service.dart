import '../models/project_portfolio_item.dart';
import 'project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairProjectCluster {
  const ProjectDomainGapRepairProjectCluster({
    required this.project,
    required this.targets,
  });

  final ProjectPortfolioItem project;
  final List<ProjectDomainGapRepairTarget> targets;

  ProjectDomainGapRepairTarget get primaryTarget => targets.first;
  int get targetCount => targets.length;
  int get requiredCount => _count(ProjectDomainGapRepairPriority.requiredField);
  int get riskSignalCount => _count(ProjectDomainGapRepairPriority.riskSignal);
  int get recommendedCount =>
      _count(ProjectDomainGapRepairPriority.recommended);
  int get coverageGapCount =>
      _count(ProjectDomainGapRepairPriority.coverageGap);
  bool get hasBlockedContext => project.health == ProjectHealth.blocked;
  bool get hasAtRiskContext => project.health == ProjectHealth.atRisk;

  String get actionLabel => '$targetCount fields: ${project.name}';
  String get fieldSummaryLabel {
    final labels = targets.map((target) => target.fieldLabel).toList();
    if (labels.length <= 3) return labels.join(', ');
    return '${labels.take(3).join(', ')} +${labels.length - 3} more';
  }

  String get prioritySummaryLabel {
    final labels = <String>[
      if (requiredCount > 0) '$requiredCount required',
      if (riskSignalCount > 0) '$riskSignalCount risk',
      if (recommendedCount > 0) '$recommendedCount recommended',
      if (coverageGapCount > 0) '$coverageGapCount coverage',
    ];
    return labels.join(' - ');
  }

  String get tooltipLabel =>
      'Open ${primaryTarget.fieldLabel}. Also missing: $fieldSummaryLabel.';

  int _count(ProjectDomainGapRepairPriority priority) {
    return targets.where((target) => target.priority == priority).length;
  }
}

class ProjectDomainGapRepairProjectClusterSummary {
  const ProjectDomainGapRepairProjectClusterSummary({
    required this.visibleClusters,
    required this.allClusters,
    required this.totalClusterCount,
  });

  factory ProjectDomainGapRepairProjectClusterSummary.empty() {
    return const ProjectDomainGapRepairProjectClusterSummary(
      visibleClusters: [],
      allClusters: [],
      totalClusterCount: 0,
    );
  }

  factory ProjectDomainGapRepairProjectClusterSummary.fromPlan(
    ProjectDomainGapRepairPlan plan, {
    int maxClusters = 3,
  }) {
    if (plan.isEmpty || maxClusters <= 0) {
      return ProjectDomainGapRepairProjectClusterSummary.empty();
    }

    final builders = <String, _ProjectClusterBuilder>{};
    final orderedProjectIds = <String>[];

    for (final target in plan.allTargets) {
      final builder = builders.putIfAbsent(target.project.id, () {
        orderedProjectIds.add(target.project.id);
        return _ProjectClusterBuilder(project: target.project);
      });
      builder.targets.add(target);
    }

    final clusters = <ProjectDomainGapRepairProjectCluster>[
      for (final projectId in orderedProjectIds) builders[projectId]!.build(),
    ].where((cluster) => cluster.targetCount > 1).toList(growable: false);

    return ProjectDomainGapRepairProjectClusterSummary(
      visibleClusters: List.unmodifiable(clusters.take(maxClusters)),
      allClusters: List.unmodifiable(clusters),
      totalClusterCount: clusters.length,
    );
  }

  final List<ProjectDomainGapRepairProjectCluster> visibleClusters;
  final List<ProjectDomainGapRepairProjectCluster> allClusters;
  final int totalClusterCount;

  bool get hasClusters => visibleClusters.isNotEmpty;
  bool get hasHiddenClusters => hiddenClusterCount > 0;
  int get hiddenClusterCount => totalClusterCount - visibleClusters.length;
}

ProjectDomainGapRepairProjectClusterSummary
buildProjectDomainGapRepairProjectClusterSummary({
  required ProjectDomainGapRepairPlan plan,
  int maxClusters = 3,
}) {
  return ProjectDomainGapRepairProjectClusterSummary.fromPlan(
    plan,
    maxClusters: maxClusters,
  );
}

class _ProjectClusterBuilder {
  _ProjectClusterBuilder({required this.project});

  final ProjectPortfolioItem project;
  final List<ProjectDomainGapRepairTarget> targets = [];

  ProjectDomainGapRepairProjectCluster build() {
    return ProjectDomainGapRepairProjectCluster(
      project: project,
      targets: List.unmodifiable(targets),
    );
  }
}
