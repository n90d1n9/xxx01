import '../billing_routes.dart';
import '../models/billing_navigation_destination_id.dart';
import '../widgets/billing_navigation_route_target.dart';
import 'billing_route_context.dart';

String billingRouteLocationForDestination(
  BillingNavigationDestinationId destinationId, {
  String? tenantId,
  String? businessDomain,
  BillingRouteContext routeContext = BillingRouteContext.empty,
}) {
  final path = switch (destinationId) {
    BillingNavigationDestinationId.dashboard => BillingRoutes.managementPath,
    BillingNavigationDestinationId.workCenter => BillingRoutes.workCenterPath,
    BillingNavigationDestinationId.tenants => BillingRoutes.workspacesPath,
    BillingNavigationDestinationId.invoices => BillingRoutes.invoicesPath,
    BillingNavigationDestinationId.createInvoice =>
      BillingRoutes.createInvoicePath,
    BillingNavigationDestinationId.reports => BillingRoutes.insightsPath,
    BillingNavigationDestinationId.issueOutbox => BillingRoutes.issueOutboxPath,
    BillingNavigationDestinationId.policyCenter => BillingRoutes.policyPath,
    BillingNavigationDestinationId.productWorkspace =>
      BillingRoutes.productsPath,
    BillingNavigationDestinationId.cartCheckout => BillingRoutes.checkoutPath,
    BillingNavigationDestinationId.diagnostics => BillingRoutes.diagnosticsPath,
  };

  return billingRouteLocation(
    path,
    tenantId: tenantId,
    businessDomain: businessDomain,
    routeContext: routeContext,
  );
}

String? billingRouteLocationForTarget(
  BillingNavigationRouteTarget routeTarget, {
  String? tenantId,
  String? businessDomain,
  BillingRouteContext routeContext = BillingRouteContext.empty,
}) {
  switch (routeTarget.kind) {
    case BillingNavigationRouteTargetKind.dashboard:
    case BillingNavigationRouteTargetKind.productWorkspace:
      final destinationId = routeTarget.initialDestinationId;
      return destinationId == null
          ? null
          : billingRouteLocationForDestination(
            destinationId,
            tenantId: tenantId,
            businessDomain: businessDomain,
            routeContext: routeContext,
          );
    case BillingNavigationRouteTargetKind.tenantSelection:
      return billingRouteLocation(
        BillingRoutes.workspacesPath,
        tenantId: tenantId,
        businessDomain: businessDomain,
        routeContext: routeContext,
      );
    case BillingNavigationRouteTargetKind.none:
      return null;
  }
}

String billingRouteLocation(
  String path, {
  String? tenantId,
  String? businessDomain,
  BillingRouteContext routeContext = BillingRouteContext.empty,
  Map<String, String> extraQueryParameters = const {},
}) {
  final context = routeContext.merge(
    tenantId: tenantId,
    businessDomain: businessDomain,
  );
  final queryParameters = Map<String, String>.from(
    context.toQueryParameters(
      tenantQueryKey: BillingRoutes.tenantQueryKey,
      businessDomainQueryKey: BillingRoutes.businessDomainQueryKey,
    ),
  );
  for (final entry in extraQueryParameters.entries) {
    queryParameters.putIfAbsent(entry.key, () => entry.value);
  }

  if (queryParameters.isEmpty) {
    return path;
  }

  return Uri(path: path, queryParameters: queryParameters).toString();
}
