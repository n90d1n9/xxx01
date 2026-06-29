import 'payroll_run_models.dart';

enum PayrollReconciliationStatus {
  blocked('Blocked'),
  watch('Watch'),
  ready('Ready');

  final String label;

  const PayrollReconciliationStatus(this.label);
}

enum PayrollVarianceStatus {
  stable('Stable'),
  watch('Watch'),
  review('Review');

  final String label;

  const PayrollVarianceStatus(this.label);
}

class PayrollReconciliationBaseline {
  final String periodLabel;
  final double grossPayroll;
  final double netPayroll;
  final double deductions;
  final double bankFundingBalance;
  final int employeeCount;

  const PayrollReconciliationBaseline({
    required this.periodLabel,
    required this.grossPayroll,
    required this.netPayroll,
    required this.deductions,
    required this.bankFundingBalance,
    required this.employeeCount,
  });
}

class PayrollVarianceLine {
  final String id;
  final String label;
  final double currentAmount;
  final double baselineAmount;
  final double tolerancePercent;

  const PayrollVarianceLine({
    required this.id,
    required this.label,
    required this.currentAmount,
    required this.baselineAmount,
    required this.tolerancePercent,
  });

  double get delta => currentAmount - baselineAmount;

  double get absoluteDelta => delta.abs();

  double get percentChange {
    if (baselineAmount == 0) {
      return currentAmount == 0 ? 0 : 100;
    }
    return (delta / baselineAmount) * 100;
  }

  PayrollVarianceStatus get status {
    final absolutePercent = percentChange.abs();
    if (absolutePercent <= tolerancePercent) {
      return PayrollVarianceStatus.stable;
    }
    if (absolutePercent <= tolerancePercent * 2) {
      return PayrollVarianceStatus.watch;
    }
    return PayrollVarianceStatus.review;
  }

  bool get requiresAttention => status != PayrollVarianceStatus.stable;
}

class PayrollReconciliationSummary {
  final String periodLabel;
  final String baselinePeriodLabel;
  final PayrollReconciliationBaseline baseline;
  final List<PayrollVarianceLine> varianceLines;
  final int openExceptionCount;
  final int pendingAdjustmentCount;
  final int pendingPaymentCount;
  final bool isReviewed;

  const PayrollReconciliationSummary({
    required this.periodLabel,
    required this.baselinePeriodLabel,
    required this.baseline,
    required this.varianceLines,
    required this.openExceptionCount,
    required this.pendingAdjustmentCount,
    required this.pendingPaymentCount,
    required this.isReviewed,
  });

  factory PayrollReconciliationSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollReconciliationBaseline baseline,
    required String? reviewedSignature,
  }) {
    final lines = [
      PayrollVarianceLine(
        id: 'gross',
        label: 'Gross payroll',
        currentAmount: dashboard.grossPayroll,
        baselineAmount: baseline.grossPayroll,
        tolerancePercent: 5,
      ),
      PayrollVarianceLine(
        id: 'net',
        label: 'Net payroll',
        currentAmount: dashboard.netPayroll,
        baselineAmount: baseline.netPayroll,
        tolerancePercent: 5,
      ),
      PayrollVarianceLine(
        id: 'deductions',
        label: 'Deductions',
        currentAmount: dashboard.deductions,
        baselineAmount: baseline.deductions,
        tolerancePercent: 5,
      ),
    ];
    final provisional = PayrollReconciliationSummary(
      periodLabel: dashboard.periodLabel,
      baselinePeriodLabel: baseline.periodLabel,
      baseline: baseline,
      varianceLines: lines,
      openExceptionCount: dashboard.openExceptionCount,
      pendingAdjustmentCount: dashboard.pendingAdjustmentCount,
      pendingPaymentCount: dashboard.pendingPaymentCount,
      isReviewed: false,
    );

    return PayrollReconciliationSummary(
      periodLabel: provisional.periodLabel,
      baselinePeriodLabel: provisional.baselinePeriodLabel,
      baseline: provisional.baseline,
      varianceLines: provisional.varianceLines,
      openExceptionCount: provisional.openExceptionCount,
      pendingAdjustmentCount: provisional.pendingAdjustmentCount,
      pendingPaymentCount: provisional.pendingPaymentCount,
      isReviewed:
          provisional.canReview &&
          reviewedSignature == provisional.reviewSignature,
    );
  }

  double get fundingGap {
    final gap = currentNetPayroll - baseline.bankFundingBalance;
    return gap > 0 ? gap : 0;
  }

  double get fundingBuffer {
    final buffer = baseline.bankFundingBalance - currentNetPayroll;
    return buffer > 0 ? buffer : 0;
  }

  double get currentNetPayroll {
    return varianceLines.firstWhere((line) => line.id == 'net').currentAmount;
  }

  int get blockerCount => openExceptionCount + pendingAdjustmentCount;

  int get materialVarianceCount {
    return varianceLines.where((line) => line.requiresAttention).length;
  }

  bool get hasReviewVariance {
    return varianceLines.any(
      (line) => line.status == PayrollVarianceStatus.review,
    );
  }

  bool get hasWatchVariance {
    return varianceLines.any(
      (line) => line.status == PayrollVarianceStatus.watch,
    );
  }

  PayrollVarianceLine get largestVariance {
    final sorted = [...varianceLines]
      ..sort((a, b) => b.absoluteDelta.compareTo(a.absoluteDelta));
    return sorted.first;
  }

  bool get canReview {
    return blockerCount == 0 && fundingGap == 0 && !hasReviewVariance;
  }

  String get reviewSignature {
    final lineSignature = varianceLines
        .map(
          (line) =>
              '${line.id}:${line.currentAmount.toStringAsFixed(2)}:${line.baselineAmount.toStringAsFixed(2)}:${line.status.name}',
        )
        .join('|');
    return '$periodLabel:$lineSignature:$blockerCount:${fundingGap.toStringAsFixed(2)}';
  }

  PayrollReconciliationStatus get status {
    if (blockerCount > 0 || fundingGap > 0 || hasReviewVariance) {
      return PayrollReconciliationStatus.blocked;
    }
    if (hasWatchVariance) return PayrollReconciliationStatus.watch;
    return PayrollReconciliationStatus.ready;
  }

  String get nextAction {
    if (blockerCount > 0) {
      return 'Clear $blockerCount payroll blockers before reconciliation sign-off.';
    }
    if (fundingGap > 0) {
      return 'Fund payroll account before disbursement approval.';
    }
    if (hasReviewVariance) {
      return 'Investigate payroll variance outside tolerance.';
    }
    if (hasWatchVariance) {
      return 'Document payroll variance and collect finance sign-off.';
    }
    return 'Reconciliation is within tolerance.';
  }
}
