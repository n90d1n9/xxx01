import 'omni_channel_activity.dart';
import 'omni_channel_activity_filter.dart';
import 'omni_channel_activity_insight.dart';

/// Serializable route state for the omni-channel activity center.
class OmniChannelActivityCenterQueryState {
  static const searchQueryKey = 'activity_search';
  static const statusQueryKey = 'activity_status';
  static const sourceIdQueryKey = 'activity_source_id';
  static const channelIdQueryKey = 'activity_channel_id';
  static const orderIdQueryKey = 'activity_order_id';
  static const fulfillmentModeQueryKey = 'activity_fulfillment_mode';
  static const selectedEntryIdQueryKey = 'activity_selected_id';

  final OmniChannelActivityFilter filter;
  final String? selectedEntryId;

  const OmniChannelActivityCenterQueryState({
    this.filter = const OmniChannelActivityFilter(),
    this.selectedEntryId,
  });

  factory OmniChannelActivityCenterQueryState.fromInsight(
    OmniChannelActivityInsight insight,
  ) {
    final entry = insight.referenceEntry;

    return OmniChannelActivityCenterQueryState(
      filter: OmniChannelActivityFilter(
        status: _statusForSeverity(insight.severity),
        sourceId: entry?.sourceId,
        channelId: entry?.channelId,
        orderId: entry?.orderId,
        fulfillmentModeKey: entry?.fulfillmentModeKey,
      ),
      selectedEntryId: entry?.id,
    );
  }

  bool get hasCustomState {
    return filter.hasConstraints || _hasValue(selectedEntryId);
  }

  Map<String, String> toQueryParameters() {
    if (!hasCustomState) return const {};

    final query = filter.query.trim();
    final sourceId = filter.sourceId?.trim();
    final channelId = filter.channelId?.trim();
    final orderId = filter.orderId?.trim();
    final fulfillmentModeKey = filter.fulfillmentModeKey?.trim();
    final selectedId = selectedEntryId?.trim();

    return {
      if (query.isNotEmpty) searchQueryKey: query,
      if (filter.status != OmniChannelActivityFilterStatus.all)
        statusQueryKey: filter.status.name,
      if (sourceId != null && sourceId.isNotEmpty) sourceIdQueryKey: sourceId,
      if (channelId != null && channelId.isNotEmpty)
        channelIdQueryKey: channelId,
      if (orderId != null && orderId.isNotEmpty) orderIdQueryKey: orderId,
      if (fulfillmentModeKey != null && fulfillmentModeKey.isNotEmpty)
        fulfillmentModeQueryKey: fulfillmentModeKey,
      if (selectedId != null && selectedId.isNotEmpty)
        selectedEntryIdQueryKey: selectedId,
    };
  }

  String locationForPath(String path) {
    final queryParameters = toQueryParameters();
    return Uri(
      path: path.trim(),
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static OmniChannelActivityCenterQueryState? fromQueryParameters(
    Map<String, String> queryParameters,
  ) {
    final hasState = _queryKeys.any(queryParameters.containsKey);
    if (!hasState) return null;

    return OmniChannelActivityCenterQueryState(
      filter: OmniChannelActivityFilter(
        query: _trimmedValue(queryParameters[searchQueryKey]) ?? '',
        status: _enumByName(
          OmniChannelActivityFilterStatus.values,
          queryParameters[statusQueryKey],
          OmniChannelActivityFilterStatus.all,
        ),
        sourceId: _trimmedValue(queryParameters[sourceIdQueryKey]),
        channelId: _trimmedValue(queryParameters[channelIdQueryKey]),
        orderId: _trimmedValue(queryParameters[orderIdQueryKey]),
        fulfillmentModeKey: _trimmedValue(
          queryParameters[fulfillmentModeQueryKey],
        ),
      ),
      selectedEntryId: _trimmedValue(queryParameters[selectedEntryIdQueryKey]),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OmniChannelActivityCenterQueryState &&
        other.filter == filter &&
        other.selectedEntryId == selectedEntryId;
  }

  @override
  int get hashCode => Object.hash(filter, selectedEntryId);

  static const _queryKeys = <String>[
    searchQueryKey,
    statusQueryKey,
    sourceIdQueryKey,
    channelIdQueryKey,
    orderIdQueryKey,
    fulfillmentModeQueryKey,
    selectedEntryIdQueryKey,
  ];
}

String? _trimmedValue(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) return null;

  return normalized;
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  final normalizedName = name?.trim() ?? '';
  for (final value in values) {
    if (value.name == normalizedName) return value;
  }

  return fallback;
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}

OmniChannelActivityFilterStatus _statusForSeverity(
  OmniChannelActivitySeverity severity,
) {
  switch (severity) {
    case OmniChannelActivitySeverity.attention:
      return OmniChannelActivityFilterStatus.attention;
    case OmniChannelActivitySeverity.review:
      return OmniChannelActivityFilterStatus.review;
    case OmniChannelActivitySeverity.ready:
      return OmniChannelActivityFilterStatus.all;
  }
}
