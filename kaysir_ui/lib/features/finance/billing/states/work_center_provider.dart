import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_tenant_preferences.dart';
import '../models/follow_up_work_item.dart';
import '../models/follow_up_work_queue_filter.dart';
import '../utils/follow_up_work_action_registry.dart';
import '../utils/work_center_source_registry.dart';
import 'billing_dashboard_provider.dart';

/// Request used to compose tenant-scoped work center follow-up queues.
class BillingWorkCenterRequest {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final int collectionLimit;
  final DateTime? now;

  const BillingWorkCenterRequest({
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.collectionLimit = 8,
    this.now,
  }) : assert(collectionLimit > 0);

  bool get hasTenant => tenantId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingWorkCenterRequest &&
            other.tenantId == tenantId &&
            other.preferences == preferences &&
            other.collectionLimit == collectionLimit &&
            other.now == now;
  }

  @override
  int get hashCode {
    return Object.hash(tenantId, preferences, collectionLimit, now);
  }
}

/// Provides the unified billing work center queue for a tenant workspace.
final billingWorkCenterQueueProvider = Provider.family<
  AsyncValue<BillingFollowUpWorkQueue>,
  BillingWorkCenterRequest
>((ref, request) {
  if (!request.hasTenant) {
    return AsyncValue.data(_emptyBillingWorkCenterQueue());
  }

  final invoicesAsync = ref.watch(billingInvoicesProvider(request.tenantId));
  final sourceRegistry = ref.watch(billingWorkCenterSourceRegistryProvider);

  return invoicesAsync.whenData((invoices) {
    return sourceRegistry.buildQueue(
      BillingWorkCenterSourceContext(
        tenantId: request.tenantId,
        invoices: invoices,
        preferences: request.preferences,
        collectionLimit: request.collectionLimit,
        now: request.now,
      ),
    );
  });
});

/// Provides modular source adapters for the billing work-center queue.
final billingWorkCenterSourceRegistryProvider =
    Provider<BillingWorkCenterSourceRegistry>(
      (ref) => BillingWorkCenterSourceRegistry.standard(),
    );

/// Provides source-specific navigation actions for work-center items.
final billingWorkCenterActionRegistryProvider =
    Provider<BillingFollowUpWorkActionRegistry>(
      (ref) => BillingFollowUpWorkActionRegistry.standard(),
    );

/// Provides tenant-scoped filter state for the billing work-center queue.
final billingWorkCenterQueueFilterProvider =
    StateProvider.family<BillingFollowUpWorkQueueFilter, String>(
      (ref, tenantId) => const BillingFollowUpWorkQueueFilter(),
    );

BillingFollowUpWorkQueue _emptyBillingWorkCenterQueue() {
  return BillingFollowUpWorkQueue(
    title: 'Billing work center',
    sourceLabel: 'All sources',
  );
}
