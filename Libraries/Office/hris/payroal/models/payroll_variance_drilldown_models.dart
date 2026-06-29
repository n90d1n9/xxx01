import 'payroll_reconciliation_models.dart';
import 'payroll_run_comparison_models.dart';

enum PayrollVarianceDrilldownScope {
  run('Run'),
  costCenter('Cost center');

  final String label;

  const PayrollVarianceDrilldownScope(this.label);
}

class PayrollVarianceDrilldownLine {
  final String id;
  final PayrollVarianceDrilldownScope scope;
  final String title;
  final String owner;
  final String cause;
  final String action;
  final double currentAmount;
  final double baselineAmount;
  final PayrollRunComparisonSignal signal;

  const PayrollVarianceDrilldownLine({
    required this.id,
    required this.scope,
    required this.title,
    required this.owner,
    required this.cause,
    required this.action,
    required this.currentAmount,
    required this.baselineAmount,
    required this.signal,
  });

  double get delta => currentAmount - baselineAmount;

  double get absoluteDelta => delta.abs();

  double get percentChange {
    if (baselineAmount == 0) return currentAmount == 0 ? 0 : 1;
    return delta / baselineAmount;
  }

  bool get needsReview => signal == PayrollRunComparisonSignal.review;
}

class PayrollVarianceDrilldownSummary {
  final String periodLabel;
  final String baselinePeriodLabel;
  final List<PayrollVarianceDrilldownLine> lines;

  const PayrollVarianceDrilldownSummary({
    required this.periodLabel,
    required this.baselinePeriodLabel,
    required this.lines,
  });

  factory PayrollVarianceDrilldownSummary.fromRun({
    required PayrollReconciliationSummary reconciliation,
    required PayrollRunComparisonSummary comparison,
  }) {
    final metricLines = comparison.metrics
        .where((metric) => metric.signal != PayrollRunComparisonSignal.stable)
        .map(
          (metric) => PayrollVarianceDrilldownLine(
            id: 'metric-${metric.id}',
            scope: PayrollVarianceDrilldownScope.run,
            title: metric.label,
            owner: _ownerForMetric(metric.id),
            cause: _causeForMetric(metric),
            action: _actionForSignal(metric.signal, metric.label),
            currentAmount: metric.currentValue,
            baselineAmount: metric.baselineValue,
            signal: metric.signal,
          ),
        );

    final costCenterLines = comparison.costCenters
        .where((line) => line.signal != PayrollRunComparisonSignal.stable)
        .map(
          (line) => PayrollVarianceDrilldownLine(
            id: 'cost-center-${line.id}',
            scope: PayrollVarianceDrilldownScope.costCenter,
            title: line.label,
            owner: 'Finance Partner',
            cause: _causeForCostCenter(line),
            action:
                line.employeeDelta.abs() > 0
                    ? 'Confirm headcount movement with HR operations.'
                    : 'Document gross payroll movement with cost owner.',
            currentAmount: line.currentGrossPayroll,
            baselineAmount: line.baselineGrossPayroll,
            signal: line.signal,
          ),
        );

    final lines = [...metricLines, ...costCenterLines]..sort((left, right) {
      final signal = right.signal.index.compareTo(left.signal.index);
      if (signal != 0) return signal;
      return right.absoluteDelta.compareTo(left.absoluteDelta);
    });

    return PayrollVarianceDrilldownSummary(
      periodLabel: reconciliation.periodLabel,
      baselinePeriodLabel: reconciliation.baselinePeriodLabel,
      lines: lines,
    );
  }

  int get reviewCount =>
      lines
          .where((line) => line.signal == PayrollRunComparisonSignal.review)
          .length;

  int get watchCount =>
      lines
          .where((line) => line.signal == PayrollRunComparisonSignal.watch)
          .length;

  double get totalAbsoluteVariance =>
      lines.fold(0, (total, line) => total + line.absoluteDelta);

  String get nextAction {
    if (reviewCount > 0) {
      return 'Investigate $reviewCount payroll variance drilldowns before sign-off.';
    }
    if (watchCount > 0) {
      return 'Document $watchCount payroll variance drilldowns for finance review.';
    }
    return 'No material payroll variance drilldowns remain.';
  }
}

String _ownerForMetric(String metricId) {
  return switch (metricId) {
    'headcount' => 'HR Operations',
    'gross-payroll' => 'Payroll Manager',
    'net-payroll' => 'Finance Ops',
    'deductions' => 'Payroll Tax',
    'adjustments' => 'Payroll Manager',
    _ => 'Finance Partner',
  };
}

String _causeForMetric(PayrollRunComparisonMetric metric) {
  final direction = metric.delta >= 0 ? 'increase' : 'decrease';
  return '${metric.label} $direction from prior period.';
}

String _causeForCostCenter(PayrollRunComparisonCostCenterLine line) {
  if (line.employeeDelta > 0) {
    return '${line.employeeDelta} employee added since baseline.';
  }
  if (line.employeeDelta < 0) {
    return '${line.employeeDelta.abs()} employee removed since baseline.';
  }
  final direction = line.grossDelta >= 0 ? 'increase' : 'decrease';
  return '${line.label} gross payroll $direction from prior period.';
}

String _actionForSignal(PayrollRunComparisonSignal signal, String label) {
  if (signal == PayrollRunComparisonSignal.review) {
    return 'Investigate ${label.toLowerCase()} movement and attach rationale.';
  }
  return 'Document ${label.toLowerCase()} movement for finance sign-off.';
}
