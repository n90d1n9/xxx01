import 'package:flutter/material.dart';

import 'project_cash_flow_forecast_service.dart';
import 'project_finance_action_queue_service.dart';
import 'project_finance_closeout_service.dart';
import 'project_finance_ledger_records_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_scenario_service.dart';
import 'project_finance_workspace_service.dart';

/// Finance handoff readiness level for client, audit, or operator packages.
enum ProjectFinanceHandoffPackLevel { ready, review, blocked }

/// Finance handoff package section used to organize closeout evidence.
enum ProjectFinanceHandoffPackSectionKind {
  executiveSummary,
  ledgerBundle,
  approvalTrail,
  reconciliationEvidence,
  closeoutChecklist,
  cashFlowRunway,
}

/// One section inside a project finance handoff package.
class ProjectFinanceHandoffPackSection {
  const ProjectFinanceHandoffPackSection({
    required this.kind,
    required this.title,
    required this.detail,
    required this.ownerLabel,
    required this.level,
    required this.icon,
  });

  final ProjectFinanceHandoffPackSectionKind kind;
  final String title;
  final String detail;
  final String ownerLabel;
  final ProjectFinanceHandoffPackLevel level;
  final IconData icon;

  bool get isReady => level == ProjectFinanceHandoffPackLevel.ready;
  bool get isBlocked => level == ProjectFinanceHandoffPackLevel.blocked;
  bool get needsReview => level != ProjectFinanceHandoffPackLevel.ready;
}

/// Generated finance handoff package for a selected project workspace.
class ProjectFinanceHandoffPackSummary {
  const ProjectFinanceHandoffPackSummary({
    required this.projectId,
    required this.projectName,
    required this.packageId,
    required this.recipients,
    required this.sections,
    required this.briefText,
  });

  final String projectId;
  final String projectName;
  final String packageId;
  final List<String> recipients;
  final List<ProjectFinanceHandoffPackSection> sections;
  final String briefText;

  int get sectionCount => sections.length;
  int get readyCount => sections.where((section) => section.isReady).length;
  int get reviewCount =>
      sections
          .where(
            (section) => section.level == ProjectFinanceHandoffPackLevel.review,
          )
          .length;
  int get blockedCount => sections.where((section) => section.isBlocked).length;

  ProjectFinanceHandoffPackLevel get level {
    return _levelForSections(sections);
  }

  ProjectFinanceHandoffPackSection? get primarySection {
    return _primarySectionFor(sections);
  }

  String get title {
    switch (level) {
      case ProjectFinanceHandoffPackLevel.ready:
        return 'Finance handoff pack ready';
      case ProjectFinanceHandoffPackLevel.review:
        return 'Finance handoff pack needs review';
      case ProjectFinanceHandoffPackLevel.blocked:
        return 'Finance handoff pack blocked';
    }
  }

  String get detail {
    final primary = primarySection;
    if (primary == null) return 'No finance handoff sections are configured.';
    return '$readyCount of $sectionCount sections ready - next: ${primary.title}.';
  }
}

/// Builds an audit-ready finance handoff package from workspace finance signals.
ProjectFinanceHandoffPackSummary buildProjectFinanceHandoffPackSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final closeout = buildProjectFinanceCloseoutSummary(summary);
  final actionQueue = buildProjectFinanceActionQueue(summary.financeLedger);
  final recordsView = buildProjectFinanceLedgerRecordsView(
    summary.financeLedger,
  );
  final scenario = buildProjectFinanceScenarioSummary(summary);
  final recipients = _recipientsFor(summary);
  final sections = [
    _executiveSummarySection(summary, scenario),
    _ledgerBundleSection(recordsView),
    _approvalTrailSection(actionQueue),
    _reconciliationEvidenceSection(summary.financeReconciliation),
    _closeoutChecklistSection(closeout),
    _cashFlowRunwaySection(summary),
  ]..sort(_compareSections);
  final packageId = '${summary.project.id}-finance-handoff';
  final packageRecipients = List<String>.unmodifiable(recipients);
  final packageSections = List<ProjectFinanceHandoffPackSection>.unmodifiable(
    sections,
  );

  return ProjectFinanceHandoffPackSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    packageId: packageId,
    recipients: packageRecipients,
    sections: packageSections,
    briefText: _briefText(
      summary: summary,
      closeout: closeout,
      actionQueue: actionQueue,
      recordsView: recordsView,
      scenario: scenario,
      level: _levelForSections(packageSections),
      packageId: packageId,
      recipients: packageRecipients,
      primarySection: _primarySectionFor(packageSections),
    ),
  );
}

ProjectFinanceHandoffPackSection _executiveSummarySection(
  ProjectFinanceWorkspaceSummary summary,
  ProjectFinanceScenarioSummary scenario,
) {
  final recommended = scenario.recommendedOption;

  return ProjectFinanceHandoffPackSection(
    kind: ProjectFinanceHandoffPackSectionKind.executiveSummary,
    title: 'Executive finance summary',
    detail:
        '${recommended.title} projects ${recommended.projectedAtCompletionPercent}% at completion for ${summary.project.businessDomain}.',
    ownerLabel: summary.project.owner,
    level: _fromScenarioLevel(recommended.level),
    icon: Icons.summarize_outlined,
  );
}

