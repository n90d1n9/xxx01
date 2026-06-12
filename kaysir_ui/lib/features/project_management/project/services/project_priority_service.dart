import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_domain_extension_readiness_service.dart';

enum ProjectPriority { critical, high, normal, steady }

enum ProjectPortfolioSortOption {
  attention,
  dueDate,
  progress,
  budget,
  domainContext,
  name,
}

extension ProjectPriorityPresentation on ProjectPriority {
  String get label {
    switch (this) {
      case ProjectPriority.critical:
        return 'Critical';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.normal:
        return 'Normal';
      case ProjectPriority.steady:
        return 'Steady';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectPriority.critical:
        return Icons.priority_high_rounded;
      case ProjectPriority.high:
        return Icons.trending_up_rounded;
      case ProjectPriority.normal:
        return Icons.low_priority_rounded;
      case ProjectPriority.steady:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectPriority.critical:
        return colorScheme.error;
      case ProjectPriority.high:
        return Colors.orange.shade700;
      case ProjectPriority.normal:
        return colorScheme.primary;
      case ProjectPriority.steady:
        return Colors.green.shade700;
    }
  }
}

extension ProjectPortfolioSortOptionPresentation on ProjectPortfolioSortOption {
  String get label {
    switch (this) {
      case ProjectPortfolioSortOption.attention:
        return 'Needs Attention';
      case ProjectPortfolioSortOption.dueDate:
        return 'Due Date';
      case ProjectPortfolioSortOption.progress:
        return 'Least Progress';
      case ProjectPortfolioSortOption.budget:
        return 'Budget Used';
      case ProjectPortfolioSortOption.domainContext:
        return 'Domain Context';
      case ProjectPortfolioSortOption.name:
        return 'Project Name';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectPortfolioSortOption.attention:
        return Icons.priority_high_rounded;
      case ProjectPortfolioSortOption.dueDate:
        return Icons.event_outlined;
      case ProjectPortfolioSortOption.progress:
        return Icons.trending_up_rounded;
      case ProjectPortfolioSortOption.budget:
        return Icons.account_balance_wallet_outlined;
      case ProjectPortfolioSortOption.domainContext:
        return Icons.extension_outlined;
      case ProjectPortfolioSortOption.name:
        return Icons.sort_by_alpha_rounded;
    }
  }
}

ProjectPriority projectPriorityFor(ProjectPortfolioItem project) {
  final hasBlockedRisk = project.risks.any(
    (risk) => risk.severity == ProjectHealth.blocked,
  );
  final atRiskCount =
      project.risks
          .where((risk) => risk.severity == ProjectHealth.atRisk)
          .length;
  final budgetGap = project.budgetUsed - project.progress;

  if (project.health == ProjectHealth.blocked || hasBlockedRisk) {
    return ProjectPriority.critical;
  }

  if (project.health == ProjectHealth.atRisk ||
      budgetGap >= 0.15 ||
      atRiskCount >= 2) {
    return ProjectPriority.high;
  }

  if (project.openMilestoneCount > 0 || project.riskCount > 0) {
    return ProjectPriority.normal;
  }

  return ProjectPriority.steady;
}

bool projectNeedsAttention(ProjectPortfolioItem project) {
  final priority = projectPriorityFor(project);
  return priority == ProjectPriority.critical ||
      priority == ProjectPriority.high;
}

List<ProjectPortfolioItem> sortProjectPortfolio(
  Iterable<ProjectPortfolioItem> projects,
  ProjectPortfolioSortOption sortOption,
) {
  final sorted = projects.toList();
  sorted.sort((a, b) {
    switch (sortOption) {
      case ProjectPortfolioSortOption.attention:
        return _compareChain([
          _priorityRank(
            projectPriorityFor(a),
          ).compareTo(_priorityRank(projectPriorityFor(b))),
          a.endDate.compareTo(b.endDate),
          a.name.compareTo(b.name),
        ]);
      case ProjectPortfolioSortOption.dueDate:
        return _compareChain([
          a.endDate.compareTo(b.endDate),
          a.name.compareTo(b.name),
        ]);
      case ProjectPortfolioSortOption.progress:
        return _compareChain([
          a.progress.compareTo(b.progress),
          a.name.compareTo(b.name),
        ]);
      case ProjectPortfolioSortOption.budget:
        return _compareChain([
          b.budgetUsed.compareTo(a.budgetUsed),
          a.name.compareTo(b.name),
        ]);
      case ProjectPortfolioSortOption.domainContext:
        return _compareDomainContext(a, b);
      case ProjectPortfolioSortOption.name:
        return a.name.compareTo(b.name);
    }
  });

  return List.unmodifiable(sorted);
}

int _compareDomainContext(ProjectPortfolioItem a, ProjectPortfolioItem b) {
  final readinessService = const ProjectDomainExtensionReadinessService();
  final aSummary = readinessService.build(
    businessDomain: a.businessDomain,
    attributes: a.customAttributes,
  );
  final bSummary = readinessService.build(
    businessDomain: b.businessDomain,
    attributes: b.customAttributes,
  );

  return _compareChain([
    _readinessStatusRank(
      aSummary.status,
    ).compareTo(_readinessStatusRank(bSummary.status)),
    bSummary.missingRequiredFields.length.compareTo(
      aSummary.missingRequiredFields.length,
    ),
    bSummary.missingRecommendedFields.length.compareTo(
      aSummary.missingRecommendedFields.length,
    ),
    aSummary.completionRatio.compareTo(bSummary.completionRatio),
    _priorityRank(
      projectPriorityFor(a),
    ).compareTo(_priorityRank(projectPriorityFor(b))),
    a.endDate.compareTo(b.endDate),
    a.name.compareTo(b.name),
  ]);
}

int _readinessStatusRank(ProjectDomainExtensionReadinessStatus status) {
  switch (status) {
    case ProjectDomainExtensionReadinessStatus.needsContext:
      return 0;
    case ProjectDomainExtensionReadinessStatus.inProgress:
      return 1;
    case ProjectDomainExtensionReadinessStatus.ready:
      return 2;
  }
}

int _priorityRank(ProjectPriority priority) {
  switch (priority) {
    case ProjectPriority.critical:
      return 0;
    case ProjectPriority.high:
      return 1;
    case ProjectPriority.normal:
      return 2;
    case ProjectPriority.steady:
      return 3;
  }
}

int _compareChain(List<int> comparisons) {
  for (final comparison in comparisons) {
    if (comparison != 0) return comparison;
  }
  return 0;
}
