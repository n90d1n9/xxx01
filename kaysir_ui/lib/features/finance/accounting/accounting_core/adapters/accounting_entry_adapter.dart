import '../../models/account_entry.dart';
import '../../models/account_entry_line.dart';
import '../models/journal_entry.dart';

extension AccountingEntryAdapter on AccountingEntry {
  JournalDraft toJournalDraft() {
    return JournalDraft(
      id: id,
      date: date,
      reference: referenceNumber,
      description: description,
      source: JournalSource.manualAdjustment,
      lines: lines.map((line) => line.toJournalLineDraft()).toList(),
    );
  }
}

extension AccountingEntryLineAdapter on AccountingEntryLine {
  JournalLineDraft toJournalLineDraft() {
    return JournalLineDraft(
      accountId: accountId,
      accountName: accountName,
      side: entryType.toJournalSide(),
      amount: amount,
      memo: memo,
    );
  }
}

extension EntryTypeAdapter on EntryType {
  JournalSide toJournalSide() {
    switch (this) {
      case EntryType.debit:
        return JournalSide.debit;
      case EntryType.credit:
        return JournalSide.credit;
    }
  }
}
