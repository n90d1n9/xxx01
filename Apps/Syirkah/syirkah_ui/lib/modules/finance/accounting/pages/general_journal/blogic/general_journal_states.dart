import 'package:flutter_riverpod/legacy.dart';

import '../models/general_joournal.dart';

class GeneralJournalModel extends StateNotifier<List<GeneralJournal>> {
  GeneralJournalModel() : super([]);

  void addEntry(GeneralJournal entry) {
    state = [...state, entry];
  }
}

final generalJournalProvider =
    StateNotifierProvider<GeneralJournalModel, List<GeneralJournal>>(
  (ref) => GeneralJournalModel(),
);
