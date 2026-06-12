import 'package:flutter/material.dart';

import '../models/project_custom_attribute.dart';
import '../models/project_portfolio_item.dart';
import 'project_budget_overview_service.dart';
import 'project_budget_pulse_service.dart';

/// Severity level for project finance and petty-cash control readiness.
enum ProjectFinanceControlLevel { stable, watch, actionRequired }

/// Finance control role inferred from project custom attributes.
enum ProjectFinanceControlRole {
  projectFloat,
  expenseOwner,
  approvalPolicy,
  procurement,
  funding,
  other,
}

/// Domain-aware finance wording for different project operating models.
class ProjectFinanceControlProfile {
  const ProjectFinanceControlProfile({
    required this.floatLabel,
    required this.expenseOwnerLabel,
    required this.approvalLabel,
  });

  final String floatLabel;
  final String expenseOwnerLabel;
  final String approvalLabel;
}

/// Finance-related custom attribute normalized for control panels.
class ProjectFinanceControlAttribute {
  const ProjectFinanceControlAttribute({
    required this.label,
    required this.value,
    required this.role,
  });

  final String label;
  final String value;
  final ProjectFinanceControlRole role;
}

/// Actionable finance signal produced from budget, risk, and extension data.
class ProjectFinanceControlSignal {
  const ProjectFinanceControlSignal({
    required this.title,
    required this.detail,
    required this.level,
    required this.icon,
  });

  final String title;
  final String detail;
  final ProjectFinanceControlLevel level;
  final IconData icon;

  bool get needsAction => level != ProjectFinanceControlLevel.stable;
}

/// Project finance readiness snapshot for detail screens and future ledgers.
class ProjectFinanceControlSummary {
  const ProjectFinanceControlSummary({
    required this.projectId,
    required this.projectName,
    required this.profile,
    required this.budgetOverview,
    required this.attributes,
    required this.signals,
  });

  final String projectId;
  final String projectName;
  final ProjectFinanceControlProfile profile;
  final ProjectBudgetOverview budgetOverview;
  final List<ProjectFinanceControlAttribute> attributes;
  final List<ProjectFinanceControlSignal> signals;

  int get expectedControlCount => 3;
  int get configuredControlCount {
    final roles = attributes.map((attribute) => attribute.role).toSet();
    var count = 0;
    if (roles.contains(ProjectFinanceControlRole.projectFloat)) count += 1;
    if (roles.contains(ProjectFinanceControlRole.expenseOwner)) count += 1;
    if (roles.contains(ProjectFinanceControlRole.approvalPolicy)) count += 1;
    return count;
  }

  int get actionCount => signals.where((signal) => signal.needsAction).length;

  ProjectFinanceControlLevel get level {
    if (signals.any(
      (signal) => signal.level == ProjectFinanceControlLevel.actionRequired,
    )) {
      return ProjectFinanceControlLevel.actionRequired;
    }
    if (signals.any(
      (signal) => signal.level == ProjectFinanceControlLevel.watch,
    )) {
      return ProjectFinanceControlLevel.watch;
    }
    return ProjectFinanceControlLevel.stable;
  }

  String get title {
    switch (level) {
      case ProjectFinanceControlLevel.stable:
        return 'Finance controls ready';
      case ProjectFinanceControlLevel.watch:
        return 'Finance controls need setup';
      case ProjectFinanceControlLevel.actionRequired:
        return 'Finance action required';
    }
  }

  String get detail {
    return '$configuredControlCount of $expectedControlCount controls configured - ${budgetOverview.detail}';
  }
}

/// Builds a finance-control snapshot from project budget, risk, and attributes.
ProjectFinanceControlSummary buildProjectFinanceControlSummary(
  ProjectPortfolioItem project,
) {
  final profile = _profileForDomain(project.businessDomain);
  final budgetOverview = buildProjectBudgetOverview(project);
  final attributes = _financeAttributes(project.customAttributes);
  final signals = _financeSignals(
    project: project,
    profile: profile,
    budgetOverview: budgetOverview,
    attributes: attributes,
  );

  return ProjectFinanceControlSummary(
    projectId: project.id,
    projectName: project.name,
    profile: profile,
    budgetOverview: budgetOverview,
    attributes: List.unmodifiable(attributes),
    signals: List.unmodifiable(signals),
  );
}

extension ProjectFinanceControlLevelPresentation on ProjectFinanceControlLevel {
  /// User-facing label for a finance-control level.
  String get label {
    switch (this) {
      case ProjectFinanceControlLevel.stable:
        return 'Stable';
      case ProjectFinanceControlLevel.watch:
        return 'Watch';
      case ProjectFinanceControlLevel.actionRequired:
        return 'Action';
    }
  }

