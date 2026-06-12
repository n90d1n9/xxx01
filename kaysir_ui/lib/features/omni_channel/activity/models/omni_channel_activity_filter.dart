import 'omni_channel_activity.dart';

enum OmniChannelActivityFilterStatus {
  all,
  attention,
  review,
  orders,
  orderSync,
  channelSwitches,
  switchActions,
  fulfillment,
  payments,
  system,
}

class OmniChannelActivityFilter {
  final String query;
  final OmniChannelActivityFilterStatus status;
  final String? sourceId;
  final String? channelId;
  final String? orderId;
  final String? fulfillmentModeKey;

  const OmniChannelActivityFilter({
    this.query = '',
    this.status = OmniChannelActivityFilterStatus.all,
    this.sourceId,
    this.channelId,
    this.orderId,
    this.fulfillmentModeKey,
  });

  bool get hasConstraints {
    return query.trim().isNotEmpty ||
        status != OmniChannelActivityFilterStatus.all ||
        _hasValue(sourceId) ||
        _hasValue(channelId) ||
        _hasValue(orderId) ||
        _hasValue(fulfillmentModeKey);
  }

  bool matches(OmniChannelActivityEntry entry) {
    return matchesContext(entry) && _matchesStatus(entry);
  }

  bool matchesContext(OmniChannelActivityEntry entry) {
    return entry.matchesQuery(query) &&
        _matchesOptional(entry.sourceId, sourceId) &&
        _matchesOptional(entry.channelId, channelId) &&
        _matchesOptional(entry.orderId, orderId) &&
        _matchesOptional(entry.fulfillmentModeKey, fulfillmentModeKey);
  }

  OmniChannelActivityFilter copyWith({
    String? query,
    OmniChannelActivityFilterStatus? status,
    String? sourceId,
    bool clearSourceId = false,
    String? channelId,
    bool clearChannelId = false,
    String? orderId,
    bool clearOrderId = false,
    String? fulfillmentModeKey,
    bool clearFulfillmentModeKey = false,
  }) {
    return OmniChannelActivityFilter(
      query: query ?? this.query,
      status: status ?? this.status,
      sourceId: clearSourceId ? null : sourceId ?? this.sourceId,
      channelId: clearChannelId ? null : channelId ?? this.channelId,
      orderId: clearOrderId ? null : orderId ?? this.orderId,
      fulfillmentModeKey:
          clearFulfillmentModeKey
              ? null
              : fulfillmentModeKey ?? this.fulfillmentModeKey,
    );
  }

  bool _matchesStatus(OmniChannelActivityEntry entry) {
    switch (status) {
      case OmniChannelActivityFilterStatus.all:
        return true;
      case OmniChannelActivityFilterStatus.attention:
        return entry.requiresAttention;
      case OmniChannelActivityFilterStatus.review:
        return entry.requiresReview;
      case OmniChannelActivityFilterStatus.orders:
        return entry.kind == OmniChannelActivityKind.order;
      case OmniChannelActivityFilterStatus.orderSync:
        return entry.kind == OmniChannelActivityKind.orderSync;
      case OmniChannelActivityFilterStatus.channelSwitches:
        return entry.kind == OmniChannelActivityKind.channelSwitch;
      case OmniChannelActivityFilterStatus.switchActions:
        return entry.kind == OmniChannelActivityKind.switchAction;
      case OmniChannelActivityFilterStatus.fulfillment:
        return entry.kind == OmniChannelActivityKind.fulfillment;
      case OmniChannelActivityFilterStatus.payments:
        return entry.kind == OmniChannelActivityKind.payment;
      case OmniChannelActivityFilterStatus.system:
        return entry.kind == OmniChannelActivityKind.system;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is OmniChannelActivityFilter &&
        other.query == query &&
        other.status == status &&
        other.sourceId == sourceId &&
        other.channelId == channelId &&
        other.orderId == orderId &&
        other.fulfillmentModeKey == fulfillmentModeKey;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      status,
      sourceId,
      channelId,
      orderId,
      fulfillmentModeKey,
    );
  }
}

class OmniChannelActivityFilterCounts {
  final int all;
  final int attention;
  final int review;
  final int orders;
  final int orderSync;
  final int channelSwitches;
  final int switchActions;
  final int fulfillment;
  final int payments;
  final int system;

