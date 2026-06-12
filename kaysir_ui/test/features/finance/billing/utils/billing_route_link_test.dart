import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_context.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_link.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  test('billingManagementRouteLinks builds context-aware sidebar links', () {
    final routeContext = BillingRouteContext(
      tenantId: ' tenant-a ',
      businessDomain: ' Construction ',
    );

    final links = billingManagementRouteLinks(routeContext: routeContext);

    expect(links, hasLength(BillingRoutes.sidebarRoutes.length));
    expect(links.first.title, 'Dashboard');
    expect(
      links.first.location,
      '${BillingRoutes.managementPath}?${BillingRoutes.tenantQueryKey}=tenant-a&${BillingRoutes.businessDomainQueryKey}=construction',
    );
    expect(links.first.carriesTenantContext, isTrue);
    expect(links.first.carriesBusinessDomainContext, isTrue);
    expect(
      links.map((link) => link.destinationId),
      BillingRoutes.sidebarRoutes.map((route) => route.destinationId),
    );
  });

  test(
    'billingManagementRouteLinksForLaunchSnapshot decorates availability',
    () {
      final snapshot = BillingNavigationLaunchPlanner(
        hasTenant: false,
        navigationSet: billingDomainNavigationSetForModule(
          constructionBillingDomainModule(),
        ),
      ).snapshotFor(
        BillingRoutes.sidebarRoutes.map((route) => route.destinationId),
      );

      final links = billingManagementRouteLinksForLaunchSnapshot(
        launchSnapshot: snapshot,
        routeContext: BillingRouteContext(businessDomain: 'construction'),
      );
      final workspaces = links.firstWhere(
        (link) => link.destinationId == BillingNavigationDestinationId.tenants,
      );
      final invoices = links.firstWhere(
        (link) => link.destinationId == BillingNavigationDestinationId.invoices,
      );
      final checkout = links.firstWhere(
        (link) =>
            link.destinationId == BillingNavigationDestinationId.cartCheckout,
      );

      expect(workspaces.isEnabled, isTrue);
      expect(workspaces.requiresTenant, isFalse);
      expect(invoices.isDisabled, isTrue);
      expect(invoices.disabledReason, 'Select a tenant first');
      expect(checkout.isDisabled, isTrue);
      expect(checkout.isExposed, isFalse);
      expect(
        checkout.disabledReason,
        'This destination is not available for this billing domain.',
      );
      expect(checkout.carriesBusinessDomainContext, isTrue);
    },
  );

  test('billingRouteLinkForDestination returns route metadata and location', () {
    final link = billingRouteLinkForDestination(
      BillingNavigationDestinationId.cartCheckout,
      routeContext: BillingRouteContext(
        tenantId: 'tenant-b',
        businessDomain: 'digital',
      ),
    );

    expect(link, isNotNull);
    expect(link?.routeName, BillingRoutes.checkoutRouteName);
    expect(link?.title, 'Cart Checkout');
    expect(link?.surface, BillingManagementRouteSurface.productWorkspace);
    expect(
      link?.location,
      '${BillingRoutes.checkoutPath}?${BillingRoutes.tenantQueryKey}=tenant-b&${BillingRoutes.businessDomainQueryKey}=digital',
    );
  });

  test('billingRouteLinkForDestination returns dashboard metadata', () {
    final link = billingRouteLinkForDestination(
      BillingNavigationDestinationId.dashboard,
      routeContext: BillingRouteContext(businessDomain: 'commerce'),
    );

    expect(link, isNotNull);
    expect(link?.routeName, BillingRoutes.managementRouteName);
    expect(link?.title, 'Dashboard');
    expect(link?.surface, BillingManagementRouteSurface.dashboard);
    expect(
      link?.location,
      '${BillingRoutes.managementPath}?${BillingRoutes.businessDomainQueryKey}=commerce',
    );
  });

  test('billingRouteLinkForDestination can include launch state', () {
    final snapshot = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        constructionBillingDomainModule(),
      ),
    ).snapshotFor(
      BillingRoutes.sidebarRoutes.map((route) => route.destinationId),
    );

    final link = billingRouteLinkForDestination(
      BillingNavigationDestinationId.cartCheckout,
      launchSnapshot: snapshot,
      routeContext: BillingRouteContext(businessDomain: 'construction'),
    );

    expect(link?.isDisabled, isTrue);
    expect(link?.requiresTenant, isTrue);
    expect(link?.hasRegisteredScreen, isFalse);
    expect(link?.screenKey, 'legacy.cartCheckout');
    expect(
      link?.availabilityDescription,
      'This destination is not available for this billing domain.',
    );
  });

  test(
    'billingRouteLinkForDestination respects filtered route definitions',
    () {
      final link = billingRouteLinkForDestination(
        BillingNavigationDestinationId.cartCheckout,
        routes: BillingRoutes.sidebarRoutes.where(
          (route) =>
              route.destinationId !=
              BillingNavigationDestinationId.cartCheckout,
        ),
      );

      expect(link, isNull);
    },
  );
}
