import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_navigation_action_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_snapshot.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_state.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  testWidgets('shows unavailable destination messages', (tester) async {
    final snapshot = _commerceDispatchSnapshot(
      hasTenant: false,
      currentSurface: BillingNavigationSurface.dashboard,
    );

    final result = await _handleDestinationInScaffold(
      tester,
      snapshot: snapshot,
      destinationId: BillingNavigationDestinationId.productWorkspace,
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.unavailable,
    );
    expect(result.handled, isTrue);
    expect(result.message, 'Select a tenant first');
    expect(find.text('Select a tenant first'), findsOneWidget);
  });

  testWidgets('dispatches local targets through the screen handler', (
    tester,
  ) async {
    final snapshot = _commerceDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
    );
    BillingNavigationLocalTarget? selectedLocalTarget;

    final result = await _handleDestinationInScaffold(
      tester,
      snapshot: snapshot,
      destinationId: BillingNavigationDestinationId.invoices,
      onLocalNavigation: (localTarget) {
        selectedLocalTarget = localTarget;
        return true;
      },
    );

    expect(result.kind, BillingManagementNavigationActionResultKind.local);
    expect(result.handled, isTrue);
    expect(
      selectedLocalTarget?.kind,
      BillingNavigationLocalTargetKind.dashboardInvoices,
    );
  });

  testWidgets('returns route fallback when app routing is unavailable', (
    tester,
  ) async {
    final snapshot = _commerceDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
    );

    final result = await _handleDestinationInScaffold(
      tester,
      snapshot: snapshot,
      destinationId: BillingNavigationDestinationId.cartCheckout,
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.routeFallback,
    );
    expect(result.handled, isFalse);
    expect(result.requiresRouteFallback, isTrue);
    expect(
      result.routeTarget?.kind,
      BillingNavigationRouteTargetKind.productWorkspace,
    );
  });

  testWidgets('marks route fallback handled when a fallback handler succeeds', (
    tester,
  ) async {
    final snapshot = _commerceDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
    );
    BillingNavigationRouteTarget? fallbackRouteTarget;

    final result = await _handleDestinationInScaffold(
      tester,
      snapshot: snapshot,
      destinationId: BillingNavigationDestinationId.cartCheckout,
      onRouteFallback: (routeTarget) {
        fallbackRouteTarget = routeTarget;
        return true;
      },
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.routeFallback,
    );
    expect(result.handled, isTrue);
    expect(result.routeFallbackHandled, isTrue);
    expect(result.requiresRouteFallback, isFalse);
    expect(
      fallbackRouteTarget?.kind,
      BillingNavigationRouteTargetKind.productWorkspace,
    );
  });

  testWidgets('reports route-opened when an injected route handler succeeds', (
    tester,
  ) async {
    final snapshot = _commerceDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
    );
    BillingNavigationRouteTarget? openedRouteTarget;

    final result = await _handleDestinationInScaffold(
      tester,
      snapshot: snapshot,
      destinationId: BillingNavigationDestinationId.cartCheckout,
      onRouteNavigation: (routeTarget) {
        openedRouteTarget = routeTarget;
        return true;
      },
    );

    expect(
      result.kind,
      BillingManagementNavigationActionResultKind.routeOpened,
    );
    expect(result.handled, isTrue);
    expect(
      openedRouteTarget?.initialDestinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
  });

  testWidgets('keeps ignored plans non-actionable', (tester) async {
    final snapshot = _ignoredDispatchSnapshot();

    final result = await _handleDestinationInScaffold(
      tester,
      snapshot: snapshot,
      destinationId: BillingNavigationDestinationId.productWorkspace,
    );

    expect(result.kind, BillingManagementNavigationActionResultKind.ignored);
    expect(result.handled, isFalse);
    expect(result.requiresRouteFallback, isFalse);
  });
}

BillingNavigationDispatchSnapshot _commerceDispatchSnapshot({
  bool hasTenant = true,
  required BillingNavigationSurface currentSurface,
}) {
  final planner = BillingNavigationLaunchPlanner(
    hasTenant: hasTenant,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  );

  return planner.destinationDispatchSnapshot(currentSurface: currentSurface);
}

BillingNavigationDispatchSnapshot _ignoredDispatchSnapshot() {
  final launchState = BillingNavigationLaunchState(
    destination: billingNavigationDestinationFor(
      BillingNavigationDestinationId.productWorkspace,
    ),
    surface: BillingNavigationSurface.dashboard,
    presentation: BillingBusinessDomainScreenPresentation.embedded,
    requiresTenant: true,
    isExposed: true,
    hasRegisteredScreen: true,
    isEnabled: true,
    description: 'Ignored destination',
    disabledReason: null,
    screenKey: 'test.ignored_product_workspace',
  );
  final plan = resolveBillingNavigationDispatchPlan(
    launchState: launchState,
    currentSurface: BillingNavigationSurface.dashboard,
  );

  return BillingNavigationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
    defaultDestinationId: BillingNavigationDestinationId.dashboard,
    plans: [plan],
  );
}

Future<BillingManagementNavigationActionResult> _handleDestinationInScaffold(
  WidgetTester tester, {
  required BillingNavigationDispatchSnapshot snapshot,
  required BillingNavigationDestinationId destinationId,
  BillingManagementLocalNavigationHandler? onLocalNavigation,
  BillingManagementRouteNavigationHandler? onRouteNavigation,
  BillingManagementRouteFallbackHandler? onRouteFallback,
}) async {
  late BillingManagementNavigationActionResult result;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                result = BillingManagementNavigationActionController(
                  context: context,
                  dispatchSnapshot: snapshot,
                  onLocalNavigation: onLocalNavigation,
                  onRouteNavigation: onRouteNavigation,
                  onRouteFallback: onRouteFallback,
                ).handle(destinationId);
              },
              child: const Text('Open destination'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open destination'));
  await tester.pump();

  return result;
}
