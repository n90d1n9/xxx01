import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../models/billing_tenant_account.dart';
import '../models/follow_up_work_action_state.dart';
import '../models/follow_up_work_item.dart';
import '../models/follow_up_work_queue_filter.dart';
import '../repositories/billing_dashboard_repository.dart';
import '../states/billing_dashboard_provider.dart';
import '../states/billing_management_navigation_context_provider.dart';
import '../states/work_center_provider.dart';
import '../utils/billing_route_context.dart';
import '../utils/billing_route_locations.dart';
import '../utils/follow_up_work_action_registry.dart';
import 'billing_empty_state.dart';
import 'billing_management_navigation_scaffold.dart';
import 'billing_navigation_destination.dart';
import 'work_center_panel.dart';

/// Tenant-scoped billing screen for unified follow-up work across domains.
class BillingWorkCenterScreen extends ConsumerWidget {
  final String? initialTenantId;
  final String? initialBusinessDomain;

  const BillingWorkCenterScreen({
    super.key,
    this.initialTenantId,
    this.initialBusinessDomain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTenantId = ref.watch(selectedBillingTenantIdProvider);
    final tenantsAsync = ref.watch(billingTenantsProvider);
    final drawerTenant = tenantsAsync.maybeWhen(
      data:
          (tenants) => _selectedTenant(
            tenants: tenants,
            currentTenantId: currentTenantId,
          ),
      orElse: () => null,
    );
    final navigationContext = ref.watch(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.dashboard(
          preferences: drawerTenant?.preferences,
          tenantId: drawerTenant?.id,
          noTenantBusinessDomain: initialBusinessDomain,
          selectedDestinationId: BillingNavigationDestinationId.workCenter,
        ),
      ),
    );

    return BillingManagementNavigationScaffold(
      navigationContext: navigationContext,
      backgroundColor: const Color(0xFFF7F9FC),
      selectedDestination: BillingNavigationDestinationId.workCenter,
      tenantName: drawerTenant?.name,
      tenantSubtitle:
          drawerTenant?.planName.isNotEmpty == true
              ? '${drawerTenant!.planName} plan'
              : null,
      onDestinationSelected:
          (destination) => _openDestination(context, drawerTenant, destination),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Billing Work Center',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) =>
                const Center(child: Text('Error loading billing work center')),
        data: (tenants) {
          if (currentTenantId.isEmpty && tenants.isNotEmpty) {
            final initialTenant = _tenantForId(
              tenants: tenants,
              tenantId: initialTenantId,
            );
            Future.microtask(
              () =>
                  ref.read(selectedBillingTenantIdProvider.notifier).state =
                      (initialTenant ?? tenants.first).id,
            );
          }

          final selectedTenant = _selectedTenant(
            tenants: tenants,
            currentTenantId: currentTenantId,
          );
          if (selectedTenant.id.isEmpty) {
            return _WorkCenterEmptyTenantState(
              onOpenTenants:
                  () => _openDestination(
                    context,
                    selectedTenant,
                    BillingNavigationDestinationId.tenants,
                  ),
            );
          }

          final queueAsync = ref.watch(
            billingWorkCenterQueueProvider(
              BillingWorkCenterRequest(
                tenantId: selectedTenant.id,
                preferences: selectedTenant.preferences,
              ),
            ),
          );
          final actionRegistry = ref.watch(
            billingWorkCenterActionRegistryProvider,
          );
          final queueFilterProvider = billingWorkCenterQueueFilterProvider(
            selectedTenant.id,
          );
          final queueFilter = ref.watch(queueFilterProvider);

          return queueAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, stack) =>
                    const Center(child: Text('Error loading follow-up work')),
            data:
                (queue) => SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WorkCenterScreenHeader(tenant: selectedTenant),
                          const SizedBox(height: 16),
                          BillingWorkCenterPanel(
                            queue: queue,
                            maxVisibleItems: 8,
                            filter: queueFilter,
                            onStatusFilterChanged:
                                (status) => _setQueueFilter(
                                  ref,
                                  queueFilterProvider,
                                  queueFilter.withStatus(status),
                                ),
                            onSourceFilterChanged:
                                (source) => _setQueueFilter(
                                  ref,
                                  queueFilterProvider,
                                  queueFilter.withSource(source),
                                ),
                            onOwnerRoleFilterChanged:
                                (ownerRole) => _setQueueFilter(
                                  ref,
                                  queueFilterProvider,
                                  queueFilter.withOwnerRole(ownerRole),
                                ),
                            onResetFilters:
                                () => _setQueueFilter(
                                  ref,
                                  queueFilterProvider,
                                  queueFilter.reset(),
                                ),
                            actionStateBuilder:
                                (item) => _actionStateFor(actionRegistry, item),
                            onItemSelected:
                                (item) => _openWorkItem(
                                  context,
                                  selectedTenant,
                                  actionRegistry,
                                  item,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }

  BillingTenantAccount _selectedTenant({
    required List<BillingTenantAccount> tenants,
    required String currentTenantId,
  }) {
    final selectedTenant = tenants.firstWhere(
      (tenant) => tenant.id == currentTenantId,
      orElse:
          () =>
              tenants.isNotEmpty
                  ? tenants.first
                  : const BillingTenantAccount(
                    id: '',
                    name: 'No Tenant',
                    logoUrl: '',
                    planName: '',
                    currentBalance: 0,
                  ),
    );

    return billingTenantAccountWithRouteContext(
      selectedTenant,
      businessDomain: initialBusinessDomain,
    );
  }

  BillingTenantAccount? _tenantForId({
    required List<BillingTenantAccount> tenants,
    required String? tenantId,
  }) {
    final normalizedTenantId = tenantId?.trim();
    if (normalizedTenantId == null || normalizedTenantId.isEmpty) return null;

    for (final tenant in tenants) {
      if (tenant.id == normalizedTenantId) return tenant;
    }

    return null;
  }

  void _openDestination(
    BuildContext context,
    BillingTenantAccount? tenant,
    BillingNavigationDestinationId destination,
  ) {
    if (destination == BillingNavigationDestinationId.workCenter) return;

    final routeLocation = billingRouteLocationForDestination(
      destination,
      tenantId: tenant?.id,
      businessDomain:
          tenant?.preferences.businessDomain ?? initialBusinessDomain,
    );
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(routeLocation);
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('Open ${destination.name} from the app shell.')),
    );
  }

  BillingFollowUpWorkActionState _actionStateFor(
    BillingFollowUpWorkActionRegistry actionRegistry,
    BillingFollowUpWorkItem item,
  ) {
    final action = actionRegistry.resolve(item);
    return BillingFollowUpWorkActionState(
      label: action.label,
      isEnabled: action.canOpen,
      disabledReason: action.disabledReason,
    );
  }

  void _setQueueFilter(
    WidgetRef ref,
    StateProvider<BillingFollowUpWorkQueueFilter> provider,
    BillingFollowUpWorkQueueFilter filter,
  ) {
    ref.read(provider.notifier).state = filter;
  }

  void _openWorkItem(
    BuildContext context,
    BillingTenantAccount tenant,
    BillingFollowUpWorkActionRegistry actionRegistry,
    BillingFollowUpWorkItem item,
  ) {
    final action = actionRegistry.resolve(item);
    if (!action.canOpen) {
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(action.disabledReason)));
      return;
    }

    _openDestination(context, tenant, action.destination);
  }
}

@Preview(name: 'Billing work center screen')
Widget billingWorkCenterScreenPreview() {
  return ProviderScope(
    overrides: [
      billingDashboardRepositoryProvider.overrideWithValue(
        const DemoBillingDashboardRepository(latency: Duration.zero),
      ),
    ],
    child: const MaterialApp(home: BillingWorkCenterScreen()),
  );
}

class _WorkCenterScreenHeader extends StatelessWidget {
  final BillingTenantAccount tenant;

  const _WorkCenterScreenHeader({required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tenant.name,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${tenant.preferences.businessDomain} billing follow-up',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _WorkCenterEmptyTenantState extends StatelessWidget {
  final VoidCallback onOpenTenants;

  const _WorkCenterEmptyTenantState({required this.onOpenTenants});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: BillingEmptyState(
          title: 'Select a billing workspace',
          message:
              'Choose a tenant before opening collection, exception, and renewal follow-up work.',
          icon: Icons.people_outline,
          action: FilledButton.icon(
            onPressed: onOpenTenants,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Open workspaces'),
          ),
        ),
      ),
    );
  }
}
