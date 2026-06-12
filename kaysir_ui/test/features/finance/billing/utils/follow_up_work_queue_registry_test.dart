import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/utils/follow_up_work_queue_registry.dart';

void main() {
  test('BillingFollowUpWorkQueueRegistry aggregates source adapters', () {
    final registry = BillingFollowUpWorkQueueRegistry(
      adapters: [
        BillingFollowUpWorkQueueSourceAdapter(
          id: 'relief',
          label: 'Relief',
          buildQueue:
              () => BillingFollowUpWorkQueue(
                title: 'Relief queue',
                sourceLabel: 'Relief',
                blockers: const ['Approval needed'],
                items: [
                  _item(
                    id: 'collect-1',
                    source: BillingFollowUpWorkSource.collections,
                    priority: BillingFollowUpWorkPriority.high,
                    status: BillingFollowUpWorkStatus.ready,
                    title: 'Collect invoice #1',
                  ),
                  _item(
                    id: 'relief-1',
                    source: BillingFollowUpWorkSource.reliefMonitoring,
                    priority: BillingFollowUpWorkPriority.urgent,
                    status: BillingFollowUpWorkStatus.blocked,
                    title: 'Resolve relief blocker',
                  ),
                ],
              ),
        ),
        BillingFollowUpWorkQueueSourceAdapter(
          id: 'subscription',
          label: 'Subscription',
          buildQueue:
              () => BillingFollowUpWorkQueue(
                title: 'Subscription queue',
                sourceLabel: 'Subscription',
                items: [
                  _item(
                    id: 'collect-1',
                    source: BillingFollowUpWorkSource.collections,
                    priority: BillingFollowUpWorkPriority.high,
                    status: BillingFollowUpWorkStatus.ready,
                    title: 'Duplicate collection item',
                  ),
                  _item(
                    id: 'renewal-1',
                    source: BillingFollowUpWorkSource.subscription,
                    priority: BillingFollowUpWorkPriority.normal,
                    status: BillingFollowUpWorkStatus.scheduled,
                    title: 'Review renewal',
                    dueInDays: 14,
                  ),
                ],
              ),
        ),
      ],
    );

    final queue = registry.buildQueue();

    expect(registry.adapterCount, 2);
    expect(queue.title, 'Billing work center');
    expect(queue.sourceLabel, 'All sources');
    expect(queue.totalCount, 3);
    expect(queue.readyCount, 1);
    expect(queue.blockedCount, 1);
    expect(queue.scheduledCount, 1);
    expect(queue.sourceCount, 3);
    expect(queue.blockers, ['Relief: Approval needed']);
    expect(queue.items.first.title, 'Resolve relief blocker');
    expect(
      queue.itemsForSource(BillingFollowUpWorkSource.subscription).single.title,
      'Review renewal',
    );
  });

  test('BillingFollowUpWorkQueueRegistry can keep duplicates', () {
    final duplicate = _item(
      id: 'same',
      source: BillingFollowUpWorkSource.collections,
      priority: BillingFollowUpWorkPriority.high,
      status: BillingFollowUpWorkStatus.ready,
      title: 'Same task',
    );
    final registry = BillingFollowUpWorkQueueRegistry(
      adapters: [
        BillingFollowUpWorkQueueSourceAdapter(
          id: 'one',
          label: 'One',
          buildQueue:
              () => BillingFollowUpWorkQueue(
                title: 'One',
                sourceLabel: 'One',
                items: [duplicate],
              ),
        ),
        BillingFollowUpWorkQueueSourceAdapter(
          id: 'two',
          label: 'Two',
          buildQueue:
              () => BillingFollowUpWorkQueue(
                title: 'Two',
                sourceLabel: 'Two',
                items: [duplicate],
              ),
        ),
      ],
    );

    expect(registry.buildQueue().totalCount, 1);
    expect(registry.buildQueue(deduplicate: false).totalCount, 2);
  });
}

BillingFollowUpWorkItem _item({
  required String id,
  required BillingFollowUpWorkSource source,
  required BillingFollowUpWorkPriority priority,
  required BillingFollowUpWorkStatus status,
  required String title,
  int dueInDays = 0,
}) {
  return BillingFollowUpWorkItem(
    id: id,
    source: source,
    priority: priority,
    status: status,
    title: title,
    description: '$title description',
    ownerRole: 'Billing owner',
    dueInDays: dueInDays,
  );
}