ProjectFinanceHandoffPackSection _ledgerBundleSection(
  ProjectFinanceLedgerRecordsView recordsView,
) {
  final level =
      recordsView.blockedCount > 0
          ? ProjectFinanceHandoffPackLevel.blocked
          : recordsView.openCount > 0
          ? ProjectFinanceHandoffPackLevel.review
          : ProjectFinanceHandoffPackLevel.ready;

  return ProjectFinanceHandoffPackSection(
    kind: ProjectFinanceHandoffPackSectionKind.ledgerBundle,
    title: 'Ledger bundle',
    detail:
        '${recordsView.rowCount} records packaged with ${recordsView.openCount} open and ${recordsView.blockedCount} blocked.',
    ownerLabel: 'Finance owner',
    level: level,
    icon: Icons.receipt_long_outlined,
  );
}

ProjectFinanceHandoffPackSection _approvalTrailSection(
  ProjectFinanceActionQueue actionQueue,
) {
  final level =
      actionQueue.criticalCount > 0
          ? ProjectFinanceHandoffPackLevel.blocked
          : actionQueue.actionCount > 0
          ? ProjectFinanceHandoffPackLevel.review
          : ProjectFinanceHandoffPackLevel.ready;

  return ProjectFinanceHandoffPackSection(
    kind: ProjectFinanceHandoffPackSectionKind.approvalTrail,
    title: 'Approval trail',
    detail:
        '${actionQueue.actionCount} action links remain, including ${actionQueue.criticalCount} critical approvals or guardrails.',
    ownerLabel: 'Approver route',
    level: level,
    icon: Icons.verified_user_outlined,
  );
}

ProjectFinanceHandoffPackSection _reconciliationEvidenceSection(
  ProjectFinanceReconciliationSummary reconciliation,
) {
  return ProjectFinanceHandoffPackSection(
    kind: ProjectFinanceHandoffPackSectionKind.reconciliationEvidence,
    title: 'Reconciliation evidence',
    detail:
        '${reconciliation.cleanCount} of ${reconciliation.itemCount} evidence checks are clean for handoff.',
    ownerLabel: 'Evidence owners',
    level: _fromReconciliationLevel(reconciliation.level),
    icon: Icons.fact_check_outlined,
  );
}

ProjectFinanceHandoffPackSection _closeoutChecklistSection(
  ProjectFinanceCloseoutSummary closeout,
) {
  return ProjectFinanceHandoffPackSection(
    kind: ProjectFinanceHandoffPackSectionKind.closeoutChecklist,
    title: 'Closeout checklist',
    detail:
        '${closeout.readyCount} of ${closeout.checkCount} checks are ready before package sign-off.',
    ownerLabel: 'Closeout owner',
    level: _fromCloseoutLevel(closeout.level),
    icon: Icons.task_alt_outlined,
  );
}

ProjectFinanceHandoffPackSection _cashFlowRunwaySection(
  ProjectFinanceWorkspaceSummary summary,
) {
  final forecast = summary.cashFlowForecast;

  return ProjectFinanceHandoffPackSection(
    kind: ProjectFinanceHandoffPackSectionKind.cashFlowRunway,
    title: 'Cash-flow runway',
    detail:
        '${forecast.remainingBudgetPercent}% budget remains with completion projected at ${forecast.projectedAtCompletionPercent}%.',
    ownerLabel: 'Funding owner',
    level: _fromCashFlowLevel(forecast.level),
    icon: Icons.query_stats_outlined,
  );
}

String _briefText({
  required ProjectFinanceWorkspaceSummary summary,
  required ProjectFinanceCloseoutSummary closeout,
  required ProjectFinanceActionQueue actionQueue,
  required ProjectFinanceLedgerRecordsView recordsView,
  required ProjectFinanceScenarioSummary scenario,
  required ProjectFinanceHandoffPackLevel level,
  required String packageId,
  required List<String> recipients,
  required ProjectFinanceHandoffPackSection? primarySection,
}) {
  return [
    'Finance handoff pack - ${summary.project.name}',
    'Status: ${level.label}',
    'Recipients: ${recipients.join(', ')}',
    'Package: $packageId',
    'Domain: ${summary.project.businessDomain}',
    'Context: ${_customContextFor(summary)}',
    'Closeout: ${closeout.completionPercent}% ready (${closeout.readyCount}/${closeout.checkCount} checks)',
    'Scenario: ${scenario.recommendedOption.title} at ${scenario.recommendedOption.projectedAtCompletionPercent}% projected completion',
    'Ledger: ${recordsView.openCount} open, ${recordsView.blockedCount} blocked',
    'Actions: ${actionQueue.actionCount} total, ${actionQueue.criticalCount} critical',
    if (primarySection != null) 'Next section: ${primarySection.title}',
  ].join('\n');
}

