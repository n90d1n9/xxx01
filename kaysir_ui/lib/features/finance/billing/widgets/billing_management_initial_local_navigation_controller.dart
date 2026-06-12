import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'billing_navigation_action_resolver.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_local_target.dart';
import 'billing_navigation_route_intent.dart';

typedef BillingInitialLocalTargetResolver =
    BillingNavigationLocalTarget Function(
      BillingNavigationDestinationId destinationId,
    );

typedef BillingInitialLocalNavigationHandler =
    bool Function(BillingNavigationLocalTarget localTarget);

typedef BillingInitialLocalNavigationGuard = bool Function();
typedef BillingPostFrameScheduler = void Function(FrameCallback callback);

class BillingInitialLocalNavigationResult {
  final BillingNavigationDestinationId destinationId;
  final BillingNavigationLocalTarget localTarget;
  final bool markedHandled;
  final bool scheduled;

  const BillingInitialLocalNavigationResult({
    required this.destinationId,
    required this.localTarget,
    required this.markedHandled,
    required this.scheduled,
  });

  bool get hasTarget => !localTarget.isNone;
}

class BillingManagementInitialLocalNavigationController {
  final bool hasHandledInitialDestination;
  final VoidCallback markInitialDestinationHandled;
  final BillingInitialLocalTargetResolver resolveLocalTarget;
  final BillingInitialLocalNavigationHandler onLocalNavigation;
  final BillingInitialLocalNavigationGuard canHandleLocalNavigation;
  final BillingPostFrameScheduler schedulePostFrame;

  BillingManagementInitialLocalNavigationController({
    required this.hasHandledInitialDestination,
    required this.markInitialDestinationHandled,
    required this.resolveLocalTarget,
    required this.onLocalNavigation,
    required this.canHandleLocalNavigation,
    BillingPostFrameScheduler? schedulePostFrame,
  }) : schedulePostFrame =
           schedulePostFrame ?? WidgetsBinding.instance.addPostFrameCallback;

  BillingInitialLocalNavigationResult schedule(
    BillingNavigationDestinationId destinationId,
  ) {
    if (hasHandledInitialDestination) {
      return BillingInitialLocalNavigationResult(
        destinationId: destinationId,
        localTarget: const BillingNavigationLocalTarget.none(),
        markedHandled: false,
        scheduled: false,
      );
    }

    markInitialDestinationHandled();

    final localTarget = resolveLocalTarget(destinationId);
    if (localTarget.isNone) {
      return BillingInitialLocalNavigationResult(
        destinationId: destinationId,
        localTarget: localTarget,
        markedHandled: true,
        scheduled: false,
      );
    }

    schedulePostFrame((_) {
      if (!canHandleLocalNavigation()) return;
      onLocalNavigation(localTarget);
    });

    return BillingInitialLocalNavigationResult(
      destinationId: destinationId,
      localTarget: localTarget,
      markedHandled: true,
      scheduled: true,
    );
  }
}

BillingNavigationLocalTarget billingInitialDashboardLocalTargetFor(
  BillingNavigationDestinationId destinationId,
) {
  final action = billingDashboardNavigationActionFor(destinationId);
  if (action == null || action == BillingDashboardNavigationAction.overview) {
    return const BillingNavigationLocalTarget.none();
  }

  return billingDashboardLocalTargetFor(
    action,
    intentKind: BillingNavigationRouteIntentKind.embedded,
    screenKey: 'initial.${destinationId.name}',
  );
}

BillingNavigationLocalTarget billingInitialProductWorkspaceLocalTargetFor(
  BillingNavigationDestinationId destinationId,
) {
  final action = billingProductWorkspaceNavigationActionFor(destinationId);
  if (action != BillingProductWorkspaceNavigationAction.cartCheckout) {
    return const BillingNavigationLocalTarget.none();
  }

  return billingProductWorkspaceLocalTargetFor(
    action!,
    intentKind: BillingNavigationRouteIntentKind.workflow,
    screenKey: 'initial.${destinationId.name}',
  );
}
