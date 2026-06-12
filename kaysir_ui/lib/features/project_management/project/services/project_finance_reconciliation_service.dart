import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_cash_flow_forecast_service.dart';
import 'project_expense_intake_service.dart';
import 'project_spend_authority_service.dart';

/// Reconciliation readiness level for project finance evidence.
enum ProjectFinanceReconciliationLevel { clean, needsEvidence, blocked }

/// Type of finance reconciliation evidence tracked for a project.
enum ProjectFinanceReconciliationKind {
  pettyCash,
  reimbursement,
  vendorProof,
  budgetException,
  reserve,
  closeout,
}

/// One reconciliation item for receipts, approvals, proof, or closeout.
class ProjectFinanceReconciliationItem {
  const ProjectFinanceReconciliationItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.evidenceLabel,
    required this.ownerLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectFinanceReconciliationKind kind;
  final ProjectFinanceReconciliationLevel level;
  final IconData icon;
  final String evidenceLabel;
  final String ownerLabel;

  bool get isClean => level == ProjectFinanceReconciliationLevel.clean;
  bool get needsAction => level != ProjectFinanceReconciliationLevel.clean;
}

/// Project finance reconciliation summary for detail and closeout workflows.
class ProjectFinanceReconciliationSummary {
  const ProjectFinanceReconciliationSummary({
    required this.projectId,
    required this.projectName,
    required this.expenseIntake,
    required this.spendAuthority,
    required this.cashFlowForecast,
    required this.items,
  });

  final String projectId;
  final String projectName;
  final ProjectExpenseIntakeSummary expenseIntake;
  final ProjectSpendAuthoritySummary spendAuthority;
  final ProjectCashFlowForecastSummary cashFlowForecast;
  final List<ProjectFinanceReconciliationItem> items;

  int get itemCount => items.length;
  int get cleanCount => items.where((item) => item.isClean).length;
  int get actionCount => items.where((item) => item.needsAction).length;
  int get blockedCount =>
      items
          .where(
            (item) => item.level == ProjectFinanceReconciliationLevel.blocked,
          )
          .length;

  ProjectFinanceReconciliationItem get primaryItem {
    final sorted = [...items]..sort(_compareItems);
    return sorted.first;
  }

  ProjectFinanceReconciliationLevel get level {
    if (blockedCount > 0) return ProjectFinanceReconciliationLevel.blocked;
    if (actionCount > 0) {
      return ProjectFinanceReconciliationLevel.needsEvidence;
    }
    return ProjectFinanceReconciliationLevel.clean;
  }

  String get title {
    switch (level) {
      case ProjectFinanceReconciliationLevel.clean:
        return 'Finance reconciliation clean';
      case ProjectFinanceReconciliationLevel.needsEvidence:
        return 'Finance evidence needed';
      case ProjectFinanceReconciliationLevel.blocked:
        return 'Finance reconciliation blocked';
    }
  }

  String get detail {
    return '$cleanCount of $itemCount items clean - ${cashFlowForecast.remainingBudgetPercent}% budget runway remains - next action: ${primaryItem.title}.';
  }
}

/// Builds receipt, approval, vendor proof, reserve, and closeout readiness.
ProjectFinanceReconciliationSummary buildProjectFinanceReconciliationSummary(
  ProjectPortfolioItem project, {
  ProjectExpenseIntakeSummary? expenseIntake,
  ProjectSpendAuthoritySummary? spendAuthority,
  ProjectCashFlowForecastSummary? cashFlowForecast,
  DateTime? today,
}) {
  final intake = expenseIntake ?? buildProjectExpenseIntakeSummary(project);
  final authority =
      spendAuthority ??
      buildProjectSpendAuthoritySummary(project, expenseIntake: intake);
  final forecast =
      cashFlowForecast ??
      buildProjectCashFlowForecastSummary(
        project,
        spendAuthority: authority,
        today: today,
      );
  final baseItems = [
    _pettyCashItem(project: project, intake: intake, authority: authority),
    _reimbursementItem(project: project, intake: intake, authority: authority),
    _vendorProofItem(project: project, intake: intake, authority: authority),
    if (_hasBudgetException(intake, authority) ||
        forecast.level == ProjectCashFlowForecastLevel.constrained)
      _budgetExceptionItem(
        project: project,
        authority: authority,
        forecast: forecast,
      ),
    _reserveItem(project: project, forecast: forecast),
  ]..sort(_compareItems);

  final items = [
    ...baseItems,
    _closeoutItem(project: project, baseItems: baseItems),
  ]..sort(_compareItems);

  return ProjectFinanceReconciliationSummary(
    projectId: project.id,
    projectName: project.name,
    expenseIntake: intake,
    spendAuthority: authority,
    cashFlowForecast: forecast,
    items: List.unmodifiable(items),
  );
}

