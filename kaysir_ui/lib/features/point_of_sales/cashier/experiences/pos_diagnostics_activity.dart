import '../../order/utils/order_save_outbox.dart';
import '../../order/utils/order_save_outbox_activity.dart';
import '../../order/utils/order_save_outbox_activity_display.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_switch_history.dart';
import 'pos_switch_action_history.dart';
import 'pos_switch_action_result.dart';
import 'pos_switch_action_text.dart';

enum POSDiagnosticsActivitySource { channelSwitch, switchAction, orderSync }

enum POSDiagnosticsActivitySeverity { ready, review, attention }

enum POSDiagnosticsActivityFilterStatus {
  all,
  attention,
  review,
  channelSwitches,
  switchActions,
  orderSync,
}

class POSDiagnosticsActivityEntry {
  final String id;
  final POSDiagnosticsActivitySource source;
  final DateTime occurredAt;
  final String title;
  final String detail;
  final POSDiagnosticsActivitySeverity severity;
  final String? supportSummary;
  final List<String> searchTerms;

  POSDiagnosticsActivityEntry({
    required this.id,
    required this.source,
    required this.occurredAt,
    required this.title,
    required this.detail,
    bool requiresAttention = false,
    POSDiagnosticsActivitySeverity? severity,
    this.supportSummary,
    Iterable<String> searchTerms = const [],
  }) : severity =
           severity ??
           (requiresAttention
               ? POSDiagnosticsActivitySeverity.attention
               : POSDiagnosticsActivitySeverity.ready),
       searchTerms = List.unmodifiable(searchTerms);

  bool get requiresAttention =>
      severity == POSDiagnosticsActivitySeverity.attention;

  bool get requiresReview => severity == POSDiagnosticsActivitySeverity.review;

  bool get needsReview => severity != POSDiagnosticsActivitySeverity.ready;

  factory POSDiagnosticsActivityEntry.fromChannelSwitch(
    POSCommerceChannelSwitchHistoryEntry entry,
  ) {
    final result = entry.result;
    final layout = result.plan.targetLayoutPreference.label;
    final fulfillment = result.resolvedFulfillmentContext.mode.label;
    final detail =
        result.requiresAttention
            ? '$layout layout, $fulfillment fulfillment, review required.'
            : result.activeOrderPreserved
            ? '$layout layout, $fulfillment fulfillment, order preserved.'
            : '$layout layout, $fulfillment fulfillment.';

    return POSDiagnosticsActivityEntry(
      id: entry.id,
      source: POSDiagnosticsActivitySource.channelSwitch,
      occurredAt: entry.occurredAt,
      title: entry.summaryLabel,
      detail: detail,
      requiresAttention: entry.requiresAttention,
      searchTerms: [
        'channel switch',
        'commerce channel',
        entry.result.plan.targetChannel.label,
        layout,
        fulfillment,
        ...entry.searchTerms,
      ],
    );
  }

  factory POSDiagnosticsActivityEntry.fromSwitchAction(
    POSSwitchActionHistoryEntry entry,
  ) {
    final result = entry.result;
    final text = POSSwitchActionText.fromResult(result);

    return POSDiagnosticsActivityEntry(
      id: entry.id,
      source: POSDiagnosticsActivitySource.switchAction,
      occurredAt: entry.occurredAt,
      title: entry.summaryLabel,
      detail: text.historyMessage,
      severity: _severityForSwitchAction(result.outcome),
      supportSummary: result.applied ? null : text.supportSummary,
      searchTerms: [
        'switch action',
        'switch attempt',
        _severityForSwitchAction(result.outcome).label,
        result.kindLabel,
        result.outcomeLabel,
        text.feedbackMessage,
        text.historyMessage,
        text.supportSummary,
        if (text.operatorGuidance != null) text.operatorGuidance!,
        ...entry.searchTerms,
      ],
    );
  }

