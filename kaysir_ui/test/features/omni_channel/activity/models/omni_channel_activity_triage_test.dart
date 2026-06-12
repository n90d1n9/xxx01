import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';

void main() {
  test('omni-channel activity triage ranks source and channel work', () {
    final queue = _feed().triageQueueFor(const OmniChannelActivityFilter());

    expect(
      queue.groups.map(
        (group) =>
            '${group.dimension.key}:${group.label}:'
            '${group.attentionCount}:${group.reviewCount}:'
            '${group.latestEntry?.id}',
      ),
      [
        'channel:Marketplace:1:1:pos-sync',
        'source:Ecommerce:1:1:ecommerce-review',
        'source:Point of sale:1:0:pos-sync',
        'channel:Web store:1:0:ecommerce-attention',
        'fulfillment:Delivery:1:0:ecommerce-attention',
        'fulfillment:Pickup:0:1:ecommerce-review',
      ],
    );
    expect(queue.attentionCount, 2);
    expect(queue.reviewCount, 1);
  });

  test('omni-channel activity triage summarizes operator focus', () {
    final summary =
        _feed().triageQueueFor(const OmniChannelActivityFilter()).summary;

    expect(summary.severity, OmniChannelActivitySeverity.attention);
    expect(summary.queueCount, 6);
    expect(summary.totalQueueCount, 6);
    expect(summary.hiddenQueueCount, 0);
    expect(summary.hasHiddenQueues, isFalse);
    expect(summary.overflowLabel, isEmpty);
    expect(summary.attentionCount, 2);
    expect(summary.reviewCount, 1);
    expect(summary.focusGroup?.label, 'Marketplace');
    expect(summary.headline, 'Focus on Marketplace');
    expect(summary.detail, '1 attention and 1 review across channel queue.');
    expect(summary.actionLabel, 'Open channel queue');

    const empty = OmniChannelActivityTriageQueue.empty();

    expect(empty.summary.hasWork, isFalse);
    expect(empty.summary.headline, 'All triage queues are clear');
  });

  test('omni-channel activity triage exposes hidden queue overflow', () {
    final queue = _feed().triageQueueFor(
      const OmniChannelActivityFilter(),
      limit: 3,
    );
    final summary = queue.summary;

    expect(queue.visibleGroupCount, 3);
    expect(queue.totalGroupCount, 6);
    expect(queue.hiddenGroupCount, 3);
    expect(queue.hasHiddenGroups, isTrue);
    expect(queue.groups.map((group) => group.label), [
      'Marketplace',
      'Ecommerce',
      'Point of sale',
    ]);
    expect(summary.queueCount, 3);
    expect(summary.totalQueueCount, 6);
    expect(summary.hiddenQueueCount, 3);
    expect(summary.hasHiddenQueues, isTrue);
    expect(summary.overflowLabel, '3 more queues available');

    final expandedQueue = _feed().triageQueueFor(
      const OmniChannelActivityFilter(),
      limit: null,
    );

    expect(expandedQueue.visibleGroupCount, 6);
    expect(expandedQueue.totalGroupCount, 6);
    expect(expandedQueue.hiddenGroupCount, 0);
    expect(expandedQueue.hasHiddenGroups, isFalse);
  });

  test('omni-channel activity triage respects current context', () {
    final queue = _feed().triageQueueFor(
      const OmniChannelActivityFilter(query: 'web'),
    );

    expect(queue.groups.map((group) => group.label), [
      'Ecommerce',
      'Web store',
      'Delivery',
    ]);
  });

  test('omni-channel activity triage group builds focused filter', () {
    final queue = _feed().triageQueueFor(const OmniChannelActivityFilter());
    final group = queue.groups.first;
    final nextFilter = group.toFilter(
      const OmniChannelActivityFilter(
        query: 'pickup',
        status: OmniChannelActivityFilterStatus.orders,
      ),
    );

    expect(nextFilter.query, 'pickup');
    expect(nextFilter.status, OmniChannelActivityFilterStatus.attention);
    expect(nextFilter.channelId, 'marketplace');
    expect(group.isSelectedBy(nextFilter), isTrue);
  });

  test('omni-channel activity triage ignores duplicate dimension keys', () {
    final queue = _feed().triageQueueFor(
      const OmniChannelActivityFilter(),
      dimensions: [
        defaultOmniChannelActivityTriageDimensionDefinitions.first,
        _duplicateSourceTriageDefinition,
      ],
      limit: null,
    );

    expect(
      queue.groups.map(
        (group) => '${group.dimension.key}:${group.label}:${group.totalCount}',
      ),
      ['source:Ecommerce:2', 'source:Point of sale:1'],
    );
    expect(queue.totalGroupCount, 2);
    expect(queue.attentionCount, 2);
    expect(queue.reviewCount, 1);
    expect(queue.groups.first.entries.map((entry) => entry.id), [
      'ecommerce-review',
      'ecommerce-attention',
    ]);
  });

  test('omni-channel activity triage accepts module dimensions', () {
    final queue = _feed().triageQueueFor(
      const OmniChannelActivityFilter(),
      dimensions: [_orderTriageDefinition],
    );

    expect(
      queue.groups.map(
        (group) =>
            '${group.dimension.key}:${group.label}:'
            '${group.attentionCount}:${group.reviewCount}',
      ),
      ['order:ECOM-1:1:1', 'order:ECOM-2:1:0'],
    );

    final nextFilter = queue.groups.first.toFilter(
      const OmniChannelActivityFilter(query: 'marketplace'),
    );

    expect(nextFilter.query, 'marketplace');
    expect(nextFilter.status, OmniChannelActivityFilterStatus.attention);
    expect(nextFilter.orderId, 'ECOM-1');
    expect(queue.groups.first.isSelectedBy(nextFilter), isTrue);
  });
}