  /// Icon for a finance-control level.
  IconData get icon {
    switch (this) {
      case ProjectFinanceControlLevel.stable:
        return Icons.verified_outlined;
      case ProjectFinanceControlLevel.watch:
        return Icons.visibility_outlined;
      case ProjectFinanceControlLevel.actionRequired:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a finance-control level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceControlLevel.stable:
        return Colors.green.shade700;
      case ProjectFinanceControlLevel.watch:
        return Colors.orange.shade700;
      case ProjectFinanceControlLevel.actionRequired:
        return colorScheme.error;
    }
  }
}

extension ProjectFinanceControlRolePresentation on ProjectFinanceControlRole {
  /// User-facing label for a finance-control attribute role.
  String get label {
    switch (this) {
      case ProjectFinanceControlRole.projectFloat:
        return 'Project Float';
      case ProjectFinanceControlRole.expenseOwner:
        return 'Expense Owner';
      case ProjectFinanceControlRole.approvalPolicy:
        return 'Approval Policy';
      case ProjectFinanceControlRole.procurement:
        return 'Procurement';
      case ProjectFinanceControlRole.funding:
        return 'Funding';
      case ProjectFinanceControlRole.other:
        return 'Finance Field';
    }
  }

  /// Icon for a finance-control attribute role.
  IconData get icon {
    switch (this) {
      case ProjectFinanceControlRole.projectFloat:
        return Icons.payments_outlined;
      case ProjectFinanceControlRole.expenseOwner:
        return Icons.person_search_outlined;
      case ProjectFinanceControlRole.approvalPolicy:
        return Icons.rule_folder_outlined;
      case ProjectFinanceControlRole.procurement:
        return Icons.inventory_2_outlined;
      case ProjectFinanceControlRole.funding:
        return Icons.account_balance_outlined;
      case ProjectFinanceControlRole.other:
        return Icons.receipt_long_outlined;
    }
  }
}

ProjectFinanceControlProfile _profileForDomain(String domain) {
  final value = domain.toLowerCase();
  if (_containsAny(value, const ['software', 'digital', 'system', 'app'])) {
    return const ProjectFinanceControlProfile(
      floatLabel: 'Expense reserve',
      expenseOwnerLabel: 'Vendor or cloud spend owner',
      approvalLabel: 'Spend approval threshold',
    );
  }
  if (_containsAny(value, const ['finance', 'audit', 'control'])) {
    return const ProjectFinanceControlProfile(
      floatLabel: 'Control reserve',
      expenseOwnerLabel: 'Finance control owner',
      approvalLabel: 'Audit approval rule',
    );
  }
  if (_containsAny(value, const [
    'construction',
    'event',
    'wedding',
    'retail',
    'education',
    'government',
    'field',
  ])) {
    return const ProjectFinanceControlProfile(
      floatLabel: 'Project float',
      expenseOwnerLabel: 'Field expense owner',
      approvalLabel: 'On-site approval threshold',
    );
  }
  return const ProjectFinanceControlProfile(
    floatLabel: 'Project float',
    expenseOwnerLabel: 'Expense owner',
    approvalLabel: 'Approval threshold',
  );
}

List<ProjectFinanceControlAttribute> _financeAttributes(
  List<ProjectCustomAttribute> attributes,
) {
  final financeAttributes = <ProjectFinanceControlAttribute>[];

  for (final attribute in attributes) {
    if (!attribute.hasValue) continue;
    final role = _financeRoleFor(attribute);
    if (role == null) continue;

    financeAttributes.add(
      ProjectFinanceControlAttribute(
        label: attribute.label,
        value: attribute.displayValue,
        role: role,
      ),
    );
  }

  return financeAttributes;
}

ProjectFinanceControlRole? _financeRoleFor(ProjectCustomAttribute attribute) {
  final value = '${attribute.key} ${attribute.label}'.toLowerCase();
  if (_containsAny(value, const [
    'petty',
    'cash',
    'float',
    'advance',
    'reserve',
  ])) {
    return ProjectFinanceControlRole.projectFloat;
  }
  if (_containsAny(value, const [
    'expense owner',
    'finance owner',
    'approver',
  ])) {
    return ProjectFinanceControlRole.expenseOwner;
  }
  if (_containsAny(value, const [
    'approval',
    'policy',
    'threshold',
    'authority',
  ])) {
    return ProjectFinanceControlRole.approvalPolicy;
  }
  if (_containsAny(value, const ['po', 'purchase', 'procurement', 'vendor'])) {
    return ProjectFinanceControlRole.procurement;
  }
  if (_containsAny(value, const ['fund', 'grant', 'sponsor'])) {
    return ProjectFinanceControlRole.funding;
  }
  if (_containsAny(value, const ['budget', 'cost', 'expense', 'finance'])) {
    return ProjectFinanceControlRole.other;
  }
  return null;
}

