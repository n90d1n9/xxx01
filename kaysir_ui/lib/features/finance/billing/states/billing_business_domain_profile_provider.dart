import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_business_domain_screen_registry.dart';
import '../models/billing_invoice_line_item_adapter.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_business_domain_module_readiness.dart';
import '../utils/billing_domain_invoice_draft_composer.dart';
import '../utils/billing_tenant_domain_module.dart';
import '../utils/billing_tenant_domain_profile.dart';
import '../widgets/billing_domain_navigation_policy.dart';
import '../widgets/billing_navigation_coverage.dart';
import '../widgets/billing_navigation_destination.dart';
import '../widgets/billing_navigation_dispatch_snapshot.dart';
import '../widgets/billing_navigation_launch_planner.dart';
import '../widgets/billing_navigation_launch_state.dart';
import '../widgets/billing_navigation_launch_snapshot.dart';
import 'billing_business_domain_pack_provider.dart';

class BillingNavigationLaunchPlannerRequest {
  final BillingTenantPreferences preferences;
  final bool hasTenant;

  const BillingNavigationLaunchPlannerRequest({
    required this.preferences,
    required this.hasTenant,
  });

  factory BillingNavigationLaunchPlannerRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
  }) {
    return BillingNavigationLaunchPlannerRequest(
      preferences: preferences,
      hasTenant: tenantId.isNotEmpty,
    );
  }

  BillingTenantNavigationLaunchStateRequest stateRequestFor(
    BillingNavigationDestinationId destinationId,
  ) {
    return BillingTenantNavigationLaunchStateRequest.fromPlannerRequest(
      this,
      destinationId: destinationId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingNavigationLaunchPlannerRequest &&
            other.preferences == preferences &&
            other.hasTenant == hasTenant;
  }

  @override
  int get hashCode => Object.hash(preferences, hasTenant);
}

class BillingDefaultNavigationLaunchStateRequest {
  final BillingNavigationDestinationId destinationId;
  final bool hasTenant;

  const BillingDefaultNavigationLaunchStateRequest({
    required this.destinationId,
    required this.hasTenant,
  });

  factory BillingDefaultNavigationLaunchStateRequest.forDestination(
    BillingNavigationDestinationId destinationId, {
    bool hasTenant = false,
  }) {
    return BillingDefaultNavigationLaunchStateRequest(
      destinationId: destinationId,
      hasTenant: hasTenant,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingDefaultNavigationLaunchStateRequest &&
            other.destinationId == destinationId &&
            other.hasTenant == hasTenant;
  }

  @override
  int get hashCode => Object.hash(destinationId, hasTenant);
}

class BillingNavigationDispatchSnapshotRequest {
  final BillingTenantPreferences preferences;
  final bool hasTenant;
  final BillingNavigationSurface currentSurface;

  const BillingNavigationDispatchSnapshotRequest({
    required this.preferences,
    required this.hasTenant,
    required this.currentSurface,
  });

  factory BillingNavigationDispatchSnapshotRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
    required BillingNavigationSurface currentSurface,
  }) {
    return BillingNavigationDispatchSnapshotRequest(
      preferences: preferences,
      hasTenant: tenantId.isNotEmpty,
      currentSurface: currentSurface,
    );
  }

  BillingNavigationLaunchPlannerRequest get plannerRequest {
    return BillingNavigationLaunchPlannerRequest(
      preferences: preferences,
      hasTenant: hasTenant,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingNavigationDispatchSnapshotRequest &&
            other.preferences == preferences &&
            other.hasTenant == hasTenant &&
            other.currentSurface == currentSurface;
  }

  @override
  int get hashCode => Object.hash(preferences, hasTenant, currentSurface);
}

class BillingDefaultNavigationDispatchSnapshotRequest {
  final bool hasTenant;
  final BillingNavigationSurface currentSurface;

  const BillingDefaultNavigationDispatchSnapshotRequest({
    required this.hasTenant,
    required this.currentSurface,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingDefaultNavigationDispatchSnapshotRequest &&
            other.hasTenant == hasTenant &&
            other.currentSurface == currentSurface;
  }

  @override
  int get hashCode => Object.hash(hasTenant, currentSurface);
}

class BillingTenantNavigationLaunchStateRequest {
  final BillingTenantPreferences preferences;
  final BillingNavigationDestinationId destinationId;
  final bool hasTenant;

  const BillingTenantNavigationLaunchStateRequest({
    required this.preferences,
    required this.destinationId,
    required this.hasTenant,
  });