List<String> _recipientsFor(ProjectFinanceWorkspaceSummary summary) {
  final seen = <String>{};
  final values = [
    summary.project.owner,
    summary.project.sponsor,
    summary.project.client,
  ];

  return [
    for (final value in values)
      if (value.trim().isNotEmpty && seen.add(value.trim())) value.trim(),
  ];
}

String _customContextFor(ProjectFinanceWorkspaceSummary summary) {
  final attributes = summary.project.pinnedCustomAttributes.take(3).toList();
  if (attributes.isEmpty) return 'No pinned custom attributes.';

  return attributes
      .map((attribute) => '${attribute.label}: ${attribute.displayValue}')
      .join('; ');
}

ProjectFinanceHandoffPackLevel _fromScenarioLevel(
  ProjectFinanceScenarioLevel level,
) {
  switch (level) {
    case ProjectFinanceScenarioLevel.healthy:
      return ProjectFinanceHandoffPackLevel.ready;
    case ProjectFinanceScenarioLevel.watch:
      return ProjectFinanceHandoffPackLevel.review;
    case ProjectFinanceScenarioLevel.constrained:
      return ProjectFinanceHandoffPackLevel.blocked;
  }
}

ProjectFinanceHandoffPackLevel _fromReconciliationLevel(
  ProjectFinanceReconciliationLevel level,
) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.clean:
      return ProjectFinanceHandoffPackLevel.ready;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return ProjectFinanceHandoffPackLevel.review;
    case ProjectFinanceReconciliationLevel.blocked:
      return ProjectFinanceHandoffPackLevel.blocked;
  }
}

ProjectFinanceHandoffPackLevel _fromCloseoutLevel(
  ProjectFinanceCloseoutLevel level,
) {
  switch (level) {
    case ProjectFinanceCloseoutLevel.ready:
      return ProjectFinanceHandoffPackLevel.ready;
    case ProjectFinanceCloseoutLevel.attention:
      return ProjectFinanceHandoffPackLevel.review;
    case ProjectFinanceCloseoutLevel.blocked:
      return ProjectFinanceHandoffPackLevel.blocked;
  }
}

ProjectFinanceHandoffPackLevel _fromCashFlowLevel(
  ProjectCashFlowForecastLevel level,
) {
  switch (level) {
    case ProjectCashFlowForecastLevel.healthy:
      return ProjectFinanceHandoffPackLevel.ready;
    case ProjectCashFlowForecastLevel.watch:
      return ProjectFinanceHandoffPackLevel.review;
    case ProjectCashFlowForecastLevel.constrained:
      return ProjectFinanceHandoffPackLevel.blocked;
  }
}

ProjectFinanceHandoffPackLevel _levelForSections(
  List<ProjectFinanceHandoffPackSection> sections,
) {
  if (sections.any((section) => section.isBlocked)) {
    return ProjectFinanceHandoffPackLevel.blocked;
  }
  if (sections.any((section) => section.needsReview)) {
    return ProjectFinanceHandoffPackLevel.review;
  }
  return ProjectFinanceHandoffPackLevel.ready;
}

ProjectFinanceHandoffPackSection? _primarySectionFor(
  List<ProjectFinanceHandoffPackSection> sections,
) {
  if (sections.isEmpty) return null;
  final sorted = [...sections]..sort(_compareSections);
  return sorted.first;
}

int _compareSections(
  ProjectFinanceHandoffPackSection left,
  ProjectFinanceHandoffPackSection right,
) {
  final levelComparison = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelComparison != 0) return levelComparison;
  return left.kind.index.compareTo(right.kind.index);
}

int _levelRank(ProjectFinanceHandoffPackLevel level) {
  switch (level) {
    case ProjectFinanceHandoffPackLevel.blocked:
      return 0;
    case ProjectFinanceHandoffPackLevel.review:
      return 1;
    case ProjectFinanceHandoffPackLevel.ready:
      return 2;
  }
}

extension ProjectFinanceHandoffPackLevelPresentation
    on ProjectFinanceHandoffPackLevel {
  /// User-facing label for a finance handoff package level.
  String get label {
    switch (this) {
      case ProjectFinanceHandoffPackLevel.ready:
        return 'Ready';
      case ProjectFinanceHandoffPackLevel.review:
        return 'Review';
      case ProjectFinanceHandoffPackLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a finance handoff package level.
  IconData get icon {
    switch (this) {
      case ProjectFinanceHandoffPackLevel.ready:
        return Icons.inventory_2_outlined;
      case ProjectFinanceHandoffPackLevel.review:
        return Icons.rate_review_outlined;
      case ProjectFinanceHandoffPackLevel.blocked:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a finance handoff package level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceHandoffPackLevel.ready:
        return Colors.green.shade700;
      case ProjectFinanceHandoffPackLevel.review:
        return Colors.orange.shade700;
      case ProjectFinanceHandoffPackLevel.blocked:
        return colorScheme.error;
    }
  }
}