  factory POSDiagnosticsActivityEntry.fromOutboxActivity(
    POSOrderSaveOutboxActivity activity,
  ) {
    final display = POSOrderSaveOutboxActivityDisplay.fromActivity(activity);

    return POSDiagnosticsActivityEntry(
      id:
          'order_sync_${activity.occurredAt.microsecondsSinceEpoch}_'
          '${activity.type.name}_${activity.idempotencyKey ?? activity.count ?? 0}',
      source: POSDiagnosticsActivitySource.orderSync,
      occurredAt: activity.occurredAt,
      title: display.title,
      detail: display.detail,
      requiresAttention: activity.type == POSOrderSaveOutboxActivityType.failed,
      searchTerms: [
        'order sync',
        'outbox',
        activity.type.name,
        display.title,
        display.detail,
        activity.orderId ?? '',
        activity.message ?? '',
        activity.idempotencyKey ?? '',
      ],
    );
  }

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return _haystack.any((term) => term.toLowerCase().contains(normalized));
  }

  Iterable<String> get _haystack sync* {
    yield id;
    yield source.name;
    yield source.label;
    yield title;
    yield detail;
    yield requiresAttention ? 'attention' : 'ready';
    yield severity.name;
    yield severity.label;
    yield occurredAt.toIso8601String();
    yield* searchTerms;
  }
}

class POSDiagnosticsActivitySnapshot {
  final List<POSDiagnosticsActivityEntry> entries;

  POSDiagnosticsActivitySnapshot({
    Iterable<POSDiagnosticsActivityEntry> entries = const [],
  }) : entries = List.unmodifiable(_sortEntries(entries));

  factory POSDiagnosticsActivitySnapshot.fromSources({
    required POSCommerceChannelSwitchHistory switchHistory,
    POSSwitchActionHistory switchActionHistory =
        const POSSwitchActionHistory.empty(),
    required POSOrderSaveOutbox outbox,
  }) {
    return POSDiagnosticsActivitySnapshot(
      entries: [
        for (final entry in switchHistory.entries)
          POSDiagnosticsActivityEntry.fromChannelSwitch(entry),
        for (final entry in switchActionHistory.entries)
          POSDiagnosticsActivityEntry.fromSwitchAction(entry),
        for (final activity in outbox.activity)
          POSDiagnosticsActivityEntry.fromOutboxActivity(activity),
      ],
    );
  }

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  int get attentionCount {
    return entries.where((entry) => entry.requiresAttention).length;
  }

  int get reviewCount {
    return entries.where((entry) => entry.requiresReview).length;
  }

  List<POSDiagnosticsActivityEntry> get attentionEntries {
    return entries
        .where((entry) => entry.requiresAttention)
        .toList(growable: false);
  }

  List<POSDiagnosticsActivityEntry> get reviewEntries {
    return entries
        .where((entry) => entry.requiresReview)
        .toList(growable: false);
  }

  int get channelSwitchCount {
    return entries
        .where(
          (entry) => entry.source == POSDiagnosticsActivitySource.channelSwitch,
        )
        .length;
  }

  int get orderSyncCount {
    return entries
        .where(
          (entry) => entry.source == POSDiagnosticsActivitySource.orderSync,
        )
        .length;
  }

  int get switchActionCount {
    return entries
        .where(
          (entry) => entry.source == POSDiagnosticsActivitySource.switchAction,
        )
        .length;
  }

  POSDiagnosticsActivityFilterCounts countsForQuery(String query) {
    final visible = entries.where((entry) => entry.matchesQuery(query));
    return POSDiagnosticsActivityFilterCounts.fromEntries(visible);
  }

  List<POSDiagnosticsActivityEntry> apply(POSDiagnosticsActivityFilter filter) {
    return entries.where(filter.matches).toList(growable: false);
  }
}

class POSDiagnosticsActivityFilter {
  final String query;
  final POSDiagnosticsActivityFilterStatus status;

  const POSDiagnosticsActivityFilter({
    this.query = '',
    this.status = POSDiagnosticsActivityFilterStatus.all,
  });

  bool matches(POSDiagnosticsActivityEntry entry) {
    return entry.matchesQuery(query) && _matchesStatus(entry);
  }

  POSDiagnosticsActivityFilter copyWith({
    String? query,
    POSDiagnosticsActivityFilterStatus? status,
  }) {
    return POSDiagnosticsActivityFilter(
      query: query ?? this.query,
      status: status ?? this.status,
    );
  }

  bool _matchesStatus(POSDiagnosticsActivityEntry entry) {
    switch (status) {
      case POSDiagnosticsActivityFilterStatus.all:
        return true;
      case POSDiagnosticsActivityFilterStatus.attention:
        return entry.requiresAttention;
      case POSDiagnosticsActivityFilterStatus.review:
        return entry.requiresReview;
      case POSDiagnosticsActivityFilterStatus.channelSwitches:
        return entry.source == POSDiagnosticsActivitySource.channelSwitch;
      case POSDiagnosticsActivityFilterStatus.switchActions:
        return entry.source == POSDiagnosticsActivitySource.switchAction;
      case POSDiagnosticsActivityFilterStatus.orderSync:
        return entry.source == POSDiagnosticsActivitySource.orderSync;
    }
  }
}

