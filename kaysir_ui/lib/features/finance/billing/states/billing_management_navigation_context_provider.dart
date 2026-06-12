import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_navigation_destination.dart';
import '../models/billing_route_link_navigation_model.dart';
import '../models/billing_tenant_preferences.dart';
import '../widgets/billing_navigation_coverage_summary.dart';
import '../widgets/billing_navigation_dispatch_snapshot.dart';
import '../widgets/billing_navigation_launch_snapshot.dart';
import 'billing_business_domain_profile_provider.dart';
import 'billing_route_link_provider.dart';

class BillingManagementNavigationContextRequest {
  final BillingManagementRouteLinkRequest routeLinkRequest;
  final BillingNavigationDestinationId selectedDestinationId;
  final BillingNavigationSurface currentSurface;

  const BillingManagementNavigationContextRequest._({
    required this.routeLinkRequest,
    required this.selectedDestinationId,
    required this.currentSurface,
  });

  factory BillingManagementNavigationContextRequest({
    BillingTenantPreferences preferences = const BillingTenantPreferences(),
    String? tenantId,
    required BillingNavigationDestinationId selectedDestinationId,
    required BillingNavigationSurface currentSurface,
  }) {
    return BillingManagementNavigationContextRequest._(
      routeLinkRequest: BillingManagementRouteLinkRequest(
        preferences: preferences,
        tenantId: tenantId,
      ),
      selectedDestinationId: selectedDestinationId,
      currentSurface: currentSurface,
    );
  }

  factory BillingManagementNavigationContextRequest.noTenant({
    String? businessDomain,
    required BillingNavigationDestinationId selectedDestinationId,
    required BillingNavigationSurface currentSurface,
  }) {
    return BillingManagementNavigationContextRequest(
      preferences:
          businessDomain?.trim().isNotEmpty == true
              ? BillingTenantPreferences(businessDomain: businessDomain!)
              : const BillingTenantPreferences(),
      selectedDestinationId: selectedDestinationId,
      currentSurface: currentSurface,
    );
  }

  factory BillingManagementNavigationContextRequest.optionalTenant({
    BillingTenantPreferences? preferences,
    String? tenantId,
    String? noTenantBusinessDomain,
    required BillingNavigationDestinationId selectedDestinationId,
    required BillingNavigationSurface currentSurface,
  }) {
    if (tenantId?.trim().isNotEmpty == true) {
      return BillingManagementNavigationContextRequest(
        preferences: preferences ?? const BillingTenantPreferences(),
        tenantId: tenantId,
        selectedDestinationId: selectedDestinationId,
        currentSurface: currentSurface,
      );
    }

    return BillingManagementNavigationContextRequest.noTenant(
      businessDomain: noTenantBusinessDomain,
      selectedDestinationId: selectedDestinationId,
      currentSurface: currentSurface,
    );
  }

  factory BillingManagementNavigationContextRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
    required BillingNavigationDestinationId selectedDestinationId,
    required BillingNavigationSurface currentSurface,
  }) {
    return BillingManagementNavigationContextRequest(
      preferences: preferences,
      tenantId: tenantId,
      selectedDestinationId: selectedDestinationId,
      currentSurface: currentSurface,
    );
  }

  factory BillingManagementNavigationContextRequest.dashboard({
    BillingTenantPreferences? preferences,
    String? tenantId,
    String? noTenantBusinessDomain,
    required BillingNavigationDestinationId selectedDestinationId,
  }) {
    return BillingManagementNavigationContextRequest.optionalTenant(
      preferences: preferences,
      tenantId: tenantId,
      noTenantBusinessDomain: noTenantBusinessDomain,
      selectedDestinationId: selectedDestinationId,
      currentSurface: BillingNavigationSurface.dashboard,
    );
  }

  factory BillingManagementNavigationContextRequest.productWorkspace({
    required BillingTenantPreferences preferences,
    required String tenantId,
    required BillingNavigationDestinationId selectedDestinationId,
  }) {
    return BillingManagementNavigationContextRequest.fromTenant(
      preferences: preferences,
      tenantId: tenantId,
      selectedDestinationId: selectedDestinationId,
      currentSurface: BillingNavigationSurface.productWorkspace,
    );
  }

  factory BillingManagementNavigationContextRequest.tenantSelection({
    String? businessDomain,
  }) {
    return BillingManagementNavigationContextRequest.noTenant(
      businessDomain: businessDomain,
      selectedDestinationId: BillingNavigationDestinationId.tenants,
      currentSurface: BillingNavigationSurface.tenantSelection,
    );
  }

  bool get hasTenant => routeLinkRequest.hasTenant;

  BillingNavigationLaunchPlannerRequest get launchPlannerRequest {
    return routeLinkRequest.launchPlannerRequest;
  }

  BillingNavigationDispatchSnapshotRequest get dispatchSnapshotRequest {
    final plannerRequest = launchPlannerRequest;

    return BillingNavigationDispatchSnapshotRequest(
      preferences: plannerRequest.preferences,
      hasTenant: plannerRequest.hasTenant,
      currentSurface: currentSurface,
    );
  }

  BillingTenantManagementNavigationModelRequest get routeModelRequest {
    return BillingTenantManagementNavigationModelRequest(
      routeLinkRequest: routeLinkRequest,
      selectedDestinationId: selectedDestinationId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingManagementNavigationContextRequest &&
            other.routeLinkRequest == routeLinkRequest &&
            other.selectedDestinationId == selectedDestinationId &&
            other.currentSurface == currentSurface;
  }

  @override
  int get hashCode {
    return Object.hash(routeLinkRequest, selectedDestinationId, currentSurface);
  }
}

class BillingManagementNavigationContext {
  final BillingManagementNavigationContextRequest request;
  final BillingNavigationLaunchSnapshot destinationLaunchSnapshot;
  final BillingNavigationLaunchSnapshot quickActionLaunchSnapshot;
  final BillingNavigationDispatchSnapshot destinationDispatchSnapshot;
  final BillingNavigationDispatchSnapshot quickActionDispatchSnapshot;
  final BillingRouteLinkNavigationModel routeLinkNavigationModel;
  final BillingNavigationCoverageSummary coverageSummary;

  const BillingManagementNavigationContext({
    required this.request,
    required this.destinationLaunchSnapshot,
    required this.quickActionLaunchSnapshot,
    required this.destinationDispatchSnapshot,
    required this.quickActionDispatchSnapshot,
    required this.routeLinkNavigationModel,
    required this.coverageSummary,
  });

  bool get hasTenant => request.hasTenant;

  BillingNavigationLaunchPlannerRequest get launchPlannerRequest {
    return request.launchPlannerRequest;
  }
}

final billingManagementNavigationContextProvider = Provider.family<
  BillingManagementNavigationContext,
  BillingManagementNavigationContextRequest
>((ref, request) {
  final launchPlannerRequest = request.launchPlannerRequest;
  final dispatchSnapshotRequest = request.dispatchSnapshotRequest;

  return BillingManagementNavigationContext(
    request: request,
    destinationLaunchSnapshot: ref.watch(
      billingTenantDomainModuleDestinationLaunchSnapshotProvider(
        launchPlannerRequest,
      ),
    ),
    quickActionLaunchSnapshot: ref.watch(
      billingTenantDomainModuleQuickActionLaunchSnapshotProvider(
        launchPlannerRequest,
      ),
    ),
    destinationDispatchSnapshot: ref.watch(
      billingTenantDomainModuleDestinationDispatchSnapshotProvider(
        dispatchSnapshotRequest,
      ),
    ),
    quickActionDispatchSnapshot: ref.watch(
      billingTenantDomainModuleQuickActionDispatchSnapshotProvider(
        dispatchSnapshotRequest,
      ),
    ),
    routeLinkNavigationModel: ref.watch(
      billingTenantManagementRouteLinkNavigationModelProvider(
        request.routeModelRequest,
      ),
    ),
    coverageSummary:
        ref
            .watch(
              billingTenantDomainModuleNavigationCoverageProvider(
                launchPlannerRequest,
              ),
            )
            .summary,
  );
});
