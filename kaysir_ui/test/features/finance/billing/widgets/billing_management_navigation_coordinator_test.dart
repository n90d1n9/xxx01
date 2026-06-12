import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_initial_local_navigation_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_navigation_action_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_navigation_coordinator.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_navigation_session.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_open_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_surface_route_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_snapshot.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  testWidgets('dispatches local destinations through local handler', (
    tester,
  ) async {
    BillingNavigationLocalTarget? handledTarget;

    final result = await _handleDestinationWithCoordinator(
      tester,
      currentSurface: BillingNavigationSurface.dashboard,
      destinationId: BillingNavigationDestinationId.invoices,
      onLocalNavigation: (localTarget) {
        handledTarget = localTarget;
        return true;
      },
    );

    expect(result.kind, BillingManagementNavigationActionResultKind.local);
    expect(result.handled, isTrue);
    expect(
      handledTarget?.kind,
      BillingNavigationLocalTargetKind.dashboardInvoices,
    );
  });

  testWidgets('falls back cross-surface routes through destination handlers', (
    tester,
  ) async {
    BillingNavigationDestinationId? openedDestination;
    BillingNavigationRouteTarget? openedRouteTarget;

    final result = await _handleDestinationWithCoordinator(
      tester,
      currentSurface: BillingNavigationSurface.dashboard,
      destinationId: BillingNavigationDestinationId.cartCheckout,
      onProductWorkspaceRouteDestination: (destination, routeTarget) {
        openedDestination = destination;
        openedRouteTarget = routeTarget;
        return true;
      },
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.routeFallback,
    );
    expect(result.handled, isTrue);
    expect(openedDestination, BillingNavigationDestinationId.cartCheckout);
    expect(
      openedRouteTarget?.kind,
      BillingNavigationRouteTargetKind.productWorkspace,
    );
  });

  testWidgets('schedules initial destinations through the local handler', (
    tester,
  ) async {
    var markedHandled = false;
    FrameCallback? scheduledCallback;
    BillingNavigationLocalTarget? handledTarget;
    late BillingInitialLocalNavigationResult result;
    final snapshot = _commerceDispatchSnapshot(
      hasTenant: true,
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final session = BillingManagementNavigationSession(
      currentSurface: BillingNavigationSurface.dashboard,
      dispatchSnapshot: snapshot,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  result = BillingManagementNavigationCoordinator.fromSession(
                    context: context,
                    session: session,
                    onLocalNavigation: (localTarget) {
                      handledTarget = localTarget;
                      return true;
                    },
                  ).scheduleInitialDestination(
                    destinationId: BillingNavigationDestinationId.createInvoice,
                    hasHandledInitialDestination: false,
                    markInitialDestinationHandled: () {
                      markedHandled = true;
                    },
                    resolveLocalTarget: billingInitialDashboardLocalTargetFor,
                    canHandleLocalNavigation: () => true,
                    schedulePostFrame: (callback) {
                      scheduledCallback = callback;
                    },
                  );
                },
                child: const Text('Schedule initial'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Schedule initial'));
    await tester.pump();

    expect(result.markedHandled, isTrue);
    expect(result.scheduled, isTrue);
    expect(markedHandled, isTrue);
    expect(handledTarget, isNull);
    expect(scheduledCallback, isNotNull);

    scheduledCallback!(Duration.zero);

    expect(
      handledTarget?.kind,
      BillingNavigationLocalTargetKind.dashboardCreateInvoice,
    );
  });

  testWidgets('runs route opening hooks before cross-surface fallback', (
    tester,
  ) async {
    BillingNavigationRouteTarget? openingTarget;
    BillingNavigationDestinationId? fallbackDestination;

    final result = await _handleDestinationWithCoordinator(
      tester,
      currentSurface: BillingNavigationSurface.productWorkspace,
      destinationId: BillingNavigationDestinationId.invoices,
      onDashboardRouteOpening: (routeTarget) {
        openingTarget = routeTarget;
      },
      onDashboardRouteDestination: (destination, _) {
        fallbackDestination = destination;
        return true;
      },
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.routeFallback,
    );
    expect(result.handled, isTrue);
    expect(
      openingTarget?.initialDestinationId,
      BillingNavigationDestinationId.invoices,
    );
    expect(fallbackDestination, BillingNavigationDestinationId.invoices);
  });

  testWidgets('presents unavailable messages through the coordinator', (
    tester,
  ) async {
    String? message;

    final result = await _handleDestinationWithCoordinator(
      tester,
      hasTenant: false,
      currentSurface: BillingNavigationSurface.dashboard,
      destinationId: BillingNavigationDestinationId.productWorkspace,
      onUnavailableMessage: (value) {
        message = value;
      },
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.unavailable,
    );
    expect(result.handled, isTrue);
    expect(message, 'Select a tenant first');
  });
}

Future<BillingManagementNavigationActionResult>
_handleDestinationWithCoordinator(
  WidgetTester tester, {
  required BillingNavigationSurface currentSurface,
  required BillingNavigationDestinationId destinationId,
  bool hasTenant = true,
  BillingManagementLocalNavigationHandler? onLocalNavigation,
  BillingManagementRouteOpeningHandler? onDashboardRouteOpening,
  BillingManagementDestinationRouteHandler? onDashboardRouteDestination,
  BillingManagementDestinationRouteHandler? onProductWorkspaceRouteDestination,
  BillingManagementNavigationMessagePresenter? onUnavailableMessage,
}) async {
  late BillingManagementNavigationActionResult result;
  final snapshot = _commerceDispatchSnapshot(
    hasTenant: hasTenant,
    currentSurface: currentSurface,
  );
  final session = BillingManagementNavigationSession(
    currentSurface: currentSurface,
    dispatchSnapshot: snapshot,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                result = BillingManagementNavigationCoordinator.fromSession(
                  context: context,
                  session: session,
                  onLocalNavigation: onLocalNavigation,
                  onDashboardRouteOpening: onDashboardRouteOpening,
                  onDashboardRouteDestination: onDashboardRouteDestination,
                  onProductWorkspaceRouteDestination:
                      onProductWorkspaceRouteDestination,
                  onUnavailableMessage: onUnavailableMessage,
                ).handleDestination(destinationId);
              },
              child: const Text('Navigate'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('Navigate'));
  await tester.pump();

  return result;
}

BillingNavigationDispatchSnapshot _commerceDispatchSnapshot({
  required bool hasTenant,
  required BillingNavigationSurface currentSurface,
}) {
  return BillingNavigationLaunchPlanner(
    hasTenant: hasTenant,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  ).destinationDispatchSnapshot(currentSurface: currentSurface);
}
