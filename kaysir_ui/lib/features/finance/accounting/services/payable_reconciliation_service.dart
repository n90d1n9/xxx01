import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../models/invoice.dart';
import '../models/payable_reconciliation.dart';

class PayableReconciliationService {
  final double tolerance;

  const PayableReconciliationService({this.tolerance = 0.01});

  PayableReconciliation reconcile({
    required Iterable<Invoice> bills,
    required Iterable<LedgerPosting> postings,
    required AccountingAccount accountsPayable,
  }) {
    final subledgerLines = _subledgerLines(bills);
    final ledgerLines = _ledgerLines(postings, accountsPayable.id);

    return PayableReconciliation(
      subledgerBalance: subledgerLines.fold(
        0,
        (total, line) => total + line.remainingAmount,
      ),
      ledgerBalance: ledgerLines.fold(
        0,
        (total, line) => total + line.balanceImpact,
      ),
      tolerance: tolerance,
      subledgerLines: subledgerLines,
      ledgerLines: ledgerLines,
    );
  }

  List<PayableSubledgerReconciliationLine> _subledgerLines(
    Iterable<Invoice> bills,
  ) {
    final lines = <PayableSubledgerReconciliationLine>[];
    for (final bill in bills) {
      final remainingAmount = bill.remainingAmount;
      if (remainingAmount <= 0) {
        continue;
      }

      lines.add(
        PayableSubledgerReconciliationLine(
          billId: bill.id,
          reference: bill.invoiceNumber ?? bill.id,
          vendorName: bill.vendorName ?? 'Unknown Vendor',
          dueDate: bill.dueDate,
          remainingAmount: remainingAmount,
        ),
      );
    }

    lines.sort(_compareSubledgerLines);
    return lines;
  }

  List<PayableLedgerReconciliationLine> _ledgerLines(
    Iterable<LedgerPosting> postings,
    String accountsPayableAccountId,
  ) {
    final lines = <PayableLedgerReconciliationLine>[];
    for (final posting in postings) {
      for (final line in posting.lines) {
        if (line.accountId != accountsPayableAccountId) {
          continue;
        }
        lines.add(
          PayableLedgerReconciliationLine(
            postingId: posting.id,
            reference: posting.reference,
            description: posting.description,
            date: posting.entryDate,
            source: posting.source.name,
            debitAmount: line.side == JournalSide.debit ? line.amount : 0,
            creditAmount: line.side == JournalSide.credit ? line.amount : 0,
          ),
        );
      }
    }

    lines.sort(_compareLedgerLines);
    return lines;
  }

  int _compareSubledgerLines(
    PayableSubledgerReconciliationLine a,
    PayableSubledgerReconciliationLine b,
  ) {
    final aDueDate = a.dueDate ?? DateTime(9999);
    final bDueDate = b.dueDate ?? DateTime(9999);
    final dueDateComparison = aDueDate.compareTo(bDueDate);
    if (dueDateComparison != 0) {
      return dueDateComparison;
    }
    return a.reference.compareTo(b.reference);
  }

  int _compareLedgerLines(
    PayableLedgerReconciliationLine a,
    PayableLedgerReconciliationLine b,
  ) {
    final dateComparison = a.date.compareTo(b.date);
    if (dateComparison != 0) {
      return dateComparison;
    }
    return a.reference.compareTo(b.reference);
  }
}
