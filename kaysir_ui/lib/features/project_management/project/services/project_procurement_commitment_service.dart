import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import '../models/project_portfolio_item.dart';
import 'project_expense_intake_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_workspace_service.dart';
import 'project_spend_authority_service.dart';

/// Procurement commitment readiness for vendor, supplier, and PO workflows.
enum ProjectProcurementCommitmentLevel { ready, review, blocked }

/// Procurement commitment source across budget, authority, proof, and risks.
enum ProjectProcurementCommitmentKind {
  budgetPackage,
  spendRoute,
  authority,
  deliveryProof,
  supplierRisk,
}

/// UI-ready procurement commitment item for external spend control.
class ProjectProcurementCommitmentItem {
  const ProjectProcurementCommitmentItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.amount,
    required this.ownerLabel,
    required this.evidenceLabel,
    required this.actionLabel,
    required this.sourceLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectProcurementCommitmentKind kind;
  final ProjectProcurementCommitmentLevel level;
  final IconData icon;
  final double amount;
  final String ownerLabel;
  final String evidenceLabel;
  final String actionLabel;
  final String sourceLabel;

  bool get isReady => level == ProjectProcurementCommitmentLevel.ready;
  bool get isBlocked => level == ProjectProcurementCommitmentLevel.blocked;
  String get amountLabel => _money(amount);
}

/// Aggregated procurement workspace for one selected project.
class ProjectProcurementCommitmentSummary {
  const ProjectProcurementCommitmentSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.items,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final List<ProjectProcurementCommitmentItem> items;

  int get itemCount => items.length;
  int get readyCount => items.where((item) => item.isReady).length;
  int get reviewCount =>
      items
          .where(
            (item) => item.level == ProjectProcurementCommitmentLevel.review,
          )
          .length;
  int get blockedCount => items.where((item) => item.isBlocked).length;
  double get commitmentAmount =>
      items.fold(0, (sum, item) => sum + item.amount);
  double get attentionAmount => items
      .where((item) => !item.isReady)
      .fold(0, (sum, item) => sum + item.amount);
  String get commitmentAmountLabel => _money(commitmentAmount);
  String get attentionAmountLabel => _money(attentionAmount);

  ProjectProcurementCommitmentLevel get level {
    if (blockedCount > 0) return ProjectProcurementCommitmentLevel.blocked;
    if (reviewCount > 0) return ProjectProcurementCommitmentLevel.review;
    return ProjectProcurementCommitmentLevel.ready;
  }

  ProjectProcurementCommitmentItem? get primaryItem {
    if (items.isEmpty) return null;
    final sorted = [...items]..sort(_compareItems);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectProcurementCommitmentLevel.ready:
        return 'Procurement commitments ready';
      case ProjectProcurementCommitmentLevel.review:
        return 'Procurement commitments need review';
      case ProjectProcurementCommitmentLevel.blocked:
        return 'Procurement commitments blocked';
    }
  }

  String get detail {
    final primary = primaryItem;
    if (primary == null) {
      return 'No procurement commitments are configured for $businessDomain.';
    }

    return '$readyCount of $itemCount commitments ready - next: ${primary.title}.';
  }
}

/// Builds procurement commitments from budget, authority, proof, and risk data.
ProjectProcurementCommitmentSummary buildProjectProcurementCommitmentSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final items = <ProjectProcurementCommitmentItem>[
    for (final line in summary.financeLedger.budgetLines)
      if (_isProcurementCategory(line.category))
        _budgetPackageItem(line, summary.spendAuthority),
    if (_vendorRoute(summary.expenseIntake) case final route?)
      _spendRouteItem(route),
    if (_vendorAuthority(summary.spendAuthority) case final authority?)
      _authorityItem(authority),
    if (_vendorProof(summary.financeReconciliation) case final proof?)
      _deliveryProofItem(summary.project.id, proof),
    for (final risk in summary.project.risks)
      if (_isSupplierRisk(risk)) _supplierRiskItem(summary.project.id, risk),
  ]..sort(_compareItems);

  return ProjectProcurementCommitmentSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    items: List.unmodifiable(items),
  );
}

