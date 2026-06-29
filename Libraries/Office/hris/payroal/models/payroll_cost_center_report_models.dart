import 'payroll_cost_center_budget_models.dart';
import 'payroll_cost_center_models.dart';

enum PayrollCostCenterReportStatus {
  blocked('Blocked'),
  ready('Ready'),
  exported('Exported');

  final String label;

  const PayrollCostCenterReportStatus(this.label);
}

class PayrollCostCenterReportLine {
  final String id;
  final String label;
  final String owner;
  final int employeeCount;
  final double budget;
  final double grossPayroll;
  final double netPayroll;
  final double deductions;
  final double approvedAdjustmentTotal;
  final int riskCount;
  final bool isApprovedForRelease;

  const PayrollCostCenterReportLine({
    required this.id,
    required this.label,
    required this.owner,
    required this.employeeCount,
    required this.budget,
    required this.grossPayroll,
    required this.netPayroll,
    required this.deductions,
    required this.approvedAdjustmentTotal,
    required this.riskCount,
    required this.isApprovedForRelease,
  });

  double get utilization {
    if (budget == 0) return 0;
    return grossPayroll / budget;
  }

  double get remainingBudget => budget - grossPayroll;

  bool get hasBlockers => riskCount > 0 || !isApprovedForRelease;
}

class PayrollCostCenterReportSummary {
  final String reportId;
  final String periodLabel;
  final List<PayrollCostCenterReportLine> lines;
  final bool isExported;

  const PayrollCostCenterReportSummary({
    required this.reportId,
    required this.periodLabel,
    required this.lines,
    required this.isExported,
  });

  factory PayrollCostCenterReportSummary.fromCostCenters({
    required PayrollCostCenterSummary costCenters,
    required PayrollCostCenterBudgetSummary budgets,
    required Set<String> exportedReportIds,
  }) {
    final budgetById = {for (final line in budgets.lines) line.id: line};
    final reportId = _reportId(costCenters.periodLabel);
    final lines =
        costCenters.lines.map((costCenter) {
          final budget = budgetById[costCenter.id];
          return PayrollCostCenterReportLine(
            id: costCenter.id,
            label: costCenter.label,
            owner: budget?.owner ?? 'Finance Partner',
            employeeCount: costCenter.employeeCount,
            budget: budget?.budget ?? 0,
            grossPayroll: costCenter.grossPayroll,
            netPayroll: costCenter.netPayroll,
            deductions: costCenter.deductions,
            approvedAdjustmentTotal: costCenter.approvedAdjustmentTotal,
            riskCount: costCenter.riskCount,
            isApprovedForRelease: budget?.isApprovedForRelease ?? false,
          );
        }).toList();

    return PayrollCostCenterReportSummary(
      reportId: reportId,
      periodLabel: costCenters.periodLabel,
      lines: lines,
      isExported: exportedReportIds.contains(reportId),
    );
  }

  int get costCenterCount => lines.length;

  int get approvedCount {
    return lines.where((line) => line.isApprovedForRelease).length;
  }

  int get blockedCount {
    return lines.where((line) => line.hasBlockers).length;
  }

  double get totalBudget {
    return lines.fold(0, (total, line) => total + line.budget);
  }

  double get totalGrossPayroll {
    return lines.fold(0, (total, line) => total + line.grossPayroll);
  }

  double get totalNetPayroll {
    return lines.fold(0, (total, line) => total + line.netPayroll);
  }

  double get totalDeductions {
    return lines.fold(0, (total, line) => total + line.deductions);
  }

  List<String> get blockers {
    return [
      if (lines.isEmpty) 'No cost center report lines are available',
      if (blockedCount > 0)
        '$blockedCount cost center report lines need approval or risk clearance',
    ];
  }

  PayrollCostCenterReportStatus get status {
    if (blockers.isNotEmpty) return PayrollCostCenterReportStatus.blocked;
    if (isExported) return PayrollCostCenterReportStatus.exported;
    return PayrollCostCenterReportStatus.ready;
  }

  bool get canExport => status == PayrollCostCenterReportStatus.ready;

  String get nextAction {
    final currentBlockers = blockers;
    if (currentBlockers.isNotEmpty) return currentBlockers.first;
    if (isExported) return 'Cost center payroll report is exported.';
    return 'Export cost center payroll report for finance review.';
  }
}

String _reportId(String periodLabel) {
  final compact = periodLabel
      .toUpperCase()
      .replaceAll(RegExp('[^A-Z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp('(^-|-\$)'), '');
  return 'CC-$compact';
}
