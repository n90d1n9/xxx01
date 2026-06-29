import 'payroll_cost_center_models.dart';
import 'payroll_run_models.dart';

enum PayrollRunComparisonSignal {
  stable('Stable'),
  watch('Watch'),
  review('Review');

  final String label;

  const PayrollRunComparisonSignal(this.label);
}

enum PayrollRunComparisonMetricType { count, currency }

class PayrollRunComparisonCostCenterBaseline {
  final String id;
  final String label;
  final int employeeCount;
  final double grossPayroll;

  const PayrollRunComparisonCostCenterBaseline({
    required this.id,
    required this.label,
    required this.employeeCount,
    required this.grossPayroll,
  });
}

class PayrollRunComparisonBaseline {
  final String periodLabel;
  final int employeeCount;
  final double grossPayroll;
  final double netPayroll;
  final double deductions;
  final double approvedAdjustmentTotal;
  final List<PayrollRunComparisonCostCenterBaseline> costCenters;

  const PayrollRunComparisonBaseline({
    required this.periodLabel,
    required this.employeeCount,
    required this.grossPayroll,
    required this.netPayroll,
    required this.deductions,
    required this.approvedAdjustmentTotal,
    required this.costCenters,
  });
}

class PayrollRunComparisonMetric {
  final String id;
  final String label;
  final double currentValue;
  final double baselineValue;
  final PayrollRunComparisonMetricType type;

  const PayrollRunComparisonMetric({
    required this.id,
    required this.label,
    required this.currentValue,
    required this.baselineValue,
    required this.type,
  });

  double get delta => currentValue - baselineValue;

  double get percentChange {
    if (baselineValue == 0) return currentValue == 0 ? 0 : 1;
    return delta / baselineValue;
  }

  PayrollRunComparisonSignal get signal {
    final change = percentChange.abs();
    if (change >= 0.1) return PayrollRunComparisonSignal.review;
    if (change >= 0.02) return PayrollRunComparisonSignal.watch;
    return PayrollRunComparisonSignal.stable;
  }
}

class PayrollRunComparisonCostCenterLine {
  final String id;
  final String label;
  final int currentEmployeeCount;
  final int baselineEmployeeCount;
  final double currentGrossPayroll;
  final double baselineGrossPayroll;

  const PayrollRunComparisonCostCenterLine({
    required this.id,
    required this.label,
    required this.currentEmployeeCount,
    required this.baselineEmployeeCount,
    required this.currentGrossPayroll,
    required this.baselineGrossPayroll,
  });

  int get employeeDelta => currentEmployeeCount - baselineEmployeeCount;

  double get grossDelta => currentGrossPayroll - baselineGrossPayroll;

  double get grossPercentChange {
    if (baselineGrossPayroll == 0) {
      return currentGrossPayroll == 0 ? 0 : 1;
    }
    return grossDelta / baselineGrossPayroll;
  }

  PayrollRunComparisonSignal get signal {
    final change = grossPercentChange.abs();
    if (employeeDelta.abs() > 0 || change >= 0.1) {
      return PayrollRunComparisonSignal.review;
    }
    if (change >= 0.02) return PayrollRunComparisonSignal.watch;
    return PayrollRunComparisonSignal.stable;
  }
}

class PayrollRunComparisonSummary {
  final String periodLabel;
  final String baselinePeriodLabel;
  final List<PayrollRunComparisonMetric> metrics;
  final List<PayrollRunComparisonCostCenterLine> costCenters;

  const PayrollRunComparisonSummary({
    required this.periodLabel,
    required this.baselinePeriodLabel,
    required this.metrics,
    required this.costCenters,
  });

