import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_decision_action_plan_service.dart';
import 'project_decision_governance_service.dart';
import 'project_decision_register_service.dart';
import 'project_next_decision_service.dart';
import 'project_status_update_service.dart';

/// Summary signal for a consolidated project decision brief pack.
enum ProjectDecisionBriefPackSignal { recovery, attention, aligned }

/// Copy-ready decision brief pack for sponsors, teams, and governance reviews.
class ProjectDecisionBriefPackSummary {
  const ProjectDecisionBriefPackSummary({
    required this.project,
    required this.signal,
    required this.title,
    required this.subtitle,
    required this.routeLabel,
    required this.primaryDecisionLabel,
    required this.ownerFocusLabel,
    required this.highlightLines,
    required this.actionLines,
    required this.evidenceLines,
    required this.briefText,
  });

  final ProjectPortfolioItem project;
  final ProjectDecisionBriefPackSignal signal;
  final String title;
  final String subtitle;
  final String routeLabel;
  final String primaryDecisionLabel;
  final String ownerFocusLabel;
  final List<String> highlightLines;
  final List<String> actionLines;
  final List<String> evidenceLines;
  final String briefText;

  int get highlightCount => highlightLines.length;
  int get actionCount => actionLines.length;
  int get evidenceCount => evidenceLines.length;
}

/// Builds a consolidated decision pack from decision workspace summaries.
ProjectDecisionBriefPackSummary buildProjectDecisionBriefPackSummary({
  required ProjectPortfolioItem project,
  required ProjectNextDecisionSummary nextDecisionSummary,
  required ProjectDecisionGovernanceSummary governanceSummary,
  required ProjectDecisionRegisterSummary registerSummary,
  required ProjectDecisionActionPlanSummary actionPlanSummary,
}) {
  final signal = _briefSignal(registerSummary, actionPlanSummary);
  final primaryDecision = nextDecisionSummary.primaryDecision;
  final primaryOwnerAction = actionPlanSummary.primaryAction;
  final routeLabel =
      '${governanceSummary.vocabulary.label}: ${governanceSummary.decisionRoute} - ${governanceSummary.level.label}';
  final ownerFocusLabel =
      primaryOwnerAction == null
          ? 'No owner actions waiting'
          : '${primaryOwnerAction.owner}: ${primaryOwnerAction.nextStepLabel}';
  final highlightLines = _highlightLines(
    project: project,
    nextDecisionSummary: nextDecisionSummary,
    governanceSummary: governanceSummary,
    registerSummary: registerSummary,
    actionPlanSummary: actionPlanSummary,
  );
  final actionLines = _actionLines(actionPlanSummary);
  final evidenceLines = _evidenceLines(registerSummary, governanceSummary);
  final title = '${project.name} decision brief pack';
  final subtitle =
      '${signal.label} - ${registerSummary.openCount} open - ${actionPlanSummary.ownerCount} owners - ${governanceSummary.decisionRoute}';
  final primaryDecisionLabel =
      '${primaryDecision.title} - ${primaryDecision.level.summaryLabel}';
  final briefText = _briefText(
    title: title,
    signal: signal,
    routeLabel: routeLabel,
    primaryDecisionLabel: primaryDecisionLabel,
    ownerFocusLabel: ownerFocusLabel,
    highlights: highlightLines,
    actions: actionLines,
    evidence: evidenceLines,
  );

  return ProjectDecisionBriefPackSummary(
    project: project,
    signal: signal,
    title: title,
    subtitle: subtitle,
    routeLabel: routeLabel,
    primaryDecisionLabel: primaryDecisionLabel,
    ownerFocusLabel: ownerFocusLabel,
    highlightLines: List.unmodifiable(highlightLines),
    actionLines: List.unmodifiable(actionLines),
    evidenceLines: List.unmodifiable(evidenceLines),
    briefText: briefText,
  );
}