ProjectProcurementCommitmentItem _budgetPackageItem(
  ProjectBudgetLine line,
  ProjectSpendAuthoritySummary authority,
) {
  final level = _budgetLineLevel(line, authority);

  return ProjectProcurementCommitmentItem(
    id: '${line.id}-procurement-package',
    title: line.title,
    detail:
        '${line.owner} owns ${_categoryLabel(line.category).toLowerCase()} package at ${(line.utilization * 100).round()}% utilization with ${_money(line.remainingAmount)} remaining.',
    kind: ProjectProcurementCommitmentKind.budgetPackage,
    level: level,
    icon: _categoryIcon(line.category),
    amount:
        line.committedAmount > 0 ? line.committedAmount : line.plannedAmount,
    ownerLabel: line.owner,
    evidenceLabel: 'Vendor, quotation, purchase reason, delivery proof',
    actionLabel: _actionLabel(
      level,
      blocked: 'Hold package',
      review: 'Review package',
      ready: 'Track package',
    ),
    sourceLabel: 'Budget package',
  );
}

ProjectProcurementCommitmentItem _spendRouteItem(
  ProjectExpenseIntakeRoute route,
) {
  final level = _fromExpenseIntakeLevel(route.level);

  return ProjectProcurementCommitmentItem(
    id: '${route.id}-procurement-route',
    title: route.title,
    detail: route.detail,
    kind: ProjectProcurementCommitmentKind.spendRoute,
    level: level,
    icon: route.icon,
    amount: 0,
    ownerLabel: route.approvalLabel,
    evidenceLabel: route.evidenceLabel,
    actionLabel: _actionLabel(
      level,
      blocked: 'Hold route',
      review: 'Complete route',
      ready: 'Open route',
    ),
    sourceLabel: 'Expense intake',
  );
}

ProjectProcurementCommitmentItem _authorityItem(
  ProjectSpendAuthorityRule rule,
) {
  final level = _fromAuthorityLevel(rule.level);

  return ProjectProcurementCommitmentItem(
    id: '${rule.id}-procurement-authority',
    title: rule.title,
    detail: rule.detail,
    kind: ProjectProcurementCommitmentKind.authority,
    level: level,
    icon: rule.icon,
    amount: 0,
    ownerLabel: rule.approverLabel,
    evidenceLabel: rule.evidenceLabel,
    actionLabel: _actionLabel(
      level,
      blocked: 'Escalate authority',
      review: 'Set authority',
      ready: 'Use authority',
    ),
    sourceLabel: 'Spend authority',
  );
}

ProjectProcurementCommitmentItem _deliveryProofItem(
  String projectId,
  ProjectFinanceReconciliationItem item,
) {
  final level = _fromReconciliationLevel(item.level);

  return ProjectProcurementCommitmentItem(
    id: '$projectId-${item.id}-procurement-proof',
    title: item.title,
    detail: item.detail,
    kind: ProjectProcurementCommitmentKind.deliveryProof,
    level: level,
    icon: item.icon,
    amount: 0,
    ownerLabel: item.ownerLabel,
    evidenceLabel: item.evidenceLabel,
    actionLabel: _actionLabel(
      level,
      blocked: 'Resolve proof',
      review: 'Validate proof',
      ready: 'Archive proof',
    ),
    sourceLabel: item.kind.label,
  );
}

ProjectProcurementCommitmentItem _supplierRiskItem(
  String projectId,
  ProjectDeliveryRisk risk,
) {
  final level = _fromProjectHealth(risk.severity);

  return ProjectProcurementCommitmentItem(
    id: '$projectId-${_slug(risk.title)}-procurement-risk',
    title: risk.title,
    detail: risk.detail,
    kind: ProjectProcurementCommitmentKind.supplierRisk,
    level: level,
    icon: risk.severity.icon,
    amount: 0,
    ownerLabel: 'Delivery owner',
    evidenceLabel: 'Supplier decision, fallback plan, delivery impact',
    actionLabel: _actionLabel(
      level,
      blocked: 'Escalate risk',
      review: 'Review risk',
      ready: 'Monitor risk',
    ),
    sourceLabel: 'Project risk',
  );
}

ProjectExpenseIntakeRoute? _vendorRoute(ProjectExpenseIntakeSummary summary) {
  for (final route in summary.routes) {
    if (route.kind == ProjectExpenseIntakeKind.vendorCommitment) return route;
  }
  return null;
}

