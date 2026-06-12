import '../models/follow_up_work_item.dart';

/// Builder callback for a queue source adapter.
typedef BillingFollowUpWorkQueueBuilder = BillingFollowUpWorkQueue Function();

/// Adapter that contributes domain-specific work into the billing work center.
class BillingFollowUpWorkQueueSourceAdapter {
  final String id;
  final String label;
  final BillingFollowUpWorkQueueBuilder buildQueue;

  const BillingFollowUpWorkQueueSourceAdapter({
    required this.id,
    required this.label,
    required this.buildQueue,
  });
}

/// Registry that aggregates follow-up work from many billing domains.
class BillingFollowUpWorkQueueRegistry {
  final List<BillingFollowUpWorkQueueSourceAdapter> adapters;

  BillingFollowUpWorkQueueRegistry({
    Iterable<BillingFollowUpWorkQueueSourceAdapter> adapters = const [],
  }) : adapters = List.unmodifiable(adapters);

  bool get isEmpty => adapters.isEmpty;

  bool get isNotEmpty => adapters.isNotEmpty;

  int get adapterCount => adapters.length;

  BillingFollowUpWorkQueue buildQueue({
    String title = 'Billing work center',
    String sourceLabel = 'All sources',
    bool deduplicate = true,
  }) {
    final items = <BillingFollowUpWorkItem>[];
    final blockers = <String>[];
    final seenItemKeys = <String>{};

    for (final adapter in adapters) {
      final queue = adapter.buildQueue();

      for (final blocker in queue.blockers) {
        blockers.add('${queue.sourceLabel}: $blocker');
      }

      for (final item in queue.items) {
        final itemKey = '${item.source.name}:${item.id}';
        if (deduplicate && !seenItemKeys.add(itemKey)) continue;
        items.add(item);
      }
    }

    items.sort((a, b) {
      final rankCompare = a.sortRank.compareTo(b.sortRank);
      if (rankCompare != 0) return rankCompare;

      final sourceCompare = a.source.label.compareTo(b.source.label);
      if (sourceCompare != 0) return sourceCompare;

      return a.title.compareTo(b.title);
    });

    return BillingFollowUpWorkQueue(
      title: title,
      sourceLabel: sourceLabel,
      items: items,
      blockers: blockers,
    );
  }
}
