import 'package:flutter/material.dart';

import '../data/project_finance_ledger_repository.dart';
import '../models/project_finance_ledger.dart';

/// Health level for a project finance ledger snapshot.
enum ProjectFinanceLedgerLevel { settled, active, attention }

/// Aggregated project finance ledger records and totals.
class ProjectFinanceLedgerSummary {
  const ProjectFinanceLedgerSummary({
    required this.projectId,
    required this.budgetLines,
    required this.expenseRequests,
    required this.pettyCashEntries,
    required this.approvalRecords,
    required this.reconciliationEvidence,
  });

  final String projectId;
  final List<ProjectBudgetLine> budgetLines;
  final List<ProjectExpenseRequest> expenseRequests;
  final List<ProjectPettyCashEntry> pettyCashEntries;
  final List<ProjectApprovalRecord> approvalRecords;
  final List<ProjectReconciliationEvidence> reconciliationEvidence;

  double get plannedAmount =>
      budgetLines.fold(0, (sum, line) => sum + line.plannedAmount);
  double get committedAmount =>
      budgetLines.fold(0, (sum, line) => sum + line.committedAmount);
  double get spentAmount =>
      budgetLines.fold(0, (sum, line) => sum + line.spentAmount);
  double get remainingAmount => plannedAmount - spentAmount;
  double get utilization =>
      plannedAmount <= 0 ? 0 : (spentAmount / plannedAmount).clamp(0, 2);

  int get budgetLineCount => budgetLines.length;
  int get openExpenseCount =>
      expenseRequests.where((request) => request.isOpen).length;
  int get openPettyCashCount =>
      pettyCashEntries.where((entry) => entry.isOpen).length;
  int get openApprovalCount =>
      approvalRecords.where((record) => record.isOpen).length;
  int get openEvidenceCount =>
      reconciliationEvidence.where((evidence) => evidence.isOpen).length;
  int get openItemCount =>
      openExpenseCount +
      openPettyCashCount +
      openApprovalCount +
      openEvidenceCount;

  ProjectBudgetLine? get highestUtilizationLine {
    if (budgetLines.isEmpty) return null;
    final sorted = [...budgetLines]
      ..sort((left, right) => right.utilization.compareTo(left.utilization));
    return sorted.first;
  }

  ProjectFinanceLedgerLevel get level {
    final hasBlocked = [
      ...expenseRequests.map((request) => request.status),
      ...pettyCashEntries.map((entry) => entry.status),
      ...approvalRecords.map((record) => record.status),
      ...reconciliationEvidence.map((evidence) => evidence.status),
    ].contains(ProjectFinanceRecordStatus.blocked);

    if (hasBlocked || utilization >= 0.9) {
      return ProjectFinanceLedgerLevel.attention;
    }
    if (openItemCount > 0 || committedAmount > spentAmount) {
      return ProjectFinanceLedgerLevel.active;
    }
    return ProjectFinanceLedgerLevel.settled;
  }

  String get title {
    switch (level) {
      case ProjectFinanceLedgerLevel.settled:
        return 'Ledger settled';
      case ProjectFinanceLedgerLevel.active:
        return 'Ledger active';
      case ProjectFinanceLedgerLevel.attention:
        return 'Ledger needs attention';
    }
  }

  String get detail {
    final primaryLine = highestUtilizationLine;
    final lineText =
        primaryLine == null
            ? 'No budget lines yet'
            : '${primaryLine.title} is ${(primaryLine.utilization * 100).round()}% utilized';
    return '$budgetLineCount budget lines - $openItemCount open finance items - $lineText.';
  }
}

/// Builds a project finance ledger summary from repository records.
ProjectFinanceLedgerSummary buildProjectFinanceLedgerSummary({
  required String projectId,
  ProjectFinanceLedgerRepository repository =
      const ProjectFinanceLedgerRepository(),
}) {
  return ProjectFinanceLedgerSummary(
    projectId: projectId,
    budgetLines: repository.budgetLinesForProject(projectId),
    expenseRequests: repository.expenseRequestsForProject(projectId),
    pettyCashEntries: repository.pettyCashEntriesForProject(projectId),
    approvalRecords: repository.approvalRecordsForProject(projectId),
    reconciliationEvidence: repository.reconciliationEvidenceForProject(
      projectId,
    ),
  );
}

extension ProjectFinanceLedgerLevelPresentation on ProjectFinanceLedgerLevel {
  /// User-facing label for a project finance ledger level.
  String get label {
    switch (this) {
      case ProjectFinanceLedgerLevel.settled:
        return 'Settled';
      case ProjectFinanceLedgerLevel.active:
        return 'Active';
      case ProjectFinanceLedgerLevel.attention:
        return 'Attention';
    }
  }

  /// Icon for a project finance ledger level.
  IconData get icon {
    switch (this) {
      case ProjectFinanceLedgerLevel.settled:
        return Icons.verified_outlined;
      case ProjectFinanceLedgerLevel.active:
        return Icons.receipt_long_outlined;
      case ProjectFinanceLedgerLevel.attention:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a project finance ledger level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceLedgerLevel.settled:
        return Colors.green.shade700;
      case ProjectFinanceLedgerLevel.active:
        return colorScheme.primary;
      case ProjectFinanceLedgerLevel.attention:
        return colorScheme.error;
    }
  }
}

extension ProjectFinanceCategoryPresentation on ProjectFinanceCategory {
  /// User-facing label for a project finance category.
  String get label {
    switch (this) {
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

  /// Icon for a project finance category.
  IconData get icon {
    switch (this) {
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
}