List<ProjectFinanceControlSignal> _financeSignals({
  required ProjectPortfolioItem project,
  required ProjectFinanceControlProfile profile,
  required ProjectBudgetOverview budgetOverview,
  required List<ProjectFinanceControlAttribute> attributes,
}) {
  final signals = <ProjectFinanceControlSignal>[];
  final roles = attributes.map((attribute) => attribute.role).toSet();
  final hasProjectFloat = roles.contains(
    ProjectFinanceControlRole.projectFloat,
  );
  final hasExpenseOwner = roles.contains(
    ProjectFinanceControlRole.expenseOwner,
  );
  final hasApprovalPolicy = roles.contains(
    ProjectFinanceControlRole.approvalPolicy,
  );

  if (budgetOverview.state == ProjectBudgetPulseState.critical) {
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Approve budget recovery',
        detail:
            '${budgetOverview.detail} Lock scope, funding source, and recovery decision before new spend.',
        level: ProjectFinanceControlLevel.actionRequired,
        icon: Icons.account_balance_wallet_outlined,
      ),
    );
  } else if (budgetOverview.state == ProjectBudgetPulseState.pressure) {
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Review spend authority',
        detail:
            '${budgetOverview.detail} Confirm who can approve the next commitment.',
        level: ProjectFinanceControlLevel.watch,
        icon: Icons.account_balance_wallet_outlined,
      ),
    );
  }

  if (!hasProjectFloat) {
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Define ${profile.floatLabel.toLowerCase()}',
        detail:
            'Capture limit, custodian, and reconciliation cadence as project custom attributes.',
        level: ProjectFinanceControlLevel.watch,
        icon: Icons.payments_outlined,
      ),
    );
  }

  if (!hasExpenseOwner) {
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Assign ${profile.expenseOwnerLabel.toLowerCase()}',
        detail:
            'Name the person accountable for reimbursements, vendor spend, and exception handling.',
        level: ProjectFinanceControlLevel.watch,
        icon: Icons.person_search_outlined,
      ),
    );
  }

  if (!hasApprovalPolicy) {
    final level =
        budgetOverview.state == ProjectBudgetPulseState.critical ||
                project.budgetUsed >= 0.75
            ? ProjectFinanceControlLevel.actionRequired
            : ProjectFinanceControlLevel.watch;
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Set ${profile.approvalLabel.toLowerCase()}',
        detail:
            'Add approval threshold, evidence requirement, and escalation route before spend accelerates.',
        level: level,
        icon: Icons.rule_folder_outlined,
      ),
    );
  }

  final financeRisk = project.risks.where(_isFinanceRisk).toList();
  if (financeRisk.isNotEmpty) {
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Resolve finance risk',
        detail: financeRisk.first.detail,
        level:
            financeRisk.first.severity == ProjectHealth.blocked
                ? ProjectFinanceControlLevel.actionRequired
                : ProjectFinanceControlLevel.watch,
        icon: Icons.receipt_long_outlined,
      ),
    );
  }

  if (signals.isEmpty) {
    signals.add(
      ProjectFinanceControlSignal(
        title: 'Keep finance controls current',
        detail:
            'Budget pace, ${profile.floatLabel.toLowerCase()}, owner, and approval threshold are ready for the next review.',
        level: ProjectFinanceControlLevel.stable,
        icon: Icons.verified_outlined,
      ),
    );
  }

  signals.sort(_compareSignals);
  return signals;
}

bool _isFinanceRisk(ProjectDeliveryRisk risk) {
  final value = '${risk.title} ${risk.detail}'.toLowerCase();
  return _containsAny(value, const [
    'budget',
    'cash',
    'cost',
    'expense',
    'finance',
    'fund',
    'vendor',
    'supplier',
    'procurement',
  ]);
}

int _compareSignals(
  ProjectFinanceControlSignal left,
  ProjectFinanceControlSignal right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return left.title.compareTo(right.title);
}

int _levelRank(ProjectFinanceControlLevel level) {
  switch (level) {
    case ProjectFinanceControlLevel.actionRequired:
      return 0;
    case ProjectFinanceControlLevel.watch:
      return 1;
    case ProjectFinanceControlLevel.stable:
      return 2;
  }
}

bool _containsAny(String value, List<String> tokens) {
  return tokens.any(value.contains);
}
