import 'omni_channel_activity.dart';
import 'omni_channel_activity_filter.dart';

const int defaultOmniChannelActivityTriageGroupLimit = 6;

typedef OmniChannelActivityTriageValueResolver =
    OmniChannelActivityTriageValue? Function(OmniChannelActivityEntry entry);

typedef OmniChannelActivityTriageFilterBuilder =
    OmniChannelActivityFilter Function({
      required OmniChannelActivityFilter baseFilter,
      required String id,
      required OmniChannelActivityFilterStatus status,
    });

typedef OmniChannelActivityTriageSelectionMatcher =
    bool Function({
      required OmniChannelActivityFilter filter,
      required String id,
      required OmniChannelActivityFilterStatus status,
    });

/// Display and ordering metadata for one triage grouping dimension.
class OmniChannelActivityTriageDimension {
  static const sourceKey = 'source';
  static const channelKey = 'channel';
  static const fulfillmentKey = 'fulfillment';

  static const source = OmniChannelActivityTriageDimension(
    key: sourceKey,
    label: 'Source',
    sortOrder: 0,
  );
  static const channel = OmniChannelActivityTriageDimension(
    key: channelKey,
    label: 'Channel',
    sortOrder: 1,
  );
  static const fulfillment = OmniChannelActivityTriageDimension(
    key: fulfillmentKey,
    label: 'Fulfillment',
    sortOrder: 2,
  );

  final String key;
  final String label;
  final int sortOrder;

  const OmniChannelActivityTriageDimension({
    required this.key,
    required this.label,
    required this.sortOrder,
  });

