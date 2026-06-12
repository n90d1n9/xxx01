import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_domain_gap_focus_service.dart';
import 'project_priority_service.dart';

enum ProjectPortfolioViewPreset {
  all,
  needsAttention,
  blocked,
  dueSoon,
  budgetPressure,
  domainGaps,
}

extension ProjectPortfolioViewPresetPresentation on ProjectPortfolioViewPreset {
  String get label {
    switch (this) {
      case ProjectPortfolioViewPreset.all:
        return 'All Projects';
      case ProjectPortfolioViewPreset.needsAttention:
        return 'Needs Attention';
      case ProjectPortfolioViewPreset.blocked:
        return 'Blocked';
      case ProjectPortfolioViewPreset.dueSoon:
        return 'Due Soon';
      case ProjectPortfolioViewPreset.budgetPressure:
        return 'Budget Pressure';
      case ProjectPortfolioViewPreset.domainGaps:
        return 'Domain Gaps';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectPortfolioViewPreset.all:
        return Icons.dashboard_customize_outlined;
      case ProjectPortfolioViewPreset.needsAttention:
        return Icons.priority_high_rounded;
      case ProjectPortfolioViewPreset.blocked:
        return Icons.block_outlined;
      case ProjectPortfolioViewPreset.dueSoon:
        return Icons.event_busy_outlined;
      case ProjectPortfolioViewPreset.budgetPressure:
        return Icons.account_balance_wallet_outlined;
      case ProjectPortfolioViewPreset.domainGaps:
        return Icons.extension_outlined;
    }
  }

  ProjectPortfolioSortOption get recommendedSortOption {
    switch (this) {
      case ProjectPortfolioViewPreset.all:
      case ProjectPortfolioViewPreset.needsAttention:
      case ProjectPortfolioViewPreset.blocked:
        return ProjectPortfolioSortOption.attention;
      case ProjectPortfolioViewPreset.dueSoon:
        return ProjectPortfolioSortOption.dueDate;
      case ProjectPortfolioViewPreset.budgetPressure:
        return ProjectPortfolioSortOption.budget;
      case ProjectPortfolioViewPreset.domainGaps:
        return ProjectPortfolioSortOption.domainContext;
    }
  }
}

bool projectMatchesPortfolioView(
  ProjectPortfolioItem project,
  ProjectPortfolioViewPreset preset, {
  DateTime? today,
  int dueSoonDays = 30,
}) {
  switch (preset) {
    case ProjectPortfolioViewPreset.all:
      return true;
    case ProjectPortfolioViewPreset.needsAttention:
      return projectNeedsAttention(project);
    case ProjectPortfolioViewPreset.blocked:
      return project.health == ProjectHealth.blocked ||
          project.risks.any((risk) => risk.severity == ProjectHealth.blocked);
    case ProjectPortfolioViewPreset.dueSoon:
      return _hasOpenMilestoneDueSoon(
        project,
        today: today,
        dueSoonDays: dueSoonDays,
      );
    case ProjectPortfolioViewPreset.budgetPressure:
      return project.budgetUsed - project.progress >= 0.15;
    case ProjectPortfolioViewPreset.domainGaps:
      return projectMatchesDomainGapFocus(
        project,
        ProjectDomainGapFocus.missingAny,
      );
  }
}

List<ProjectPortfolioItem> filterProjectPortfolioView(
  Iterable<ProjectPortfolioItem> projects,
  ProjectPortfolioViewPreset preset, {
  DateTime? today,
  int dueSoonDays = 30,
}) {
  return List.unmodifiable(
    projects.where(
      (project) => projectMatchesPortfolioView(
        project,
        preset,
        today: today,
        dueSoonDays: dueSoonDays,
      ),
    ),
  );
}

Map<ProjectPortfolioViewPreset, int> countProjectPortfolioViews(
  Iterable<ProjectPortfolioItem> projects, {
  DateTime? today,
  int dueSoonDays = 30,
}) {
  final projectList = projects.toList();

  return {
    for (final preset in ProjectPortfolioViewPreset.values)
      preset:
          preset == ProjectPortfolioViewPreset.all
              ? projectList.length
              : filterProjectPortfolioView(
                projectList,
                preset,
                today: today,
                dueSoonDays: dueSoonDays,
              ).length,
  };
}

bool _hasOpenMilestoneDueSoon(
  ProjectPortfolioItem project, {
  DateTime? today,
  required int dueSoonDays,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());

  for (final milestone in project.milestones) {
    if (milestone.isComplete) continue;

    final days = DateUtils.dateOnly(milestone.dueDate).difference(asOf).inDays;
    if (days >= 0 && days <= dueSoonDays) return true;
  }

  return false;
}
