import 'omni_channel_activity.dart';
import 'omni_channel_activity_filter.dart';

/// Available source, channel, and fulfillment scopes for the activity center.
class OmniChannelActivityScopeOptions {
  final List<OmniChannelActivityScopeOption> sources;
  final List<OmniChannelActivityScopeOption> channels;
  final List<OmniChannelActivityScopeOption> fulfillmentModes;

  const OmniChannelActivityScopeOptions({
    required this.sources,
    required this.channels,
    this.fulfillmentModes = const [],
  });

  bool get hasSources => sources.isNotEmpty;

  bool get hasChannels => channels.isNotEmpty;

  bool get hasFulfillmentModes => fulfillmentModes.isNotEmpty;

  factory OmniChannelActivityScopeOptions.fromFeed({
    required OmniChannelActivityFeed feed,
    required OmniChannelActivityFilter filter,
  }) {
    return OmniChannelActivityScopeOptions(
      sources: _sourceOptions(feed, filter),
      channels: _channelOptions(feed, filter),
      fulfillmentModes: _fulfillmentModeOptions(feed, filter),
    );
  }
}

/// Selectable scope option derived from an activity source or sales channel.
class OmniChannelActivityScopeOption {
  final String id;
  final String label;
  final int count;

  const OmniChannelActivityScopeOption({
    required this.id,
    required this.label,
    required this.count,
  });
}

extension OmniChannelActivityFeedScoping on OmniChannelActivityFeed {
  OmniChannelActivityScopeOptions scopeOptionsFor(
    OmniChannelActivityFilter filter,
  ) {
    return OmniChannelActivityScopeOptions.fromFeed(feed: this, filter: filter);
  }
}

List<OmniChannelActivityScopeOption> _sourceOptions(
  OmniChannelActivityFeed feed,
  OmniChannelActivityFilter filter,
) {
  final scopedFilter = filter.copyWith(clearSourceId: true);
  final counts = <String, _ScopeCounter>{};

  for (final entry in feed.entries.where(scopedFilter.matches)) {
    counts.update(
      entry.sourceId,
      (counter) => counter.incremented(),
      ifAbsent:
          () => _ScopeCounter(id: entry.sourceId, label: entry.sourceLabel),
    );
  }

  return _sortedOptions(counts.values);
}

List<OmniChannelActivityScopeOption> _channelOptions(
  OmniChannelActivityFeed feed,
  OmniChannelActivityFilter filter,
) {
  final scopedFilter = filter.copyWith(clearChannelId: true);
  final counts = <String, _ScopeCounter>{};

  for (final entry in feed.entries.where(scopedFilter.matches)) {
    final channelId = entry.channelId?.trim();
    if (channelId == null || channelId.isEmpty) continue;

    counts.update(
      channelId,
      (counter) => counter.incremented(),
      ifAbsent:
          () => _ScopeCounter(
            id: channelId,
            label: _firstPresent([entry.channelLabel, channelId]),
          ),
    );
  }

  return _sortedOptions(counts.values);
}

List<OmniChannelActivityScopeOption> _fulfillmentModeOptions(
  OmniChannelActivityFeed feed,
  OmniChannelActivityFilter filter,
) {
  final scopedFilter = filter.copyWith(clearFulfillmentModeKey: true);
  final counts = <String, _ScopeCounter>{};

  for (final entry in feed.entries.where(scopedFilter.matches)) {
    final fulfillmentModeKey = entry.fulfillmentModeKey?.trim();
    if (fulfillmentModeKey == null || fulfillmentModeKey.isEmpty) continue;

    counts.update(
      fulfillmentModeKey,
      (counter) => counter.incremented(),
      ifAbsent:
          () => _ScopeCounter(
            id: fulfillmentModeKey,
            label: _firstPresent([
              entry.fulfillmentModeLabel,
              fulfillmentModeKey,
            ]),
          ),
    );
  }

  return _sortedOptions(counts.values);
}

List<OmniChannelActivityScopeOption> _sortedOptions(
  Iterable<_ScopeCounter> counters,
) {
  final options =
      counters
          .map(
            (counter) => OmniChannelActivityScopeOption(
              id: counter.id,
              label: counter.label,
              count: counter.count,
            ),
          )
          .toList();

  options.sort((left, right) {
    final countComparison = right.count.compareTo(left.count);
    if (countComparison != 0) return countComparison;

    return left.label.compareTo(right.label);
  });

  return List.unmodifiable(options);
}

String _firstPresent(Iterable<String?> values) {
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) return normalized;
  }

  return 'Unknown';
}

class _ScopeCounter {
  final String id;
  final String label;
  final int count;

  const _ScopeCounter({required this.id, required this.label, this.count = 1});

  _ScopeCounter incremented() {
    return _ScopeCounter(id: id, label: label, count: count + 1);
  }
}
