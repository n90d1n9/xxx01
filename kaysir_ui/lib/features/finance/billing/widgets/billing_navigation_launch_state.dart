import '../models/billing_business_domain_screen_registry.dart';
import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_destination.dart';

class BillingNavigationLaunchState {
  final BillingNavigationDestination destination;
  final BillingNavigationSurface surface;
  final BillingBusinessDomainScreenPresentation presentation;
  final bool requiresTenant;
  final bool isExposed;
  final bool hasRegisteredScreen;
  final bool isEnabled;
  final String description;
  final String? disabledReason;
  final String screenKey;

  const BillingNavigationLaunchState({
    required this.destination,
    required this.surface,
    required this.presentation,
    required this.requiresTenant,
    required this.isExposed,
    required this.hasRegisteredScreen,
    required this.isEnabled,
    required this.description,
    required this.disabledReason,
    required this.screenKey,
  });

  BillingNavigationDestinationId get destinationId => destination.id;

  factory BillingNavigationLaunchState.fromAvailability(
    BillingNavigationAvailability availability,
  ) {
    return BillingNavigationLaunchState(
      destination: availability.destination,
      surface: availability.destination.surface,
      presentation: BillingBusinessDomainScreenPresentation.embedded,
      requiresTenant: availability.destination.requiresTenant,
      isExposed: true,
      hasRegisteredScreen: true,
      isEnabled: availability.isEnabled,
      description: availability.description,
      disabledReason: availability.disabledReason,
      screenKey: 'legacy.${availability.destination.id.name}',
    );
  }

  factory BillingNavigationLaunchState.fromLaunchPlan(
    BillingDomainScreenLaunchPlan launchPlan,
  ) {
    return BillingNavigationLaunchState(
      destination: launchPlan.destination,
      surface: launchPlan.surface,
      presentation: launchPlan.presentation,
      requiresTenant: launchPlan.requiresTenant,
      isExposed: launchPlan.isExposed,
      hasRegisteredScreen: launchPlan.hasRegisteredScreen,
      isEnabled: launchPlan.isEnabled,
      description: launchPlan.description,
      disabledReason: launchPlan.disabledReason,
      screenKey: launchPlan.screenKey,
    );
  }
}

BillingNavigationLaunchState billingNavigationLaunchStateFor(
  BillingNavigationDestinationId destinationId, {
  required bool hasTenant,
  BillingDomainNavigationSet? navigationSet,
}) {
  final launchPlan = navigationSet?.launchPlanFor(
    destinationId,
    hasTenant: hasTenant,
  );

  if (launchPlan != null) {
    return BillingNavigationLaunchState.fromLaunchPlan(launchPlan);
  }

  return BillingNavigationLaunchState.fromAvailability(
    billingNavigationAvailabilityFor(destinationId, hasTenant: hasTenant),
  );
}
