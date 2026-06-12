import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_budget_pulse_service.dart';
import 'project_finance_control_service.dart';

/// Readiness level for a project expense intake route.
enum ProjectExpenseIntakeLevel { ready, setupNeeded, approvalRequired }

/// Type of project expense route supported by the intake foundation.
enum ProjectExpenseIntakeKind {
  pettyCash,
  reimbursement,
  vendorCommitment,
  budgetException,
}

/// One project expense route such as petty cash, reimbursement, or vendors.
class ProjectExpenseIntakeRoute {
  const ProjectExpenseIntakeRoute({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.evidenceLabel,
    required this.approvalLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectExpenseIntakeKind kind;
  final ProjectExpenseIntakeLevel level;
  final IconData icon;
  final String evidenceLabel;
  final String approvalLabel;

  bool get isReady => level == ProjectExpenseIntakeLevel.ready;
  bool get needsApproval => level == ProjectExpenseIntakeLevel.approvalRequired;
}

/// Expense intake snapshot for project finance and petty-cash workflows.
class ProjectExpenseIntakeSummary {
  const ProjectExpenseIntakeSummary({
    required this.projectId,
    required this.projectName,
    required this.financeSummary,
    required this.routes,
  });

  final String projectId;
  final String projectName;
  final ProjectFinanceControlSummary financeSummary;
  final List<ProjectExpenseIntakeRoute> routes;

  int get routeCount => routes.length;
  int get readyCount => routes.where((route) => route.isReady).length;
  int get setupNeededCount =>
      routes
          .where(
            (route) => route.level == ProjectExpenseIntakeLevel.setupNeeded,
          )
          .length;
  int get approvalRequiredCount =>
      routes.where((route) => route.needsApproval).length;

  ProjectExpenseIntakeLevel get level {
    if (approvalRequiredCount > 0) {
      return ProjectExpenseIntakeLevel.approvalRequired;
    }
    if (setupNeededCount > 0) return ProjectExpenseIntakeLevel.setupNeeded;
    return ProjectExpenseIntakeLevel.ready;
  }

  String get title {
    switch (level) {
      case ProjectExpenseIntakeLevel.ready:
        return 'Expense intake ready';
      case ProjectExpenseIntakeLevel.setupNeeded:
        return 'Expense intake setup needed';
      case ProjectExpenseIntakeLevel.approvalRequired:
        return 'Expense approvals required';
    }
  }

  String get detail {
    return '$readyCount of $routeCount routes ready - ${financeSummary.configuredControlCount}/${financeSummary.expectedControlCount} finance controls configured.';
  }
}

/// Builds route readiness for petty cash, reimbursements, vendors, and exceptions.
ProjectExpenseIntakeSummary buildProjectExpenseIntakeSummary(
  ProjectPortfolioItem project,
) {
  final financeSummary = buildProjectFinanceControlSummary(project);
  final roles =
      financeSummary.attributes.map((attribute) => attribute.role).toSet();
  final hasProjectFloat = roles.contains(
    ProjectFinanceControlRole.projectFloat,
  );
  final hasExpenseOwner = roles.contains(
    ProjectFinanceControlRole.expenseOwner,
  );
  final hasApprovalPolicy = roles.contains(
    ProjectFinanceControlRole.approvalPolicy,
  );
  final hasProcurement = roles.contains(ProjectFinanceControlRole.procurement);
  final isBudgetPressured =
      financeSummary.budgetOverview.state == ProjectBudgetPulseState.critical ||
      financeSummary.budgetOverview.state == ProjectBudgetPulseState.pressure;

  final routes = [
    _pettyCashRoute(
      project: project,
      financeSummary: financeSummary,
      hasProjectFloat: hasProjectFloat,
      hasExpenseOwner: hasExpenseOwner,
      hasApprovalPolicy: hasApprovalPolicy,
      isBudgetPressured: isBudgetPressured,
    ),
    _reimbursementRoute(
      project: project,
      financeSummary: financeSummary,
      hasExpenseOwner: hasExpenseOwner,
      hasApprovalPolicy: hasApprovalPolicy,
      isBudgetPressured: isBudgetPressured,
    ),
    _vendorCommitmentRoute(
      project: project,
      financeSummary: financeSummary,
      hasExpenseOwner: hasExpenseOwner,
      hasApprovalPolicy: hasApprovalPolicy,
      hasProcurement: hasProcurement,
      isBudgetPressured: isBudgetPressured,
    ),
    if (isBudgetPressured)
      _budgetExceptionRoute(project: project, financeSummary: financeSummary),
  ]..sort(_compareRoutes);

  return ProjectExpenseIntakeSummary(
    projectId: project.id,
    projectName: project.name,
    financeSummary: financeSummary,
    routes: List.unmodifiable(routes),
  );
}

extension ProjectExpenseIntakeLevelPresentation on ProjectExpenseIntakeLevel {
  /// User-facing label for an expense intake level.
  String get label {
    switch (this) {
      case ProjectExpenseIntakeLevel.ready:
        return 'Ready';
      case ProjectExpenseIntakeLevel.setupNeeded:
        return 'Setup';
      case ProjectExpenseIntakeLevel.approvalRequired:
        return 'Approval';
    }
  }

  /// Icon for an expense intake level.
  IconData get icon {
    switch (this) {
      case ProjectExpenseIntakeLevel.ready:
        return Icons.verified_outlined;
      case ProjectExpenseIntakeLevel.setupNeeded:
        return Icons.tune_outlined;
      case ProjectExpenseIntakeLevel.approvalRequired:
        return Icons.approval_outlined;
    }
  }

  /// Color for an expense intake level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectExpenseIntakeLevel.ready:
        return Colors.green.shade700;
      case ProjectExpenseIntakeLevel.setupNeeded:
        return Colors.orange.shade700;
      case ProjectExpenseIntakeLevel.approvalRequired:
        return colorScheme.error;
    }
  }
}

