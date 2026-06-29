import '../../employee/models/employee.dart';
import 'payroll_adjustment_models.dart';
import 'payroll_detail.dart';

class PayrollCostCenterLine {
  final String id;
  final String label;
  final int employeeCount;
  final int paidCount;
  final int pendingPaymentCount;
  final int pendingAdjustmentCount;
  final double grossPayroll;
  final double netPayroll;
  final double deductions;
  final double approvedAdjustmentTotal;

  const PayrollCostCenterLine({
    required this.id,
    required this.label,
    required this.employeeCount,
    required this.paidCount,
    required this.pendingPaymentCount,
    required this.pendingAdjustmentCount,
    required this.grossPayroll,
    required this.netPayroll,
    required this.deductions,
    required this.approvedAdjustmentTotal,
  });

  double get completionRate {
    if (employeeCount == 0) return 0;
    return paidCount / employeeCount;
  }

  double get deductionRate {
    if (grossPayroll == 0) return 0;
    return deductions / grossPayroll;
  }

  int get riskCount => pendingPaymentCount + pendingAdjustmentCount;
}

class PayrollCostCenterSummary {
  final String periodLabel;
  final List<PayrollCostCenterLine> lines;
  final String nextAction;

  const PayrollCostCenterSummary({
    required this.periodLabel,
    required this.lines,
    required this.nextAction,
  });

  factory PayrollCostCenterSummary.fromRun({
    required String periodLabel,
    required List<Employee> employees,
    required Map<int, bool> paymentStatus,
    required List<PayrollAdjustmentRequest> adjustments,
  }) {
    final pendingAdjustmentsByEmployeeId = <int, int>{};
    final approvedAdjustmentsByEmployeeId = <int, double>{};

    for (final adjustment in adjustments) {
      if (adjustment.isPending) {
        pendingAdjustmentsByEmployeeId.update(
          adjustment.employeeId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      if (adjustment.isApproved) {
        approvedAdjustmentsByEmployeeId.update(
          adjustment.employeeId,
          (total) => total + adjustment.amount,
          ifAbsent: () => adjustment.amount,
        );
      }
    }

    final builders = <String, _CostCenterLineBuilder>{};
    for (final employee in employees) {
      final center = _costCenterFor(employee);
      final details = PayrollDetails.fromSalary(employee.salary ?? 0);
      final approvedAdjustment =
          approvedAdjustmentsByEmployeeId[employee.id] ?? 0;
      final builder = builders.putIfAbsent(
        center.id,
        () => _CostCenterLineBuilder(id: center.id, label: center.label),
      );

      builder.employeeCount++;
      if (paymentStatus[employee.id] ?? false) {
        builder.paidCount++;
      } else {
        builder.pendingPaymentCount++;
      }
      builder.pendingAdjustmentCount +=
          pendingAdjustmentsByEmployeeId[employee.id] ?? 0;
      builder.grossPayroll += details.grossSalary + approvedAdjustment;
      builder.netPayroll += details.netSalary + approvedAdjustment;
      builder.deductions += details.totalDeductions;
      builder.approvedAdjustmentTotal += approvedAdjustment;
    }

    final lines =
        builders.values.map((builder) => builder.build()).toList()..sort(
          (left, right) => right.grossPayroll.compareTo(left.grossPayroll),
        );
    final riskiest = _firstRiskLine(lines);

    return PayrollCostCenterSummary(
      periodLabel: periodLabel,
      lines: lines,
      nextAction:
          riskiest == null
              ? 'All cost centers are clear for payroll release.'
              : '${riskiest.label} has ${riskiest.riskCount} payroll items to clear.',
    );
  }

  int get totalEmployeeCount {
    return lines.fold(0, (total, line) => total + line.employeeCount);
  }

  int get totalRiskCount {
    return lines.fold(0, (total, line) => total + line.riskCount);
  }

  double get totalGrossPayroll {
    return lines.fold(0, (total, line) => total + line.grossPayroll);
  }
}

class _CostCenter {
  final String id;
  final String label;

  const _CostCenter({required this.id, required this.label});
}

class _CostCenterLineBuilder {
  final String id;
  final String label;
  int employeeCount = 0;
  int paidCount = 0;
  int pendingPaymentCount = 0;
  int pendingAdjustmentCount = 0;
  double grossPayroll = 0;
  double netPayroll = 0;
  double deductions = 0;
  double approvedAdjustmentTotal = 0;

  _CostCenterLineBuilder({required this.id, required this.label});

  PayrollCostCenterLine build() {
    return PayrollCostCenterLine(
      id: id,
      label: label,
      employeeCount: employeeCount,
      paidCount: paidCount,
      pendingPaymentCount: pendingPaymentCount,
      pendingAdjustmentCount: pendingAdjustmentCount,
      grossPayroll: grossPayroll,
      netPayroll: netPayroll,
      deductions: deductions,
      approvedAdjustmentTotal: approvedAdjustmentTotal,
    );
  }
}

_CostCenter _costCenterFor(Employee employee) {
  final department = employee.department?.trim();
  if (department != null && department.isNotEmpty) {
    return _CostCenter(
      id: department.toLowerCase().replaceAll(' ', '-'),
      label: department,
    );
  }

  final position = employee.position?.toLowerCase() ?? '';
  if (position.contains('developer')) {
    return const _CostCenter(id: 'engineering', label: 'Engineering');
  }
  if (position.contains('designer')) {
    return const _CostCenter(id: 'design', label: 'Design');
  }
  if (position.contains('manager')) {
    return const _CostCenter(id: 'operations', label: 'Operations');
  }
  return const _CostCenter(id: 'payroll', label: 'Payroll');
}

PayrollCostCenterLine? _firstRiskLine(List<PayrollCostCenterLine> lines) {
  final sorted = [...lines]..sort((left, right) {
    final risk = right.riskCount.compareTo(left.riskCount);
    if (risk != 0) return risk;
    return right.grossPayroll.compareTo(left.grossPayroll);
  });
  for (final line in sorted) {
    if (line.riskCount > 0) return line;
  }
  return null;
}
