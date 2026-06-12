import 'package:intl/intl.dart';

import '../models/financial_period_close.dart';

class FinancialPeriodPostingGuardService {
  const FinancialPeriodPostingGuardService();

  FinancialPeriodCloseRecord? closedRecordForDate({
    required DateTime entryDate,
    required Iterable<FinancialPeriodCloseRecord> records,
  }) {
    for (final record in records) {
      if (record.isClosed && record.covers(entryDate)) {
        return record;
      }
    }
    return null;
  }

  void ensureDateIsOpen({
    required DateTime entryDate,
    required Iterable<FinancialPeriodCloseRecord> records,
    String actionLabel = 'post this transaction',
  }) {
    final record = closedRecordForDate(entryDate: entryDate, records: records);
    if (record == null) {
      return;
    }

    final dateLabel = DateFormat('MMM d, yyyy').format(entryDate);
    throw StateError(
      'Cannot $actionLabel on $dateLabel because ${record.periodLabel} is closed. Reopen the period before posting.',
    );
  }
}
