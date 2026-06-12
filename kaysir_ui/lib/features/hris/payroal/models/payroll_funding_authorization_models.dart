import 'payroll_cost_center_budget_models.dart';
import 'payroll_funding_models.dart';
import 'payroll_payment_batch_models.dart';

enum PayrollFundingAuthorizationStatus {
  blocked('Blocked'),
  ready('Ready'),
  authorized('Authorized');

  final String label;

  const PayrollFundingAuthorizationStatus(this.label);
}

class PayrollFundingAuthorizationLine {
  final String accountLabel;
  final int recipientCount;
  final double pendingNet;
  final PayrollFundingAuthorizationRecord? authorization;
  final List<String> blockers;

  const PayrollFundingAuthorizationLine({
    required this.accountLabel,
    required this.recipientCount,
    required this.pendingNet,
    required this.authorization,
    required this.blockers,
  });

  bool get isAuthorized => authorization?.isComplete == true;

  bool get hasBlockers => blockers.isNotEmpty;

  bool get canAuthorize => !isAuthorized && !hasBlockers && pendingNet > 0;

  PayrollFundingAuthorizationStatus get status {
    if (isAuthorized || pendingNet <= 0.01) {
      return PayrollFundingAuthorizationStatus.authorized;
    }
    if (hasBlockers) return PayrollFundingAuthorizationStatus.blocked;
    return PayrollFundingAuthorizationStatus.ready;
  }
}

class PayrollFundingAuthorizationRecord {
  final String accountLabel;
  final String authorizedBy;
  final DateTime authorizedAt;
  final String referenceCode;
  final String notes;

  const PayrollFundingAuthorizationRecord({
    required this.accountLabel,
    required this.authorizedBy,
    required this.authorizedAt,
    required this.referenceCode,
    required this.notes,
  });

  bool get isComplete {
    return accountLabel.trim().isNotEmpty &&
        authorizedBy.trim().isNotEmpty &&
        referenceCode.trim().isNotEmpty &&
        notes.trim().length >= 12;
  }
}

class PayrollFundingAuthorizationDraft {
  final String accountLabel;
  final String authorizedBy;
  final DateTime authorizedAt;
  final String referenceCode;
  final String notes;

  const PayrollFundingAuthorizationDraft({
    required this.accountLabel,
    required this.authorizedBy,
    required this.authorizedAt,
    required this.referenceCode,
    required this.notes,
  });

  factory PayrollFundingAuthorizationDraft.empty(DateTime authorizedAt) {
    return PayrollFundingAuthorizationDraft(
      accountLabel: '',
      authorizedBy: 'Payroll Controller',
      authorizedAt: authorizedAt,
      referenceCode: '',
      notes: 'Funding release reviewed against payroll close controls.',
    );
  }

  factory PayrollFundingAuthorizationDraft.forAccount({
    required String accountLabel,
    required DateTime authorizedAt,
  }) {
    return PayrollFundingAuthorizationDraft(
      accountLabel: accountLabel,
      authorizedBy: 'Payroll Controller',
      authorizedAt: authorizedAt,
      referenceCode: 'AUTH-${accountLabel.hashCode.abs()}',
      notes: 'Funding release reviewed against payroll close controls.',
    );
  }

  PayrollFundingAuthorizationDraft copyWith({
    String? accountLabel,
    String? authorizedBy,
    DateTime? authorizedAt,
    String? referenceCode,
    String? notes,
  }) {
    return PayrollFundingAuthorizationDraft(
      accountLabel: accountLabel ?? this.accountLabel,
      authorizedBy: authorizedBy ?? this.authorizedBy,
      authorizedAt: authorizedAt ?? this.authorizedAt,
      referenceCode: referenceCode ?? this.referenceCode,
      notes: notes ?? this.notes,
    );
  }

