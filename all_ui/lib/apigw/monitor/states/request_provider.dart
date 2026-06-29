import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/request_entry.dart';

final requestsCounterProvider =
    StateNotifierProvider<RequestsCounterNotifier, List<RequestCountEntry>>((
      ref,
    ) {
      return RequestsCounterNotifier();
    });

class RequestsCounterNotifier extends StateNotifier<List<RequestCountEntry>> {
  RequestsCounterNotifier() : super([]);

  void addEntry(DateTime timestamp, int count) {
    // Keep only the last 50 entries for the time series
    if (state.length >= 50) {
      state = [
        ...state.skip(1),
        RequestCountEntry(timestamp: timestamp, count: count),
      ];
    } else {
      state = [...state, RequestCountEntry(timestamp: timestamp, count: count)];
    }
  }
}
