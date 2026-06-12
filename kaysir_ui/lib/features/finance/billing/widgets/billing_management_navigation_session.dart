import '../models/billing_tenant.dart';
import '../models/billing_tenant_account.dart';
import '../utils/billing_route_context.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_snapshot.dart';

class BillingManagementNavigationSession {
  final BillingNavigationSurface currentSurface;
  final BillingNavigationDispatchSnapshot dispatchSnapshot;
  final BillingRouteContext routeContext;

  const BillingManagementNavigationSession({
    required this.currentSurface,
    required this.dispatchSnapshot,
    this.routeContext = BillingRouteContext.empty,
  });

  factory BillingManagementNavigationSession.dashboard({
    required BillingNavigationDispatchSnapshot dispatchSnapshot,
    BillingTenantAccount? tenant,
    String? businessDomain,
  }) {
    return BillingManagementNavigationSession(
      currentSurface: BillingNavigationSurface.dashboard,
      dispatchSnapshot: dispatchSnapshot,
      routeContext:
          tenant == null
              ? BillingRouteContext(businessDomain: businessDomain)
              : BillingRouteContext.fromTenantAccount(
                tenant,
              ).merge(businessDomain: businessDomain),
    );
  }

  factory BillingManagementNavigationSession.productWorkspace({
    required BillingNavigationDispatchSnapshot dispatchSnapshot,
    Tenant? tenant,
    String? businessDomain,
  }) {
    return BillingManagementNavigationSession(
      currentSurface: BillingNavigationSurface.productWorkspace,
      dispatchSnapshot: dispatchSnapshot,
      routeContext:
          tenant == null
              ? BillingRouteContext(businessDomain: businessDomain)
              : BillingRouteContext.fromTenant(
                tenant,
              ).merge(businessDomain: businessDomain),
    );
  }

  factory BillingManagementNavigationSession.tenantSelection({
    required BillingNavigationDispatchSnapshot dispatchSnapshot,
    String? businessDomain,
  }) {
    return BillingManagementNavigationSession(
      currentSurface: BillingNavigationSurface.tenantSelection,
      dispatchSnapshot: dispatchSnapshot,
      routeContext: BillingRouteContext(businessDomain: businessDomain),
    );
  }

  String? get tenantId => routeContext.tenantId;

  String? get businessDomain => routeContext.businessDomain;

  bool get hasTenant => tenantId != null;
}
