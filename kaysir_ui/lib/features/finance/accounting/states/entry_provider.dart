import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/account_entry.dart';
import '../models/account_entry_line.dart';

final entryNotifierProvider =
    StateNotifierProvider<EntryNotifier, AccountingEntry>((ref) {
      return EntryNotifier();
    });

class EntryNotifier extends StateNotifier<AccountingEntry> {
  EntryNotifier()
    : super(
        AccountingEntry(
          date: DateTime.now(),
          description: '',
          referenceNumber: '',
          lines: [],
        ),
      );

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setReferenceNumber(String referenceNumber) {
    state = state.copyWith(referenceNumber: referenceNumber);
  }

  void addLine(AccountingEntryLine line) {
    state = state.copyWith(lines: [...state.lines, line]);
  }

  void updateLine(String lineId, AccountingEntryLine updatedLine) {
    final updatedLines =
        state.lines
            .map((line) => line.id == lineId ? updatedLine : line)
            .toList();
    state = state.copyWith(lines: updatedLines);
  }

  void removeLine(String lineId) {
    final updatedLines =
        state.lines.where((line) => line.id != lineId).toList();
    state = state.copyWith(lines: updatedLines);
  }

  void clear() {
    state = AccountingEntry(
      date: DateTime.now(),
      description: '',
      referenceNumber: '',
      lines: [],
    );
  }
}
