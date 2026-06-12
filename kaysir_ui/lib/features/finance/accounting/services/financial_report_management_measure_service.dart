import '../models/financial_report_management_measure.dart';
import '../models/financial_report_pack.dart';

class FinancialReportManagementMeasureService {
  const FinancialReportManagementMeasureService();

  List<FinancialReportManagementMeasure> effectiveMeasures(
    List<FinancialReportManagementMeasure> measures,
  ) {
    if (measures.isEmpty) {
      return const [
        FinancialReportManagementMeasure.defaultOperatingPerformance(),
      ];
    }
    return List.unmodifiable(measures);
  }

  List<FinancialReportManagementMeasureReconciliation> reconcileAll({
    required FinancialReportStatement profitOrLoss,
    required List<FinancialReportManagementMeasure> measures,
  }) {
    return [
      for (final measure in effectiveMeasures(measures))
        reconcile(profitOrLoss: profitOrLoss, measure: measure),
    ];
  }

  FinancialReportManagementMeasureReconciliation reconcile({
    required FinancialReportStatement profitOrLoss,
    required FinancialReportManagementMeasure measure,
  }) {
    final subtotal = _amountFor(profitOrLoss, measure.closestSubtotalLabel);
    final comparativeSubtotal = _comparativeAmountFor(
      profitOrLoss,
      measure.closestSubtotalLabel,
    );
    final adjustmentTotal = _adjustmentTotal(measure.adjustments);
    final comparativeAdjustmentTotal =
        _hasComparativeAdjustment(measure.adjustments)
            ? _comparativeAdjustmentTotal(measure.adjustments)
            : null;
    final amount =
        measure.amountOverride == null
            ? subtotal + adjustmentTotal
            : measure.amountOverride!;
    final comparativeAmount =
        measure.comparativeAmountOverride ??
        (comparativeSubtotal == null
            ? null
            : comparativeSubtotal + (comparativeAdjustmentTotal ?? 0));

    return FinancialReportManagementMeasureReconciliation(
      measure: measure,
      subtotalAmount: subtotal,
      comparativeSubtotalAmount: comparativeSubtotal,
      measureAmount: amount,
      comparativeMeasureAmount: comparativeAmount,
      adjustmentTotal: adjustmentTotal,
      comparativeAdjustmentTotal: comparativeAdjustmentTotal,
    );
  }

  int approvedCount(
    Iterable<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    return reconciliations
        .where((reconciliation) => reconciliation.isApproved)
        .length;
  }

  int openVarianceCount(
    Iterable<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    return reconciliations
        .where((reconciliation) => reconciliation.hasOpenVariance)
        .length;
  }

  int pendingApprovalCount(
    Iterable<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    return reconciliations
        .where((reconciliation) => !reconciliation.isApproved)
        .length;
  }

  bool releaseReady(
    Iterable<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    final items = reconciliations.toList(growable: false);
    return items.isNotEmpty &&
        items.every(
          (reconciliation) =>
              reconciliation.isApproved && !reconciliation.hasOpenVariance,
        );
  }

  String? releaseLockedReason(
    Iterable<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    final items = reconciliations.toList(growable: false);
    if (items.isEmpty) {
      return 'Document and reconcile UKTM management measures before distribution.';
    }

    final openVariances = openVarianceCount(items);
    if (openVariances > 0) {
      return 'Resolve $openVariances UKTM management measure variance(s) before distribution.';
    }

    final pendingApprovals = pendingApprovalCount(items);
    if (pendingApprovals > 0) {
      return 'Approve $pendingApprovals UKTM management measure(s) before distribution.';
    }

    return null;
  }

  double _amountFor(FinancialReportStatement statement, String label) {
    for (final line in statement.lines) {
      if (line.label == label) {
        return line.amount ?? 0;
      }
    }
    return 0;
  }

  double? _comparativeAmountFor(
    FinancialReportStatement statement,
    String label,
  ) {
    for (final line in statement.lines) {
      if (line.label == label) {
        return line.comparativeAmount;
      }
    }
    return null;
  }

  double _adjustmentTotal(
    List<FinancialReportManagementMeasureAdjustment> adjustments,
  ) {
    return adjustments.fold(0.0, (sum, adjustment) => sum + adjustment.amount);
  }

  double _comparativeAdjustmentTotal(
    List<FinancialReportManagementMeasureAdjustment> adjustments,
  ) {
    return adjustments.fold(
      0.0,
      (sum, adjustment) => sum + (adjustment.comparativeAmount ?? 0),
    );
  }

  bool _hasComparativeAdjustment(
    List<FinancialReportManagementMeasureAdjustment> adjustments,
  ) {
    return adjustments.any(
      (adjustment) => adjustment.comparativeAmount != null,
    );
  }
}