extension ProjectExpenseIntakeKindPresentation on ProjectExpenseIntakeKind {
  /// User-facing label for an expense intake route kind.
  String get label {
    switch (this) {
      case ProjectExpenseIntakeKind.pettyCash:
        return 'Petty Cash';
      case ProjectExpenseIntakeKind.reimbursement:
        return 'Reimbursement';
      case ProjectExpenseIntakeKind.vendorCommitment:
        return 'Vendor Spend';
      case ProjectExpenseIntakeKind.budgetException:
        return 'Budget Exception';
    }
  }
}

ProjectExpenseIntakeRoute _pettyCashRoute({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary financeSummary,
  required bool hasProjectFloat,
  required bool hasExpenseOwner,
  required bool hasApprovalPolicy,
  required bool isBudgetPressured,
}) {
  final profile = financeSummary.profile;
  final level = _routeLevel(
    hasRequiredControls:
        hasProjectFloat && hasExpenseOwner && hasApprovalPolicy,
    isBudgetPressured: isBudgetPressured,
  );

  return ProjectExpenseIntakeRoute(
    id: '${project.id}-petty-cash',
    title:
        hasProjectFloat
            ? '${profile.floatLabel} request'
            : 'Configure ${profile.floatLabel.toLowerCase()}',
    detail:
        hasProjectFloat
            ? 'Capture field spend with custodian, purpose, receipt, and reconciliation date.'
            : 'Define limit, custodian, and reconciliation cadence before petty-cash requests open.',
    kind: ProjectExpenseIntakeKind.pettyCash,
    level: level,
    icon: Icons.payments_outlined,
    evidenceLabel: 'Receipt, purpose, custodian, reconciliation date',
    approvalLabel: profile.approvalLabel,
  );
}

