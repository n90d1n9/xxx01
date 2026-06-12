import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('BillingNavigationDestination exposes complete unique registry', () {
    final ids =
        BillingNavigationDestination.all
            .map((destination) => destination.id)
            .toSet();

    expect(ids.length, BillingNavigationDestination.all.length);
    expect(ids, BillingNavigationDestinationId.values.toSet());
  });

  test('BillingNavigationDestination defines tenant requirements', () {
    expect(
      billingNavigationDestinationFor(
        BillingNavigationDestinationId.dashboard,
      ).requiresTenant,
      isFalse,
    );
    expect(
      billingNavigationDestinationFor(
        BillingNavigationDestinationId.tenants,
      ).requiresTenant,
      isFalse,
    );
    expect(
      billingNavigationDestinationFor(
        BillingNavigationDestinationId.diagnostics,
      ).requiresTenant,
      isFalse,
    );
    expect(
      billingNavigationDestinationFor(
        BillingNavigationDestinationId.policyCenter,
      ).requiresTenant,
      isFalse,
    );

    for (final id in [
      BillingNavigationDestinationId.workCenter,
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.cartCheckout,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
    ]) {
      expect(billingNavigationDestinationFor(id).requiresTenant, isTrue);
    }
  });

  test(
    'BillingNavigationDestination quick actions resolve to registry items',
    () {
      final registryIds =
          BillingNavigationDestination.all
              .map((destination) => destination.id)
              .toSet();

      expect(
        BillingNavigationDestination.quickActionIds.toSet().difference(
          registryIds,
        ),
        isEmpty,
      );
      expect(
        BillingNavigationDestination.quickActionIds.first,
        BillingNavigationDestinationId.createInvoice,
      );
      expect(
        BillingNavigationDestination.quickActionIds,
        contains(BillingNavigationDestinationId.cartCheckout),
      );
      expect(
        BillingNavigationDestination.quickActionIds,
        isNot(contains(BillingNavigationDestinationId.diagnostics)),
      );
    },
  );

  test('BillingNavigationDestination defines destination surfaces', () {
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.dashboard),
      BillingNavigationSurface.dashboard,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.invoices),
      BillingNavigationSurface.dashboard,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.workCenter),
      BillingNavigationSurface.dashboard,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.reports),
      BillingNavigationSurface.dashboard,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.diagnostics),
      BillingNavigationSurface.dashboard,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.policyCenter),
      BillingNavigationSurface.dashboard,
    );
    expect(
      billingNavigationSurfaceFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      BillingNavigationSurface.productWorkspace,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.cartCheckout),
      BillingNavigationSurface.productWorkspace,
    );
    expect(
      billingNavigationSurfaceFor(BillingNavigationDestinationId.tenants),
      BillingNavigationSurface.tenantSelection,
    );
  });

  test('billing active destination helpers map cross-surface entries', () {
    expect(
      billingDashboardActiveDestinationFor(
        BillingNavigationDestinationId.reports,
      ),
      BillingNavigationDestinationId.reports,
    );
    expect(
      billingDashboardActiveDestinationFor(
        BillingNavigationDestinationId.workCenter,
      ),
      BillingNavigationDestinationId.workCenter,
    );
    expect(
      billingDashboardActiveDestinationFor(
        BillingNavigationDestinationId.diagnostics,
      ),
      BillingNavigationDestinationId.diagnostics,
    );
    expect(
      billingDashboardActiveDestinationFor(
        BillingNavigationDestinationId.policyCenter,
      ),
      BillingNavigationDestinationId.policyCenter,
    );
    expect(
      billingDashboardActiveDestinationFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      billingProductWorkspaceActiveDestinationFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(
      billingProductWorkspaceActiveDestinationFor(
        BillingNavigationDestinationId.reports,
      ),
      BillingNavigationDestinationId.productWorkspace,
    );
  });

  test('billingNavigationAvailabilityFor reports disabled destinations', () {
    final availability = billingNavigationAvailabilityFor(
      BillingNavigationDestinationId.createInvoice,
      hasTenant: false,
    );

    expect(availability.isEnabled, isFalse);
    expect(availability.disabledReason, 'Select a tenant first');
    expect(availability.description, 'Select a tenant first');
  });

  test('billingNavigationAvailabilityFor allows tenant destinations', () {
    final availability = billingNavigationAvailabilityFor(
      BillingNavigationDestinationId.createInvoice,
      hasTenant: true,
    );

    expect(availability.isEnabled, isTrue);
    expect(availability.disabledReason, isNull);
    expect(availability.description, 'Issue a draft from tenant data');
  });
}