  @override
  bool operator ==(Object other) {
    return other is OmniChannelActivityTriageDimension && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// Resolved id and label for a single activity entry inside a dimension.
class OmniChannelActivityTriageValue {
  final String id;
  final String label;

  const OmniChannelActivityTriageValue({required this.id, required this.label});
}

/// Pluggable strategy for grouping and selecting omni-channel triage work.
class OmniChannelActivityTriageDimensionDefinition {
  final OmniChannelActivityTriageDimension dimension;
  final OmniChannelActivityTriageValueResolver resolve;
  final OmniChannelActivityTriageFilterBuilder applyFilter;
  final OmniChannelActivityTriageSelectionMatcher isSelected;

  const OmniChannelActivityTriageDimensionDefinition({
    required this.dimension,
    required this.resolve,
    required this.applyFilter,
    required this.isSelected,
  });
}

/// Built-in triage dimensions shared by POS, ecommerce, and channel modules.
final defaultOmniChannelActivityTriageDimensionDefinitions =
    List<OmniChannelActivityTriageDimensionDefinition>.unmodifiable([
      OmniChannelActivityTriageDimensionDefinition(
        dimension: OmniChannelActivityTriageDimension.source,
        resolve: _sourceTriageValue,
        applyFilter: _sourceTriageFilter,
        isSelected: _sourceTriageSelected,
      ),
      OmniChannelActivityTriageDimensionDefinition(
        dimension: OmniChannelActivityTriageDimension.channel,
        resolve: _channelTriageValue,
        applyFilter: _channelTriageFilter,
        isSelected: _channelTriageSelected,
      ),
      OmniChannelActivityTriageDimensionDefinition(
        dimension: OmniChannelActivityTriageDimension.fulfillment,
        resolve: _fulfillmentTriageValue,
        applyFilter: _fulfillmentTriageFilter,
        isSelected: _fulfillmentTriageSelected,
      ),
    ]);

/// Ranked queue for activity sharing one triage dimension and value.
class OmniChannelActivityTriageGroup {
  final OmniChannelActivityTriageDimensionDefinition definition;
  final String id;
  final String label;
  final List<OmniChannelActivityEntry> entries;

  OmniChannelActivityTriageGroup({
    required this.definition,
    required this.id,
    required this.label,
    Iterable<OmniChannelActivityEntry> entries = const [],
  }) : entries = List.unmodifiable(entries);

  OmniChannelActivityTriageDimension get dimension => definition.dimension;

  int get totalCount => entries.length;

  int get attentionCount {
    return entries.where((entry) => entry.requiresAttention).length;
  }

  int get reviewCount {
    return entries.where((entry) => entry.requiresReview).length;
  }

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  OmniChannelActivitySeverity get severity {
    return attentionCount > 0
        ? OmniChannelActivitySeverity.attention
        : OmniChannelActivitySeverity.review;
  }

  OmniChannelActivityEntry? get latestEntry {
    return entries.isEmpty ? null : entries.first;
  }

  DateTime? get latestOccurredAt => latestEntry?.occurredAt;

  OmniChannelActivityFilterStatus get recommendedStatus {
    return attentionCount > 0
        ? OmniChannelActivityFilterStatus.attention
        : OmniChannelActivityFilterStatus.review;
  }

  OmniChannelActivityFilter toFilter(OmniChannelActivityFilter baseFilter) {
    return definition.applyFilter(
      baseFilter: baseFilter,
      id: id,
      status: recommendedStatus,
    );
  }

  bool isSelectedBy(OmniChannelActivityFilter filter) {
    return definition.isSelected(
      filter: filter,
      id: id,
      status: recommendedStatus,
    );
  }
}

/// Ranked triage groups derived from the current omni-channel activity feed.
class OmniChannelActivityTriageQueue {
  /// Queue groups currently exposed to the UI after the display limit is used.
  final List<OmniChannelActivityTriageGroup> groups;

  /// Total number of ranked groups available before the display limit is used.
  final int totalGroupCount;

  OmniChannelActivityTriageQueue({
    Iterable<OmniChannelActivityTriageGroup> groups = const [],
    int? totalGroupCount,
  }) : this._(List.unmodifiable(groups), totalGroupCount);

  OmniChannelActivityTriageQueue._(this.groups, int? totalGroupCount)
    : totalGroupCount = totalGroupCount ?? groups.length;

  const OmniChannelActivityTriageQueue.empty()
    : groups = const [],
      totalGroupCount = 0;

  int get visibleGroupCount => groups.length;

  int get hiddenGroupCount {
    final hiddenCount = totalGroupCount - visibleGroupCount;
    return hiddenCount < 0 ? 0 : hiddenCount;
  }

  bool get hasHiddenGroups => hiddenGroupCount > 0;

  bool get isEmpty => groups.isEmpty;

  bool get isNotEmpty => groups.isNotEmpty;

  int get attentionCount {
    return _uniqueEntryCount(groups, (entry) => entry.requiresAttention);
  }

  int get reviewCount {
    return _uniqueEntryCount(groups, (entry) => entry.requiresReview);
  }

  OmniChannelActivityTriageSummary get summary {
    return OmniChannelActivityTriageSummary.fromQueue(this);
  }

  factory OmniChannelActivityTriageQueue.fromFeed({
    required OmniChannelActivityFeed feed,
    OmniChannelActivityFilter filter = const OmniChannelActivityFilter(),
    Iterable<OmniChannelActivityTriageDimensionDefinition>? dimensions,
    int? limit = defaultOmniChannelActivityTriageGroupLimit,
  }) {
    final resolvedDimensions = _uniqueDimensions(
      dimensions ?? defaultOmniChannelActivityTriageDimensionDefinitions,
    );
    if (resolvedDimensions.isEmpty || (limit != null && limit <= 0)) {
      return const OmniChannelActivityTriageQueue.empty();
    }

    final counters = <String, _TriageCounter>{};

    for (final entry in feed.entries.where(filter.matchesContext)) {
      if (!entry.needsReview) continue;

      for (final definition in resolvedDimensions) {
        final value = definition.resolve(entry);
        final id = value?.id.trim() ?? '';
        if (id.isEmpty) continue;

        final label = _firstPresent([value?.label, id]);
        final counterKey = '${definition.dimension.key}\u001F$id';
        counters.update(
          counterKey,
          (counter) => counter.withEntry(entry),
          ifAbsent:
              () => _TriageCounter(
                definition: definition,
                id: id,
                label: label,
                entries: [entry],
              ),
        );
      }
    }

    final groups =
        counters.values.map((counter) => counter.toGroup()).toList()
          ..sort(_compareGroups);

    return OmniChannelActivityTriageQueue(
      groups: limit == null ? groups : groups.take(limit),
      totalGroupCount: groups.length,
    );
  }
}

/// Operator-facing summary for the current triage queue focus.
class OmniChannelActivityTriageSummary {
  final OmniChannelActivitySeverity severity;
  final int queueCount;
  final int totalQueueCount;
  final int hiddenQueueCount;
  final int attentionCount;
  final int reviewCount;
  final OmniChannelActivityTriageGroup? focusGroup;

  const OmniChannelActivityTriageSummary({
    required this.severity,
    required this.queueCount,
    required this.totalQueueCount,
    required this.hiddenQueueCount,
    required this.attentionCount,
    required this.reviewCount,
    this.focusGroup,
  });

  bool get hasWork => focusGroup != null;

  bool get hasHiddenQueues => hiddenQueueCount > 0;

  String get headline {
    final group = focusGroup;
    if (group == null) return 'All triage queues are clear';

    return 'Focus on ${group.label}';
  }

  String get detail {
    final group = focusGroup;
    if (group == null) return 'No attention or review queues need follow-up.';

    return '${_workLabel(group)} across ${group.dimension.label.toLowerCase()} '
        'queue.';
  }

  String get overflowLabel {
    if (!hasHiddenQueues) return '';

    return '${_countLabel(hiddenQueueCount, 'more queue')} available';
  }

  String get actionLabel {
    final group = focusGroup;
    if (group == null) return 'Open focus';

    return 'Open ${group.dimension.label.toLowerCase()} queue';
  }

  factory OmniChannelActivityTriageSummary.fromQueue(
    OmniChannelActivityTriageQueue queue,
  ) {
    final focusGroup = queue.groups.isEmpty ? null : queue.groups.first;

    return OmniChannelActivityTriageSummary(
      severity: focusGroup?.severity ?? OmniChannelActivitySeverity.ready,
      queueCount: queue.visibleGroupCount,
      totalQueueCount: queue.totalGroupCount,
      hiddenQueueCount: queue.hiddenGroupCount,
      attentionCount: queue.attentionCount,
      reviewCount: queue.reviewCount,
      focusGroup: focusGroup,
    );
  }
}

extension OmniChannelActivityFeedTriage on OmniChannelActivityFeed {
  OmniChannelActivityTriageQueue triageQueueFor(
    OmniChannelActivityFilter filter, {
    Iterable<OmniChannelActivityTriageDimensionDefinition>? dimensions,
    int? limit = defaultOmniChannelActivityTriageGroupLimit,
  }) {
    return OmniChannelActivityTriageQueue.fromFeed(
      feed: this,
      filter: filter,
      dimensions: dimensions,
      limit: limit,
    );
  }
}

OmniChannelActivityTriageValue? _sourceTriageValue(
  OmniChannelActivityEntry entry,
) {
  return OmniChannelActivityTriageValue(
    id: entry.sourceId,
    label: entry.sourceLabel,
  );
}

OmniChannelActivityFilter _sourceTriageFilter({
  required OmniChannelActivityFilter baseFilter,
  required String id,
  required OmniChannelActivityFilterStatus status,
}) {
  return baseFilter.copyWith(status: status, sourceId: id);
}

bool _sourceTriageSelected({
  required OmniChannelActivityFilter filter,
  required String id,
  required OmniChannelActivityFilterStatus status,
}) {
  return filter.status == status && filter.sourceId == id;
}

OmniChannelActivityTriageValue? _channelTriageValue(
  OmniChannelActivityEntry entry,
) {
  final channelId = entry.channelId?.trim();
  if (channelId == null || channelId.isEmpty) return null;

  return OmniChannelActivityTriageValue(
    id: channelId,
    label: _firstPresent([entry.channelLabel, channelId]),
  );
}

OmniChannelActivityFilter _channelTriageFilter({
  required OmniChannelActivityFilter baseFilter,
  required String id,
  required OmniChannelActivityFilterStatus status,
}) {
  return baseFilter.copyWith(status: status, channelId: id);
}

bool _channelTriageSelected({
  required OmniChannelActivityFilter filter,
  required String id,
  required OmniChannelActivityFilterStatus status,
}) {
  return filter.status == status && filter.channelId == id;
}

OmniChannelActivityTriageValue? _fulfillmentTriageValue(
  OmniChannelActivityEntry entry,
) {
  final fulfillmentModeKey = entry.fulfillmentModeKey?.trim();
  if (fulfillmentModeKey == null || fulfillmentModeKey.isEmpty) return null;

  return OmniChannelActivityTriageValue(
    id: fulfillmentModeKey,
    label: _firstPresent([entry.fulfillmentModeLabel, fulfillmentModeKey]),
  );
}

OmniChannelActivityFilter _fulfillmentTriageFilter({
  required OmniChannelActivityFilter baseFilter,
  required String id,
  required OmniChannelActivityFilterStatus status,
}) {
  return baseFilter.copyWith(status: status, fulfillmentModeKey: id);
}

bool _fulfillmentTriageSelected({
  required OmniChannelActivityFilter filter,
  required String id,
  required OmniChannelActivityFilterStatus status,
}) {
  return filter.status == status && filter.fulfillmentModeKey == id;
}

int _compareGroups(
  OmniChannelActivityTriageGroup left,
  OmniChannelActivityTriageGroup right,
) {
  final attentionComparison = right.attentionCount.compareTo(
    left.attentionCount,
  );
  if (attentionComparison != 0) return attentionComparison;

  final reviewComparison = right.reviewCount.compareTo(left.reviewCount);
  if (reviewComparison != 0) return reviewComparison;

  final latestComparison = _latestMillis(right).compareTo(_latestMillis(left));
  if (latestComparison != 0) return latestComparison;

  final dimensionComparison = left.dimension.sortOrder.compareTo(
    right.dimension.sortOrder,
  );
  if (dimensionComparison != 0) return dimensionComparison;

  return left.label.compareTo(right.label);
}

int _latestMillis(OmniChannelActivityTriageGroup group) {
  return group.latestOccurredAt?.millisecondsSinceEpoch ?? 0;
}

int _uniqueEntryCount(
  Iterable<OmniChannelActivityTriageGroup> groups,
  bool Function(OmniChannelActivityEntry entry) include,
) {
  final ids = <String>{};

  for (final group in groups) {
    for (final entry in group.entries) {
      if (include(entry)) ids.add(entry.id);
    }
  }

  return ids.length;
}

List<OmniChannelActivityTriageDimensionDefinition> _uniqueDimensions(
  Iterable<OmniChannelActivityTriageDimensionDefinition> dimensions,
) {
  final seenKeys = <String>{};
  final result = <OmniChannelActivityTriageDimensionDefinition>[];

  for (final definition in dimensions) {
    final key = definition.dimension.key.trim();
    if (key.isEmpty || !seenKeys.add(key)) continue;

    result.add(definition);
  }

  return List.unmodifiable(result);
}

String _firstPresent(Iterable<String?> values) {
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) return normalized;
  }

  return 'Unknown';
}

String _workLabel(OmniChannelActivityTriageGroup group) {
  final parts = <String>[
    if (group.attentionCount > 0)
      _countLabel(group.attentionCount, 'attention'),
    if (group.reviewCount > 0) _countLabel(group.reviewCount, 'review'),
  ];

  return parts.join(' and ');
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}

/// Mutable-building value used before exposing immutable triage groups.
class _TriageCounter {
  final OmniChannelActivityTriageDimensionDefinition definition;
  final String id;
  final String label;
  final List<OmniChannelActivityEntry> entries;

  const _TriageCounter({
    required this.definition,
    required this.id,
    required this.label,
    required this.entries,
  });

  _TriageCounter withEntry(OmniChannelActivityEntry entry) {
    return _TriageCounter(
      definition: definition,
      id: id,
      label: label,
      entries: [...entries, entry],
    );
  }

  OmniChannelActivityTriageGroup toGroup() {
    return OmniChannelActivityTriageGroup(
      definition: definition,
      id: id,
      label: label,
      entries: entries,
    );
  }
}