  factory BillingTenantNavigationLaunchStateRequest.fromPlannerRequest(
    BillingNavigationLaunchPlannerRequest request, {
    required BillingNavigationDestinationId destinationId,
  }) {
    return BillingTenantNavigationLaunchStateRequest(
      preferences: request.preferences,
      destinationId: destinationId,
      hasTenant: request.hasTenant,
    );
  }

  factory BillingTenantNavigationLaunchStateRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
    required BillingNavigationDestinationId destinationId,
  }) {
    return BillingNavigationLaunchPlannerRequest.fromTenant(
      preferences: preferences,
      tenantId: tenantId,
    ).stateRequestFor(destinationId);
  }

  BillingNavigationLaunchPlannerRequest get plannerRequest {
    return BillingNavigationLaunchPlannerRequest(
      preferences: preferences,
      hasTenant: hasTenant,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingTenantNavigationLaunchStateRequest &&
            other.preferences == preferences &&
            other.destinationId == destinationId &&
            other.hasTenant == hasTenant;
  }

  @override
  int get hashCode => Object.hash(preferences, destinationId, hasTenant);
}

final billingBusinessDomainModuleRegistryProvider =
    Provider<BillingBusinessDomainModuleRegistry>((ref) {
      return ref
          .watch(billingBusinessDomainPackRegistryProvider)
          .moduleRegistry;
    });

final billingBusinessDomainProfileRegistryProvider =
    Provider<BillingBusinessDomainProfileRegistry>((ref) {
      return ref
          .watch(billingBusinessDomainModuleRegistryProvider)
          .profileRegistry;
    });

final billingInvoiceLineItemAdapterRegistryProvider =
    Provider<BillingInvoiceLineItemAdapterRegistry>((ref) {
      return ref
          .watch(billingBusinessDomainModuleRegistryProvider)
          .lineItemAdapterRegistry;
    });

final billingDomainInvoiceDraftComposerProvider =
    Provider<BillingDomainInvoiceDraftComposer>((ref) {
      return BillingDomainInvoiceDraftComposer(
        moduleRegistry: ref.watch(billingBusinessDomainModuleRegistryProvider),
      );
    });

final billingBusinessDomainModuleRegistryNavigationCoverageProvider =
    Provider.family<BillingNavigationRegistryCoverageReport, bool>((
      ref,
      hasTenant,
    ) {
      return BillingNavigationRegistryCoverageReport.forRegistry(
        ref.watch(billingBusinessDomainModuleRegistryProvider),
        hasTenant: hasTenant,
      );
    });

final billingBusinessDomainModuleRegistryReadinessProvider =
    Provider.family<BillingDomainModuleRegistryReadinessReport, bool>((
      ref,
      hasTenant,
    ) {
      return BillingDomainModuleRegistryReadinessReport.forRegistry(
        ref.watch(billingBusinessDomainModuleRegistryProvider),
        hasTenant: hasTenant,
      );
    });

final billingBusinessDomainModuleForDomainProvider =
    Provider.family<BillingBusinessDomainModule, String>((ref, domain) {
      return billingTenantBusinessDomainModule(
        BillingTenantPreferences(businessDomain: domain),
        registry: ref.watch(billingBusinessDomainModuleRegistryProvider),
      );
    });

final billingBusinessDomainProfileForDomainProvider =
    Provider.family<BillingBusinessDomainProfile, String>((ref, domain) {
      return billingTenantBusinessDomainProfile(
        BillingTenantPreferences(businessDomain: domain),
        registry: ref.watch(billingBusinessDomainProfileRegistryProvider),
      );
    });

final billingBusinessDomainScreenRegistryForDomainProvider =
    Provider.family<BillingBusinessDomainScreenRegistry?, String>((
      ref,
      domain,
    ) {
      return ref
          .watch(billingBusinessDomainModuleForDomainProvider(domain))
          .screenRegistry;
    });

final billingDomainNavigationSetProvider =
    Provider.family<BillingDomainNavigationSet, String>((ref, domain) {
      return billingDomainNavigationSetForProfile(
        ref.watch(billingBusinessDomainProfileForDomainProvider(domain)),
      );
    });

final billingDomainModuleNavigationSetProvider =
    Provider.family<BillingDomainNavigationSet, String>((ref, domain) {
      return billingDomainNavigationSetForModule(
        ref.watch(billingBusinessDomainModuleForDomainProvider(domain)),
      );
    });

