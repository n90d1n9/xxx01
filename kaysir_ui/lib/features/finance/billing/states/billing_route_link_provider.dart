import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_navigation_destination.dart';
import '../models/billing_route_link_navigation_model.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_route_context.dart';
import '../utils/billing_route_link.dart';
import '../utils/billing_tenant_domain_profile.dart';
import 'billing_business_domain_profile_provider.dart';
import 'billing_route_contract_provider.dart';

/// Request for building billing management links with tenant context.
class BillingManagementRouteLinkRequest {
  final BillingTenantPreferences preferences;
  final String? tenantId;

  const BillingManagementRouteLinkRequest._({
    required this.preferences,
    required this.tenantId,
  });

  factory BillingManagementRouteLinkRequest({
    BillingTenantPreferences preferences = const BillingTenantPreferences(),
    String? tenantId,
  }) {
    final businessDomain = billingTenantBusinessDomain(preferences);

    return BillingManagementRouteLinkRequest._(
      preferences: billingPreferencesWithRouteDomain(
        preferences,
        businessDomain: businessDomain,
      ),
      tenantId: normalizeBillingRouteTenantId(tenantId),
    );
  }

  factory BillingManagementRouteLinkRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
  }) {
    return BillingManagementRouteLinkRequest(
      preferences: preferences,
      tenantId: tenantId,
    );
  }

  bool get hasTenant => tenantId != null;

  String get businessDomain => billingTenantBusinessDomain(preferences);

  BillingRouteContext get routeContext {
    return BillingRouteContext(
      tenantId: tenantId,
      businessDomain: businessDomain,
    );
  }

  BillingNavigationLaunchPlannerRequest get launchPlannerRequest {
    return BillingNavigationLaunchPlannerRequest(
      preferences: preferences,
      hasTenant: hasTenant,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingManagementRouteLinkRequest &&
            other.preferences == preferences &&
            other.tenantId == tenantId;
  }

  @override
  int get hashCode => Object.hash(preferences, tenantId);
}

/// Request for default billing navigation without a selected tenant.
class BillingDefaultManagementNavigationModelRequest {
  final bool hasTenant;
  final BillingNavigationDestinationId selectedDestinationId;

  const BillingDefaultManagementNavigationModelRequest({
    required this.hasTenant,
    required this.selectedDestinationId,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingDefaultManagementNavigationModelRequest &&
            other.hasTenant == hasTenant &&
            other.selectedDestinationId == selectedDestinationId;
  }

  @override
  int get hashCode => Object.hash(hasTenant, selectedDestinationId);
}

/// Request for tenant-scoped billing navigation models.
class BillingTenantManagementNavigationModelRequest {
  final BillingManagementRouteLinkRequest routeLinkRequest;
  final BillingNavigationDestinationId selectedDestinationId;

  const BillingTenantManagementNavigationModelRequest({
    required this.routeLinkRequest,
    required this.selectedDestinationId,
  });

  factory BillingTenantManagementNavigationModelRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
    required BillingNavigationDestinationId selectedDestinationId,
  }) {
    return BillingTenantManagementNavigationModelRequest(
      routeLinkRequest: BillingManagementRouteLinkRequest.fromTenant(
        preferences: preferences,
        tenantId: tenantId,
      ),
      selectedDestinationId: selectedDestinationId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingTenantManagementNavigationModelRequest &&
            other.routeLinkRequest == routeLinkRequest &&
            other.selectedDestinationId == selectedDestinationId;
  }

  @override
  int get hashCode => Object.hash(routeLinkRequest, selectedDestinationId);
}

final billingDefaultManagementRouteLinksProvider =
    Provider.family<List<BillingRouteLink>, bool>((ref, hasTenant) {
      final launchPlanner = ref.watch(
        billingDefaultDomainModuleNavigationLaunchPlannerProvider(hasTenant),
      );
      final routes = ref.watch(billingRouteContractRouteDefinitionsProvider);

      return billingManagementRouteLinksForLaunchSnapshot(
        launchSnapshot: launchPlanner.snapshotFor(
          routes.map((route) => route.destinationId),
        ),
        routeContext: BillingRouteContext(
          businessDomain: defaultBillingBusinessDomain,
        ),
        routes: routes,
      );
    });

final billingTenantManagementRouteLinksProvider =
    Provider.family<List<BillingRouteLink>, BillingManagementRouteLinkRequest>((
      ref,
      request,
    ) {
      final launchPlanner = ref.watch(
        billingTenantDomainModuleNavigationLaunchPlannerProvider(
          request.launchPlannerRequest,
        ),
      );
      final routes = ref.watch(billingRouteContractRouteDefinitionsProvider);

      return billingManagementRouteLinksForLaunchSnapshot(
        launchSnapshot: launchPlanner.snapshotFor(
          routes.map((route) => route.destinationId),
        ),
        routeContext: request.routeContext,
        routes: routes,
      );
    });

final billingDefaultManagementRouteLinkNavigationModelProvider =
    Provider.family<
      BillingRouteLinkNavigationModel,
      BillingDefaultManagementNavigationModelRequest
    >((ref, request) {
      final routeLinks = ref.watch(
        billingDefaultManagementRouteLinksProvider(request.hasTenant),
      );

      return BillingRouteLinkNavigationModel(
        routeLinks: routeLinks,
        selectedDestinationId: request.selectedDestinationId,
      );
    });

final billingTenantManagementRouteLinkNavigationModelProvider = Provider.family<
  BillingRouteLinkNavigationModel,
  BillingTenantManagementNavigationModelRequest
>((ref, request) {
  final routeLinks = ref.watch(
    billingTenantManagementRouteLinksProvider(request.routeLinkRequest),
  );

  return BillingRouteLinkNavigationModel(
    routeLinks: routeLinks,
    selectedDestinationId: request.selectedDestinationId,
  );
});