class POSDiagnosticsActivityFilterCounts {
  final int all;
  final int attention;
  final int review;
  final int channelSwitches;
  final int switchActions;
  final int orderSync;

  const POSDiagnosticsActivityFilterCounts({
    required this.all,
    required this.attention,
    required this.review,
    required this.channelSwitches,
    required this.switchActions,
    required this.orderSync,
  });

  factory POSDiagnosticsActivityFilterCounts.fromEntries(
    Iterable<POSDiagnosticsActivityEntry> entries,
  ) {
    var all = 0;
    var attention = 0;
    var review = 0;
    var channelSwitches = 0;
    var switchActions = 0;
    var orderSync = 0;

    for (final entry in entries) {
      all += 1;
      if (entry.requiresAttention) attention += 1;
      if (entry.requiresReview) review += 1;
      switch (entry.source) {
        case POSDiagnosticsActivitySource.channelSwitch:
          channelSwitches += 1;
        case POSDiagnosticsActivitySource.switchAction:
          switchActions += 1;
        case POSDiagnosticsActivitySource.orderSync:
          orderSync += 1;
      }
    }

    return POSDiagnosticsActivityFilterCounts(
      all: all,
      attention: attention,
      review: review,
      channelSwitches: channelSwitches,
      switchActions: switchActions,
      orderSync: orderSync,
    );
  }

  int countFor(POSDiagnosticsActivityFilterStatus status) {
    switch (status) {
      case POSDiagnosticsActivityFilterStatus.all:
        return all;
      case POSDiagnosticsActivityFilterStatus.attention:
        return attention;
      case POSDiagnosticsActivityFilterStatus.review:
        return review;
      case POSDiagnosticsActivityFilterStatus.channelSwitches:
        return channelSwitches;
      case POSDiagnosticsActivityFilterStatus.switchActions:
        return switchActions;
      case POSDiagnosticsActivityFilterStatus.orderSync:
        return orderSync;
    }
  }
}

extension POSDiagnosticsActivitySeverityLabel
    on POSDiagnosticsActivitySeverity {
  String get label {
    switch (this) {
      case POSDiagnosticsActivitySeverity.ready:
        return 'Ready';
      case POSDiagnosticsActivitySeverity.review:
        return 'Review';
      case POSDiagnosticsActivitySeverity.attention:
        return 'Attention';
    }
  }
}

extension POSDiagnosticsActivitySourceLabel on POSDiagnosticsActivitySource {
  String get label {
    switch (this) {
      case POSDiagnosticsActivitySource.channelSwitch:
        return 'Channel';
      case POSDiagnosticsActivitySource.switchAction:
        return 'Switch';
      case POSDiagnosticsActivitySource.orderSync:
        return 'Order sync';
    }
  }
}

extension POSDiagnosticsActivityFilterStatusLabel
    on POSDiagnosticsActivityFilterStatus {
  String get label {
    switch (this) {
      case POSDiagnosticsActivityFilterStatus.all:
        return 'All';
      case POSDiagnosticsActivityFilterStatus.attention:
        return 'Attention';
      case POSDiagnosticsActivityFilterStatus.review:
        return 'Review';
      case POSDiagnosticsActivityFilterStatus.channelSwitches:
        return 'Channel';
      case POSDiagnosticsActivityFilterStatus.switchActions:
        return 'Switches';
      case POSDiagnosticsActivityFilterStatus.orderSync:
        return 'Order sync';
    }
  }
}

POSDiagnosticsActivitySeverity _severityForSwitchAction(
  POSSwitchActionOutcome outcome,
) {
  switch (outcome) {
    case POSSwitchActionOutcome.applied:
      return POSDiagnosticsActivitySeverity.ready;
    case POSSwitchActionOutcome.blocked:
      return POSDiagnosticsActivitySeverity.attention;
    case POSSwitchActionOutcome.cancelled:
      return POSDiagnosticsActivitySeverity.review;
  }
}

List<POSDiagnosticsActivityEntry> _sortEntries(
  Iterable<POSDiagnosticsActivityEntry> entries,
) {
  final next = entries.toList();
  next.sort((left, right) {
    final timeComparison = right.occurredAt.compareTo(left.occurredAt);
    if (timeComparison != 0) return timeComparison;
    return right.id.compareTo(left.id);
  });
  return next;
}