ProjectExpenseIntakeRoute _reimbursementRoute({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary financeSummary,
  required bool hasExpenseOwner,
  required bool hasApprovalPolicy,
  required bool isBudgetPressured,
}) {
  final profile = financeSummary.profile;
  final level = _routeLevel(
    hasRequiredControls: hasExpenseOwner && hasApprovalPolicy,
    isBudgetPressured: isBudgetPressured,
  );

  return ProjectExpenseIntakeRoute(
    id: '${project.id}-reimbursement',
    title:
        hasExpenseOwner
            ? 'Reimbursement claim'
            : 'Assign ${profile.expenseOwnerLabel.toLowerCase()}',
    detail:
        hasExpenseOwner
            ? 'Route staff claims through the accountable finance owner with proof and category.'
            : 'Name the owner who validates staff claims, exceptions, and payout timing.',
    kind: ProjectExpenseIntakeKind.reimbursement,
    level: level,
    icon: Icons.receipt_long_outlined,
    evidenceLabel: 'Receipt, claimant, category, payment method',
    approvalLabel: profile.approvalLabel,
  );
}

ProjectExpenseIntakeRoute _vendorCommitmentRoute({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary financeSummary,
  required bool hasExpenseOwner,
  required bool hasApprovalPolicy,
  required bool hasProcurement,
  required bool isBudgetPressured,
}) {
  final profile = financeSummary.profile;
  final level = _routeLevel(
    hasRequiredControls: hasExpenseOwner && hasApprovalPolicy,
    isBudgetPressured: isBudgetPressured,
  );

  return ProjectExpenseIntakeRoute(
    id: '${project.id}-vendor-commitment',
    title: hasProcurement ? 'Vendor commitment' : 'Prepare vendor spend route',
    detail:
        hasProcurement
            ? 'Use procurement context to capture vendor, purchase reason, and delivery proof.'
            : 'Add procurement or vendor context when this project needs purchase orders or supplier spend.',
    kind: ProjectExpenseIntakeKind.vendorCommitment,
    level: level,
    icon: Icons.inventory_2_outlined,
    evidenceLabel: 'Vendor, quotation, purchase reason, delivery proof',
    approvalLabel: profile.approvalLabel,
  );
}

ProjectExpenseIntakeRoute _budgetExceptionRoute({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary financeSummary,
}) {
  final isCritical =
      financeSummary.budgetOverview.state == ProjectBudgetPulseState.critical;

  return ProjectExpenseIntakeRoute(
    id: '${project.id}-budget-exception',
    title:
        isCritical
            ? 'Submit budget recovery exception'
            : 'Prepare spend exception',
    detail:
        '${financeSummary.budgetOverview.detail} Capture scope tradeoff, funding source, and sponsor decision.',
    kind: ProjectExpenseIntakeKind.budgetException,
    level: ProjectExpenseIntakeLevel.approvalRequired,
    icon: Icons.account_balance_wallet_outlined,
    evidenceLabel: 'Variance reason, tradeoff, funding source, sponsor note',
    approvalLabel: financeSummary.profile.approvalLabel,
  );
}

ProjectExpenseIntakeLevel _routeLevel({
  required bool hasRequiredControls,
  required bool isBudgetPressured,
}) {
  if (!hasRequiredControls) return ProjectExpenseIntakeLevel.setupNeeded;
  if (isBudgetPressured) return ProjectExpenseIntakeLevel.approvalRequired;
  return ProjectExpenseIntakeLevel.ready;
}

int _compareRoutes(
  ProjectExpenseIntakeRoute left,
  ProjectExpenseIntakeRoute right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return _kindRank(left.kind).compareTo(_kindRank(right.kind));
}

int _levelRank(ProjectExpenseIntakeLevel level) {
  switch (level) {
    case ProjectExpenseIntakeLevel.approvalRequired:
      return 0;
    case ProjectExpenseIntakeLevel.setupNeeded:
      return 1;
    case ProjectExpenseIntakeLevel.ready:
      return 2;
  }
}

int _kindRank(ProjectExpenseIntakeKind kind) {
  switch (kind) {
    case ProjectExpenseIntakeKind.budgetException:
      return 0;
    case ProjectExpenseIntakeKind.pettyCash:
      return 1;
    case ProjectExpenseIntakeKind.reimbursement:
      return 2;
    case ProjectExpenseIntakeKind.vendorCommitment:
      return 3;
  }
}
