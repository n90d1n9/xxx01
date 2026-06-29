import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_reconciliation_models.dart';

enum PayrollFundingStatus {
  shortfall('Shortfall'),
  watch('Watch'),
  ready('Ready'),
  settled('Settled');

  final String label;

  const PayrollFundingStatus(this.label);
}

class PayrollFundingObligation {
  final String id;
  final String title;
  final String owner;
  final DateTime dueDate;
  final double amount;
  final double settledAmount;
  final String detail;

  const PayrollFundingObligation({
    required this.id,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.amount,
    required this.settledAmount,
    required this.detail,
  });

  double get pendingAmount {
    final pending = amount - settledAmount;
    return pending > 0 ? pending : 0;
  }

  bool get isSettled => pendingAmount <= 0.01;

  double get progress {
    if (amount <= 0) return 1;
    return (settledAmount / amount).clamp(0, 1).toDouble();
  }
}

class PayrollFundingForecastSummary {
  final String periodLabel;
  final String accountLabel;
  final double availableFunding;
  final double totalRequiredFunding;
  final double shortfall;
  final double buffer;
  final double utilizationRatio;
  final PayrollFundingStatus status;
  final String nextAction;
  final List<PayrollFundingObligation> obligations;

  const PayrollFundingForecastSummary({
    required this.periodLabel,
    required this.accountLabel,
    required this.availableFunding,
    required this.totalRequiredFunding,
    required this.shortfall,
    required this.buffer,
    required this.utilizationRatio,
    required this.status,
    required this.nextAction,
    required this.obligations,
  });

  factory PayrollFundingForecastSummary.fromRun({
    required PayrollReconciliationSummary reconciliation,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollLiabilitySummary liabilities,
  }) {
    final availableFunding = reconciliation.baseline.bankFundingBalance;
    final obligations = [
      PayrollFundingObligation(
        id: 'employee-net-pay',
        title: 'Employee net pay',
        owner: 'Finance Ops',
        dueDate: paymentBatch.payDate,
        amount: paymentBatch.totalNet,
        settledAmount: paymentBatch.releasedNet,
        detail:
            '${paymentBatch.paidCount}/${paymentBatch.lines.length} employee payments released',
      ),
      PayrollFundingObligation(
        id: 'payroll-liabilities',
        title: 'Tax and benefit liabilities',
        owner: 'Payroll Tax',
        dueDate: liabilities.nextDueLine?.dueDate ?? liabilities.payDate,
        amount: liabilities.totalAmount,
        settledAmount: liabilities.remittedAmount,
        detail:
            '${liabilities.remittedCount}/${liabilities.lines.length} remittances complete',
      ),
    ];
    final totalRequiredFunding = obligations.fold<double>(
      0,
      (total, obligation) => total + obligation.pendingAmount,
    );
    final gap = totalRequiredFunding - availableFunding;
    final shortfall = gap > 0 ? gap : 0.0;
    final buffer = gap < 0 ? gap.abs() : 0.0;
    final utilizationRatio =
        availableFunding <= 0 ? 1.0 : totalRequiredFunding / availableFunding;
    final status = _statusFor(
      totalRequiredFunding: totalRequiredFunding,
      shortfall: shortfall,
      buffer: buffer,
    );

    return PayrollFundingForecastSummary(
      periodLabel: paymentBatch.periodLabel,
      accountLabel: _primaryFundingAccount(paymentBatch),
      availableFunding: availableFunding,
      totalRequiredFunding: totalRequiredFunding,
      shortfall: shortfall,
      buffer: buffer,
      utilizationRatio: utilizationRatio.clamp(0, 1).toDouble(),
      status: status,
      nextAction: _nextAction(status, buffer),
      obligations: obligations,
    );
  }

  int get settledObligationCount {
    return obligations.where((obligation) => obligation.isSettled).length;
  }

  int get pendingObligationCount => obligations.length - settledObligationCount;
}

PayrollFundingStatus _statusFor({
  required double totalRequiredFunding,
  required double shortfall,
  required double buffer,
}) {
  if (totalRequiredFunding <= 0.01) return PayrollFundingStatus.settled;
  if (shortfall > 0.01) return PayrollFundingStatus.shortfall;
  if (buffer < totalRequiredFunding * 0.05) return PayrollFundingStatus.watch;
  return PayrollFundingStatus.ready;
}

String _nextAction(PayrollFundingStatus status, double buffer) {
  return switch (status) {
    PayrollFundingStatus.shortfall =>
      'Top up payroll funding before release and remittance.',
    PayrollFundingStatus.watch =>
      'Keep payroll funding buffer under finance review.',
    PayrollFundingStatus.ready =>
      'Payroll funding is sufficient with ${buffer.toStringAsFixed(0)} buffer.',
    PayrollFundingStatus.settled =>
      'Payroll cash obligations are settled for this run.',
  };
}

String _primaryFundingAccount(PayrollPaymentBatchSummary paymentBatch) {
  final accounts =
      paymentBatch.lines
          .map((line) => line.fundingSource.trim())
          .where((account) => account.isNotEmpty)
          .toSet()
          .toList();
  if (accounts.length == 1) return accounts.first;
  if (accounts.isEmpty) return 'Payroll funding account';
  return '${accounts.length} payroll funding accounts';
}