extension ProjectFinanceReconciliationLevelPresentation
    on ProjectFinanceReconciliationLevel {
  /// User-facing label for a finance reconciliation level.
  String get label {
    switch (this) {
      case ProjectFinanceReconciliationLevel.clean:
        return 'Clean';
      case ProjectFinanceReconciliationLevel.needsEvidence:
        return 'Evidence';
      case ProjectFinanceReconciliationLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a finance reconciliation level.
  IconData get icon {
    switch (this) {
      case ProjectFinanceReconciliationLevel.clean:
        return Icons.verified_outlined;
      case ProjectFinanceReconciliationLevel.needsEvidence:
        return Icons.fact_check_outlined;
      case ProjectFinanceReconciliationLevel.blocked:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a finance reconciliation level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceReconciliationLevel.clean:
        return Colors.green.shade700;
      case ProjectFinanceReconciliationLevel.needsEvidence:
        return Colors.orange.shade700;
      case ProjectFinanceReconciliationLevel.blocked:
        return colorScheme.error;
    }
  }
}

extension ProjectFinanceReconciliationKindPresentation
    on ProjectFinanceReconciliationKind {
  /// User-facing label for a finance reconciliation evidence kind.
  String get label {
    switch (this) {
      case ProjectFinanceReconciliationKind.pettyCash:
        return 'Petty Cash';
      case ProjectFinanceReconciliationKind.reimbursement:
        return 'Reimbursement';
      case ProjectFinanceReconciliationKind.vendorProof:
        return 'Vendor Proof';
      case ProjectFinanceReconciliationKind.budgetException:
        return 'Budget Exception';
      case ProjectFinanceReconciliationKind.reserve:
        return 'Reserve';
      case ProjectFinanceReconciliationKind.closeout:
        return 'Closeout';
    }
  }
}

ProjectFinanceReconciliationItem _pettyCashItem({
  required ProjectPortfolioItem project,
  required ProjectExpenseIntakeSummary intake,
  required ProjectSpendAuthoritySummary authority,
}) {
  final route = _routeFor(intake, ProjectExpenseIntakeKind.pettyCash);
  final rule = _ruleFor(authority, ProjectSpendAuthorityBand.pettyCash);
  final level = _itemLevel(route?.level, rule?.level);

  return ProjectFinanceReconciliationItem(
    id: '${project.id}-reconcile-petty-cash',
    title:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Petty cash receipts ready'
            : 'Reconcile petty cash evidence',
    detail:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Project float can close through receipts, custodian confirmation, and reconciliation date.'
            : 'Petty cash needs receipts, custodian ownership, approval trail, and reconciliation cadence before closeout.',
    kind: ProjectFinanceReconciliationKind.pettyCash,
    level: level,
    icon: Icons.payments_outlined,
    evidenceLabel: route?.evidenceLabel ?? 'Receipt and custodian record',
    ownerLabel: rule?.approverLabel ?? 'Expense owner',
  );
}

ProjectFinanceReconciliationItem _reimbursementItem({
  required ProjectPortfolioItem project,
  required ProjectExpenseIntakeSummary intake,
  required ProjectSpendAuthoritySummary authority,
}) {
  final route = _routeFor(intake, ProjectExpenseIntakeKind.reimbursement);
  final rule = _ruleFor(authority, ProjectSpendAuthorityBand.reimbursement);
  final level = _itemLevel(route?.level, rule?.level);

  return ProjectFinanceReconciliationItem(
    id: '${project.id}-reconcile-reimbursement',
    title:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Claims evidence ready'
            : 'Complete reimbursement proof',
    detail:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Reimbursement claims can close with claimant, receipt, category, and payment method proof.'
            : 'Claims need owner review, receipt proof, category, and approval threshold before payout is clean.',
    kind: ProjectFinanceReconciliationKind.reimbursement,
    level: level,
    icon: Icons.receipt_long_outlined,
    evidenceLabel: route?.evidenceLabel ?? 'Receipt and claimant proof',
    ownerLabel: rule?.approverLabel ?? 'Expense owner',
  );
}

ProjectFinanceReconciliationItem _vendorProofItem({
  required ProjectPortfolioItem project,
  required ProjectExpenseIntakeSummary intake,
  required ProjectSpendAuthoritySummary authority,
}) {
  final route = _routeFor(intake, ProjectExpenseIntakeKind.vendorCommitment);
  final rule = _ruleFor(authority, ProjectSpendAuthorityBand.vendorCommitment);
  final level = _itemLevel(route?.level, rule?.level);

  return ProjectFinanceReconciliationItem(
    id: '${project.id}-reconcile-vendor',
    title:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Vendor proof ready'
            : 'Validate vendor delivery proof',
    detail:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Vendor spend can close with quotation, purchase reason, and delivery proof.'
            : 'Vendor commitments need procurement route, quotation, delivery evidence, and authority trail.',
    kind: ProjectFinanceReconciliationKind.vendorProof,
    level: level,
    icon: Icons.inventory_2_outlined,
    evidenceLabel: route?.evidenceLabel ?? 'Vendor proof and delivery evidence',
    ownerLabel: rule?.approverLabel ?? 'Procurement route',
  );
}

ProjectFinanceReconciliationItem _budgetExceptionItem({
  required ProjectPortfolioItem project,
  required ProjectSpendAuthoritySummary authority,
  required ProjectCashFlowForecastSummary forecast,
}) {
  final rule = _ruleFor(authority, ProjectSpendAuthorityBand.budgetException);
  final level =
      forecast.level == ProjectCashFlowForecastLevel.constrained
          ? ProjectFinanceReconciliationLevel.blocked
          : ProjectFinanceReconciliationLevel.needsEvidence;

  return ProjectFinanceReconciliationItem(
    id: '${project.id}-reconcile-budget-exception',
    title: 'Reconcile budget exception',
    detail:
        '${forecast.projectedAtCompletionPercent}% projected at completion needs variance reason, sponsor decision, funding source, and tradeoff evidence.',
    kind: ProjectFinanceReconciliationKind.budgetException,
    level: level,
    icon: Icons.account_balance_wallet_outlined,
    evidenceLabel: rule?.evidenceLabel ?? 'Variance and sponsor decision',
    ownerLabel: rule?.approverLabel ?? 'Sponsor',
  );
}

ProjectFinanceReconciliationItem _reserveItem({
  required ProjectPortfolioItem project,
  required ProjectCashFlowForecastSummary forecast,
}) {
  final reserveWindow = _reserveWindow(forecast);
  final level = _forecastLevel(reserveWindow.level);

  return ProjectFinanceReconciliationItem(
    id: '${project.id}-reconcile-reserve',
    title:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Reserve runway clean'
            : 'Review reserve guardrail',
    detail:
        '${reserveWindow.releaseSharePercent}% reserve window remains tied to ${reserveWindow.gateLabel.toLowerCase()} funding guardrails.',
    kind: ProjectFinanceReconciliationKind.reserve,
    level: level,
    icon: Icons.savings_outlined,
    evidenceLabel: 'Reserve reason, release gate, sponsor note',
    ownerLabel: 'Finance owner',
  );
}

ProjectFinanceReconciliationItem _closeoutItem({
  required ProjectPortfolioItem project,
  required List<ProjectFinanceReconciliationItem> baseItems,
}) {
  final blocked = baseItems.any(
    (item) => item.level == ProjectFinanceReconciliationLevel.blocked,
  );
  final needsEvidence = baseItems.any((item) => item.needsAction);
  final level =
      blocked
          ? ProjectFinanceReconciliationLevel.blocked
          : needsEvidence
          ? ProjectFinanceReconciliationLevel.needsEvidence
          : ProjectFinanceReconciliationLevel.clean;

  return ProjectFinanceReconciliationItem(
    id: '${project.id}-reconcile-closeout',
    title:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Finance closeout package ready'
            : 'Prepare finance closeout package',
    detail:
        level == ProjectFinanceReconciliationLevel.clean
            ? 'Receipts, claims, vendor proof, reserve, and approvals are ready for finance closeout.'
            : 'Resolve open evidence, approvals, and variance notes before closing the project finance package.',
    kind: ProjectFinanceReconciliationKind.closeout,
    level: level,
    icon: Icons.inventory_2_outlined,
    evidenceLabel: 'Receipts, approvals, variance, reserve, vendor proof',
    ownerLabel: project.owner,
  );
}

ProjectExpenseIntakeRoute? _routeFor(
  ProjectExpenseIntakeSummary summary,
  ProjectExpenseIntakeKind kind,
) {
  for (final route in summary.routes) {
    if (route.kind == kind) return route;
  }
  return null;
}

ProjectSpendAuthorityRule? _ruleFor(
  ProjectSpendAuthoritySummary summary,
  ProjectSpendAuthorityBand band,
) {
  for (final rule in summary.rules) {
    if (rule.band == band) return rule;
  }
  return null;
}

ProjectCashFlowWindow _reserveWindow(ProjectCashFlowForecastSummary forecast) {
  for (final window in forecast.windows) {
    if (window.kind == ProjectCashFlowWindowKind.reserve) return window;
  }
  return forecast.windows.last;
}

ProjectFinanceReconciliationLevel _itemLevel(
  ProjectExpenseIntakeLevel? routeLevel,
  ProjectSpendAuthorityLevel? authorityLevel,
) {
  if (routeLevel == ProjectExpenseIntakeLevel.approvalRequired ||
      authorityLevel == ProjectSpendAuthorityLevel.escalation) {
    return ProjectFinanceReconciliationLevel.blocked;
  }
  if (routeLevel == ProjectExpenseIntakeLevel.setupNeeded ||
      authorityLevel == ProjectSpendAuthorityLevel.guarded ||
      routeLevel == null ||
      authorityLevel == null) {
    return ProjectFinanceReconciliationLevel.needsEvidence;
  }
  return ProjectFinanceReconciliationLevel.clean;
}

ProjectFinanceReconciliationLevel _forecastLevel(
  ProjectCashFlowForecastLevel level,
) {
  switch (level) {
    case ProjectCashFlowForecastLevel.healthy:
      return ProjectFinanceReconciliationLevel.clean;
    case ProjectCashFlowForecastLevel.watch:
      return ProjectFinanceReconciliationLevel.needsEvidence;
    case ProjectCashFlowForecastLevel.constrained:
      return ProjectFinanceReconciliationLevel.blocked;
  }
}

bool _hasBudgetException(
  ProjectExpenseIntakeSummary intake,
  ProjectSpendAuthoritySummary authority,
) {
  final hasRoute = intake.routes.any(
    (route) => route.kind == ProjectExpenseIntakeKind.budgetException,
  );
  final hasRule = authority.rules.any(
    (rule) => rule.band == ProjectSpendAuthorityBand.budgetException,
  );
  return hasRoute || hasRule;
}

int _compareItems(
  ProjectFinanceReconciliationItem left,
  ProjectFinanceReconciliationItem right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return _kindRank(left.kind).compareTo(_kindRank(right.kind));
}

int _levelRank(ProjectFinanceReconciliationLevel level) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.blocked:
      return 0;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return 1;
    case ProjectFinanceReconciliationLevel.clean:
      return 2;
  }
}

int _kindRank(ProjectFinanceReconciliationKind kind) {
  switch (kind) {
    case ProjectFinanceReconciliationKind.budgetException:
      return 0;
    case ProjectFinanceReconciliationKind.pettyCash:
      return 1;
    case ProjectFinanceReconciliationKind.reimbursement:
      return 2;
    case ProjectFinanceReconciliationKind.vendorProof:
      return 3;
    case ProjectFinanceReconciliationKind.reserve:
      return 4;
    case ProjectFinanceReconciliationKind.closeout:
      return 5;
  }
}