  factory PayrollRunComparisonSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollCostCenterSummary costCenters,
    required PayrollRunComparisonBaseline baseline,
  }) {
    final baselineCostCentersById = {
      for (final line in baseline.costCenters) line.id: line,
    };
    final currentCostCentersById = {
      for (final line in costCenters.lines) line.id: line,
    };
    final allCostCenterIds = {
      ...baselineCostCentersById.keys,
      ...currentCostCentersById.keys,
    };

    final costCenterLines =
        allCostCenterIds.map((id) {
            final current = currentCostCentersById[id];
            final previous = baselineCostCentersById[id];
            return PayrollRunComparisonCostCenterLine(
              id: id,
              label: current?.label ?? previous?.label ?? id,
              currentEmployeeCount: current?.employeeCount ?? 0,
              baselineEmployeeCount: previous?.employeeCount ?? 0,
              currentGrossPayroll: current?.grossPayroll ?? 0,
              baselineGrossPayroll: previous?.grossPayroll ?? 0,
            );
          }).toList()
          ..sort((left, right) {
            final signal = right.signal.index.compareTo(left.signal.index);
            if (signal != 0) return signal;
            return right.grossDelta.abs().compareTo(left.grossDelta.abs());
          });

    return PayrollRunComparisonSummary(
      periodLabel: dashboard.periodLabel,
      baselinePeriodLabel: baseline.periodLabel,
      metrics: [
        PayrollRunComparisonMetric(
          id: 'headcount',
          label: 'Headcount',
          currentValue: dashboard.employeeCount.toDouble(),
          baselineValue: baseline.employeeCount.toDouble(),
          type: PayrollRunComparisonMetricType.count,
        ),
        PayrollRunComparisonMetric(
          id: 'gross-payroll',
          label: 'Gross payroll',
          currentValue: dashboard.grossPayroll,
          baselineValue: baseline.grossPayroll,
          type: PayrollRunComparisonMetricType.currency,
        ),
        PayrollRunComparisonMetric(
          id: 'net-payroll',
          label: 'Net payroll',
          currentValue: dashboard.netPayroll,
          baselineValue: baseline.netPayroll,
          type: PayrollRunComparisonMetricType.currency,
        ),
        PayrollRunComparisonMetric(
          id: 'deductions',
          label: 'Deductions',
          currentValue: dashboard.deductions,
          baselineValue: baseline.deductions,
          type: PayrollRunComparisonMetricType.currency,
        ),
        PayrollRunComparisonMetric(
          id: 'adjustments',
          label: 'Approved adjustments',
          currentValue: dashboard.approvedAdjustmentTotal,
          baselineValue: baseline.approvedAdjustmentTotal,
          type: PayrollRunComparisonMetricType.currency,
        ),
      ],
      costCenters: costCenterLines,
    );
  }

  int get reviewCount {
    return [
      ...metrics.map((metric) => metric.signal),
      ...costCenters.map((line) => line.signal),
    ].where((signal) => signal == PayrollRunComparisonSignal.review).length;
  }

  int get watchCount {
    return [
      ...metrics.map((metric) => metric.signal),
      ...costCenters.map((line) => line.signal),
    ].where((signal) => signal == PayrollRunComparisonSignal.watch).length;
  }

  PayrollRunComparisonSignal get signal {
    if (reviewCount > 0) return PayrollRunComparisonSignal.review;
    if (watchCount > 0) return PayrollRunComparisonSignal.watch;
    return PayrollRunComparisonSignal.stable;
  }

  String get nextAction {
    PayrollRunComparisonMetric? reviewMetric;
    for (final metric in metrics) {
      if (metric.signal == PayrollRunComparisonSignal.review) {
        reviewMetric = metric;
        break;
      }
    }
    if (reviewMetric != null) {
      return 'Review ${reviewMetric.label.toLowerCase()} change before close sign-off.';
    }

    PayrollRunComparisonCostCenterLine? reviewCostCenter;
    for (final line in costCenters) {
      if (line.signal == PayrollRunComparisonSignal.review) {
        reviewCostCenter = line;
        break;
      }
    }
    if (reviewCostCenter != null) {
      return 'Review ${reviewCostCenter.label} cost center movement.';
    }

    if (watchCount > 0) {
      return '$watchCount payroll comparison signals need monitoring.';
    }
    return 'Payroll run is aligned with the prior period.';
  }
}
