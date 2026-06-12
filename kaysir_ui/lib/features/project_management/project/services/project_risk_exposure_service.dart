import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';

class ProjectRiskExposureItem {
  const ProjectRiskExposureItem({
    required this.projectId,
    required this.projectName,
    required this.projectHealth,
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String projectId;
  final String projectName;
  final ProjectHealth projectHealth;
  final String title;
  final String detail;
  final ProjectHealth severity;

  int get exposureWeight {
    switch (severity) {
      case ProjectHealth.blocked:
        return 3;
      case ProjectHealth.atRisk:
        return 2;
      case ProjectHealth.onTrack:
        return 1;
    }
  }

  bool get isActive => severity != ProjectHealth.onTrack;
}

class ProjectRiskExposureSummary {
  const ProjectRiskExposureSummary({required this.items});

  final List<ProjectRiskExposureItem> items;

  int get totalCount => items.length;
  int get activeCount => items.where((item) => item.isActive).length;
  int get criticalCount =>
      items.where((item) => item.severity == ProjectHealth.blocked).length;
  int get warningCount =>
      items.where((item) => item.severity == ProjectHealth.atRisk).length;
  int get monitoredCount =>
      items.where((item) => item.severity == ProjectHealth.onTrack).length;
  int get projectCount =>
      items
          .where((item) => item.isActive)
          .map((item) => item.projectId)
          .toSet()
          .length;
  int get exposureScore =>
      items.fold<int>(0, (sum, item) => sum + item.exposureWeight);

  ProjectHealth get signal {
    if (criticalCount > 0) return ProjectHealth.blocked;
    if (warningCount > 0) return ProjectHealth.atRisk;
    return ProjectHealth.onTrack;
  }

  List<ProjectRiskExposureItem> get prioritizedItems {
    final sortedItems = [...items]..sort(_compareRiskExposureItems);
    return List.unmodifiable(sortedItems);
  }
}

ProjectRiskExposureSummary buildProjectRiskExposureSummary({
  required List<ProjectPortfolioItem> projects,
}) {
  final items = <ProjectRiskExposureItem>[];

  for (final project in projects) {
    for (final risk in project.risks) {
      items.add(
        ProjectRiskExposureItem(
          projectId: project.id,
          projectName: project.name,
          projectHealth: project.health,
          title: risk.title,
          detail: risk.detail,
          severity: risk.severity,
        ),
      );
    }
  }

  items.sort(_compareRiskExposureItems);
  return ProjectRiskExposureSummary(items: List.unmodifiable(items));
}

String projectRiskExposureDetail(ProjectRiskExposureItem item) {
  if (!item.isActive) {
    return '${item.projectName} is monitoring this risk with no current escalation.';
  }

  return '${item.projectName} needs attention: ${item.detail}';
}

extension ProjectRiskExposurePresentation on ProjectHealth {
  String get riskLabel {
    switch (this) {
      case ProjectHealth.onTrack:
        return 'Monitored';
      case ProjectHealth.atRisk:
        return 'Warning';
      case ProjectHealth.blocked:
        return 'Critical';
    }
  }

  IconData get riskIcon {
    switch (this) {
      case ProjectHealth.onTrack:
        return Icons.verified_outlined;
      case ProjectHealth.atRisk:
        return Icons.warning_amber_rounded;
      case ProjectHealth.blocked:
        return Icons.priority_high_rounded;
    }
  }
}

int _compareRiskExposureItems(
  ProjectRiskExposureItem left,
  ProjectRiskExposureItem right,
) {
  final severityCompare = _severityRank(
    left.severity,
  ).compareTo(_severityRank(right.severity));
  if (severityCompare != 0) return severityCompare;

  final projectHealthCompare = _severityRank(
    left.projectHealth,
  ).compareTo(_severityRank(right.projectHealth));
  if (projectHealthCompare != 0) return projectHealthCompare;

  final projectCompare = left.projectName.compareTo(right.projectName);
  if (projectCompare != 0) return projectCompare;

  return left.title.compareTo(right.title);
}

int _severityRank(ProjectHealth health) {
  switch (health) {
    case ProjectHealth.blocked:
      return 0;
    case ProjectHealth.atRisk:
      return 1;
    case ProjectHealth.onTrack:
      return 2;
  }
}