final billingDefaultBusinessDomainProfileProvider =
    Provider<BillingBusinessDomainProfile>((ref) {
      return ref.watch(
        billingBusinessDomainProfileForDomainProvider(
          defaultBillingBusinessDomain,
        ),
      );
    });

final billingDefaultBusinessDomainModuleProvider =
    Provider<BillingBusinessDomainModule>((ref) {
      return ref.watch(
        billingBusinessDomainModuleForDomainProvider(
          defaultBillingBusinessDomain,
        ),
      );
    });

final billingDefaultDomainModuleReadinessProvider =
    Provider.family<BillingDomainModuleReadinessReport, bool>((ref, hasTenant) {
      return BillingDomainModuleReadinessReport.forModule(
        ref.watch(billingDefaultBusinessDomainModuleProvider),
        hasTenant: hasTenant,
      );
    });

final billingTenantDomainProfileProvider =
    Provider.family<BillingBusinessDomainProfile, BillingTenantPreferences>((
      ref,
      preferences,
    ) {
      return ref.watch(
        billingBusinessDomainProfileForDomainProvider(
          billingTenantBusinessDomain(preferences),
        ),
      );
    });

final billingTenantDomainModuleProvider =
    Provider.family<BillingBusinessDomainModule, BillingTenantPreferences>((
      ref,
      preferences,
    ) {
      return ref.watch(
        billingBusinessDomainModuleForDomainProvider(
          billingTenantBusinessDomain(preferences),
        ),
      );
    });

final billingTenantDomainModuleReadinessProvider = Provider.family<
  BillingDomainModuleReadinessReport,
  BillingNavigationLaunchPlannerRequest
>((ref, request) {
  return BillingDomainModuleReadinessReport.forModule(
    ref.watch(billingTenantDomainModuleProvider(request.preferences)),
    hasTenant: request.hasTenant,
  );
});

final billingTenantDomainModuleScreenRegistryProvider = Provider.family<
  BillingBusinessDomainScreenRegistry?,
  BillingTenantPreferences
>((ref, preferences) {
  return ref.watch(
    billingBusinessDomainScreenRegistryForDomainProvider(
      billingTenantBusinessDomain(preferences),
    ),
  );
});

final billingDefaultDomainNavigationSetProvider =
    Provider<BillingDomainNavigationSet>((ref) {
      return ref.watch(
        billingDomainNavigationSetProvider(defaultBillingBusinessDomain),
      );
    });

final billingDefaultDomainModuleNavigationSetProvider =
    Provider<BillingDomainNavigationSet>((ref) {
      return ref.watch(
        billingDomainModuleNavigationSetProvider(defaultBillingBusinessDomain),
      );
    });

final billingTenantDomainNavigationSetProvider =
    Provider.family<BillingDomainNavigationSet, BillingTenantPreferences>((
      ref,
      preferences,
    ) {
      return ref.watch(
        billingDomainNavigationSetProvider(
          billingTenantBusinessDomain(preferences),
        ),
      );
    });

final billingTenantDomainModuleNavigationSetProvider =
    Provider.family<BillingDomainNavigationSet, BillingTenantPreferences>((
      ref,
      preferences,
    ) {
      return ref.watch(
        billingDomainModuleNavigationSetProvider(
          billingTenantBusinessDomain(preferences),
        ),
      );
    });

final billingDefaultDomainModuleNavigationLaunchPlannerProvider =
    Provider.family<BillingNavigationLaunchPlanner, bool>((ref, hasTenant) {
      return BillingNavigationLaunchPlanner(
        hasTenant: hasTenant,
        navigationSet: ref.watch(
          billingDefaultDomainModuleNavigationSetProvider,
        ),
      );
    });

final billingDefaultDomainModuleDestinationLaunchSnapshotProvider =
    Provider.family<BillingNavigationLaunchSnapshot, bool>((ref, hasTenant) {
      return ref
          .watch(
            billingDefaultDomainModuleNavigationLaunchPlannerProvider(
              hasTenant,
            ),
          )
          .destinationSnapshot();
    });

final billingDefaultDomainModuleQuickActionLaunchSnapshotProvider =
    Provider.family<BillingNavigationLaunchSnapshot, bool>((ref, hasTenant) {
      return ref
          .watch(
            billingDefaultDomainModuleNavigationLaunchPlannerProvider(
              hasTenant,
            ),
          )
          .quickActionSnapshot();
    });

