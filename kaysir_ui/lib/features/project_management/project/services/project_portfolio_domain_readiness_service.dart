import '../models/project_portfolio_item.dart';
import 'project_domain_extension_readiness_service.dart';

class ProjectPortfolioDomainReadinessSummary {
  const ProjectPortfolioDomainReadinessSummary({
    required this.projectCount,
    required this.readyCount,
    required this.inProgressCount,
    required this.needsContextCount,
    required this.completedReadinessFieldCount,
    required this.readinessFieldCount,
  });

  final int projectCount;
  final int readyCount;
  final int inProgressCount;
  final int needsContextCount;
  final int completedReadinessFieldCount;
  final int readinessFieldCount;

  bool get hasProjects => projectCount > 0;

  double get completionRatio {
    if (readinessFieldCount == 0) return hasProjects ? 1 : 0;
    return completedReadinessFieldCount / readinessFieldCount;
  }

  int get completionPercent => (completionRatio * 100).round();

  String get helperLabel {
    if (!hasProjects) return 'No projects in view';
    if (needsContextCount > 0) {
      return '$needsContextCount need context - $readyCount ready';
    }
    if (inProgressCount > 0) {
      return '$inProgressCount in progress - $readyCount ready';
    }
    return '$readyCount of $projectCount ready';
  }
}

ProjectPortfolioDomainReadinessSummary buildProjectPortfolioDomainReadiness({
  required Iterable<ProjectPortfolioItem> projects,
  ProjectDomainExtensionReadinessService readinessService =
      const ProjectDomainExtensionReadinessService(),
}) {
  var projectCount = 0;
  var readyCount = 0;
  var inProgressCount = 0;
  var needsContextCount = 0;
  var completedReadinessFieldCount = 0;
  var readinessFieldCount = 0;

  for (final project in projects) {
    projectCount += 1;
    final summary = readinessService.build(
      businessDomain: project.businessDomain,
      attributes: project.customAttributes,
    );

    completedReadinessFieldCount += summary.completedReadinessFieldCount;
    readinessFieldCount += summary.readinessFieldCount;

    switch (summary.status) {
      case ProjectDomainExtensionReadinessStatus.ready:
        readyCount += 1;
      case ProjectDomainExtensionReadinessStatus.inProgress:
        inProgressCount += 1;
      case ProjectDomainExtensionReadinessStatus.needsContext:
        needsContextCount += 1;
    }
  }

  return ProjectPortfolioDomainReadinessSummary(
    projectCount: projectCount,
    readyCount: readyCount,
    inProgressCount: inProgressCount,
    needsContextCount: needsContextCount,
    completedReadinessFieldCount: completedReadinessFieldCount,
    readinessFieldCount: readinessFieldCount,
  );
}
