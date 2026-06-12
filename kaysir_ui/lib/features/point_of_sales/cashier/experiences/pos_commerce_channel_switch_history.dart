import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'pos_commerce_channel_switch_result.dart';

const int defaultPOSCommerceChannelSwitchHistoryLimit = 8;

class POSCommerceChannelSwitchHistoryEntry {
  final String id;
  final POSCommerceChannelSwitchResult result;
  final DateTime occurredAt;
  final int sequence;

  const POSCommerceChannelSwitchHistoryEntry({
    required this.id,
    required this.result,
    required this.occurredAt,
    required this.sequence,
  });

  String get summaryLabel => result.summaryLabel;

  bool get requiresAttention => result.requiresAttention;

  bool get hasChanges => result.hasChanges;

  Iterable<String> get searchTerms sync* {
    yield id;
    yield summaryLabel;
    yield occurredAt.toIso8601String();
    yield sequence.toString();
    yield requiresAttention ? 'requires attention' : 'ready';
    yield* result.searchTerms;
  }
}

class POSCommerceChannelSwitchHistory {
  final List<POSCommerceChannelSwitchHistoryEntry> entries;
  final int limit;

  POSCommerceChannelSwitchHistory({
    Iterable<POSCommerceChannelSwitchHistoryEntry> entries = const [],
    this.limit = defaultPOSCommerceChannelSwitchHistoryLimit,
  }) : entries = List.unmodifiable(entries);

  const POSCommerceChannelSwitchHistory.empty({
    this.limit = defaultPOSCommerceChannelSwitchHistoryLimit,
  }) : entries = const [];

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  POSCommerceChannelSwitchHistoryEntry? get latest {
    return entries.isEmpty ? null : entries.first;
  }

  int get attentionCount {
    return entries.where((entry) => entry.requiresAttention).length;
  }

  int get changedCount {
    return entries.where((entry) => entry.hasChanges).length;
  }

  POSCommerceChannelSwitchHistory record(
    POSCommerceChannelSwitchResult result, {
    required DateTime occurredAt,
    required int sequence,
  }) {
    final entry = POSCommerceChannelSwitchHistoryEntry(
      id: _entryId(occurredAt: occurredAt, sequence: sequence),
      result: result,
      occurredAt: occurredAt,
      sequence: sequence,
    );

    return copyWith(entries: [entry, ...entries].take(limit));
  }

  POSCommerceChannelSwitchHistory clear() {
    return POSCommerceChannelSwitchHistory.empty(limit: limit);
  }

  POSCommerceChannelSwitchHistory copyWith({
    Iterable<POSCommerceChannelSwitchHistoryEntry>? entries,
    int? limit,
  }) {
    final resolvedLimit = limit ?? this.limit;

    return POSCommerceChannelSwitchHistory(
      entries: (entries ?? this.entries).take(resolvedLimit),
      limit: resolvedLimit,
    );
  }

  Iterable<String> get searchTerms sync* {
    yield 'commerce channel switch history';
    yield 'recent channel switches';
    yield entries.length.toString();
    yield attentionCount.toString();

    for (final entry in entries) {
      yield* entry.searchTerms;
    }
  }
}

class POSCommerceChannelSwitchHistoryNotifier
    extends StateNotifier<POSCommerceChannelSwitchHistory> {
  final DateTime Function() _clock;
  int _sequence = 0;

  POSCommerceChannelSwitchHistoryNotifier({
    DateTime Function()? clock,
    int limit = defaultPOSCommerceChannelSwitchHistoryLimit,
  }) : _clock = clock ?? DateTime.now,
       super(POSCommerceChannelSwitchHistory.empty(limit: limit));

  POSCommerceChannelSwitchHistoryEntry record(
    POSCommerceChannelSwitchResult result,
  ) {
    _sequence += 1;
    state = state.record(result, occurredAt: _clock(), sequence: _sequence);
    return state.entries.first;
  }

  void clear() {
    state = state.clear();
  }
}

final posCommerceChannelSwitchHistoryProvider = StateNotifierProvider<
  POSCommerceChannelSwitchHistoryNotifier,
  POSCommerceChannelSwitchHistory
>((ref) => POSCommerceChannelSwitchHistoryNotifier());

String _entryId({required DateTime occurredAt, required int sequence}) {
  return 'channel_switch_${occurredAt.microsecondsSinceEpoch}_$sequence';
}
