import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_business_domain_screen_registry.dart';
import 'billing_navigation_destination.dart';

const _universalBillingDestinationIds = {
  BillingNavigationDestinationId.dashboard,
  BillingNavigationDestinationId.workCenter,
  BillingNavigationDestinationId.tenants,
  BillingNavigationDestinationId.invoices,
  BillingNavigationDestinationId.createInvoice,
  BillingNavigationDestinationId.reports,
  BillingNavigationDestinationId.issueOutbox,
  BillingNavigationDestinationId.policyCenter,
  BillingNavigationDestinationId.diagnostics,
};

const _destinationCapabilities =
    <BillingNavigationDestinationId, Set<BillingBusinessDomainCapability>>{
      BillingNavigationDestinationId.productWorkspace: {
        BillingBusinessDomainCapability.productCatalog,
      },
      BillingNavigationDestinationId.cartCheckout: {
        BillingBusinessDomainCapability.cartCheckout,
      },
    };

class BillingDomainNavigationSet {
  final BillingBusinessDomainProfile profile;
  final List<BillingNavigationDestination> destinations;
  final List<BillingNavigationDestinationId> quickActionIds;
  final BillingNavigationDestinationId defaultDestinationId;
  final BillingBusinessDomainScreenRegistry? screenRegistry;

  BillingDomainNavigationSet({
    required this.profile,
    required this.destinations,
    required this.quickActionIds,
    BillingNavigationDestinationId? defaultDestinationId,
    this.screenRegistry,
  }) : defaultDestinationId =
           defaultDestinationId ?? _firstDestinationIdOrDashboard(destinations);

  bool exposes(BillingNavigationDestinationId destinationId) {
    return destinations.any((destination) => destination.id == destinationId);
  }

  BillingDomainScreenLaunchPlan launchPlanFor(
    BillingNavigationDestinationId destinationId, {
    required bool hasTenant,
  }) {
    final destination = billingNavigationDestinationFor(destinationId);
    final screen = screenRegistry?.find(destinationId);

    return BillingDomainScreenLaunchPlan(
      destination: destination,
      screen: screen,
      hasTenant: hasTenant,
      isExposed: exposes(destinationId),
      requiresRegisteredScreen: screenRegistry != null,
    );
  }
}

class BillingDomainScreenLaunchPlan {
  final BillingNavigationDestination destination;
  final BillingBusinessDomainScreenDescriptor? screen;
  final bool hasTenant;
  final bool isExposed;
  final bool requiresRegisteredScreen;

  const BillingDomainScreenLaunchPlan({
    required this.destination,
    required this.screen,
    required this.hasTenant,
    required this.isExposed,
    required this.requiresRegisteredScreen,
  });

  BillingNavigationDestinationId get destinationId => destination.id;

  BillingNavigationSurface get surface =>
      screen?.surface ?? destination.surface;

  BillingBusinessDomainScreenPresentation get presentation {
    return screen?.presentation ??
        BillingBusinessDomainScreenPresentation.embedded;
  }

  String get screenKey => screen?.key ?? 'legacy.${destination.id.name}';

  bool get requiresTenant =>
      screen?.requiresTenant ?? destination.requiresTenant;

  bool get hasRegisteredScreen => screen != null || !requiresRegisteredScreen;

  bool get isEnabled => disabledReason == null;

  String get description => disabledReason ?? destination.description;

  String? get disabledReason {
    if (!isExposed) {
      return 'This destination is not available for this billing domain.';
    }
    if (!hasRegisteredScreen) {
      return 'This destination is not configured for this billing domain.';
    }
    if (requiresTenant && !hasTenant) return destination.disabledDescription;

    return null;
  }
}

bool billingNavigationDestinationSupportsProfile(
  BillingNavigationDestinationId destinationId,
  BillingBusinessDomainProfile profile,
) {
  if (_universalBillingDestinationIds.contains(destinationId)) return true;

  final requiredCapabilities = _destinationCapabilities[destinationId];
  if (requiredCapabilities == null || requiredCapabilities.isEmpty) {
    return false;
  }

  return requiredCapabilities.every(profile.supports);
}

bool billingNavigationDestinationSupportsModule(
  BillingNavigationDestinationId destinationId,
  BillingBusinessDomainModule module,
) {
  if (!_moduleRegistersDestination(module, destinationId)) return false;

  final explicitDestinationIds = module.navigationPolicy?.destinationIds;
  if (explicitDestinationIds != null) {
    return explicitDestinationIds.contains(destinationId);
  }

  return billingNavigationDestinationSupportsProfile(
    destinationId,
    module.profile,
  );
}

List<BillingNavigationDestinationId> billingNavigationDestinationIdsForProfile(
  BillingBusinessDomainProfile profile, {
  Iterable<BillingNavigationDestinationId>? candidates,
}) {
  final destinationIds =
      candidates ??
      BillingNavigationDestination.all.map((destination) => destination.id);

  return List.unmodifiable(
    destinationIds.where(
      (destinationId) =>
          billingNavigationDestinationSupportsProfile(destinationId, profile),
    ),
  );
}