ProjectSpendAuthorityRule? _vendorAuthority(
  ProjectSpendAuthoritySummary summary,
) {
  for (final rule in summary.rules) {
    if (rule.band == ProjectSpendAuthorityBand.vendorCommitment) return rule;
  }
  return null;
}

ProjectFinanceReconciliationItem? _vendorProof(
  ProjectFinanceReconciliationSummary summary,
) {
  for (final item in summary.items) {
    if (item.kind == ProjectFinanceReconciliationKind.vendorProof) return item;
  }
  return null;
}

ProjectProcurementCommitmentLevel _budgetLineLevel(
  ProjectBudgetLine line,
  ProjectSpendAuthoritySummary authority,
) {
  if (authority.level == ProjectSpendAuthorityLevel.escalation ||
      line.utilization >= 0.95) {
    return ProjectProcurementCommitmentLevel.blocked;
  }
  if (authority.level == ProjectSpendAuthorityLevel.guarded ||
      line.utilization >= 0.65 ||
      line.committedAmount > line.spentAmount) {
    return ProjectProcurementCommitmentLevel.review;
  }
  return ProjectProcurementCommitmentLevel.ready;
}

ProjectProcurementCommitmentLevel _fromExpenseIntakeLevel(
  ProjectExpenseIntakeLevel level,
) {
  switch (level) {
    case ProjectExpenseIntakeLevel.ready:
      return ProjectProcurementCommitmentLevel.ready;
    case ProjectExpenseIntakeLevel.setupNeeded:
      return ProjectProcurementCommitmentLevel.review;
    case ProjectExpenseIntakeLevel.approvalRequired:
      return ProjectProcurementCommitmentLevel.blocked;
  }
}

ProjectProcurementCommitmentLevel _fromAuthorityLevel(
  ProjectSpendAuthorityLevel level,
) {
  switch (level) {
    case ProjectSpendAuthorityLevel.delegated:
      return ProjectProcurementCommitmentLevel.ready;
    case ProjectSpendAuthorityLevel.guarded:
      return ProjectProcurementCommitmentLevel.review;
    case ProjectSpendAuthorityLevel.escalation:
      return ProjectProcurementCommitmentLevel.blocked;
  }
}

ProjectProcurementCommitmentLevel _fromReconciliationLevel(
  ProjectFinanceReconciliationLevel level,
) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.clean:
      return ProjectProcurementCommitmentLevel.ready;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return ProjectProcurementCommitmentLevel.review;
    case ProjectFinanceReconciliationLevel.blocked:
      return ProjectProcurementCommitmentLevel.blocked;
  }
}

ProjectProcurementCommitmentLevel _fromProjectHealth(ProjectHealth health) {
  switch (health) {
    case ProjectHealth.onTrack:
      return ProjectProcurementCommitmentLevel.ready;
    case ProjectHealth.atRisk:
      return ProjectProcurementCommitmentLevel.review;
    case ProjectHealth.blocked:
      return ProjectProcurementCommitmentLevel.blocked;
  }
}

bool _isProcurementCategory(ProjectFinanceCategory category) {
  switch (category) {
    case ProjectFinanceCategory.material:
    case ProjectFinanceCategory.vendor:
    case ProjectFinanceCategory.technology:
    case ProjectFinanceCategory.logistics:
      return true;
    case ProjectFinanceCategory.labor:
    case ProjectFinanceCategory.governance:
    case ProjectFinanceCategory.training:
    case ProjectFinanceCategory.reserve:
    case ProjectFinanceCategory.pettyCash:
    case ProjectFinanceCategory.other:
      return false;
  }
}

bool _isSupplierRisk(ProjectDeliveryRisk risk) {
  final value = '${risk.title} ${risk.detail}'.toLowerCase();
  return _containsAny(value, const [
    'supplier',
    'vendor',
    'procurement',
    'purchase',
    'contract',
    'quotation',
    'lead time',
    'venue',
  ]);
}

String _actionLabel(
  ProjectProcurementCommitmentLevel level, {
  required String blocked,
  required String review,
  required String ready,
}) {
  switch (level) {
    case ProjectProcurementCommitmentLevel.blocked:
      return blocked;
    case ProjectProcurementCommitmentLevel.review:
      return review;
    case ProjectProcurementCommitmentLevel.ready:
      return ready;
  }
}

