import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_budget_overview_service.dart';
import 'project_finance_action_queue_service.dart';
import 'project_finance_ledger_records_service.dart';
import 'project_finance_ledger_summary_service.dart';

/// Portfolio-level finance triage status for project finance operations.
enum ProjectFinancePortfolioTriageLevel { healthy, watch, critical }

/// Finance triage entry for one project in the portfolio queue.
class ProjectFinancePortfolioTriageEntry {
  const ProjectFinancePortfolioTriageEntry({
    required this.projectId,
    required this.projectName,
    required this.client,
    required this.businessDomain,
    required this.budgetUsedPercent,
    required this.budgetVariancePoints,
    required this.actionCount,
    required this.criticalActionCount,
    required this.watchActionCount,
    required this.openLedgerCount,
    required this.blockedLedgerCount,
    required this.primaryActionTitle,
    required this.level,
  });

  final String projectId;
  final String projectName;
  final String client;
  final String businessDomain;
  final int budgetUsedPercent;
  final int budgetVariancePoints;
  final int actionCount;
  final int criticalActionCount;
  final int watchActionCount;
  final int openLedgerCount;
  final int blockedLedgerCount;
  final String primaryActionTitle;
  final ProjectFinancePortfolioTriageLevel level;

  bool get hasActions => actionCount > 0;

  String get budgetVarianceLabel {
    if (budgetVariancePoints == 0) return '0 pts';
    return '${budgetVariancePoints > 0 ? '+' : ''}$budgetVariancePoints pts';
  }
}

/// Portfolio finance triage rollup used by the finance workspace selector.
class ProjectFinancePortfolioTriageSummary {
  const ProjectFinancePortfolioTriageSummary({required this.entries});

  final List<ProjectFinancePortfolioTriageEntry> entries;

  int get projectCount => entries.length;
  int get actionCount =>
      entries.fold(0, (sum, entry) => sum + entry.actionCount);
  int get criticalActionCount =>
      entries.fold(0, (sum, entry) => sum + entry.criticalActionCount);
  int get openLedgerCount =>
      entries.fold(0, (sum, entry) => sum + entry.openLedgerCount);
  int get blockedLedgerCount =>
      entries.fold(0, (sum, entry) => sum + entry.blockedLedgerCount);
  int get criticalProjectCount =>
      entries
          .where(
            (entry) =>
                entry.level == ProjectFinancePortfolioTriageLevel.critical,
          )
          .length;

  ProjectFinancePortfolioTriageLevel get level {
    if (criticalProjectCount > 0 || blockedLedgerCount > 0) {
      return ProjectFinancePortfolioTriageLevel.critical;
    }
    if (actionCount > 0 || openLedgerCount > 0) {
      return ProjectFinancePortfolioTriageLevel.watch;
    }
    return ProjectFinancePortfolioTriageLevel.healthy;
  }

  String get title {
    switch (level) {
      case ProjectFinancePortfolioTriageLevel.healthy:
        return 'Portfolio finance is clear';
      case ProjectFinancePortfolioTriageLevel.watch:
        return 'Portfolio finance needs follow-up';
      case ProjectFinancePortfolioTriageLevel.critical:
        return 'Portfolio finance needs intervention';
    }
  }

  String get detail {
    if (entries.isEmpty) {
      return 'No projects are available for finance triage yet.';
    }
    return '$actionCount actions across $projectCount projects - $openLedgerCount open ledger items - $blockedLedgerCount blocked.';
  }
}

/// Builds a sorted portfolio finance triage summary from project records.
ProjectFinancePortfolioTriageSummary buildProjectFinancePortfolioTriageSummary(
  List<ProjectPortfolioItem> projects,
) {
  final entries = projects.map(_buildEntry).toList(growable: false)
    ..sort(_compareEntries);
  return ProjectFinancePortfolioTriageSummary(entries: entries);
}

