import 'bank_reconciliation.dart';

enum BankReconciliationResolutionType {
  bankFee,
  bankInterest,
  statementOnlyReceipt,
  statementOnlyPayment,
  depositInTransit,
  outstandingPayment,
}

extension BankReconciliationResolutionTypeLabel
    on BankReconciliationResolutionType {
  String get label {
    switch (this) {
      case BankReconciliationResolutionType.bankFee:
        return 'Bank fee';
      case BankReconciliationResolutionType.bankInterest:
        return 'Bank interest';
      case BankReconciliationResolutionType.statementOnlyReceipt:
        return 'Statement receipt';
      case BankReconciliationResolutionType.statementOnlyPayment:
        return 'Statement payment';
      case BankReconciliationResolutionType.depositInTransit:
        return 'Deposit in transit';
      case BankReconciliationResolutionType.outstandingPayment:
        return 'Outstanding payment';
    }
  }
}

class BankReconciliationResolutionAction {
  final BankReconciliationResolutionType type;
  final String title;
  final String description;
  final String suggestedAction;
  final double amount;
  final DateTime date;
  final String reference;
  final bool suggestsJournal;

  const BankReconciliationResolutionAction({
    required this.type,
    required this.title,
    required this.description,
    required this.suggestedAction,
    required this.amount,
    required this.date,
    required this.reference,
    required this.suggestsJournal,
  });
}

class BankReconciliationResolutionPlan {
  final List<BankReconciliationResolutionAction> actions;

  const BankReconciliationResolutionPlan({required this.actions});

  bool get hasActions => actions.isNotEmpty;

  int get suggestedJournalCount {
    return actions.where((action) => action.suggestsJournal).length;
  }

  int get timingDifferenceCount {
    return actions.where((action) => !action.suggestsJournal).length;
  }
}

extension BankStatementLineResolutionItem on BankStatementLine {
  String get resolutionReference => reference ?? id;
}

extension BankLedgerLineResolutionItem on BankLedgerReconciliationLine {
  String get resolutionReference =>
      reference.isEmpty ? transactionId : reference;
}
