import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../billing_routes.dart';
import '../models/billing_navigation_destination_id.dart';
import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import '../widgets/billing_dashboard_screen.dart';
import '../widgets/billing_diagnostics_release_profile_filter_hydrator.dart';
import '../widgets/billing_policy_center_screen.dart';
import '../widgets/billing_product_workspace_screen.dart';
import '../widgets/billing_route_context_hydrator.dart';
import '../widgets/billing_route_unavailable_screen.dart';
import '../widgets/billing_tenant_selection_screen.dart';
import '../widgets/work_center_screen.dart';
import 'billing_route_context.dart';

/// Page builder signature used by billing feature routes.
typedef BillingRoutePageBuilder =
    Page<dynamic> Function(BuildContext context, GoRouterState state);

/// Builds fallback page builders for routes without explicit registrations.
typedef BillingRouteFallbackPageBuilderFactory =
    BillingRoutePageBuilder Function(
      BillingManagementRouteDefinition routeDefinition,
    );

/// Resolves executable page builders for core and extension billing routes.
class BillingRoutePageBuilderRegistry {
  final Map<String, BillingRoutePageBuilder> buildersByRouteIdentityKey;
  final BillingRouteFallbackPageBuilderFactory fallbackPageBuilderFactory;

  BillingRoutePageBuilderRegistry({
    Map<String, BillingRoutePageBuilder> buildersByRouteIdentityKey = const {},
    BillingRouteFallbackPageBuilderFactory? fallbackPageBuilderFactory,
  }) : buildersByRouteIdentityKey = Map.unmodifiable(
         _normalizedBuilders(buildersByRouteIdentityKey),
       ),
       fallbackPageBuilderFactory =
           fallbackPageBuilderFactory ?? _unavailableRoutePageBuilder;

  /// Builds the executable registry for standard billing routes.
  factory BillingRoutePageBuilderRegistry.standard({
    Map<String, BillingRoutePageBuilder> extensionBuildersByRouteIdentityKey =
        const {},
  }) {
    return BillingRoutePageBuilderRegistry(
      buildersByRouteIdentityKey: {
        for (final route in BillingRoutes.sidebarRoutes)
          route.resolvedRouteIdentityKey: _standardPageBuilderFor(route),
        ...extensionBuildersByRouteIdentityKey,
      },
    );
  }

  bool hasPageBuilderFor(BillingManagementRouteDefinition routeDefinition) {
    return buildersByRouteIdentityKey.containsKey(
      routeDefinition.resolvedRouteIdentityKey,
    );
  }

  BillingRoutePageBuilder? explicitPageBuilderFor(
    BillingManagementRouteDefinition routeDefinition,
  ) {
    return buildersByRouteIdentityKey[routeDefinition.resolvedRouteIdentityKey];
  }

  BillingRoutePageBuilder pageBuilderFor(
    BillingManagementRouteDefinition routeDefinition,
  ) {
    return explicitPageBuilderFor(routeDefinition) ??
        fallbackPageBuilderFactory(routeDefinition);
  }
}

Map<String, BillingRoutePageBuilder> _normalizedBuilders(
  Map<String, BillingRoutePageBuilder> builders,
) {
  return {
    for (final entry in builders.entries)
      if (entry.key.trim().isNotEmpty) entry.key.trim(): entry.value,
  };
}

