import 'package:flutter_riverpod/legacy.dart';

import 'pos_switch_action_result.dart';

const int defaultPOSSwitchActionHistoryLimit = 16;

class POSSwitchActionHistoryEntry {
  final String id;
  final POSSwitchActionResult result;
  final DateTime occurredAt;
  final int sequence;

  const POSSwitchActionHistoryEntry({
    required this.id,
    required this.result,
    required this.occurredAt,
    required this.sequence,
  });

  String get summaryLabel => result.summaryLabel;

  bool get requiresAttention => result.requiresAttention;

  Iterable<String> get searchTerms sync* {
    yield id;
    yield occurredAt.toIso8601String();
    yield sequence.toString();
    yield requiresAttention ? 'requires attention' : 'ready';
    yield* result.searchTerms;
  }
}

class POSSwitchActionHistory {
  final List<POSSwitchActionHistoryEntry> entries;
  final int limit;

  POSSwitchActionHistory({
    Iterable<POSSwitchActionHistoryEntry> entries = const [],
    this.limit = defaultPOSSwitchActionHistoryLimit,
  }) : entries = List.unmodifiable(entries);

  const POSSwitchActionHistory.empty({
    this.limit = defaultPOSSwitchActionHistoryLimit,
  }) : entries = const [];

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  POSSwitchActionHistoryEntry? get latest {
    return entries.isEmpty ? null : entries.first;
  }

  int get appliedCount {
    return entries.where((entry) => entry.result.applied).length;
  }

  int get blockedCount {
    return entries.where((entry) => entry.result.blocked).length;
  }

  int get cancelledCount {
    return entries.where((entry) => entry.result.cancelled).length;
  }

  int get attentionCount {
    return entries.where((entry) => entry.requiresAttention).length;
  }

  POSSwitchActionHistory record(
    POSSwitchActionResult result, {
    required DateTime occurredAt,
    required int sequence,
  }) {
    final entry = POSSwitchActionHistoryEntry(
      id: _entryId(occurredAt: occurredAt, sequence: sequence),
      result: result,
      occurredAt: occurredAt,
      sequence: sequence,
    );

    return copyWith(entries: [entry, ...entries].take(limit));
  }

  POSSwitchActionHistory clear() {
    return POSSwitchActionHistory.empty(limit: limit);
  }

  POSSwitchActionHistory copyWith({
    Iterable<POSSwitchActionHistoryEntry>? entries,
    int? limit,
  }) {
    final resolvedLimit = limit ?? this.limit;

    return POSSwitchActionHistory(
      entries: (entries ?? this.entries).take(resolvedLimit),
      limit: resolvedLimit,
    );
  }

  Iterable<String> get searchTerms sync* {
    yield 'pos switch action history';
    yield 'recent switch attempts';
    yield entries.length.toString();
    yield appliedCount.toString();
    yield blockedCount.toString();
    yield cancelledCount.toString();

    for (final entry in entries) {
      yield* entry.searchTerms;
    }
  }
}

class POSSwitchActionHistoryNotifier
    extends StateNotifier<POSSwitchActionHistory> {
  final DateTime Function() _clock;
  int _sequence = 0;

  POSSwitchActionHistoryNotifier({
    DateTime Function()? clock,
    int limit = defaultPOSSwitchActionHistoryLimit,
  }) : _clock = clock ?? DateTime.now,
       super(POSSwitchActionHistory.empty(limit: limit));

  POSSwitchActionHistoryEntry record(POSSwitchActionResult result) {
    _sequence += 1;
    state = state.record(result, occurredAt: _clock(), sequence: _sequence);
    return state.entries.first;
  }

  void clear() {
    state = state.clear();
  }
}

final posSwitchActionHistoryProvider = StateNotifierProvider<
  POSSwitchActionHistoryNotifier,
  POSSwitchActionHistory
>((ref) => POSSwitchActionHistoryNotifier());

String _entryId({required DateTime occurredAt, required int sequence}) {
  return 'pos_switch_${occurredAt.microsecondsSinceEpoch}_$sequence';
}
