import 'package:flutter/material.dart';

import 'project_finance_action_queue_service.dart';
import 'project_finance_ledger_records_service.dart';
import 'project_finance_workspace_service.dart';

/// Finance scenario option used to compare budget outcomes.
enum ProjectFinanceScenarioKind { currentPace, guardedSpend, recoveryPlan }

/// Scenario health level based on forecast, open records, and actions.
enum ProjectFinanceScenarioLevel { healthy, watch, constrained }

/// One finance scenario projection for project budget planning.
class ProjectFinanceScenarioOption {
  const ProjectFinanceScenarioOption({
    required this.kind,
    required this.title,
    required this.detail,
    required this.releasePolicyLabel,
    required this.projectedAtCompletion,
    required this.expectedActionCount,
    required this.expectedOpenLedgerCount,
    required this.level,
  });

  final ProjectFinanceScenarioKind kind;
  final String title;
  final String detail;
  final String releasePolicyLabel;
  final double projectedAtCompletion;
  final int expectedActionCount;
  final int expectedOpenLedgerCount;
  final ProjectFinanceScenarioLevel level;

  int get projectedAtCompletionPercent => (projectedAtCompletion * 100).round();
  int get budgetDeltaPoints => ((projectedAtCompletion - 1) * 100).round();

  String get budgetDeltaLabel {
    if (budgetDeltaPoints == 0) return 'On budget';
    if (budgetDeltaPoints > 0) return '+$budgetDeltaPoints pts over';
    return '${budgetDeltaPoints.abs()} pts under';
  }
}

/// Scenario planning summary for one project finance workspace.
class ProjectFinanceScenarioSummary {
  const ProjectFinanceScenarioSummary({
    required this.projectId,
    required this.projectName,
    required this.budgetUsedPercent,
    required this.options,
  });

  final String projectId;
  final String projectName;
  final int budgetUsedPercent;
  final List<ProjectFinanceScenarioOption> options;

  int get scenarioCount => options.length;

  ProjectFinanceScenarioOption get recommendedOption {
    for (final option in options) {
      if (option.level == ProjectFinanceScenarioLevel.healthy) return option;
    }
    for (final option in options) {
      if (option.level == ProjectFinanceScenarioLevel.watch) return option;
    }
    return options.first;
  }

  String get title {
    switch (recommendedOption.level) {
      case ProjectFinanceScenarioLevel.healthy:
        return 'Scenario runway healthy';
      case ProjectFinanceScenarioLevel.watch:
        return 'Scenario runway needs watch';
      case ProjectFinanceScenarioLevel.constrained:
        return 'Scenario runway constrained';
    }
  }

  String get detail {
    return 'Recommended: ${recommendedOption.title} projects ${recommendedOption.projectedAtCompletionPercent}% at completion with ${recommendedOption.expectedActionCount} finance actions remaining.';
  }
}

/// Builds budget scenarios from the selected project finance workspace summary.
ProjectFinanceScenarioSummary buildProjectFinanceScenarioSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final actionQueue = buildProjectFinanceActionQueue(summary.financeLedger);
  final recordsView = buildProjectFinanceLedgerRecordsView(
    summary.financeLedger,
  );
  final currentProjection = _boundedProjection(
    summary.cashFlowForecast.projectedAtCompletion +
        _criticalPressure(actionQueue.criticalCount),
  );
  final guardedProjection = _boundedProjection(
    currentProjection -
        _guardedReduction(
          actionQueue: actionQueue,
          openLedgerCount: recordsView.openCount,
        ),
  );
  final recoveryProjection = _boundedProjection(
    currentProjection -
        _recoveryReduction(
          actionQueue: actionQueue,
          openLedgerCount: recordsView.openCount,
        ),
  );

  final currentActions = actionQueue.actionCount;
  final currentOpenLedger = recordsView.openCount;
  final guardedActions = _reducedCount(currentActions, 2);
  final guardedOpenLedger = _reducedCount(currentOpenLedger, 2);
  final recoveryActions = _reducedCount(currentActions, 4);
  final recoveryOpenLedger = _reducedCount(currentOpenLedger, 4);

  return ProjectFinanceScenarioSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    budgetUsedPercent: summary.budgetOverview.budgetUsedPercent,
    options: List.unmodifiable([
      ProjectFinanceScenarioOption(
        kind: ProjectFinanceScenarioKind.currentPace,
        title: ProjectFinanceScenarioKind.currentPace.label,
        detail:
            'Keep current release rhythm and resolve finance records as they arrive.',
        releasePolicyLabel: 'Normal release cadence',
        projectedAtCompletion: currentProjection,
        expectedActionCount: currentActions,
        expectedOpenLedgerCount: currentOpenLedger,
        level: _scenarioLevel(
          projectedAtCompletion: currentProjection,
          criticalActionCount: actionQueue.criticalCount,
          expectedActionCount: currentActions,
          expectedOpenLedgerCount: currentOpenLedger,
        ),
      ),
      ProjectFinanceScenarioOption(
        kind: ProjectFinanceScenarioKind.guardedSpend,
        title: ProjectFinanceScenarioKind.guardedSpend.label,
        detail:
            'Hold discretionary releases until approval, proof, and petty-cash records are cleaner.',
        releasePolicyLabel: 'Gate spend by proof',
        projectedAtCompletion: guardedProjection,
        expectedActionCount: guardedActions,
        expectedOpenLedgerCount: guardedOpenLedger,
        level: _scenarioLevel(
          projectedAtCompletion: guardedProjection,
          criticalActionCount: actionQueue.criticalCount,
          expectedActionCount: guardedActions,
          expectedOpenLedgerCount: guardedOpenLedger,
        ),
      ),
      ProjectFinanceScenarioOption(
        kind: ProjectFinanceScenarioKind.recoveryPlan,
        title: ProjectFinanceScenarioKind.recoveryPlan.label,
        detail:
            'Prioritize blocks, pause low-value spend, and protect reserve until the next finance gate clears.',
        releasePolicyLabel: 'Recovery gate',
        projectedAtCompletion: recoveryProjection,
        expectedActionCount: recoveryActions,
        expectedOpenLedgerCount: recoveryOpenLedger,
        level: _scenarioLevel(
          projectedAtCompletion: recoveryProjection,
          criticalActionCount:
              recoveryActions == 0 ? 0 : actionQueue.criticalCount,
          expectedActionCount: recoveryActions,
          expectedOpenLedgerCount: recoveryOpenLedger,
        ),
      ),
    ]),
  );
}