final _orderTriageDefinition = OmniChannelActivityTriageDimensionDefinition(
  dimension: const OmniChannelActivityTriageDimension(
    key: 'order',
    label: 'Order',
    sortOrder: 0,
  ),
  resolve: (entry) {
    final orderId = entry.orderId?.trim();
    if (orderId == null || orderId.isEmpty) return null;

    return OmniChannelActivityTriageValue(id: orderId, label: orderId);
  },
  applyFilter:
      ({
        required OmniChannelActivityFilter baseFilter,
        required String id,
        required OmniChannelActivityFilterStatus status,
      }) => baseFilter.copyWith(status: status, orderId: id),
  isSelected:
      ({
        required OmniChannelActivityFilter filter,
        required String id,
        required OmniChannelActivityFilterStatus status,
      }) => filter.status == status && filter.orderId == id,
);

final _duplicateSourceTriageDefinition =
    OmniChannelActivityTriageDimensionDefinition(
      dimension: const OmniChannelActivityTriageDimension(
        key: OmniChannelActivityTriageDimension.sourceKey,
        label: 'Source copy',
        sortOrder: 99,
      ),
      resolve:
          (entry) => OmniChannelActivityTriageValue(
            id: entry.sourceId,
            label: entry.sourceLabel,
          ),
      applyFilter:
          ({
            required OmniChannelActivityFilter baseFilter,
            required String id,
            required OmniChannelActivityFilterStatus status,
          }) => baseFilter.copyWith(status: status, sourceId: id),
      isSelected:
          ({
            required OmniChannelActivityFilter filter,
            required String id,
            required OmniChannelActivityFilterStatus status,
          }) => filter.status == status && filter.sourceId == id,
    );

OmniChannelActivityFeed _feed() {
  return OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'pos-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 12),
        title: 'POS sync failed',
        detail: 'Marketplace order failed to sync.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-1',
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Marketplace pickup review',
        detail: 'Pickup capacity needs review.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-attention',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 10),
        title: 'Web handoff blocked',
        detail: 'Web store courier slot is blocked.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'web_store',
        channelLabel: 'Web store',
        orderId: 'ECOM-2',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
      ),
      OmniChannelActivityEntry(
        id: 'ready-payment',
        kind: OmniChannelActivityKind.payment,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 9),
        title: 'Payment accepted',
        detail: 'Ready payment should not create triage work.',
      ),
    ],
  );
}
