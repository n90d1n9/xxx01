import '../models/project_portfolio_item.dart';
import 'project_budget_pulse_service.dart';

/// Single-project budget rollup used by detail screens and finance panels.
class ProjectBudgetOverview {
  const ProjectBudgetOverview({
    required this.projectId,
    required this.projectName,
    required this.progress,
    required this.budgetUsed,
    required this.state,
  });

  final String projectId;
  final String projectName;
  final double progress;
  final double budgetUsed;
  final ProjectBudgetPulseState state;

  double get variance => budgetUsed - progress;
  int get progressPercent => _percent(progress);
  int get budgetUsedPercent => _percent(budgetUsed);
  int get remainingBudgetPercent => _percent((1 - budgetUsed).clamp(0, 1));
  int get variancePoints => (variance * 100).round();

  String get varianceLabel => _signedPoints(variancePoints);

  String get paceLabel {
    switch (state) {
      case ProjectBudgetPulseState.critical:
        return 'Budget overrun risk';
      case ProjectBudgetPulseState.pressure:
        return 'Spend ahead of progress';
      case ProjectBudgetPulseState.aligned:
        return 'Spend aligned to progress';
      case ProjectBudgetPulseState.efficient:
        return 'Under planned spend';
    }
  }

  String get detail {
    return '$budgetUsedPercent% budget used against $progressPercent% progress ($varianceLabel).';
  }
}

/// Builds a reusable single-project budget overview from portfolio fields.
ProjectBudgetOverview buildProjectBudgetOverview(ProjectPortfolioItem project) {
  return ProjectBudgetOverview(
    projectId: project.id,
    projectName: project.name,
    progress: project.progress,
    budgetUsed: project.budgetUsed,
    state: _budgetState(project),
  );
}

ProjectBudgetPulseState _budgetState(ProjectPortfolioItem project) {
  final variance = project.budgetUsed - project.progress;
  if (project.budgetUsed >= 1 ||
      variance >= 0.25 ||
      (variance >= 0.18 && project.health == ProjectHealth.blocked)) {
    return ProjectBudgetPulseState.critical;
  }
  if (variance >= 0.15 || project.budgetUsed >= 0.85) {
    return ProjectBudgetPulseState.pressure;
  }
  if (variance <= -0.12 && project.progress >= 0.3) {
    return ProjectBudgetPulseState.efficient;
  }
  return ProjectBudgetPulseState.aligned;
}

int _percent(num value) => (value * 100).round();

String _signedPoints(int points) {
  if (points == 0) return '0 pts';
  return '${points > 0 ? '+' : ''}$points pts';
}