final billingDefaultDomainModuleDestinationDispatchSnapshotProvider =
    Provider.family<
      BillingNavigationDispatchSnapshot,
      BillingDefaultNavigationDispatchSnapshotRequest
    >((ref, request) {
      return ref
          .watch(
            billingDefaultDomainModuleNavigationLaunchPlannerProvider(
              request.hasTenant,
            ),
          )
          .destinationDispatchSnapshot(currentSurface: request.currentSurface);
    });

final billingDefaultDomainModuleQuickActionDispatchSnapshotProvider =
    Provider.family<
      BillingNavigationDispatchSnapshot,
      BillingDefaultNavigationDispatchSnapshotRequest
    >((ref, request) {
      return ref
          .watch(
            billingDefaultDomainModuleNavigationLaunchPlannerProvider(
              request.hasTenant,
            ),
          )
          .quickActionDispatchSnapshot(currentSurface: request.currentSurface);
    });

final billingDefaultDomainModuleNavigationCoverageProvider =
    Provider.family<BillingNavigationCoverageReport, bool>((ref, hasTenant) {
      return BillingNavigationCoverageReport.forNavigationSet(
        navigationSet: ref.watch(
          billingDefaultDomainModuleNavigationSetProvider,
        ),
        hasTenant: hasTenant,
      );
    });

final billingDefaultDomainModuleNavigationLaunchStateProvider = Provider.family<
  BillingNavigationLaunchState,
  BillingDefaultNavigationLaunchStateRequest
>((ref, request) {
  return ref
      .watch(
        billingDefaultDomainModuleNavigationLaunchPlannerProvider(
          request.hasTenant,
        ),
      )
      .stateFor(request.destinationId);
});

final billingTenantDomainModuleNavigationLaunchPlannerProvider =
    Provider.family<
      BillingNavigationLaunchPlanner,
      BillingNavigationLaunchPlannerRequest
    >((ref, request) {
      return BillingNavigationLaunchPlanner(
        hasTenant: request.hasTenant,
        navigationSet: ref.watch(
          billingTenantDomainModuleNavigationSetProvider(request.preferences),
        ),
      );
    });

final billingTenantDomainModuleDestinationLaunchSnapshotProvider =
    Provider.family<
      BillingNavigationLaunchSnapshot,
      BillingNavigationLaunchPlannerRequest
    >((ref, request) {
      return ref
          .watch(
            billingTenantDomainModuleNavigationLaunchPlannerProvider(request),
          )
          .destinationSnapshot();
    });

final billingTenantDomainModuleQuickActionLaunchSnapshotProvider =
    Provider.family<
      BillingNavigationLaunchSnapshot,
      BillingNavigationLaunchPlannerRequest
    >((ref, request) {
      return ref
          .watch(
            billingTenantDomainModuleNavigationLaunchPlannerProvider(request),
          )
          .quickActionSnapshot();
    });

final billingTenantDomainModuleDestinationDispatchSnapshotProvider =
    Provider.family<
      BillingNavigationDispatchSnapshot,
      BillingNavigationDispatchSnapshotRequest
    >((ref, request) {
      return ref
          .watch(
            billingTenantDomainModuleNavigationLaunchPlannerProvider(
              request.plannerRequest,
            ),
          )
          .destinationDispatchSnapshot(currentSurface: request.currentSurface);
    });

final billingTenantDomainModuleQuickActionDispatchSnapshotProvider =
    Provider.family<
      BillingNavigationDispatchSnapshot,
      BillingNavigationDispatchSnapshotRequest
    >((ref, request) {
      return ref
          .watch(
            billingTenantDomainModuleNavigationLaunchPlannerProvider(
              request.plannerRequest,
            ),
          )
          .quickActionDispatchSnapshot(currentSurface: request.currentSurface);
    });

final billingTenantDomainModuleNavigationCoverageProvider = Provider.family<
  BillingNavigationCoverageReport,
  BillingNavigationLaunchPlannerRequest
>((ref, request) {
  return BillingNavigationCoverageReport.forNavigationSet(
    navigationSet: ref.watch(
      billingTenantDomainModuleNavigationSetProvider(request.preferences),
    ),
    hasTenant: request.hasTenant,
  );
});

final billingTenantDomainModuleNavigationLaunchStateProvider = Provider.family<
  BillingNavigationLaunchState,
  BillingTenantNavigationLaunchStateRequest
>((ref, request) {
  return ref
      .watch(
        billingTenantDomainModuleNavigationLaunchPlannerProvider(
          request.plannerRequest,
        ),
      )
      .stateFor(request.destinationId);
});
