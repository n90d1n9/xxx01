import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_launch_state.dart';
import 'billing_navigation_launch_snapshot.dart';

class BillingNavigationLaunchPlanner {
  final bool hasTenant;
  final BillingDomainNavigationSet? navigationSet;

  const BillingNavigationLaunchPlanner({
    required this.hasTenant,
    this.navigationSet,
  });

  List<BillingNavigationDestination> get destinations {
    return navigationSet?.destinations ?? BillingNavigationDestination.all;
  }

  List<BillingNavigationDestinationId> get quickActionIds {
    return navigationSet?.quickActionIds ??
        BillingNavigationDestination.quickActionIds;
  }

  BillingNavigationDestinationId get defaultDestinationId {
    return navigationSet?.defaultDestinationId ??
        BillingNavigationDestinationId.dashboard;
  }

  BillingNavigationLaunchState stateFor(
    BillingNavigationDestinationId destinationId,
  ) {
    return billingNavigationLaunchStateFor(
      destinationId,
      hasTenant: hasTenant,
      navigationSet: navigationSet,
    );
  }

  List<BillingNavigationLaunchState> statesFor(
    Iterable<BillingNavigationDestinationId> destinationIds,
  ) {
    return List.unmodifiable(destinationIds.map(stateFor));
  }

  BillingNavigationLaunchSnapshot snapshotFor(
    Iterable<BillingNavigationDestinationId> destinationIds,
  ) {
    return BillingNavigationLaunchSnapshot(
      states: statesFor(destinationIds),
      defaultDestinationId: defaultDestinationId,
    );
  }

  List<BillingNavigationLaunchState> destinationStates({
    Iterable<BillingNavigationDestination>? destinations,
  }) {
    final resolvedDestinations = destinations ?? this.destinations;

    return List.unmodifiable(
      resolvedDestinations.map((destination) => stateFor(destination.id)),
    );
  }

  BillingNavigationLaunchSnapshot destinationSnapshot({
    Iterable<BillingNavigationDestination>? destinations,
  }) {
    return BillingNavigationLaunchSnapshot(
      states: destinationStates(destinations: destinations),
      defaultDestinationId: defaultDestinationId,
    );
  }

  BillingNavigationDispatchSnapshot destinationDispatchSnapshot({
    required BillingNavigationSurface currentSurface,
    Iterable<BillingNavigationDestination>? destinations,
  }) {
    return BillingNavigationDispatchSnapshot.fromLaunchSnapshot(
      launchSnapshot: destinationSnapshot(destinations: destinations),
      currentSurface: currentSurface,
    );
  }

  List<BillingNavigationLaunchState> quickActionStates({
    Iterable<BillingNavigationDestinationId>? destinationIds,
  }) {
    return statesFor(destinationIds ?? quickActionIds);
  }

  BillingNavigationLaunchSnapshot quickActionSnapshot({
    Iterable<BillingNavigationDestinationId>? destinationIds,
  }) {
    return BillingNavigationLaunchSnapshot(
      states: quickActionStates(destinationIds: destinationIds),
      defaultDestinationId: defaultDestinationId,
    );
  }

  BillingNavigationDispatchSnapshot quickActionDispatchSnapshot({
    required BillingNavigationSurface currentSurface,
    Iterable<BillingNavigationDestinationId>? destinationIds,
  }) {
    return BillingNavigationDispatchSnapshot.fromLaunchSnapshot(
      launchSnapshot: quickActionSnapshot(destinationIds: destinationIds),
      currentSurface: currentSurface,
    );
  }

  BillingNavigationLaunchState? firstEnabledState({
    Iterable<BillingNavigationDestinationId>? destinationIds,
  }) {
    for (final state in statesFor(
      destinationIds ?? destinations.map((destination) => destination.id),
    )) {
      if (state.isEnabled) return state;
    }

    return null;
  }

  BillingNavigationDestinationId selectedDestinationIdFor(
    BillingNavigationDestinationId preferredDestinationId, {
    Iterable<BillingNavigationDestinationId>? fallbackDestinationIds,
  }) {
    final preferredState = stateFor(preferredDestinationId);
    if (preferredState.isEnabled) return preferredState.destinationId;

    final fallbackState = firstEnabledState(
      destinationIds:
          fallbackDestinationIds ??
          [
            defaultDestinationId,
            ...destinations.map((destination) => destination.id),
          ],
    );

    return fallbackState?.destinationId ?? preferredDestinationId;
  }
}
