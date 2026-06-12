import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../models/invoice.dart';
import '../models/receivable_reconciliation.dart';

class ReceivableReconciliationService {
  final double tolerance;

  const ReceivableReconciliationService({this.tolerance = 0.01});

  ReceivableReconciliation reconcile({
    required Iterable<Invoice> invoices,
    required Iterable<LedgerPosting> postings,
    required AccountingAccount accountsReceivable,
    DateTime? asOf,
    Map<String, String> customerNamesById = const {},
  }) {
    final effectiveAsOf = asOf ?? DateTime.now();
    final subledgerLines = _subledgerLines(
      invoices,
      effectiveAsOf,
      customerNamesById,
    );
    final ledgerLines = _ledgerLines(postings, accountsReceivable.id);

    return ReceivableReconciliation(
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
      agingBuckets: _agingBuckets(subledgerLines),
    );
  }

  List<ReceivableSubledgerReconciliationLine> _subledgerLines(
    Iterable<Invoice> invoices,
    DateTime asOf,
    Map<String, String> customerNamesById,
  ) {
    final lines = <ReceivableSubledgerReconciliationLine>[];
    for (final invoice in invoices) {
      if (invoice.customerId == null) {
        continue;
      }
      final remainingAmount = invoice.remainingAmount;
      if (remainingAmount <= 0) {
        continue;
      }

      lines.add(
        ReceivableSubledgerReconciliationLine(
          invoiceId: invoice.id,
          reference: invoice.invoiceNumber ?? invoice.reference ?? invoice.id,
          customerName:
              customerNamesById[invoice.customerId] ??
              invoice.customerId ??
              'Unknown Customer',
          dueDate: invoice.dueDate,
          remainingAmount: remainingAmount,
          daysPastDue: _daysPastDue(invoice.dueDate, asOf),
        ),
      );
    }

    lines.sort(_compareSubledgerLines);
    return lines;
  }

  List<ReceivableLedgerReconciliationLine> _ledgerLines(
    Iterable<LedgerPosting> postings,
    String accountsReceivableAccountId,
  ) {
    final lines = <ReceivableLedgerReconciliationLine>[];
    for (final posting in postings) {
      for (final line in posting.lines) {
        if (line.accountId != accountsReceivableAccountId) {
          continue;
        }
        lines.add(
          ReceivableLedgerReconciliationLine(
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

  List<ReceivableAgingBucket> _agingBuckets(
    Iterable<ReceivableSubledgerReconciliationLine> lines,
  ) {
    final amounts = <String, double>{};
    final counts = <String, int>{};
    for (final line in lines) {
      final bucketId = _bucketIdFor(line.daysPastDue);
      amounts[bucketId] = (amounts[bucketId] ?? 0) + line.remainingAmount;
      counts[bucketId] = (counts[bucketId] ?? 0) + 1;
    }

    return [
      _bucket(
        id: ReceivableAgingBucketIds.current,
        label: 'Current',
        amounts: amounts,
        counts: counts,
      ),
      _bucket(
        id: ReceivableAgingBucketIds.overdue1To30,
        label: '1-30 days overdue',
        amounts: amounts,
        counts: counts,
      ),
      _bucket(
        id: ReceivableAgingBucketIds.overdue31To60,
        label: '31-60 days overdue',
        amounts: amounts,
        counts: counts,
      ),
      _bucket(
        id: ReceivableAgingBucketIds.overdue61To90,
        label: '61-90 days overdue',
        amounts: amounts,
        counts: counts,
      ),
      _bucket(
        id: ReceivableAgingBucketIds.overdueOver90,
        label: 'Over 90 days overdue',
        amounts: amounts,
        counts: counts,
      ),
    ];
  }

  ReceivableAgingBucket _bucket({
    required String id,
    required String label,
    required Map<String, double> amounts,
    required Map<String, int> counts,
  }) {
    return ReceivableAgingBucket(
      id: id,
      label: label,
      amount: amounts[id] ?? 0,
      invoiceCount: counts[id] ?? 0,
    );
  }

  String _bucketIdFor(int daysPastDue) {
    if (daysPastDue <= 0) {
      return ReceivableAgingBucketIds.current;
    }
    if (daysPastDue <= 30) {
      return ReceivableAgingBucketIds.overdue1To30;
    }
    if (daysPastDue <= 60) {
      return ReceivableAgingBucketIds.overdue31To60;
    }
    if (daysPastDue <= 90) {
      return ReceivableAgingBucketIds.overdue61To90;
    }
    return ReceivableAgingBucketIds.overdueOver90;
  }

  int _daysPastDue(DateTime? dueDate, DateTime asOf) {
    if (dueDate == null || !dueDate.isBefore(asOf)) {
      return 0;
    }
    return asOf.difference(dueDate).inDays;
  }

  int _compareSubledgerLines(
    ReceivableSubledgerReconciliationLine a,
    ReceivableSubledgerReconciliationLine b,
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
    ReceivableLedgerReconciliationLine a,
    ReceivableLedgerReconciliationLine b,
  ) {
    final dateComparison = a.date.compareTo(b.date);
    if (dateComparison != 0) {
      return dateComparison;
    }
    return a.reference.compareTo(b.reference);
  }
}
