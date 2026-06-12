import 'billing_navigation_destination.dart';
import 'billing_navigation_launch_state.dart';
import 'billing_navigation_local_target.dart';
import 'billing_navigation_route_intent.dart';
import 'billing_navigation_route_target.dart';

enum BillingNavigationDispatchKind { unavailable, local, route, ignored }

class BillingNavigationDispatchPlan {
  final BillingNavigationDispatchKind kind;
  final BillingNavigationRouteIntent routeIntent;
  final BillingNavigationLocalTarget localTarget;
  final BillingNavigationRouteTarget routeTarget;

  const BillingNavigationDispatchPlan._({
    required this.kind,
    required this.routeIntent,
    this.localTarget = const BillingNavigationLocalTarget.none(),
    this.routeTarget = const BillingNavigationRouteTarget.none(),
  });

  const BillingNavigationDispatchPlan.unavailable({
    required BillingNavigationRouteIntent routeIntent,
  }) : this._(
         kind: BillingNavigationDispatchKind.unavailable,
         routeIntent: routeIntent,
       );

  const BillingNavigationDispatchPlan.local({
    required BillingNavigationRouteIntent routeIntent,
    required BillingNavigationLocalTarget localTarget,
  }) : this._(
         kind: BillingNavigationDispatchKind.local,
         routeIntent: routeIntent,
         localTarget: localTarget,
       );

  const BillingNavigationDispatchPlan.route({
    required BillingNavigationRouteIntent routeIntent,
    required BillingNavigationRouteTarget routeTarget,
  }) : this._(
         kind: BillingNavigationDispatchKind.route,
         routeIntent: routeIntent,
         routeTarget: routeTarget,
       );

  const BillingNavigationDispatchPlan.ignored({
    required BillingNavigationRouteIntent routeIntent,
  }) : this._(
         kind: BillingNavigationDispatchKind.ignored,
         routeIntent: routeIntent,
       );

  BillingNavigationDestinationId get destinationId {
    return routeIntent.destinationId;
  }

  BillingNavigationDestination get destination => routeIntent.destination;

  String get description => disabledReason ?? destination.description;

  String? get disabledReason => routeIntent.disabledReason;

  BillingNavigationSurface get targetSurface => routeIntent.targetSurface;

  bool get isUnavailable {
    return kind == BillingNavigationDispatchKind.unavailable;
  }

  bool get isLocal => kind == BillingNavigationDispatchKind.local;

  bool get opensRoute => kind == BillingNavigationDispatchKind.route;

  bool get isIgnored => kind == BillingNavigationDispatchKind.ignored;

  bool get isActionable => isLocal || opensRoute;

  String get screenKey => routeIntent.screenKey;
}

BillingNavigationDispatchPlan resolveBillingNavigationDispatchPlan({
  required BillingNavigationLaunchState launchState,
  required BillingNavigationSurface currentSurface,
}) {
  final routeIntent = resolveBillingNavigationRouteIntent(
    launchState: launchState,
    currentSurface: currentSurface,
  );

  switch (routeIntent.kind) {
    case BillingNavigationRouteIntentKind.unavailable:
      return BillingNavigationDispatchPlan.unavailable(
        routeIntent: routeIntent,
      );
    case BillingNavigationRouteIntentKind.embedded:
    case BillingNavigationRouteIntentKind.sheet:
    case BillingNavigationRouteIntentKind.workflow:
      final localTarget = resolveBillingNavigationLocalTarget(routeIntent);
      if (localTarget.isNone) {
        return BillingNavigationDispatchPlan.ignored(routeIntent: routeIntent);
      }

      return BillingNavigationDispatchPlan.local(
        routeIntent: routeIntent,
        localTarget: localTarget,
      );
    case BillingNavigationRouteIntentKind.route:
      final routeTarget = resolveBillingNavigationRouteTarget(routeIntent);
      if (!routeTarget.opensRoute) {
        return BillingNavigationDispatchPlan.ignored(routeIntent: routeIntent);
      }

      return BillingNavigationDispatchPlan.route(
        routeIntent: routeIntent,
        routeTarget: routeTarget,
      );
    case BillingNavigationRouteIntentKind.ignored:
      return BillingNavigationDispatchPlan.ignored(routeIntent: routeIntent);
  }
}