double _criticalPressure(int criticalActionCount) {
  return (criticalActionCount * 0.02).clamp(0.0, 0.12).toDouble();
}

double _guardedReduction({
  required ProjectFinanceActionQueue actionQueue,
  required int openLedgerCount,
}) {
  return (0.04 + actionQueue.watchCount * 0.01 + openLedgerCount * 0.005)
      .clamp(0.04, 0.14)
      .toDouble();
}

double _recoveryReduction({
  required ProjectFinanceActionQueue actionQueue,
  required int openLedgerCount,
}) {
  return (0.08 +
          actionQueue.actionCount * 0.015 +
          actionQueue.criticalCount * 0.02 +
          openLedgerCount * 0.005)
      .clamp(0.08, 0.24)
      .toDouble();
}

double _boundedProjection(double projection) {
  return projection.clamp(0.0, 2.0).toDouble();
}

int _reducedCount(int value, int reduction) {
  return (value - reduction).clamp(0, value).toInt();
}

ProjectFinanceScenarioLevel _scenarioLevel({
  required double projectedAtCompletion,
  required int criticalActionCount,
  required int expectedActionCount,
  required int expectedOpenLedgerCount,
}) {
  if (projectedAtCompletion >= 1.12 || criticalActionCount > 0) {
    return ProjectFinanceScenarioLevel.constrained;
  }
  if (projectedAtCompletion >= 1 ||
      expectedActionCount > 0 ||
      expectedOpenLedgerCount > 0) {
    return ProjectFinanceScenarioLevel.watch;
  }
  return ProjectFinanceScenarioLevel.healthy;
}

extension ProjectFinanceScenarioKindPresentation on ProjectFinanceScenarioKind {
  /// User-facing label for a project finance scenario kind.
  String get label {
    switch (this) {
      case ProjectFinanceScenarioKind.currentPace:
        return 'Current Pace';
      case ProjectFinanceScenarioKind.guardedSpend:
        return 'Guarded Spend';
      case ProjectFinanceScenarioKind.recoveryPlan:
        return 'Recovery Plan';
    }
  }

  /// Icon for a project finance scenario kind.
  IconData get icon {
    switch (this) {
      case ProjectFinanceScenarioKind.currentPace:
        return Icons.speed_outlined;
      case ProjectFinanceScenarioKind.guardedSpend:
        return Icons.verified_user_outlined;
      case ProjectFinanceScenarioKind.recoveryPlan:
        return Icons.health_and_safety_outlined;
    }
  }
}

extension ProjectFinanceScenarioLevelPresentation
    on ProjectFinanceScenarioLevel {
  /// User-facing label for a project finance scenario level.
  String get label {
    switch (this) {
      case ProjectFinanceScenarioLevel.healthy:
        return 'Healthy';
      case ProjectFinanceScenarioLevel.watch:
        return 'Watch';
      case ProjectFinanceScenarioLevel.constrained:
        return 'Constrained';
    }
  }

  /// Icon for a project finance scenario level.
  IconData get icon {
    switch (this) {
      case ProjectFinanceScenarioLevel.healthy:
        return Icons.verified_outlined;
      case ProjectFinanceScenarioLevel.watch:
        return Icons.visibility_outlined;
      case ProjectFinanceScenarioLevel.constrained:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a project finance scenario level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceScenarioLevel.healthy:
        return Colors.green.shade700;
      case ProjectFinanceScenarioLevel.watch:
        return Colors.orange.shade700;
      case ProjectFinanceScenarioLevel.constrained:
        return colorScheme.error;
    }
  }
}
