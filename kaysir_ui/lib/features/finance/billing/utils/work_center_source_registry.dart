import '../models/billing_invoice.dart';
import '../models/billing_tenant_preferences.dart';
import '../models/follow_up_work_item.dart';
import 'billing_collection_tasks.dart';
import 'collection_follow_up_queue.dart';
import 'follow_up_work_queue_registry.dart';

/// Tenant-scoped data available to billing work-center source adapters.
class BillingWorkCenterSourceContext {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final List<BillingInvoice> invoices;
  final int collectionLimit;
  final DateTime? now;

  BillingWorkCenterSourceContext({
    required this.tenantId,
    required this.preferences,
    Iterable<BillingInvoice> invoices = const [],
    required this.collectionLimit,
    this.now,
  }) : assert(collectionLimit > 0),
       invoices = List.unmodifiable(invoices);

  bool get hasTenant => tenantId.trim().isNotEmpty;

  bool get hasInvoices => invoices.isNotEmpty;
}

/// Builds one follow-up queue for a work-center source adapter.
typedef BillingWorkCenterSourceQueueBuilder =
    BillingFollowUpWorkQueue Function(BillingWorkCenterSourceContext context);

/// Source adapter that contributes one queue into the billing work center.
class BillingWorkCenterSourceAdapter {
  final String id;
  final String label;
  final BillingWorkCenterSourceQueueBuilder buildQueue;

  const BillingWorkCenterSourceAdapter({
    required this.id,
    required this.label,
    required this.buildQueue,
  });
}

/// Registry for modular work-center source adapters.
class BillingWorkCenterSourceRegistry {
  final List<BillingWorkCenterSourceAdapter> adapters;

  BillingWorkCenterSourceRegistry({
    Iterable<BillingWorkCenterSourceAdapter> adapters = const [],
  }) : adapters = List.unmodifiable(_validateAdapters(adapters));

  /// Standard source registry for the shared billing management module.
  factory BillingWorkCenterSourceRegistry.standard() {
    return BillingWorkCenterSourceRegistry(
      adapters: standardBillingWorkCenterSourceAdapters,
    );
  }

  bool get isEmpty => adapters.isEmpty;

  bool get isNotEmpty => adapters.isNotEmpty;

  int get adapterCount => adapters.length;

  /// Appends additional source adapters while preserving existing ones.
  BillingWorkCenterSourceRegistry withAdapters(
    Iterable<BillingWorkCenterSourceAdapter> additionalAdapters,
  ) {
    return BillingWorkCenterSourceRegistry(
      adapters: [...adapters, ...additionalAdapters],
    );
  }

  /// Replaces matching adapter ids and appends new ids from the overrides.
  BillingWorkCenterSourceRegistry withOverrides(
    Iterable<BillingWorkCenterSourceAdapter> overrides,
  ) {
    final overrideMap = _indexAdapters(overrides);

    return BillingWorkCenterSourceRegistry(
      adapters: [
        for (final adapter in adapters)
          if (!overrideMap.containsKey(adapter.id)) adapter,
        ...overrideMap.values,
      ],
    );
  }

  /// Builds the aggregate follow-up queue for the supplied tenant context.
  BillingFollowUpWorkQueue buildQueue(
    BillingWorkCenterSourceContext context, {
    String title = 'Billing work center',
    String sourceLabel = 'All sources',
    bool deduplicate = true,
  }) {
    final registry = BillingFollowUpWorkQueueRegistry(
      adapters: [
        for (final adapter in adapters)
          BillingFollowUpWorkQueueSourceAdapter(
            id: adapter.id,
            label: adapter.label,
            buildQueue: () => adapter.buildQueue(context),
          ),
      ],
    );

    return registry.buildQueue(
      title: title,
      sourceLabel: sourceLabel,
      deduplicate: deduplicate,
    );
  }

  static Map<String, BillingWorkCenterSourceAdapter> _indexAdapters(
    Iterable<BillingWorkCenterSourceAdapter> adapters,
  ) {
    final indexed = <String, BillingWorkCenterSourceAdapter>{};

    for (final adapter in _validateAdapters(adapters)) {
      if (indexed.containsKey(adapter.id)) {
        throw ArgumentError.value(
          adapter.id,
          'adapter.id',
          'Duplicate work-center source adapter id',
        );
      }
      indexed[adapter.id] = adapter;
    }

    return Map.unmodifiable(indexed);
  }

  static List<BillingWorkCenterSourceAdapter> _validateAdapters(
    Iterable<BillingWorkCenterSourceAdapter> adapters,
  ) {
    final validated = <BillingWorkCenterSourceAdapter>[];
    final seenIds = <String>{};

    for (final adapter in adapters) {
      if (adapter.id.trim().isEmpty) {
        throw ArgumentError.value(
          adapter.id,
          'adapter.id',
          'Work-center source adapter id cannot be blank',
        );
      }
      if (adapter.label.trim().isEmpty) {
        throw ArgumentError.value(
          adapter.label,
          'adapter.label',
          'Work-center source adapter label cannot be blank',
        );
      }
      if (!seenIds.add(adapter.id)) {
        throw ArgumentError.value(
          adapter.id,
          'adapter.id',
          'Duplicate work-center source adapter id',
        );
      }
      validated.add(adapter);
    }

    return validated;
  }
}

/// Standard source adapters used by the shared billing work center.
final List<BillingWorkCenterSourceAdapter>
standardBillingWorkCenterSourceAdapters = List.unmodifiable([
  BillingWorkCenterSourceAdapter(
    id: 'core.collections',
    label: BillingFollowUpWorkSource.collections.label,
    buildQueue: _buildCollectionWorkCenterQueue,
  ),
]);

BillingFollowUpWorkQueue _buildCollectionWorkCenterQueue(
  BillingWorkCenterSourceContext context,
) {
  final collectionTasks = buildBillingCollectionTasks(
    context.invoices,
    preferences: context.preferences,
    now: context.now,
    limit: context.collectionLimit,
  );

  return buildCollectionFollowUpWorkQueue(tasks: collectionTasks);
}
