import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant.dart';
import '../states/billing_management_navigation_context_provider.dart';
import '../states/billing_product_catalog_provider.dart';
import '../utils/billing_route_context.dart';
import 'billing_dashboard_screen.dart';
import 'billing_management_navigation_coordinator.dart';
import 'billing_management_navigation_session.dart';
import 'billing_management_navigation_scaffold.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_drawer.dart';
import 'billing_tenant_avatar.dart';

class TenantSelectionScreen extends ConsumerWidget {
  final bool popOnSelect;
  final String? initialBusinessDomain;

  const TenantSelectionScreen({
    super.key,
    this.popOnSelect = false,
    this.initialBusinessDomain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(billingProductTenantsProvider);
    final navigationContext = ref.watch(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.tenantSelection(
          businessDomain: initialBusinessDomain,
        ),
      ),
    );

    return BillingManagementNavigationScaffold(
      navigationContext: navigationContext,
      selectedDestination: BillingNavigationDestinationId.tenants,
      tenantName: 'No tenant selected',
      tenantSubtitle: 'Choose a business workspace',
      onDestinationSelected:
          (destination) => _handleNavigationDestination(
            context,
            destination,
            navigationContext.destinationDispatchSnapshot,
          ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Billing Workspaces',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Tenant',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the tenant to manage billing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: tenantsAsync.when(
                loading:
                    () => const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                error:
                    (err, stack) => const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: Center(child: Text('Failed to load tenants')),
                      ),
                    ),
                data:
                    (tenants) => _TenantGrid(
                      tenants: tenants,
                      onTenantSelected: (tenant) {
                        ref
                            .read(currentTenantProvider.notifier)
                            .state = billingTenantWithRouteContext(
                          tenant,
                          businessDomain: initialBusinessDomain,
                        );
                        if (popOnSelect) {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigationDestination(
    BuildContext context,
    BillingNavigationDestinationId destination,
    BillingNavigationDispatchSnapshot dispatchSnapshot,
  ) {
    final session = BillingManagementNavigationSession.tenantSelection(
      dispatchSnapshot: dispatchSnapshot,
      businessDomain: initialBusinessDomain,
    );

    BillingManagementNavigationCoordinator.fromSession(
      context: context,
      session: session,
      onDashboardRouteDestination: (destinationId, _) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (_) => BillingDashboardScreen(
                  initialDestination: destinationId,
                  initialBusinessDomain: initialBusinessDomain,
                ),
          ),
        );
        return true;
      },
    ).handleDestination(destination);
  }
}

class _TenantGrid extends StatelessWidget {
  final List<Tenant> tenants;
  final ValueChanged<Tenant> onTenantSelected;

  const _TenantGrid({required this.tenants, required this.onTenantSelected});

  @override
  Widget build(BuildContext context) {
    if (tenants.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 240,
          child: Center(
            child: Text(
              'No tenants available',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns =
            width >= 900
                ? 4
                : width >= 620
                ? 3
                : 2;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.25,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final tenant = tenants[index];
            return TenantCard(
              tenant: tenant,
              onTap: () => onTenantSelected(tenant),
            );
          }, childCount: tenants.length),
        );
      },
    );
  }
}

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onTap;

  const TenantCard({super.key, required this.tenant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BillingTenantAvatar(
                name: tenant.name,
                logoUrl: tenant.logoUrl,
                radius: 32,
              ),
              const SizedBox(height: 12),
              Text(
                tenant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
