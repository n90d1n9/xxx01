import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_queue_filter.dart';

void main() {
  test('follow-up work queue filter matches status source and owner', () {
    const filter = BillingFollowUpWorkQueueFilter(
      status: BillingFollowUpWorkStatus.ready,
      source: BillingFollowUpWorkSource.collections,
      ownerRole: 'Billing owner',
    );

    expect(filter.matches(_item(id: 'ready')), isTrue);
    expect(
      filter.matches(
        _item(id: 'scheduled', status: BillingFollowUpWorkStatus.scheduled),
      ),
      isFalse,
    );
    expect(
      filter.matches(
        _item(
          id: 'external',
          source: BillingFollowUpWorkSource.reliefMonitoring,
        ),
      ),
      isFalse,
    );
    expect(
      filter.matches(_item(id: 'owner', ownerRole: 'Finance owner')),
      isFalse,
    );
  });

  test('follow-up work queue filter applies display queue', () {
    final queue = BillingFollowUpWorkQueue(
      title: 'Billing work center',
      sourceLabel: 'All sources',
      blockers: const ['Resolve approvals'],
      items: [
        _item(id: 'ready'),
        _item(id: 'blocked', status: BillingFollowUpWorkStatus.blocked),
      ],
    );

    final readyQueue = const BillingFollowUpWorkQueueFilter(
      status: BillingFollowUpWorkStatus.ready,
    ).applyTo(queue);
    final blockedQueue = const BillingFollowUpWorkQueueFilter(
      status: BillingFollowUpWorkStatus.blocked,
    ).applyTo(queue);

    expect(readyQueue.items.map((item) => item.id), ['ready']);
    expect(readyQueue.blockers, isEmpty);
    expect(blockedQueue.items.map((item) => item.id), ['blocked']);
    expect(blockedQueue.blockers, ['Resolve approvals']);
  });

  test('follow-up work queue filter resets active filters', () {
    final filter = const BillingFollowUpWorkQueueFilter(
      status: BillingFollowUpWorkStatus.ready,
      source: BillingFollowUpWorkSource.collections,
      ownerRole: 'Billing owner',
    );

    expect(filter.activeFilterCount, 3);
    expect(filter.reset().isDefault, isTrue);
    expect(filter.withStatus(null).status, isNull);
    expect(filter.withSource(null).source, isNull);
    expect(filter.withOwnerRole(null).ownerRole, isNull);
    expect(filter.copyWith(ownerRole: '').normalizedOwnerRole, isNull);
  });
}

BillingFollowUpWorkItem _item({
  required String id,
  BillingFollowUpWorkStatus status = BillingFollowUpWorkStatus.ready,
  BillingFollowUpWorkSource source = BillingFollowUpWorkSource.collections,
  String ownerRole = 'Billing owner',
}) {
  return BillingFollowUpWorkItem(
    id: id,
    source: source,
    priority: BillingFollowUpWorkPriority.normal,
    status: status,
    title: 'Work $id',
    description: 'Follow-up work item.',
    ownerRole: ownerRole,
    dueInDays: 0,
  );
}