ProjectDecisionBriefPackSignal _briefSignal(
  ProjectDecisionRegisterSummary registerSummary,
  ProjectDecisionActionPlanSummary actionPlanSummary,
) {
  if (registerSummary.overdueCount > 0 ||
      registerSummary.blockedCount > 0 ||
      actionPlanSummary.signal == ProjectDecisionOwnerSignal.critical) {
    return ProjectDecisionBriefPackSignal.recovery;
  }
  if (registerSummary.awaitingDecisionCount > 0 ||
      registerSummary.openCount > 0) {
    return ProjectDecisionBriefPackSignal.attention;
  }

  return ProjectDecisionBriefPackSignal.aligned;
}

List<String> _highlightLines({
  required ProjectPortfolioItem project,
  required ProjectNextDecisionSummary nextDecisionSummary,
  required ProjectDecisionGovernanceSummary governanceSummary,
  required ProjectDecisionRegisterSummary registerSummary,
  required ProjectDecisionActionPlanSummary actionPlanSummary,
}) {
  return [
    'Decision signal: ${nextDecisionSummary.level.summaryLabel} with ${nextDecisionSummary.readinessScore}/100 readiness.',
    'Governance route: ${governanceSummary.decisionRoute} for ${governanceSummary.audience.label.toLowerCase()} review.',
    'Register load: ${registerSummary.openCount} open, ${registerSummary.awaitingDecisionCount} awaiting, ${registerSummary.overdueCount} overdue.',
    'Owner focus: ${actionPlanSummary.ownerCount} accountable owners across ${project.businessDomain}.',
  ];
}

List<String> _actionLines(ProjectDecisionActionPlanSummary actionPlanSummary) {
  if (actionPlanSummary.ownerActions.isEmpty) {
    return const [
      'Keep the current decision cadence and close completed proof.',
    ];
  }

  return [
    for (final action in actionPlanSummary.ownerActions.take(3))
      '${action.owner}: ${action.nextStepLabel}',
  ];
}

List<String> _evidenceLines(
  ProjectDecisionRegisterSummary registerSummary,
  ProjectDecisionGovernanceSummary governanceSummary,
) {
  final evidence = <String>['Route proof: ${governanceSummary.decisionRoute}'];

  for (final record in registerSummary.records) {
    final evidenceLabel = record.evidenceLabel.trim();
    if (evidenceLabel.isEmpty || evidence.contains(evidenceLabel)) continue;
    evidence.add(evidenceLabel);
    if (evidence.length == 4) break;
  }

  return evidence;
}

String _briefText({
  required String title,
  required ProjectDecisionBriefPackSignal signal,
  required String routeLabel,
  required String primaryDecisionLabel,
  required String ownerFocusLabel,
  required List<String> highlights,
  required List<String> actions,
  required List<String> evidence,
}) {
  return [
    title,
    'Status: ${signal.label}',
    'Route: $routeLabel',
    'Primary decision: $primaryDecisionLabel',
    'Owner focus: $ownerFocusLabel',
    '',
    'Highlights:',
    for (final line in highlights) '- $line',
    '',
    'Actions:',
    for (final line in actions) '- $line',
    '',
    'Evidence:',
    for (final line in evidence) '- $line',
  ].join('\n');
}

extension ProjectDecisionBriefPackSignalPresentation
    on ProjectDecisionBriefPackSignal {
  /// User-facing label for a project decision brief pack signal.
  String get label {
    switch (this) {
      case ProjectDecisionBriefPackSignal.recovery:
        return 'Recovery';
      case ProjectDecisionBriefPackSignal.attention:
        return 'Attention';
      case ProjectDecisionBriefPackSignal.aligned:
        return 'Aligned';
    }
  }

  /// Icon for a project decision brief pack signal.
  IconData get icon {
    switch (this) {
      case ProjectDecisionBriefPackSignal.recovery:
        return Icons.priority_high_rounded;
      case ProjectDecisionBriefPackSignal.attention:
        return Icons.assignment_outlined;
      case ProjectDecisionBriefPackSignal.aligned:
        return Icons.verified_outlined;
    }
  }

  /// Color for a project decision brief pack signal.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionBriefPackSignal.recovery:
        return colorScheme.error;
      case ProjectDecisionBriefPackSignal.attention:
        return Colors.orange.shade700;
      case ProjectDecisionBriefPackSignal.aligned:
        return Colors.green.shade700;
    }
  }
}
