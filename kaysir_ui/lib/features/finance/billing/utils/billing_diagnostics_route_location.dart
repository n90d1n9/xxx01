import '../billing_routes.dart';
import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import 'billing_route_context.dart';
import 'billing_route_locations.dart';

/// Builds diagnostics route locations with tenant, domain, and filter context.
String billingDiagnosticsRouteLocation({
  String? tenantId,
  String? businessDomain,
  BillingRouteContext routeContext = BillingRouteContext.empty,
  BillingDiagnosticsReleaseProfileFilterState releaseProfileFilterState =
      const BillingDiagnosticsReleaseProfileFilterState(),
}) {
  return billingRouteLocation(
    BillingRoutes.diagnosticsPath,
    tenantId: tenantId,
    businessDomain: businessDomain,
    routeContext: routeContext,
    extraQueryParameters: releaseProfileFilterState.toQueryParameters(),
  );
}

/// Builds a browser-safe diagnostics link for sharing the active billing view.
String billingDiagnosticsBrowserLink({
  String? tenantId,
  String? businessDomain,
  BillingRouteContext routeContext = BillingRouteContext.empty,
  BillingDiagnosticsReleaseProfileFilterState releaseProfileFilterState =
      const BillingDiagnosticsReleaseProfileFilterState(),
  Uri? baseUri,
}) {
  return billingBrowserDeepLink(
    billingDiagnosticsRouteLocation(
      tenantId: tenantId,
      businessDomain: businessDomain,
      routeContext: routeContext,
      releaseProfileFilterState: releaseProfileFilterState,
    ),
    baseUri: baseUri,
  );
}

/// Turns an app route into a hash-based browser link when a host is available.
String billingBrowserDeepLink(String route, {Uri? baseUri}) {
  final base = baseUri ?? Uri.base;
  final normalizedRoute = route.startsWith('/') ? route : '/$route';

  if (base.scheme.isEmpty || base.host.isEmpty) {
    return normalizedRoute;
  }

  final buffer =
      StringBuffer()
        ..write(base.scheme)
        ..write('://');
  if (base.userInfo.isNotEmpty) {
    buffer
      ..write(base.userInfo)
      ..write('@');
  }
  buffer.write(base.host);
  if (base.hasPort) {
    buffer
      ..write(':')
      ..write(base.port);
  }

  final basePath =
      base.path.isEmpty || !base.path.endsWith('/') ? '/' : base.path;
  buffer
    ..write(basePath)
    ..write('#')
    ..write(normalizedRoute);

  return buffer.toString();
}
