import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';

enum PayrollJournalLineType {
  debit('Debit'),
  credit('Credit');

  final String label;

  const PayrollJournalLineType(this.label);
}

enum PayrollJournalPostingStatus {
  blocked('Blocked'),
  ready('Ready'),
  posted('Posted');

  final String label;

  const PayrollJournalPostingStatus(this.label);
}

class PayrollJournalLine {
  final String id;
  final PayrollJournalLineType type;
  final String accountCode;
  final String accountName;
  final String memo;
  final double amount;

  const PayrollJournalLine({
    required this.id,
    required this.type,
    required this.accountCode,
    required this.accountName,
    required this.memo,
    required this.amount,
  });

  double get debit => type == PayrollJournalLineType.debit ? amount : 0;

  double get credit => type == PayrollJournalLineType.credit ? amount : 0;
}

class PayrollJournalPostingSummary {
  final String journalId;
  final String periodLabel;
  final DateTime postingDate;
  final List<PayrollJournalLine> lines;
  final List<String> blockers;
  final bool isPosted;

  const PayrollJournalPostingSummary({
    required this.journalId,
    required this.periodLabel,
    required this.postingDate,
    required this.lines,
    required this.blockers,
    required this.isPosted,
  });

  factory PayrollJournalPostingSummary.fromPayrollRun({
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required Set<String> postedJournalIds,
  }) {
    final journalId = paymentBatch.batchId.replaceFirst('PB-', 'JE-');
    final deductionAmount = paymentBatch.lines.fold<double>(
      0,
      (total, line) => total + line.deductionAmount,
    );
    final blockers = <String>[
      if (!paymentBatch.reconciliationReviewed)
        'Payroll reconciliation is not reviewed',
      if (!paymentBatch.isRunLocked) 'Payroll run is not locked',
      if (paymentBatch.pendingCount > 0)
        '${paymentBatch.pendingCount} payment releases pending',
      if (payslipPackage.pendingCount > 0)
        '${payslipPackage.pendingCount} payslips unpublished',
      if (liabilities.pendingCount > 0)
        '${liabilities.pendingCount} liability remittances pending',
      if (paymentBatch.lines.isEmpty) 'No payroll lines available',
    ];

    return PayrollJournalPostingSummary(
      journalId: journalId,
      periodLabel: paymentBatch.periodLabel,
      postingDate: paymentBatch.payDate,
      lines: [
        PayrollJournalLine(
          id: '$journalId-EXP',
          type: PayrollJournalLineType.debit,
          accountCode: '6100',
          accountName: 'Salaries and wages expense',
          memo: '${paymentBatch.periodLabel} gross payroll cost',
          amount: paymentBatch.totalGross,
        ),
        PayrollJournalLine(
          id: '$journalId-CASH',
          type: PayrollJournalLineType.credit,
          accountCode: '1015',
          accountName: 'Payroll cash clearing',
          memo: 'Released employee net payroll',
          amount: paymentBatch.totalNet,
        ),
        PayrollJournalLine(
          id: '$journalId-LIAB',
          type: PayrollJournalLineType.credit,
          accountCode: '2205',
          accountName: 'Payroll withholding liabilities',
          memo: 'Tax, benefit, and retirement deductions',
          amount: deductionAmount,
        ),
      ],
      blockers: blockers,
      isPosted: postedJournalIds.contains(journalId),
    );
  }

  bool get hasBlockers => blockers.isNotEmpty;

  double get totalDebits => lines.fold(0, (total, line) => total + line.debit);

  double get totalCredits =>
      lines.fold(0, (total, line) => total + line.credit);

  double get balanceDelta => totalDebits - totalCredits;

  double get balanceVariance => balanceDelta.abs();

  bool get isBalanced => balanceVariance <= 0.01;

  PayrollJournalPostingStatus get status {
    if (hasBlockers || !isBalanced) return PayrollJournalPostingStatus.blocked;
    if (isPosted) return PayrollJournalPostingStatus.posted;
    return PayrollJournalPostingStatus.ready;
  }

  bool get canPost => !isPosted && !hasBlockers && isBalanced;

  String get nextAction {
    if (hasBlockers) {
      return 'Resolve ${blockers.length} journal posting blockers.';
    }
    if (!isBalanced) {
      return 'Balance payroll journal debits and credits before posting.';
    }
    if (isPosted) {
      return 'Payroll journal is posted to finance.';
    }
    return 'Post balanced payroll journal to finance.';
  }
}
