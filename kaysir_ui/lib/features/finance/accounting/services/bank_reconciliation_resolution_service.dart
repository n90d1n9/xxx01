import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_resolution.dart';

class BankReconciliationResolutionService {
  const BankReconciliationResolutionService();

  BankReconciliationResolutionPlan build(BankReconciliation reconciliation) {
    final actions = <BankReconciliationResolutionAction>[
      for (final line in reconciliation.unmatchedStatementLines)
        _statementAction(line),
      for (final line in reconciliation.unmatchedLedgerLines)
        _ledgerAction(line),
    ];

    return BankReconciliationResolutionPlan(actions: actions);
  }

  BankReconciliationResolutionAction _statementAction(BankStatementLine line) {
    final normalized = _normalize(line.description);
    if (line.amount < 0 &&
        _containsAny(normalized, const [
          'fee',
          'charge',
          'admin',
          'biaya',
          'adm',
        ])) {
      return BankReconciliationResolutionAction(
        type: BankReconciliationResolutionType.bankFee,
        title: 'Post bank fee expense',
        description: line.description,
        suggestedAction:
            'Create an expense journal for bank charges and credit cash/bank.',
        amount: line.amount,
        date: line.date,
        reference: line.resolutionReference,
        suggestsJournal: true,
      );
    }

    if (line.amount > 0 &&
        _containsAny(normalized, const [
          'interest',
          'bunga',
          'jasa giro',
          'jasagiro',
        ])) {
      return BankReconciliationResolutionAction(
        type: BankReconciliationResolutionType.bankInterest,
        title: 'Post bank interest income',
        description: line.description,
        suggestedAction:
            'Create an income journal for bank interest and debit cash/bank.',
        amount: line.amount,
        date: line.date,
        reference: line.resolutionReference,
        suggestsJournal: true,
      );
    }

    if (line.amount >= 0) {
      return BankReconciliationResolutionAction(
        type: BankReconciliationResolutionType.statementOnlyReceipt,
        title: 'Investigate unposted receipt',
        description: line.description,
        suggestedAction:
            'Match to a customer receipt or create a cash receipt journal.',
        amount: line.amount,
        date: line.date,
        reference: line.resolutionReference,
        suggestsJournal: true,
      );
    }

    return BankReconciliationResolutionAction(
      type: BankReconciliationResolutionType.statementOnlyPayment,
      title: 'Investigate unposted payment',
      description: line.description,
      suggestedAction:
          'Match to a supplier payment or create the missing cash payment journal.',
      amount: line.amount,
      date: line.date,
      reference: line.resolutionReference,
      suggestsJournal: true,
    );
  }

  BankReconciliationResolutionAction _ledgerAction(
    BankLedgerReconciliationLine line,
  ) {
    if (line.signedAmount >= 0) {
      return BankReconciliationResolutionAction(
        type: BankReconciliationResolutionType.depositInTransit,
        title: 'Track deposit in transit',
        description: line.description,
        suggestedAction:
            'Confirm the receipt clears on a later bank statement before closing.',
        amount: line.signedAmount,
        date: line.date,
        reference: line.resolutionReference,
        suggestsJournal: false,
      );
    }

    return BankReconciliationResolutionAction(
      type: BankReconciliationResolutionType.outstandingPayment,
      title: 'Track outstanding payment',
      description: line.description,
      suggestedAction:
          'Confirm the payment clears on a later bank statement or investigate stale items.',
      amount: line.signedAmount,
      date: line.date,
      reference: line.resolutionReference,
      suggestsJournal: false,
    );
  }

  bool _containsAny(String value, List<String> tokens) {
    return tokens.any((token) => value.contains(_normalize(token)));
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
