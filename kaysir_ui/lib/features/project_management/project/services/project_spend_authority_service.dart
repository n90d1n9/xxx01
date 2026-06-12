import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_budget_pulse_service.dart';
import 'project_expense_intake_service.dart';
import 'project_finance_control_service.dart';

/// Approval posture for one project spend authority band.
enum ProjectSpendAuthorityLevel { delegated, guarded, escalation }

/// Spend authority band used by petty cash, claims, vendors, and exceptions.
enum ProjectSpendAuthorityBand {
  pettyCash,
  reimbursement,
  vendorCommitment,
  budgetException,
}

/// One approval rule for a project spend authority band.
class ProjectSpendAuthorityRule {
  const ProjectSpendAuthorityRule({
    required this.id,
    required this.title,
    required this.detail,
    required this.band,
    required this.level,
    required this.icon,
    required this.thresholdLabel,
    required this.approverLabel,
    required this.evidenceLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectSpendAuthorityBand band;
  final ProjectSpendAuthorityLevel level;
  final IconData icon;
  final String thresholdLabel;
  final String approverLabel;
  final String evidenceLabel;

  bool get needsEscalation => level == ProjectSpendAuthorityLevel.escalation;
}

/// Spend authority matrix for project finance requests and approvals.
class ProjectSpendAuthoritySummary {
  const ProjectSpendAuthoritySummary({
    required this.projectId,
    required this.projectName,
    required this.financeSummary,
    required this.expenseIntake,
    required this.rules,
  });

  final String projectId;
  final String projectName;
  final ProjectFinanceControlSummary financeSummary;
  final ProjectExpenseIntakeSummary expenseIntake;
  final List<ProjectSpendAuthorityRule> rules;

  int get ruleCount => rules.length;
  int get delegatedCount =>
      rules
          .where((rule) => rule.level == ProjectSpendAuthorityLevel.delegated)
          .length;
  int get guardedCount =>
      rules
          .where((rule) => rule.level == ProjectSpendAuthorityLevel.guarded)
          .length;
  int get escalationCount => rules.where((rule) => rule.needsEscalation).length;

  ProjectSpendAuthorityLevel get level {
    if (escalationCount > 0) return ProjectSpendAuthorityLevel.escalation;
    if (guardedCount > 0) return ProjectSpendAuthorityLevel.guarded;
    return ProjectSpendAuthorityLevel.delegated;
  }

  String get title {
    switch (level) {
      case ProjectSpendAuthorityLevel.delegated:
        return 'Spend authority delegated';
      case ProjectSpendAuthorityLevel.guarded:
        return 'Spend authority needs setup';
      case ProjectSpendAuthorityLevel.escalation:
        return 'Spend escalation required';
    }
  }

  String get detail {
    return '$delegatedCount of $ruleCount bands delegated - ${expenseIntake.readyCount}/${expenseIntake.routeCount} intake routes ready.';
  }
}

/// Builds a reusable spend authority matrix from finance and intake signals.
ProjectSpendAuthoritySummary buildProjectSpendAuthoritySummary(
  ProjectPortfolioItem project, {
  ProjectExpenseIntakeSummary? expenseIntake,
}) {
  final intake = expenseIntake ?? buildProjectExpenseIntakeSummary(project);
  final finance = intake.financeSummary;
  final roles = finance.attributes.map((attribute) => attribute.role).toSet();
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
  final isCritical =
      finance.budgetOverview.state == ProjectBudgetPulseState.critical;
  final isBudgetPressured =
      isCritical ||
      finance.budgetOverview.state == ProjectBudgetPulseState.pressure;

  final rules = [
    _pettyCashRule(
      project: project,
      finance: finance,
      hasProjectFloat: hasProjectFloat,
      hasExpenseOwner: hasExpenseOwner,
      hasApprovalPolicy: hasApprovalPolicy,
      isCritical: isCritical,
    ),
    _reimbursementRule(
      project: project,
      finance: finance,
      hasExpenseOwner: hasExpenseOwner,
      hasApprovalPolicy: hasApprovalPolicy,
      isCritical: isCritical,
    ),
    _vendorCommitmentRule(
      project: project,
      finance: finance,
      hasExpenseOwner: hasExpenseOwner,
      hasApprovalPolicy: hasApprovalPolicy,
      hasProcurement: hasProcurement,
      isBudgetPressured: isBudgetPressured,
    ),
    if (isBudgetPressured)
      _budgetExceptionRule(project: project, finance: finance),
  ]..sort(_compareRules);

  return ProjectSpendAuthoritySummary(
    projectId: project.id,
    projectName: project.name,
    financeSummary: finance,
    expenseIntake: intake,
    rules: List.unmodifiable(rules),
  );
}

extension ProjectSpendAuthorityLevelPresentation on ProjectSpendAuthorityLevel {
  /// User-facing label for a spend authority level.
  String get label {
    switch (this) {
      case ProjectSpendAuthorityLevel.delegated:
        return 'Delegated';
      case ProjectSpendAuthorityLevel.guarded:
        return 'Guarded';
      case ProjectSpendAuthorityLevel.escalation:
        return 'Escalate';
    }
  }

  /// Icon for a spend authority level.
  IconData get icon {
    switch (this) {
      case ProjectSpendAuthorityLevel.delegated:
        return Icons.verified_user_outlined;
      case ProjectSpendAuthorityLevel.guarded:
        return Icons.admin_panel_settings_outlined;
      case ProjectSpendAuthorityLevel.escalation:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a spend authority level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectSpendAuthorityLevel.delegated:
        return Colors.green.shade700;
      case ProjectSpendAuthorityLevel.guarded:
        return Colors.orange.shade700;
      case ProjectSpendAuthorityLevel.escalation:
        return colorScheme.error;
    }
  }
}

extension ProjectSpendAuthorityBandPresentation on ProjectSpendAuthorityBand {
  /// User-facing label for a spend authority band.
  String get label {
    switch (this) {
      case ProjectSpendAuthorityBand.pettyCash:
        return 'Petty Cash';
      case ProjectSpendAuthorityBand.reimbursement:
        return 'Reimbursement';
      case ProjectSpendAuthorityBand.vendorCommitment:
        return 'Vendor Commitment';
      case ProjectSpendAuthorityBand.budgetException:
        return 'Budget Exception';
    }
  }
}

ProjectSpendAuthorityRule _pettyCashRule({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary finance,
  required bool hasProjectFloat,
  required bool hasExpenseOwner,
  required bool hasApprovalPolicy,
  required bool isCritical,
}) {
  final ready = hasProjectFloat && hasExpenseOwner && hasApprovalPolicy;
  final level =
      isCritical
          ? ProjectSpendAuthorityLevel.escalation
          : ready
          ? ProjectSpendAuthorityLevel.delegated
          : ProjectSpendAuthorityLevel.guarded;

  return ProjectSpendAuthorityRule(
    id: '${project.id}-authority-petty-cash',
    title: '${finance.profile.floatLabel} authority',
    detail:
        ready
            ? 'Field spend can move through delegated float controls with reconciliation.'
            : 'Define float, expense owner, and approval policy before delegated petty cash opens.',
    band: ProjectSpendAuthorityBand.pettyCash,
    level: level,
    icon: Icons.payments_outlined,
    thresholdLabel:
        hasProjectFloat ? 'Within configured float' : 'Float not configured',
    approverLabel:
        hasExpenseOwner ? finance.profile.expenseOwnerLabel : 'Owner needed',
    evidenceLabel: 'Receipt, purpose, custodian, reconciliation date',
  );
}

ProjectSpendAuthorityRule _reimbursementRule({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary finance,
  required bool hasExpenseOwner,
  required bool hasApprovalPolicy,
  required bool isCritical,
}) {
  final ready = hasExpenseOwner && hasApprovalPolicy;
  final level =
      isCritical
          ? ProjectSpendAuthorityLevel.escalation
          : ready
          ? ProjectSpendAuthorityLevel.delegated
          : ProjectSpendAuthorityLevel.guarded;

  return ProjectSpendAuthorityRule(
    id: '${project.id}-authority-reimbursement',
    title: 'Reimbursement authority',
    detail:
        ready
            ? 'Staff claims can route through the delegated expense owner with proof.'
            : 'Assign claim owner and approval threshold before reimbursements are delegated.',
    band: ProjectSpendAuthorityBand.reimbursement,
    level: level,
    icon: Icons.receipt_long_outlined,
    thresholdLabel:
        hasApprovalPolicy ? finance.profile.approvalLabel : 'Policy needed',
    approverLabel:
        hasExpenseOwner ? finance.profile.expenseOwnerLabel : 'Owner needed',
    evidenceLabel: 'Receipt, claimant, category, payment method',
  );
}

ProjectSpendAuthorityRule _vendorCommitmentRule({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary finance,
  required bool hasExpenseOwner,
  required bool hasApprovalPolicy,
  required bool hasProcurement,
  required bool isBudgetPressured,
}) {
  final ready = hasExpenseOwner && hasApprovalPolicy && hasProcurement;
  final level =
      isBudgetPressured
          ? ProjectSpendAuthorityLevel.escalation
          : ready
          ? ProjectSpendAuthorityLevel.delegated
          : ProjectSpendAuthorityLevel.guarded;

  return ProjectSpendAuthorityRule(
    id: '${project.id}-authority-vendor',
    title: 'Vendor commitment authority',
    detail:
        ready
            ? 'Vendor commitments can proceed through procurement and approval controls.'
            : 'Add procurement context, approval threshold, and accountable owner before vendor spend is delegated.',
    band: ProjectSpendAuthorityBand.vendorCommitment,
    level: level,
    icon: Icons.inventory_2_outlined,
    thresholdLabel:
        hasApprovalPolicy ? finance.profile.approvalLabel : 'Policy needed',
    approverLabel:
        hasProcurement ? 'Procurement route' : 'Procurement route needed',
    evidenceLabel: 'Vendor, quotation, purchase reason, delivery proof',
  );
}

ProjectSpendAuthorityRule _budgetExceptionRule({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlSummary finance,
}) {
  return ProjectSpendAuthorityRule(
    id: '${project.id}-authority-budget-exception',
    title: 'Budget exception authority',
    detail:
        '${finance.budgetOverview.detail} Sponsor sign-off is required before new spend is committed.',
    band: ProjectSpendAuthorityBand.budgetException,
    level: ProjectSpendAuthorityLevel.escalation,
    icon: Icons.account_balance_wallet_outlined,
    thresholdLabel: 'Above approved baseline',
    approverLabel: 'Sponsor and ${finance.profile.approvalLabel}',
    evidenceLabel: 'Variance reason, tradeoff, funding source, sponsor note',
  );
}

int _compareRules(
  ProjectSpendAuthorityRule left,
  ProjectSpendAuthorityRule right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return _bandRank(left.band).compareTo(_bandRank(right.band));
}

int _levelRank(ProjectSpendAuthorityLevel level) {
  switch (level) {
    case ProjectSpendAuthorityLevel.escalation:
      return 0;
    case ProjectSpendAuthorityLevel.guarded:
      return 1;
    case ProjectSpendAuthorityLevel.delegated:
      return 2;
  }
}

int _bandRank(ProjectSpendAuthorityBand band) {
  switch (band) {
    case ProjectSpendAuthorityBand.budgetException:
      return 0;
    case ProjectSpendAuthorityBand.pettyCash:
      return 1;
    case ProjectSpendAuthorityBand.reimbursement:
      return 2;
    case ProjectSpendAuthorityBand.vendorCommitment:
      return 3;
  }
}