BillingRoutePageBuilder _standardPageBuilderFor(
  BillingManagementRouteDefinition routeDefinition,
) {
  if (routeDefinition.destinationId ==
      BillingNavigationDestinationId.policyCenter) {
    return (BuildContext context, GoRouterState state) {
      final routeContext = _routeContextFromState(state);
      return MaterialPage(
        child: BillingRouteContextHydrator(
          routeContext: routeContext,
          child: BillingPolicyCenterScreen(
            initialTenantId: routeContext.tenantId,
            initialBusinessDomain: routeContext.businessDomain,
          ),
        ),
      );
    };
  }

  if (routeDefinition.destinationId ==
      BillingNavigationDestinationId.workCenter) {
    return (BuildContext context, GoRouterState state) {
      final routeContext = _routeContextFromState(state);
      return MaterialPage(
        child: BillingRouteContextHydrator(
          routeContext: routeContext,
          child: BillingWorkCenterScreen(
            initialTenantId: routeContext.tenantId,
            initialBusinessDomain: routeContext.businessDomain,
          ),
        ),
      );
    };
  }

  switch (routeDefinition.surface) {
    case BillingManagementRouteSurface.dashboard:
      return _dashboardPageBuilder(
        initialDestination: routeDefinition.destinationId,
      );
    case BillingManagementRouteSurface.productWorkspace:
      return (BuildContext context, GoRouterState state) {
        final routeContext = _routeContextFromState(state);
        return MaterialPage(
          child: BillingRouteContextHydrator(
            routeContext: routeContext,
            child: BillingScreen(
              initialDestination: routeDefinition.destinationId,
              initialBusinessDomain: routeContext.businessDomain,
            ),
          ),
        );
      };
    case BillingManagementRouteSurface.tenantSelection:
      return (BuildContext context, GoRouterState state) {
        final routeContext = _routeContextFromState(state);
        return MaterialPage(
          child: BillingRouteContextHydrator(
            routeContext: routeContext,
            child: TenantSelectionScreen(
              initialBusinessDomain: routeContext.businessDomain,
            ),
          ),
        );
      };
  }
}

BillingRoutePageBuilder _dashboardPageBuilder({
  BillingNavigationDestinationId initialDestination =
      BillingNavigationDestinationId.dashboard,
}) {
  return (BuildContext context, GoRouterState state) {
    final routeContext = _routeContextFromState(state);
    final diagnosticsReleaseProfileFilterState =
        _diagnosticsReleaseProfileFilterStateFromState(
          state,
          initialDestination: initialDestination,
        );
    return MaterialPage(
      child: BillingRouteContextHydrator(
        routeContext: routeContext,
        child: _withDiagnosticsFilterHydrator(
          initialDestination: initialDestination,
          initialState: diagnosticsReleaseProfileFilterState,
          child: BillingDashboardScreen(
            initialDestination: initialDestination,
            initialTenantId: routeContext.tenantId,
            initialBusinessDomain: routeContext.businessDomain,
          ),
        ),
      ),
    );
  };
}

BillingRoutePageBuilder _unavailableRoutePageBuilder(
  BillingManagementRouteDefinition routeDefinition,
) {
  return (BuildContext context, GoRouterState state) {
    final routeContext = _routeContextFromState(state);
    return MaterialPage(
      child: BillingRouteContextHydrator(
        routeContext: routeContext,
        child: BillingRouteUnavailableScreen(
          routeDefinition: routeDefinition,
          routeContext: routeContext,
        ),
      ),
    );
  };
}

BillingRouteContext _routeContextFromState(GoRouterState state) {
  return BillingRouteContext.fromQueryParameters(
    state.uri.queryParameters,
    tenantQueryKey: BillingRoutes.tenantQueryKey,
    businessDomainQueryKey: BillingRoutes.businessDomainQueryKey,
  );
}

BillingDiagnosticsReleaseProfileFilterState
_diagnosticsReleaseProfileFilterStateFromState(
  GoRouterState state, {
  required BillingNavigationDestinationId initialDestination,
}) {
  if (initialDestination != BillingNavigationDestinationId.diagnostics) {
    return const BillingDiagnosticsReleaseProfileFilterState();
  }

  return BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters(
    state.uri.queryParameters,
  );
}

Widget _withDiagnosticsFilterHydrator({
  required BillingNavigationDestinationId initialDestination,
  required BillingDiagnosticsReleaseProfileFilterState initialState,
  required Widget child,
}) {
  if (initialDestination != BillingNavigationDestinationId.diagnostics) {
    return child;
  }

  return BillingDiagnosticsReleaseProfileFilterHydrator(
    initialState: initialState,
    child: child,
  );
}
