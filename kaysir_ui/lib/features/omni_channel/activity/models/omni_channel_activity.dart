enum OmniChannelActivitySeverity { ready, review, attention }

enum OmniChannelActivityKind {
  order,
  orderSync,
  channelSwitch,
  switchAction,
  fulfillment,
  payment,
  system,
}

class OmniChannelActivityEntry {
  final String id;
  final OmniChannelActivityKind kind;
  final String sourceId;
  final String sourceLabel;
  final DateTime occurredAt;
  final String title;
  final String detail;
  final OmniChannelActivitySeverity severity;
  final String? channelId;
  final String? channelLabel;
  final String? orderId;
  final String? fulfillmentModeKey;
  final String? fulfillmentModeLabel;
  final String? supportSummary;
  final List<String> searchTerms;
  final Map<String, String> attributes;

  OmniChannelActivityEntry({
    required this.id,
    required this.kind,
    required this.sourceId,
    required this.sourceLabel,
    required this.occurredAt,
    required this.title,
    required this.detail,
    this.severity = OmniChannelActivitySeverity.ready,
    this.channelId,
    this.channelLabel,
    this.orderId,
    this.fulfillmentModeKey,
    this.fulfillmentModeLabel,
    this.supportSummary,
    Iterable<String> searchTerms = const [],
    Map<String, String> attributes = const {},
  }) : searchTerms = List.unmodifiable(searchTerms),
       attributes = Map.unmodifiable(attributes);

  bool get requiresAttention =>
      severity == OmniChannelActivitySeverity.attention;

  bool get requiresReview => severity == OmniChannelActivitySeverity.review;

  bool get needsReview => severity != OmniChannelActivitySeverity.ready;

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return _haystack.any((term) => term.toLowerCase().contains(normalized));
  }

  Iterable<String> get _haystack sync* {
    yield id;
    yield kind.name;
    yield kind.label;
    yield sourceId;
    yield sourceLabel;
    yield title;
    yield detail;
    yield severity.name;
    yield severity.label;
    yield occurredAt.toIso8601String();
    yield _ifNotNull(channelId);
    yield _ifNotNull(channelLabel);
    yield _ifNotNull(orderId);
    yield _ifNotNull(fulfillmentModeKey);
    yield _ifNotNull(fulfillmentModeLabel);
    yield _ifNotNull(supportSummary);
    yield* searchTerms;
    yield* attributes.keys;
    yield* attributes.values;
  }
}

class OmniChannelActivityFeed {
  final List<OmniChannelActivityEntry> entries;

  OmniChannelActivityFeed({
    Iterable<OmniChannelActivityEntry> entries = const [],
  }) : entries = List.unmodifiable(_sortEntries(entries));

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  int get attentionCount {
    return entries.where((entry) => entry.requiresAttention).length;
  }

  int get reviewCount {
    return entries.where((entry) => entry.requiresReview).length;
  }

  int get orderCount {
    return entries
        .where((entry) => entry.kind == OmniChannelActivityKind.order)
        .length;
  }

  int get orderSyncCount {
    return entries
        .where((entry) => entry.kind == OmniChannelActivityKind.orderSync)
        .length;
  }

  int get channelSwitchCount {
    return entries
        .where((entry) => entry.kind == OmniChannelActivityKind.channelSwitch)
        .length;
  }

  int get switchActionCount {
    return entries
        .where((entry) => entry.kind == OmniChannelActivityKind.switchAction)
        .length;
  }

  List<OmniChannelActivityEntry> get attentionEntries {
    return entries
        .where((entry) => entry.requiresAttention)
        .toList(growable: false);
  }

  List<OmniChannelActivityEntry> get reviewEntries {
    return entries
        .where((entry) => entry.requiresReview)
        .toList(growable: false);
  }

  List<OmniChannelActivityEntry> forOrder(String orderId) {
    final normalized = orderId.trim();
    return entries
        .where((entry) => entry.orderId == normalized)
        .toList(growable: false);
  }

  List<OmniChannelActivityEntry> forChannel(String channelId) {
    final normalized = channelId.trim();
    return entries
        .where((entry) => entry.channelId == normalized)
        .toList(growable: false);
  }

  List<OmniChannelActivityEntry> search(String query) {
    return entries
        .where((entry) => entry.matchesQuery(query))
        .toList(growable: false);
  }
}

extension OmniChannelActivitySeverityLabel on OmniChannelActivitySeverity {
  String get label {
    switch (this) {
      case OmniChannelActivitySeverity.ready:
        return 'Ready';
      case OmniChannelActivitySeverity.review:
        return 'Review';
      case OmniChannelActivitySeverity.attention:
        return 'Attention';
    }
  }
}

extension OmniChannelActivityKindLabel on OmniChannelActivityKind {
  String get label {
    switch (this) {
      case OmniChannelActivityKind.order:
        return 'Order';
      case OmniChannelActivityKind.orderSync:
        return 'Order sync';
      case OmniChannelActivityKind.channelSwitch:
        return 'Channel switch';
      case OmniChannelActivityKind.switchAction:
        return 'Switch action';
      case OmniChannelActivityKind.fulfillment:
        return 'Fulfillment';
      case OmniChannelActivityKind.payment:
        return 'Payment';
      case OmniChannelActivityKind.system:
        return 'System';
    }
  }
}

String _ifNotNull(String? value) {
  return value ?? '';
}

List<OmniChannelActivityEntry> _sortEntries(
  Iterable<OmniChannelActivityEntry> entries,
) {
  final next = entries.toList();
  next.sort((left, right) {
    final timeComparison = right.occurredAt.compareTo(left.occurredAt);
    if (timeComparison != 0) return timeComparison;
    return right.id.compareTo(left.id);
  });
  return next;
}
