import 'payroll_detail.dart';
import 'payroll_payment_batch_models.dart';

enum PayrollLiabilityType {
  federalIncomeTax('federal-tax', 'Federal income tax'),
  stateIncomeTax('state-tax', 'State income tax'),
  socialSecurity('social-security', 'Social Security'),
  medicare('medicare', 'Medicare'),
  retirement401k('retirement-401k', '401(k) contribution'),
  healthInsurance('health-insurance', 'Health insurance premium');

  final String id;
  final String label;

  const PayrollLiabilityType(this.id, this.label);
}

enum PayrollLiabilityRemittanceStatus {
  blocked('Blocked'),
  ready('Ready'),
  remitting('Remitting'),
  remitted('Remitted');

  final String label;

  const PayrollLiabilityRemittanceStatus(this.label);
}

class PayrollLiabilityProfile {
  final PayrollLiabilityType type;
  final String recipientName;
  final String methodLabel;
  final String referenceCode;
  final int dueInDays;

  const PayrollLiabilityProfile({
    required this.type,
    required this.recipientName,
    required this.methodLabel,
    required this.referenceCode,
    required this.dueInDays,
  });

  bool get hasRecipient => recipientName.trim().isNotEmpty;
}

class PayrollLiabilityLine {
  final String id;
  final PayrollLiabilityType type;
  final String label;
  final String recipientName;
  final String methodLabel;
  final String referenceCode;
  final DateTime dueDate;
  final double amount;
  final bool isRemitted;
  final List<String> blockers;

  const PayrollLiabilityLine({
    required this.id,
    required this.type,
    required this.label,
    required this.recipientName,
    required this.methodLabel,
    required this.referenceCode,
    required this.dueDate,
    required this.amount,
    required this.isRemitted,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;

  bool get canRemit => !isRemitted && !hasBlockers;

  String get statusLabel {
    if (isRemitted) return 'Remitted';
    if (hasBlockers) return 'Blocked';
    return 'Ready';
  }
}

class PayrollLiabilitySummary {
  final String remittanceId;
  final String periodLabel;
  final DateTime payDate;
  final bool paymentsReleased;
  final List<PayrollLiabilityLine> lines;

  const PayrollLiabilitySummary({
    required this.remittanceId,
    required this.periodLabel,
    required this.payDate,
    required this.paymentsReleased,
    required this.lines,
  });

  factory PayrollLiabilitySummary.fromPaymentBatch({
    required PayrollPaymentBatchSummary paymentBatch,
    required List<PayrollLiabilityProfile> profiles,
    required Set<String> remittedLiabilityIds,
  }) {
    final profileByType = {
      for (final profile in profiles) profile.type: profile,
    };
    final amounts = _liabilityAmounts(paymentBatch.lines);
    final paymentsReleased = paymentBatch.pendingCount == 0;

    final lines =
        PayrollLiabilityType.values.map((type) {
          final profile = profileByType[type];
          final amount = amounts[type] ?? 0;
          final blockers = <String>[
            if (!paymentsReleased) 'Payment batch is not fully released',
            if (amount <= 0) 'No liability amount calculated',
            if (profile == null || !profile.hasRecipient)
              'Missing remittance recipient',
          ];

          return PayrollLiabilityLine(
            id: type.id,
            type: type,
            label: type.label,
            recipientName: profile?.recipientName ?? 'Not configured',
            methodLabel: profile?.methodLabel ?? 'Manual remittance',
            referenceCode:
                profile?.referenceCode ??
                'LIAB-${paymentBatch.payDate.year}${paymentBatch.payDate.month.toString().padLeft(2, '0')}-${type.id}',
            dueDate: paymentBatch.payDate.add(
              Duration(days: profile?.dueInDays ?? 5),
            ),
            amount: amount,
            isRemitted:
                paymentsReleased && remittedLiabilityIds.contains(type.id),
            blockers: blockers,
          );
        }).toList();

    return PayrollLiabilitySummary(
      remittanceId: paymentBatch.batchId.replaceFirst('PB-', 'LR-'),
      periodLabel: paymentBatch.periodLabel,
      payDate: paymentBatch.payDate,
      paymentsReleased: paymentsReleased,
      lines: lines,
    );
  }

  int get remittedCount => lines.where((line) => line.isRemitted).length;

  int get pendingCount => lines.length - remittedCount;

  int get readyCount => lines.where((line) => line.canRemit).length;

  int get blockedCount =>
      lines.where((line) => !line.isRemitted && line.hasBlockers).length;

  double get totalAmount => lines.fold(0, (total, line) => total + line.amount);

  double get remittedAmount => lines
      .where((line) => line.isRemitted)
      .fold(0, (total, line) => total + line.amount);

  double get pendingAmount => totalAmount - remittedAmount;

  PayrollLiabilityRemittanceStatus get status {
    if (pendingCount == 0) return PayrollLiabilityRemittanceStatus.remitted;
    if (blockedCount > 0) return PayrollLiabilityRemittanceStatus.blocked;
    if (remittedCount > 0) return PayrollLiabilityRemittanceStatus.remitting;
    return PayrollLiabilityRemittanceStatus.ready;
  }

  bool get canRemit => readyCount > 0 && blockedCount == 0;

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount liability remittance blockers.';
    }
    if (pendingCount > 0) {
      return 'Remit $pendingCount payroll liabilities before closing the period.';
    }
    return 'Payroll liabilities are fully remitted.';
  }

  PayrollLiabilityLine? get nextDueLine {
    final pendingLines =
        lines.where((line) => !line.isRemitted).toList()
          ..sort((left, right) => left.dueDate.compareTo(right.dueDate));
    if (pendingLines.isEmpty) return null;
    return pendingLines.first;
  }
}

Map<PayrollLiabilityType, double> _liabilityAmounts(
  List<PayrollPaymentBatchLine> lines,
) {
  final amounts = {for (final type in PayrollLiabilityType.values) type: 0.0};

  for (final line in lines) {
    final baseSalary = line.grossAmount - line.adjustmentAmount;
    final details = PayrollDetails.fromSalary(baseSalary);

    amounts[PayrollLiabilityType.federalIncomeTax] =
        amounts[PayrollLiabilityType.federalIncomeTax]! + details.federalTax;
    amounts[PayrollLiabilityType.stateIncomeTax] =
        amounts[PayrollLiabilityType.stateIncomeTax]! + details.stateTax;
    amounts[PayrollLiabilityType.socialSecurity] =
        amounts[PayrollLiabilityType.socialSecurity]! + details.socialSecurity;
    amounts[PayrollLiabilityType.medicare] =
        amounts[PayrollLiabilityType.medicare]! + details.medicare;
    amounts[PayrollLiabilityType.retirement401k] =
        amounts[PayrollLiabilityType.retirement401k]! + details.retirement401k;
    amounts[PayrollLiabilityType.healthInsurance] =
        amounts[PayrollLiabilityType.healthInsurance]! +
        details.healthInsurance;
  }

  return amounts;
}
