import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_initial_local_navigation_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';

void main() {
  test('dashboard resolver skips overview and unsupported destinations', () {
    final overviewTarget = billingInitialDashboardLocalTargetFor(
      BillingNavigationDestinationId.dashboard,
    );
    final productTarget = billingInitialDashboardLocalTargetFor(
      BillingNavigationDestinationId.productWorkspace,
    );
    final reportsTarget = billingInitialDashboardLocalTargetFor(
      BillingNavigationDestinationId.reports,
    );

    expect(overviewTarget.isNone, isTrue);
    expect(productTarget.isNone, isTrue);
    expect(
      reportsTarget.kind,
      BillingNavigationLocalTargetKind.dashboardReports,
    );
    expect(reportsTarget.screenKey, 'initial.reports');
  });

  test('product resolver schedules checkout workflow only', () {
    final catalogTarget = billingInitialProductWorkspaceLocalTargetFor(
      BillingNavigationDestinationId.productWorkspace,
    );
    final checkoutTarget = billingInitialProductWorkspaceLocalTargetFor(
      BillingNavigationDestinationId.cartCheckout,
    );

    expect(catalogTarget.isNone, isTrue);
    expect(checkoutTarget.kind, BillingNavigationLocalTargetKind.cartCheckout);
    expect(checkoutTarget.screenKey, 'initial.cartCheckout');
  });

  test('schedules initial local target after the current frame', () {
    var markedHandled = false;
    FrameCallback? scheduledCallback;
    BillingNavigationLocalTarget? handledTarget;

    final result = BillingManagementInitialLocalNavigationController(
      hasHandledInitialDestination: false,
      markInitialDestinationHandled: () {
        markedHandled = true;
      },
      resolveLocalTarget: billingInitialDashboardLocalTargetFor,
      canHandleLocalNavigation: () => true,
      onLocalNavigation: (localTarget) {
        handledTarget = localTarget;
        return true;
      },
      schedulePostFrame: (callback) {
        scheduledCallback = callback;
      },
    ).schedule(BillingNavigationDestinationId.createInvoice);

    expect(result.markedHandled, isTrue);
    expect(result.scheduled, isTrue);
    expect(result.hasTarget, isTrue);
    expect(markedHandled, isTrue);
    expect(handledTarget, isNull);
    expect(scheduledCallback, isNotNull);

    scheduledCallback!(Duration.zero);

    expect(
      handledTarget?.kind,
      BillingNavigationLocalTargetKind.dashboardCreateInvoice,
    );
  });

  test('does not run scheduled handler when guard fails', () {
    FrameCallback? scheduledCallback;
    var handlerCalls = 0;

    final result = BillingManagementInitialLocalNavigationController(
      hasHandledInitialDestination: false,
      markInitialDestinationHandled: () {},
      resolveLocalTarget: billingInitialProductWorkspaceLocalTargetFor,
      canHandleLocalNavigation: () => false,
      onLocalNavigation: (_) {
        handlerCalls += 1;
        return true;
      },
      schedulePostFrame: (callback) {
        scheduledCallback = callback;
      },
    ).schedule(BillingNavigationDestinationId.cartCheckout);

    expect(result.scheduled, isTrue);
    expect(scheduledCallback, isNotNull);

    scheduledCallback!(Duration.zero);

    expect(handlerCalls, 0);
  });

  test('does not resolve or mark already-handled destinations', () {
    var markCalls = 0;
    var resolverCalls = 0;
    var scheduleCalls = 0;

    final result = BillingManagementInitialLocalNavigationController(
      hasHandledInitialDestination: true,
      markInitialDestinationHandled: () {
        markCalls += 1;
      },
      resolveLocalTarget: (_) {
        resolverCalls += 1;
        return const BillingNavigationLocalTarget.none();
      },
      canHandleLocalNavigation: () => true,
      onLocalNavigation: (_) => true,
      schedulePostFrame: (_) {
        scheduleCalls += 1;
      },
    ).schedule(BillingNavigationDestinationId.createInvoice);

    expect(result.markedHandled, isFalse);
    expect(result.scheduled, isFalse);
    expect(markCalls, 0);
    expect(resolverCalls, 0);
    expect(scheduleCalls, 0);
  });
}
