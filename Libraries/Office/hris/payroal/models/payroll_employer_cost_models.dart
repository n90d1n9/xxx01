import 'payroll_cost_center_budget_models.dart';
import 'payroll_cost_center_models.dart';
import 'payroll_liability_models.dart';

enum PayrollEmployerCostStatus {
  onTrack('On track'),
  watch('Watch'),
  overBudget('Over budget');

  final String label;

  const PayrollEmployerCostStatus(this.label);
}

class PayrollEmployerCostLine {
  final String id;
  final String label;
  final String owner;
  final int employeeCount;
  final double grossPayroll;
  final double netPayroll;
  final double employeeDeductions;
  final double liabilityAllocation;
  final double budget;

  const PayrollEmployerCostLine({
    required this.id,
    required this.label,
    required this.owner,
    required this.employeeCount,
    required this.grossPayroll,
    required this.netPayroll,
    required this.employeeDeductions,
    required this.liabilityAllocation,
    required this.budget,
  });

  double get totalEmployerCost => grossPayroll + liabilityAllocation;

  double get budgetVariance => budget - totalEmployerCost;

  double get utilization {
    if (budget == 0) return 0;
    return totalEmployerCost / budget;
  }

  double get liabilityRate {
    if (grossPayroll == 0) return 0;
    return liabilityAllocation / grossPayroll;
  }

  PayrollEmployerCostStatus get status {
    if (budgetVariance < 0) return PayrollEmployerCostStatus.overBudget;
    if (utilization >= 0.9) return PayrollEmployerCostStatus.watch;
    return PayrollEmployerCostStatus.onTrack;
  }
}

class PayrollEmployerCostSummary {
  final String periodLabel;
  final List<PayrollEmployerCostLine> lines;

  const PayrollEmployerCostSummary({
    required this.periodLabel,
    required this.lines,
  });

  factory PayrollEmployerCostSummary.fromRun({
    required PayrollCostCenterSummary costCenters,
    required PayrollCostCenterBudgetSummary budgets,
    required PayrollLiabilitySummary liabilities,
  }) {
    final budgetById = {for (final line in budgets.lines) line.id: line};
    final totalGross = costCenters.totalGrossPayroll;
    final totalLiabilities = liabilities.totalAmount;

    final lines =
        costCenters.lines.map((costCenter) {
            final budget = budgetById[costCenter.id];
            final allocation =
                totalGross == 0
                    ? 0.0
                    : totalLiabilities * (costCenter.grossPayroll / totalGross);
            return PayrollEmployerCostLine(
              id: costCenter.id,
              label: costCenter.label,
              owner: budget?.owner ?? 'Finance Partner',
              employeeCount: costCenter.employeeCount,
              grossPayroll: costCenter.grossPayroll,
              netPayroll: costCenter.netPayroll,
              employeeDeductions: costCenter.deductions,
              liabilityAllocation: allocation,
              budget: budget?.budget ?? costCenter.grossPayroll + allocation,
            );
          }).toList()
          ..sort((left, right) {
            final status = right.status.index.compareTo(left.status.index);
            if (status != 0) return status;
            return right.totalEmployerCost.compareTo(left.totalEmployerCost);
          });

    return PayrollEmployerCostSummary(
      periodLabel: costCenters.periodLabel,
      lines: lines,
    );
  }

  int get employeeCount =>
      lines.fold(0, (total, line) => total + line.employeeCount);

  int get overBudgetCount =>
      lines
          .where((line) => line.status == PayrollEmployerCostStatus.overBudget)
          .length;

  int get watchCount =>
      lines
          .where((line) => line.status == PayrollEmployerCostStatus.watch)
          .length;

  double get totalGrossPayroll =>
      lines.fold(0, (total, line) => total + line.grossPayroll);

  double get totalLiabilityAllocation =>
      lines.fold(0, (total, line) => total + line.liabilityAllocation);

  double get totalEmployerCost =>
      lines.fold(0, (total, line) => total + line.totalEmployerCost);

  double get totalBudget => lines.fold(0, (total, line) => total + line.budget);

  double get totalBudgetVariance => totalBudget - totalEmployerCost;

  PayrollEmployerCostLine? get topCostLine {
    if (lines.isEmpty) return null;
    return lines.reduce(
      (left, right) =>
          left.totalEmployerCost >= right.totalEmployerCost ? left : right,
    );
  }

  String get nextAction {
    final overBudget =
        lines
            .where(
              (line) => line.status == PayrollEmployerCostStatus.overBudget,
            )
            .toList();
    if (overBudget.isNotEmpty) {
      return '${overBudget.first.label} is over employer cost budget.';
    }
    if (watchCount > 0) {
      return '$watchCount cost centers are nearing employer cost budget.';
    }
    return 'Employer cost is within budget across all cost centers.';
  }
}
