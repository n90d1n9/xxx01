import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';

enum ProjectBudgetPulseState { critical, pressure, aligned, efficient }

class ProjectBudgetPulseItem {
  const ProjectBudgetPulseItem({
    required this.projectId,
    required this.projectName,
    required this.projectHealth,
    required this.progress,
    required this.budgetUsed,
    required this.state,
  });

  final String projectId;
  final String projectName;
  final ProjectHealth projectHealth;
  final double progress;
  final double budgetUsed;
  final ProjectBudgetPulseState state;

  double get variance => budgetUsed - progress;
  int get variancePoints => (variance * 100).round();
  int get progressPercent => (progress * 100).round();
  int get budgetPercent => (budgetUsed * 100).round();
  bool get needsAttention =>
      state == ProjectBudgetPulseState.critical ||
      state == ProjectBudgetPulseState.pressure;
}

class ProjectBudgetPulseSummary {
  const ProjectBudgetPulseSummary({required this.items});

  final List<ProjectBudgetPulseItem> items;

  int get projectCount => items.length;
  int get pressureCount => items.where((item) => item.needsAttention).length;
  int get criticalCount =>
      items
          .where((item) => item.state == ProjectBudgetPulseState.critical)
          .length;
  int get efficientCount =>
      items
          .where((item) => item.state == ProjectBudgetPulseState.efficient)
          .length;
  int get averageVariancePoints {
    if (items.isEmpty) return 0;
    final average =
        items.fold<double>(0, (sum, item) => sum + item.variance) /
        items.length;
    return (average * 100).round();
  }

  ProjectBudgetPulseState get signal {
    if (criticalCount > 0) return ProjectBudgetPulseState.critical;
    if (pressureCount > 0) return ProjectBudgetPulseState.pressure;
    if (efficientCount == items.length && items.isNotEmpty) {
      return ProjectBudgetPulseState.efficient;
    }
    return ProjectBudgetPulseState.aligned;
  }

  List<ProjectBudgetPulseItem> get prioritizedItems {
    final sortedItems = [...items]..sort(_compareBudgetPulseItems);
    return List.unmodifiable(sortedItems);
  }
}

ProjectBudgetPulseSummary buildProjectBudgetPulseSummary({
  required List<ProjectPortfolioItem> projects,
}) {
  final items = [
    for (final project in projects)
      ProjectBudgetPulseItem(
        projectId: project.id,
        projectName: project.name,
        projectHealth: project.health,
        progress: project.progress,
        budgetUsed: project.budgetUsed,
        state: _budgetPulseState(project),
      ),
  ]..sort(_compareBudgetPulseItems);

  return ProjectBudgetPulseSummary(items: List.unmodifiable(items));
}

String projectBudgetPulseDetail(ProjectBudgetPulseItem item) {
  return '${item.budgetPercent}% budget used against ${item.progressPercent}% progress (${_signedPoints(item.variancePoints)}).';
}

extension ProjectBudgetPulseStatePresentation on ProjectBudgetPulseState {
  String get label {
    switch (this) {
      case ProjectBudgetPulseState.critical:
        return 'Critical';
      case ProjectBudgetPulseState.pressure:
        return 'Pressure';
      case ProjectBudgetPulseState.aligned:
        return 'Aligned';
      case ProjectBudgetPulseState.efficient:
        return 'Efficient';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectBudgetPulseState.critical:
        return Icons.priority_high_rounded;
      case ProjectBudgetPulseState.pressure:
        return Icons.account_balance_wallet_outlined;
      case ProjectBudgetPulseState.aligned:
        return Icons.sync_alt_rounded;
      case ProjectBudgetPulseState.efficient:
        return Icons.savings_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectBudgetPulseState.critical:
        return colorScheme.error;
      case ProjectBudgetPulseState.pressure:
        return Colors.orange.shade700;
      case ProjectBudgetPulseState.aligned:
        return colorScheme.primary;
      case ProjectBudgetPulseState.efficient:
        return Colors.green.shade700;
    }
  }
}

ProjectBudgetPulseState _budgetPulseState(ProjectPortfolioItem project) {
  final variance = project.budgetUsed - project.progress;
  if (variance >= 0.25 ||
      (variance >= 0.18 && project.health == ProjectHealth.blocked)) {
    return ProjectBudgetPulseState.critical;
  }
  if (variance >= 0.15) return ProjectBudgetPulseState.pressure;
  if (variance <= -0.12 && project.progress >= 0.3) {
    return ProjectBudgetPulseState.efficient;
  }
  return ProjectBudgetPulseState.aligned;
}

int _compareBudgetPulseItems(
  ProjectBudgetPulseItem left,
  ProjectBudgetPulseItem right,
) {
  final stateCompare = _stateRank(
    left.state,
  ).compareTo(_stateRank(right.state));
  if (stateCompare != 0) return stateCompare;

  final varianceCompare = right.variance.compareTo(left.variance);
  if (varianceCompare != 0) return varianceCompare;

  return left.projectName.compareTo(right.projectName);
}

int _stateRank(ProjectBudgetPulseState state) {
  switch (state) {
    case ProjectBudgetPulseState.critical:
      return 0;
    case ProjectBudgetPulseState.pressure:
      return 1;
    case ProjectBudgetPulseState.efficient:
      return 2;
    case ProjectBudgetPulseState.aligned:
      return 3;
  }
}

String _signedPoints(int points) {
  if (points == 0) return '0 pts';
  return '${points > 0 ? '+' : ''}$points pts';
}