  const OmniChannelActivityFilterCounts({
    required this.all,
    required this.attention,
    required this.review,
    required this.orders,
    required this.orderSync,
    required this.channelSwitches,
    required this.switchActions,
    required this.fulfillment,
    required this.payments,
    required this.system,
  });

  factory OmniChannelActivityFilterCounts.fromEntries(
    Iterable<OmniChannelActivityEntry> entries,
  ) {
    var all = 0;
    var attention = 0;
    var review = 0;
    var orders = 0;
    var orderSync = 0;
    var channelSwitches = 0;
    var switchActions = 0;
    var fulfillment = 0;
    var payments = 0;
    var system = 0;

    for (final entry in entries) {
      all += 1;
      if (entry.requiresAttention) attention += 1;
      if (entry.requiresReview) review += 1;

      switch (entry.kind) {
        case OmniChannelActivityKind.order:
          orders += 1;
        case OmniChannelActivityKind.orderSync:
          orderSync += 1;
        case OmniChannelActivityKind.channelSwitch:
          channelSwitches += 1;
        case OmniChannelActivityKind.switchAction:
          switchActions += 1;
        case OmniChannelActivityKind.fulfillment:
          fulfillment += 1;
        case OmniChannelActivityKind.payment:
          payments += 1;
        case OmniChannelActivityKind.system:
          system += 1;
      }
    }

    return OmniChannelActivityFilterCounts(
      all: all,
      attention: attention,
      review: review,
      orders: orders,
      orderSync: orderSync,
      channelSwitches: channelSwitches,
      switchActions: switchActions,
      fulfillment: fulfillment,
      payments: payments,
      system: system,
    );
  }

  int countFor(OmniChannelActivityFilterStatus status) {
    switch (status) {
      case OmniChannelActivityFilterStatus.all:
        return all;
      case OmniChannelActivityFilterStatus.attention:
        return attention;
      case OmniChannelActivityFilterStatus.review:
        return review;
      case OmniChannelActivityFilterStatus.orders:
        return orders;
      case OmniChannelActivityFilterStatus.orderSync:
        return orderSync;
      case OmniChannelActivityFilterStatus.channelSwitches:
        return channelSwitches;
      case OmniChannelActivityFilterStatus.switchActions:
        return switchActions;
      case OmniChannelActivityFilterStatus.fulfillment:
        return fulfillment;
      case OmniChannelActivityFilterStatus.payments:
        return payments;
      case OmniChannelActivityFilterStatus.system:
        return system;
    }
  }
}

extension OmniChannelActivityFeedFiltering on OmniChannelActivityFeed {
  List<OmniChannelActivityEntry> apply(OmniChannelActivityFilter filter) {
    return entries.where(filter.matches).toList(growable: false);
  }

  OmniChannelActivityFilterCounts countsFor(OmniChannelActivityFilter filter) {
    return OmniChannelActivityFilterCounts.fromEntries(
      entries.where(filter.matchesContext),
    );
  }
}

extension OmniChannelActivityFilterStatusLabel
    on OmniChannelActivityFilterStatus {
  String get label {
    switch (this) {
      case OmniChannelActivityFilterStatus.all:
        return 'All';
      case OmniChannelActivityFilterStatus.attention:
        return 'Attention';
      case OmniChannelActivityFilterStatus.review:
        return 'Review';
      case OmniChannelActivityFilterStatus.orders:
        return 'Orders';
      case OmniChannelActivityFilterStatus.orderSync:
        return 'Order sync';
      case OmniChannelActivityFilterStatus.channelSwitches:
        return 'Channels';
      case OmniChannelActivityFilterStatus.switchActions:
        return 'Switches';
      case OmniChannelActivityFilterStatus.fulfillment:
        return 'Fulfillment';
      case OmniChannelActivityFilterStatus.payments:
        return 'Payments';
      case OmniChannelActivityFilterStatus.system:
        return 'System';
    }
  }
}

bool _matchesOptional(String? value, String? expected) {
  final normalizedExpected = expected?.trim();
  if (normalizedExpected == null || normalizedExpected.isEmpty) return true;
  return value?.trim() == normalizedExpected;
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}
