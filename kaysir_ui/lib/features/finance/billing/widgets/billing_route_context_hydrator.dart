import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant.dart';
import '../states/billing_dashboard_provider.dart';
import '../states/billing_product_catalog_provider.dart';
import '../utils/billing_route_context.dart';

class BillingRouteContextHydrator extends ConsumerWidget {
  final String? tenantId;
  final String? businessDomain;
  final BillingRouteContext routeContext;
  final Widget child;

  const BillingRouteContextHydrator({
    super.key,
    required this.child,
    this.tenantId,
    this.businessDomain,
    this.routeContext = BillingRouteContext.empty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveRouteContext = routeContext.merge(
      tenantId: tenantId,
      businessDomain: businessDomain,
    );
    if (effectiveRouteContext.isEmpty) {
      return child;
    }

    if (effectiveRouteContext.tenantId != null) {
      _scheduleDashboardTenantSync(ref, effectiveRouteContext.tenantId!);
    }
    _scheduleProductTenantSync(ref, routeContext: effectiveRouteContext);

    return child;
  }

  void _scheduleDashboardTenantSync(WidgetRef ref, String tenantId) {
    if (ref.read(selectedBillingTenantIdProvider) == tenantId) return;

    Future<void>.microtask(() {
      ref.read(selectedBillingTenantIdProvider.notifier).state = tenantId;
    });
  }

  void _scheduleProductTenantSync(
    WidgetRef ref, {
    required BillingRouteContext routeContext,
  }) {
    if (routeContext.tenantId == null) {
      _scheduleCurrentProductTenantDomainSync(ref, routeContext);
      return;
    }

    final tenantsAsync = ref.watch(billingProductTenantsProvider);
    tenantsAsync.whenData((tenants) {
      Tenant? tenant;
      for (final candidate in tenants) {
        if (candidate.id == routeContext.tenantId) {
          tenant = candidate;
          break;
        }
      }
      if (tenant == null) return;
      final contextualTenant = routeContext.applyToTenant(tenant);
      if (_hasSameProductTenantContext(
        ref.read(currentTenantProvider),
        contextualTenant,
      )) {
        return;
      }

      Future<void>.microtask(() {
        ref.read(currentTenantProvider.notifier).state = contextualTenant;
      });
    });
  }

  void _scheduleCurrentProductTenantDomainSync(
    WidgetRef ref,
    BillingRouteContext routeContext,
  ) {
    if (routeContext.businessDomain == null) return;

    final currentTenant = ref.read(currentTenantProvider);
    if (currentTenant == null) return;

    final contextualTenant = routeContext.applyToTenant(currentTenant);
    if (_hasSameProductTenantContext(currentTenant, contextualTenant)) return;

    Future<void>.microtask(() {
      ref.read(currentTenantProvider.notifier).state = contextualTenant;
    });
  }

  bool _hasSameProductTenantContext(Tenant? left, Tenant right) {
    return left?.id == right.id &&
        left?.name == right.name &&
        left?.logoUrl == right.logoUrl &&
        left?.preferences == right.preferences;
  }
}