List<BillingNavigationDestinationId> billingNavigationDestinationIdsForModule(
  BillingBusinessDomainModule module, {
  Iterable<BillingNavigationDestinationId>? candidates,
}) {
  final explicitDestinationIds = module.navigationPolicy?.destinationIds;
  if (explicitDestinationIds != null) {
    return _filterModuleDestinationIds(
      module,
      explicitDestinationIds,
      candidates,
    );
  }

  return _filterModuleDestinationIds(
    module,
    billingNavigationDestinationIdsForProfile(
      module.profile,
      candidates: candidates,
    ),
    null,
  );
}

List<BillingNavigationDestination> billingNavigationDestinationsForProfile(
  BillingBusinessDomainProfile profile, {
  Iterable<BillingNavigationDestinationId>? candidates,
}) {
  return List.unmodifiable(
    billingNavigationDestinationIdsForProfile(
      profile,
      candidates: candidates,
    ).map(billingNavigationDestinationFor),
  );
}

List<BillingNavigationDestination> billingNavigationDestinationsForModule(
  BillingBusinessDomainModule module, {
  Iterable<BillingNavigationDestinationId>? candidates,
}) {
  return List.unmodifiable(
    billingNavigationDestinationIdsForModule(
      module,
      candidates: candidates,
    ).map(billingNavigationDestinationFor),
  );
}

List<BillingNavigationDestinationId> billingQuickActionDestinationIdsForProfile(
  BillingBusinessDomainProfile profile,
) {
  return billingNavigationDestinationIdsForProfile(
    profile,
    candidates: BillingNavigationDestination.quickActionIds,
  );
}

List<BillingNavigationDestinationId> billingQuickActionDestinationIdsForModule(
  BillingBusinessDomainModule module,
) {
  final policy = module.navigationPolicy;
  if (policy != null) {
    final availableIds =
        billingNavigationDestinationIdsForModule(module).toSet();
    final quickActionIds =
        policy.quickActionIds ?? BillingNavigationDestination.quickActionIds;

    return List.unmodifiable(quickActionIds.where(availableIds.contains));
  }

  return billingNavigationDestinationIdsForModule(
    module,
    candidates: BillingNavigationDestination.quickActionIds,
  );
}

BillingDomainNavigationSet billingDomainNavigationSetForProfile(
  BillingBusinessDomainProfile profile,
) {
  return BillingDomainNavigationSet(
    profile: profile,
    destinations: billingNavigationDestinationsForProfile(profile),
    quickActionIds: billingQuickActionDestinationIdsForProfile(profile),
    defaultDestinationId: BillingNavigationDestinationId.dashboard,
  );
}

BillingDomainNavigationSet billingDomainNavigationSetForModule(
  BillingBusinessDomainModule module,
) {
  final destinations = billingNavigationDestinationsForModule(module);

  return BillingDomainNavigationSet(
    profile: module.profile,
    destinations: destinations,
    quickActionIds: billingQuickActionDestinationIdsForModule(module),
    screenRegistry: module.screenRegistry,
    defaultDestinationId: _resolveModuleDefaultDestinationId(
      module,
      destinations,
    ),
  );
}

List<BillingNavigationDestinationId> _filterDestinationIds(
  Iterable<BillingNavigationDestinationId> destinationIds,
  Iterable<BillingNavigationDestinationId>? candidates,
) {
  if (candidates == null) return List.unmodifiable(destinationIds);

  final candidateSet = candidates.toSet();
  return List.unmodifiable(destinationIds.where(candidateSet.contains));
}

List<BillingNavigationDestinationId> _filterModuleDestinationIds(
  BillingBusinessDomainModule module,
  Iterable<BillingNavigationDestinationId> destinationIds,
  Iterable<BillingNavigationDestinationId>? candidates,
) {
  return _filterDestinationIds(
    destinationIds.where(
      (destinationId) => _moduleRegistersDestination(module, destinationId),
    ),
    candidates,
  );
}

bool _moduleRegistersDestination(
  BillingBusinessDomainModule module,
  BillingNavigationDestinationId destinationId,
) {
  final screenRegistry = module.screenRegistry;
  if (screenRegistry == null) return true;

  return screenRegistry.contains(destinationId);
}

BillingNavigationDestinationId _resolveModuleDefaultDestinationId(
  BillingBusinessDomainModule module,
  List<BillingNavigationDestination> destinations,
) {
  final preferredId = module.navigationPolicy?.defaultDestinationId;
  if (preferredId != null &&
      destinations.any((destination) => destination.id == preferredId)) {
    return preferredId;
  }

  return _firstDestinationIdOrDashboard(destinations);
}

BillingNavigationDestinationId _firstDestinationIdOrDashboard(
  List<BillingNavigationDestination> destinations,
) {
  if (destinations.isEmpty) return BillingNavigationDestinationId.dashboard;

  return destinations.first.id;
}
