import 'omni_channel_activity.dart';
import 'omni_channel_activity_action_execution.dart';

const int defaultOmniChannelActivityActionExecutionLogLimit = 8;

/// Outcome filter used to scope recent omni-channel action execution records.
enum OmniChannelActivityActionExecutionLogFilter {
  all,
  attention,
  completed,
  blocked,
  failed,
}

/// Durable summary of one handled omni-channel activity action.
class OmniChannelActivityActionExecutionRecord {
  final String id;
  final OmniChannelActivityActionExecutionResult result;
  final String entryId;
  final String entryTitle;
  final String sourceLabel;
  final DateTime occurredAt;
  final int sequence;

  const OmniChannelActivityActionExecutionRecord({
    required this.id,
    required this.result,
    required this.entryId,
    required this.entryTitle,
    required this.sourceLabel,
    required this.occurredAt,
    required this.sequence,
  });

  String get actionIdentity => result.action.identity;

  String get actionLabel => result.action.label;

  String get openLocation {
    final resultLocation = result.location?.trim() ?? '';
    if (resultLocation.isNotEmpty) return resultLocation;

    return result.action.location.trim();
  }

  bool get canOpenLocation => openLocation.isNotEmpty;

  bool get completed => result.completed;

  bool get requiresAttention => result.blocked || result.failed;

  Iterable<String> get searchTerms sync* {
    yield id;
    yield entryId;
    yield entryTitle;
    yield sourceLabel;
    yield actionIdentity;
    yield actionLabel;
    yield result.message;
    yield result.outcome.name;
    yield occurredAt.toIso8601String();
    yield sequence.toString();
  }
}

/// Bounded in-memory history of recent omni-channel activity action results.
class OmniChannelActivityActionExecutionLog {
  final List<OmniChannelActivityActionExecutionRecord> entries;
  final int limit;

  OmniChannelActivityActionExecutionLog({
    Iterable<OmniChannelActivityActionExecutionRecord> entries = const [],
    this.limit = defaultOmniChannelActivityActionExecutionLogLimit,
  }) : entries = List.unmodifiable(entries.take(limit));

  const OmniChannelActivityActionExecutionLog.empty({
    this.limit = defaultOmniChannelActivityActionExecutionLogLimit,
  }) : entries = const [];

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  OmniChannelActivityActionExecutionRecord? get latest {
    return entries.isEmpty ? null : entries.first;
  }

  int get completedCount {
    return entries.where((entry) => entry.completed).length;
  }

  int get blockedCount {
    return entries.where((entry) => entry.result.blocked).length;
  }

  int get failedCount {
    return entries.where((entry) => entry.result.failed).length;
  }

  int get attentionCount {
    return entries.where((entry) => entry.requiresAttention).length;
  }

  List<OmniChannelActivityActionExecutionRecord> get attentionEntries {
    return entries
        .where((entry) => entry.requiresAttention)
        .toList(growable: false);
  }

  List<OmniChannelActivityActionExecutionRecord> entriesFor(
    OmniChannelActivityActionExecutionLogFilter filter,
  ) {
    return entries
        .where((entry) => _matchesFilter(entry, filter))
        .toList(growable: false);
  }

  int countFor(OmniChannelActivityActionExecutionLogFilter filter) {
    return entriesFor(filter).length;
  }

  OmniChannelActivityActionExecutionLog record({
    required OmniChannelActivityEntry entry,
    required OmniChannelActivityActionExecutionResult result,
    required DateTime occurredAt,
    required int sequence,
  }) {
    final record = OmniChannelActivityActionExecutionRecord(
      id: _recordId(occurredAt: occurredAt, sequence: sequence),
      result: result,
      entryId: entry.id,
      entryTitle: entry.title,
      sourceLabel: entry.sourceLabel,
      occurredAt: occurredAt,
      sequence: sequence,
    );

    return copyWith(entries: [record, ...entries]);
  }

  OmniChannelActivityActionExecutionLog clear() {
    return OmniChannelActivityActionExecutionLog.empty(limit: limit);
  }

  OmniChannelActivityActionExecutionLog clearCompleted() {
    return copyWith(entries: entries.where((entry) => !entry.completed));
  }

  OmniChannelActivityActionExecutionLog copyWith({
    Iterable<OmniChannelActivityActionExecutionRecord>? entries,
    int? limit,
  }) {
    final resolvedLimit = limit ?? this.limit;

    return OmniChannelActivityActionExecutionLog(
      entries: (entries ?? this.entries).take(resolvedLimit),
      limit: resolvedLimit,
    );
  }

  Iterable<String> get searchTerms sync* {
    yield 'omni-channel activity action execution log';
    yield entries.length.toString();
    yield completedCount.toString();
    yield attentionCount.toString();

    for (final entry in entries) {
      yield* entry.searchTerms;
    }
  }
}

String _recordId({required DateTime occurredAt, required int sequence}) {
  return 'omni_activity_action_${occurredAt.microsecondsSinceEpoch}_$sequence';
}

bool _matchesFilter(
  OmniChannelActivityActionExecutionRecord entry,
  OmniChannelActivityActionExecutionLogFilter filter,
) {
  switch (filter) {
    case OmniChannelActivityActionExecutionLogFilter.all:
      return true;
    case OmniChannelActivityActionExecutionLogFilter.attention:
      return entry.requiresAttention;
    case OmniChannelActivityActionExecutionLogFilter.completed:
      return entry.result.completed;
    case OmniChannelActivityActionExecutionLogFilter.blocked:
      return entry.result.blocked;
    case OmniChannelActivityActionExecutionLogFilter.failed:
      return entry.result.failed;
  }
}