ProjectFinancePortfolioTriageEntry _buildEntry(ProjectPortfolioItem project) {
  final budget = buildProjectBudgetOverview(project);
  final ledger = buildProjectFinanceLedgerSummary(projectId: project.id);
  final records = buildProjectFinanceLedgerRecordsView(ledger);
  final queue = buildProjectFinanceActionQueue(ledger);
  final level = _levelFor(
    budgetUsedPercent: budget.budgetUsedPercent,
    criticalActionCount: queue.criticalCount,
    actionCount: queue.actionCount,
    blockedLedgerCount: records.blockedCount,
    openLedgerCount: records.openCount,
  );

  return ProjectFinancePortfolioTriageEntry(
    projectId: project.id,
    projectName: project.name,
    client: project.client,
    businessDomain: project.businessDomain,
    budgetUsedPercent: budget.budgetUsedPercent,
    budgetVariancePoints: budget.variancePoints,
    actionCount: queue.actionCount,
    criticalActionCount: queue.criticalCount,
    watchActionCount: queue.watchCount,
    openLedgerCount: records.openCount,
    blockedLedgerCount: records.blockedCount,
    primaryActionTitle:
        queue.primaryAction?.title ?? 'No finance action queued',
    level: level,
  );
}

ProjectFinancePortfolioTriageLevel _levelFor({
  required int budgetUsedPercent,
  required int criticalActionCount,
  required int actionCount,
  required int blockedLedgerCount,
  required int openLedgerCount,
}) {
  if (criticalActionCount > 0 ||
      blockedLedgerCount > 0 ||
      budgetUsedPercent >= 90) {
    return ProjectFinancePortfolioTriageLevel.critical;
  }
  if (actionCount > 0 || openLedgerCount > 0 || budgetUsedPercent >= 75) {
    return ProjectFinancePortfolioTriageLevel.watch;
  }
  return ProjectFinancePortfolioTriageLevel.healthy;
}

int _compareEntries(
  ProjectFinancePortfolioTriageEntry left,
  ProjectFinancePortfolioTriageEntry right,
) {
  final levelComparison = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelComparison != 0) return levelComparison;

  final criticalComparison = right.criticalActionCount.compareTo(
    left.criticalActionCount,
  );
  if (criticalComparison != 0) return criticalComparison;

  final actionComparison = right.actionCount.compareTo(left.actionCount);
  if (actionComparison != 0) return actionComparison;

  return right.budgetUsedPercent.compareTo(left.budgetUsedPercent);
}

int _levelRank(ProjectFinancePortfolioTriageLevel level) {
  switch (level) {
    case ProjectFinancePortfolioTriageLevel.critical:
      return 0;
    case ProjectFinancePortfolioTriageLevel.watch:
      return 1;
    case ProjectFinancePortfolioTriageLevel.healthy:
      return 2;
  }
}

extension ProjectFinancePortfolioTriageLevelPresentation
    on ProjectFinancePortfolioTriageLevel {
  /// User-facing label for a project finance triage level.
  String get label {
    switch (this) {
      case ProjectFinancePortfolioTriageLevel.healthy:
        return 'Healthy';
      case ProjectFinancePortfolioTriageLevel.watch:
        return 'Watch';
      case ProjectFinancePortfolioTriageLevel.critical:
        return 'Critical';
    }
  }

  /// Icon for a project finance triage level.
  IconData get icon {
    switch (this) {
      case ProjectFinancePortfolioTriageLevel.healthy:
        return Icons.verified_outlined;
      case ProjectFinancePortfolioTriageLevel.watch:
        return Icons.pending_actions_outlined;
      case ProjectFinancePortfolioTriageLevel.critical:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a project finance triage level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinancePortfolioTriageLevel.healthy:
        return Colors.green.shade700;
      case ProjectFinancePortfolioTriageLevel.watch:
        return Colors.orange.shade700;
      case ProjectFinancePortfolioTriageLevel.critical:
        return colorScheme.error;
    }
  }
}