int _compareItems(
  ProjectProcurementCommitmentItem left,
  ProjectProcurementCommitmentItem right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final amountCompare = right.amount.compareTo(left.amount);
  if (amountCompare != 0) return amountCompare;

  final kindCompare = left.kind.index.compareTo(right.kind.index);
  if (kindCompare != 0) return kindCompare;

  return left.title.compareTo(right.title);
}

int _levelRank(ProjectProcurementCommitmentLevel level) {
  switch (level) {
    case ProjectProcurementCommitmentLevel.blocked:
      return 0;
    case ProjectProcurementCommitmentLevel.review:
      return 1;
    case ProjectProcurementCommitmentLevel.ready:
      return 2;
  }
}

String _categoryLabel(ProjectFinanceCategory category) {
  switch (category) {
    case ProjectFinanceCategory.labor:
      return 'Labor';
    case ProjectFinanceCategory.material:
      return 'Material';
    case ProjectFinanceCategory.vendor:
      return 'Vendor';
    case ProjectFinanceCategory.technology:
      return 'Technology';
    case ProjectFinanceCategory.logistics:
      return 'Logistics';
    case ProjectFinanceCategory.governance:
      return 'Governance';
    case ProjectFinanceCategory.training:
      return 'Training';
    case ProjectFinanceCategory.reserve:
      return 'Reserve';
    case ProjectFinanceCategory.pettyCash:
      return 'Petty Cash';
    case ProjectFinanceCategory.other:
      return 'Other';
  }
}

IconData _categoryIcon(ProjectFinanceCategory category) {
  switch (category) {
    case ProjectFinanceCategory.labor:
      return Icons.engineering_outlined;
    case ProjectFinanceCategory.material:
      return Icons.category_outlined;
    case ProjectFinanceCategory.vendor:
      return Icons.inventory_2_outlined;
    case ProjectFinanceCategory.technology:
      return Icons.devices_outlined;
    case ProjectFinanceCategory.logistics:
      return Icons.local_shipping_outlined;
    case ProjectFinanceCategory.governance:
      return Icons.account_tree_outlined;
    case ProjectFinanceCategory.training:
      return Icons.school_outlined;
    case ProjectFinanceCategory.reserve:
      return Icons.savings_outlined;
    case ProjectFinanceCategory.pettyCash:
      return Icons.payments_outlined;
    case ProjectFinanceCategory.other:
      return Icons.receipt_long_outlined;
  }
}

String _money(double value) {
  if (value <= 0) return '-';
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
}

String _slug(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

bool _containsAny(String value, List<String> tokens) {
  return tokens.any(value.contains);
}

extension ProjectProcurementCommitmentLevelPresentation
    on ProjectProcurementCommitmentLevel {
  /// User-facing label for a procurement commitment readiness level.
  String get label {
    switch (this) {
      case ProjectProcurementCommitmentLevel.ready:
        return 'Ready';
      case ProjectProcurementCommitmentLevel.review:
        return 'Review';
      case ProjectProcurementCommitmentLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a procurement commitment readiness level.
  IconData get icon {
    switch (this) {
      case ProjectProcurementCommitmentLevel.ready:
        return Icons.verified_outlined;
      case ProjectProcurementCommitmentLevel.review:
        return Icons.inventory_2_outlined;
      case ProjectProcurementCommitmentLevel.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for a procurement commitment readiness level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectProcurementCommitmentLevel.ready:
        return Colors.green.shade700;
      case ProjectProcurementCommitmentLevel.review:
        return Colors.orange.shade700;
      case ProjectProcurementCommitmentLevel.blocked:
        return colorScheme.error;
    }
  }
}

extension ProjectProcurementCommitmentKindPresentation
    on ProjectProcurementCommitmentKind {
  /// User-facing label for a procurement commitment source kind.
  String get label {
    switch (this) {
      case ProjectProcurementCommitmentKind.budgetPackage:
        return 'Budget Package';
      case ProjectProcurementCommitmentKind.spendRoute:
        return 'Spend Route';
      case ProjectProcurementCommitmentKind.authority:
        return 'Authority';
      case ProjectProcurementCommitmentKind.deliveryProof:
        return 'Delivery Proof';
      case ProjectProcurementCommitmentKind.supplierRisk:
        return 'Supplier Risk';
    }
  }
}
