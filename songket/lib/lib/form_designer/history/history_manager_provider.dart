import 'package:flutter_riverpod/legacy.dart';

import 'history_manager.dart';
import 'history_state.dart';

final historyManagerProvider =
    StateNotifierProvider<HistoryManager, HistoryState>((ref) {
      return HistoryManager();
    });
