import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_domain_extension_readiness_service.dart';
import 'project_priority_service.dart';

enum ProjectPortfolioBriefingSignal { clear, watch, pressure, blocked }

class ProjectPortfolioBriefingRisk {
  const ProjectPortfolioBriefingRisk({
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String projectId;
  final String projectName;
  final String title;
  final String detail;
  final ProjectHealth severity;
}

class ProjectPortfolioBriefingMilestone {
  const ProjectPortfolioBriefingMilestone({
    required this.projectId,
    required this.projectName,
    required this.label,
    required this.dueDate,
    required this.daysUntilDue,
  });

  final String projectId;
  final String projectName;
  final String label;
  final DateTime dueDate;
  final int daysUntilDue;

  bool get isOverdue => daysUntilDue < 0;

  String get dueLabel {
    if (daysUntilDue < 0) return '${daysUntilDue.abs()}d overdue';
    if (daysUntilDue == 0) return 'Due today';
    if (daysUntilDue == 1) return 'Due tomorrow';

    return 'Due in ${daysUntilDue}d';
  }
}

class ProjectPortfolioBriefingDomainGap {
  const ProjectPortfolioBriefingDomainGap({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.status,
    required this.completedReadinessFieldCount,
    required this.readinessFieldCount,
    required this.missingRequiredFields,
    required this.missingRecommendedFields,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final ProjectDomainExtensionReadinessStatus status;
  final int completedReadinessFieldCount;
  final int readinessFieldCount;
  final List<String> missingRequiredFields;
  final List<String> missingRecommendedFields;

  String get completionLabel {
    return '$completedReadinessFieldCount/$readinessFieldCount';
  }

  String get statusLabel {
    switch (status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return 'Needs Context';
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return 'In Progress';
      case ProjectDomainExtensionReadinessStatus.ready:
        return 'Ready';
    }
  }

  String get missingFieldLabel {
    final fields =
        missingRequiredFields.isNotEmpty
            ? missingRequiredFields
            : missingRecommendedFields;
    if (fields.isEmpty) return 'No missing domain fields';

    final visible = fields.take(3).join(', ');
    final hiddenCount = fields.length - fields.take(3).length;
    return hiddenCount > 0 ? '$visible +$hiddenCount more' : visible;
  }
}

class ProjectPortfolioBriefingSummary {
  const ProjectPortfolioBriefingSummary({
    required this.visibleCount,
    required this.totalCount,
    required this.attentionCount,
    required this.blockedCount,
    required this.budgetPressureCount,
    required this.domainContextGapCount,
    required this.signal,
    this.recommendedProject,
    this.strongestRisk,
    this.nextMilestone,
    this.domainGap,
  });

  final int visibleCount;
  final int totalCount;
  final int attentionCount;
  final int blockedCount;
  final int budgetPressureCount;
  final int domainContextGapCount;
  final ProjectPortfolioBriefingSignal signal;
  final ProjectPortfolioItem? recommendedProject;
  final ProjectPortfolioBriefingRisk? strongestRisk;
  final ProjectPortfolioBriefingMilestone? nextMilestone;
  final ProjectPortfolioBriefingDomainGap? domainGap;

  bool get hasProjects => visibleCount > 0;

  String get actionTitle {
    final projectName = recommendedProject?.name ?? 'this portfolio view';

    switch (signal) {
      case ProjectPortfolioBriefingSignal.blocked:
        return 'Unblock $projectName';
      case ProjectPortfolioBriefingSignal.pressure:
        return 'Rebalance $projectName';
      case ProjectPortfolioBriefingSignal.watch:
        return 'Protect the next milestone';
      case ProjectPortfolioBriefingSignal.clear:
        if (hasProjects && domainContextGapCount > 0) {
          return 'Complete domain context';
        }
        return hasProjects ? 'Portfolio view is steady' : 'No projects in view';
    }
  }

  String get actionDetail {
    if (!hasProjects) {
      return 'Adjust the search, health filter, or saved view to bring projects back into focus.';
    }

    if (blockedCount > 0) {
      return '$blockedCount blocked signal${blockedCount == 1 ? '' : 's'} need ownership before delivery can recover.';
    }

    if (attentionCount > 0) {
      return '$attentionCount project${attentionCount == 1 ? '' : 's'} need delivery attention in the current board view.';
    }

    final milestone = nextMilestone;
    if (milestone != null && milestone.daysUntilDue <= 14) {
      return '${milestone.projectName} has ${milestone.label} ${milestone.dueLabel.toLowerCase()}.';
    }

    if (domainContextGapCount > 0) {
      return '$domainContextGapCount project${domainContextGapCount == 1 ? '' : 's'} need domain fields completed before handoff quality is reliable.';
    }

    return '$visibleCount of $totalCount project${totalCount == 1 ? '' : 's'} are ready for routine follow-up.';
  }
}

extension ProjectPortfolioBriefingSignalPresentation
    on ProjectPortfolioBriefingSignal {
  String get label {
    switch (this) {
      case ProjectPortfolioBriefingSignal.clear:
        return 'Clear';
      case ProjectPortfolioBriefingSignal.watch:
        return 'Watch';
      case ProjectPortfolioBriefingSignal.pressure:
        return 'Pressure';
      case ProjectPortfolioBriefingSignal.blocked:
        return 'Blocked';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectPortfolioBriefingSignal.clear:
        return Icons.check_circle_outline;
      case ProjectPortfolioBriefingSignal.watch:
        return Icons.visibility_outlined;
      case ProjectPortfolioBriefingSignal.pressure:
        return Icons.priority_high_rounded;
      case ProjectPortfolioBriefingSignal.blocked:
        return Icons.block_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectPortfolioBriefingSignal.clear:
        return Colors.green.shade700;
      case ProjectPortfolioBriefingSignal.watch:
        return colorScheme.primary;
      case ProjectPortfolioBriefingSignal.pressure:
        return Colors.orange.shade700;
      case ProjectPortfolioBriefingSignal.blocked:
        return colorScheme.error;
    }
  }
}

ProjectPortfolioBriefingSummary buildProjectPortfolioBriefing({
  required Iterable<ProjectPortfolioItem> projects,
  int? totalProjectCount,
  DateTime? today,
}) {
  final projectList = projects.toList();
  final totalCount = totalProjectCount ?? projectList.length;
  final attentionProjects =
      sortProjectPortfolio(
        projectList.where(projectNeedsAttention),
        ProjectPortfolioSortOption.attention,
      ).toList();
  final sortedProjects =
      sortProjectPortfolio(
        projectList,
        ProjectPortfolioSortOption.attention,
      ).toList();
  final blockedCount =
      projectList.where((project) => _projectHasBlockedSignal(project)).length;
  final budgetPressureCount =
      projectList.where((project) => _projectHasBudgetPressure(project)).length;
  final domainGap = _topDomainGap(projectList);
  final domainContextGapCount = _domainContextGapCount(projectList);
  final strongestRisk = _strongestRisk(projectList);
  final nextMilestone = _nextOpenMilestone(projectList, today: today);
  final recommendedProject =
      attentionProjects.isNotEmpty
          ? attentionProjects.first
          : sortedProjects.isNotEmpty
          ? sortedProjects.first
          : null;

  return ProjectPortfolioBriefingSummary(
    visibleCount: projectList.length,
    totalCount: totalCount,
    attentionCount: attentionProjects.length,
    blockedCount: blockedCount,
    budgetPressureCount: budgetPressureCount,
    domainContextGapCount: domainContextGapCount,
    signal: _briefingSignal(
      hasProjects: projectList.isNotEmpty,
      blockedCount: blockedCount,
      attentionCount: attentionProjects.length,
      budgetPressureCount: budgetPressureCount,
      nextMilestone: nextMilestone,
    ),
    recommendedProject: recommendedProject,
    strongestRisk: strongestRisk,
    nextMilestone: nextMilestone,
    domainGap: domainGap,
  );
}

bool _projectHasBlockedSignal(ProjectPortfolioItem project) {
  return project.health == ProjectHealth.blocked ||
      project.risks.any((risk) => risk.severity == ProjectHealth.blocked);
}

bool _projectHasBudgetPressure(ProjectPortfolioItem project) {
  return project.budgetUsed - project.progress >= 0.15;
}

int _domainContextGapCount(Iterable<ProjectPortfolioItem> projects) {
  final readinessService = const ProjectDomainExtensionReadinessService();
  return projects.where((project) {
    final summary = readinessService.build(
      businessDomain: project.businessDomain,
      attributes: project.customAttributes,
    );
    return summary.status != ProjectDomainExtensionReadinessStatus.ready;
  }).length;
}

ProjectPortfolioBriefingDomainGap? _topDomainGap(
  Iterable<ProjectPortfolioItem> projects,
) {
  final readinessService = const ProjectDomainExtensionReadinessService();
  final candidates = <_DomainGapCandidate>[];

  for (final project in projects) {
    final summary = readinessService.build(
      businessDomain: project.businessDomain,
      attributes: project.customAttributes,
    );
    if (summary.status == ProjectDomainExtensionReadinessStatus.ready) {
      continue;
    }

    candidates.add(_DomainGapCandidate(project: project, summary: summary));
  }

  candidates.sort((a, b) {
    return _compareChain([
      _domainReadinessRank(
        a.summary.status,
      ).compareTo(_domainReadinessRank(b.summary.status)),
      b.summary.missingRequiredFields.length.compareTo(
        a.summary.missingRequiredFields.length,
      ),
      b.summary.missingRecommendedFields.length.compareTo(
        a.summary.missingRecommendedFields.length,
      ),
      _priorityRank(
        projectPriorityFor(a.project),
      ).compareTo(_priorityRank(projectPriorityFor(b.project))),
      a.project.endDate.compareTo(b.project.endDate),
      a.project.name.compareTo(b.project.name),
    ]);
  });

  final top = candidates.isEmpty ? null : candidates.first;
  if (top == null) return null;

  return ProjectPortfolioBriefingDomainGap(
    projectId: top.project.id,
    projectName: top.project.name,
    businessDomain: top.summary.businessDomain,
    status: top.summary.status,
    completedReadinessFieldCount: top.summary.completedReadinessFieldCount,
    readinessFieldCount: top.summary.readinessFieldCount,
    missingRequiredFields: List.unmodifiable(
      top.summary.missingRequiredFields.map((field) => field.label),
    ),
    missingRecommendedFields: List.unmodifiable(
      top.summary.missingRecommendedFields.map((field) => field.label),
    ),
  );
}

ProjectPortfolioBriefingSignal _briefingSignal({
  required bool hasProjects,
  required int blockedCount,
  required int attentionCount,
  required int budgetPressureCount,
  required ProjectPortfolioBriefingMilestone? nextMilestone,
}) {
  if (!hasProjects) return ProjectPortfolioBriefingSignal.clear;
  if (blockedCount > 0) return ProjectPortfolioBriefingSignal.blocked;
  if (attentionCount > 0 || budgetPressureCount > 0) {
    return ProjectPortfolioBriefingSignal.pressure;
  }
  if (nextMilestone != null && nextMilestone.daysUntilDue <= 14) {
    return ProjectPortfolioBriefingSignal.watch;
  }

  return ProjectPortfolioBriefingSignal.clear;
}

ProjectPortfolioBriefingRisk? _strongestRisk(
  Iterable<ProjectPortfolioItem> projects,
) {
  final risks = <_RiskCandidate>[];

  for (final project in projects) {
    for (final risk in project.risks) {
      if (risk.severity == ProjectHealth.onTrack) continue;

      risks.add(_RiskCandidate(project: project, risk: risk));
    }
  }

  risks.sort((a, b) {
    return _compareChain([
      _healthRank(a.risk.severity).compareTo(_healthRank(b.risk.severity)),
      _priorityRank(
        projectPriorityFor(a.project),
      ).compareTo(_priorityRank(projectPriorityFor(b.project))),
      a.project.endDate.compareTo(b.project.endDate),
      a.risk.title.compareTo(b.risk.title),
    ]);
  });

  final strongest = risks.isEmpty ? null : risks.first;
  if (strongest == null) return null;

  return ProjectPortfolioBriefingRisk(
    projectId: strongest.project.id,
    projectName: strongest.project.name,
    title: strongest.risk.title,
    detail: strongest.risk.detail,
    severity: strongest.risk.severity,
  );
}

ProjectPortfolioBriefingMilestone? _nextOpenMilestone(
  Iterable<ProjectPortfolioItem> projects, {
  DateTime? today,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final milestones = <ProjectPortfolioBriefingMilestone>[];

  for (final project in projects) {
    for (final milestone in project.milestones) {
      if (milestone.isComplete) continue;

      final dueDate = DateUtils.dateOnly(milestone.dueDate);
      milestones.add(
        ProjectPortfolioBriefingMilestone(
          projectId: project.id,
          projectName: project.name,
          label: milestone.label,
          dueDate: dueDate,
          daysUntilDue: dueDate.difference(asOf).inDays,
        ),
      );
    }
  }

  milestones.sort((a, b) {
    return _compareChain([
      a.dueDate.compareTo(b.dueDate),
      a.projectName.compareTo(b.projectName),
      a.label.compareTo(b.label),
    ]);
  });

  return milestones.isEmpty ? null : milestones.first;
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

int _domainReadinessRank(ProjectDomainExtensionReadinessStatus status) {
  switch (status) {
    case ProjectDomainExtensionReadinessStatus.needsContext:
      return 0;
    case ProjectDomainExtensionReadinessStatus.inProgress:
      return 1;
    case ProjectDomainExtensionReadinessStatus.ready:
      return 2;
  }
}

int _compareChain(List<int> comparisons) {
  for (final comparison in comparisons) {
    if (comparison != 0) return comparison;
  }

  return 0;
}

class _RiskCandidate {
  const _RiskCandidate({required this.project, required this.risk});

  final ProjectPortfolioItem project;
  final ProjectDeliveryRisk risk;
}

class _DomainGapCandidate {
  const _DomainGapCandidate({required this.project, required this.summary});

  final ProjectPortfolioItem project;
  final ProjectDomainExtensionReadinessSummary summary;
}