  List<String> get validationErrors {
    return [
      if (accountLabel.trim().isEmpty) 'Select a funding account',
      if (authorizedBy.trim().isEmpty) 'Enter an authorizer',
      if (referenceCode.trim().isEmpty) 'Enter an authorization reference',
      if (notes.trim().length < 12) 'Enter authorization notes',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  PayrollFundingAuthorizationRecord toRecord() {
    return PayrollFundingAuthorizationRecord(
      accountLabel: accountLabel.trim(),
      authorizedBy: authorizedBy.trim(),
      authorizedAt: authorizedAt,
      referenceCode: referenceCode.trim(),
      notes: notes.trim(),
    );
  }
}

class PayrollFundingAuthorizationSummary {
  final String periodLabel;
  final List<PayrollFundingAuthorizationLine> lines;
  final String nextAction;

  const PayrollFundingAuthorizationSummary({
    required this.periodLabel,
    required this.lines,
    required this.nextAction,
  });

  factory PayrollFundingAuthorizationSummary.fromRun({
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollFundingForecastSummary fundingForecast,
    required PayrollCostCenterBudgetSummary costCenterBudgets,
    required Map<String, PayrollFundingAuthorizationRecord>
    authorizationRecords,
  }) {
    final totalsByAccount = <String, _FundingAccountBuilder>{};
    for (final line in paymentBatch.lines.where((line) => !line.isPaid)) {
      final accountLabel =
          line.fundingSource.trim().isEmpty
              ? 'Payroll funding account'
              : line.fundingSource.trim();
      final builder = totalsByAccount.putIfAbsent(
        accountLabel,
        () => _FundingAccountBuilder(accountLabel),
      );
      builder.recipientCount++;
      builder.pendingNet += line.netAmount;
    }
    final employeeFundingShortfall =
        paymentBatch.pendingNet - fundingForecast.availableFunding;

    final lines =
        totalsByAccount.values.map((builder) {
            final blockers = <String>[
              if (!paymentBatch.reconciliationReviewed)
                'Payroll reconciliation is not reviewed',
              if (!paymentBatch.isRunLocked) 'Payroll run is not locked',
              if (costCenterBudgets.pendingApprovalCount > 0)
                '${costCenterBudgets.pendingApprovalCount} cost center approvals pending',
              if (employeeFundingShortfall > 0.01)
                'Employee net-pay funding shortfall remains open',
            ];

            return PayrollFundingAuthorizationLine(
              accountLabel: builder.accountLabel,
              recipientCount: builder.recipientCount,
              pendingNet: builder.pendingNet,
              authorization: authorizationRecords[builder.accountLabel],
              blockers: blockers,
            );
          }).toList()
          ..sort((left, right) => right.pendingNet.compareTo(left.pendingNet));

    final blockedCount = lines.where((line) => line.hasBlockers).length;
    final readyCount = lines.where((line) => line.canAuthorize).length;
    final pendingCount = lines.where((line) => !line.isAuthorized).length;

    final nextAction =
        lines.isEmpty
            ? 'Funding authorization is complete for released payments.'
            : blockedCount > 0
            ? 'Resolve $blockedCount funding authorization blockers.'
            : readyCount > 0
            ? 'Authorize $readyCount payroll funding accounts.'
            : pendingCount > 0
            ? 'Review payroll funding authorization status.'
            : 'All payroll funding accounts are authorized.';

    return PayrollFundingAuthorizationSummary(
      periodLabel: paymentBatch.periodLabel,
      lines: lines,
      nextAction: nextAction,
    );
  }

  int get authorizedCount {
    return lines.where((line) => line.isAuthorized).length;
  }

  int get pendingCount => lines.length - authorizedCount;

  int get readyCount => lines.where((line) => line.canAuthorize).length;

  int get blockedCount => lines.where((line) => line.hasBlockers).length;

  double get pendingNet {
    return lines.fold(0, (total, line) => total + line.pendingNet);
  }

  bool get isAuthorizedForRelease {
    return lines.isEmpty || lines.every((line) => line.isAuthorized);
  }
}

class _FundingAccountBuilder {
  final String accountLabel;
  int recipientCount = 0;
  double pendingNet = 0;

  _FundingAccountBuilder(this.accountLabel);
}
