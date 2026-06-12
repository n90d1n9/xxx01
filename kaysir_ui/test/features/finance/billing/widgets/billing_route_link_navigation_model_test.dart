import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_route_link_navigation_model.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_link.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  test(
    'navigation model exposes sections, items, and selected destination',
    () {
      final launchSnapshot = const BillingNavigationLaunchPlanner(
        hasTenant: false,
      ).snapshotFor(const [
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.tenants,
        BillingNavigationDestinationId.invoices,
      ]);
      final model = BillingRouteLinkNavigationModel(
        routeLinks: [
          billingRouteLinkForDestination(
            BillingNavigationDestinationId.productWorkspace,
            launchSnapshot: launchSnapshot,
          )!,
          billingRouteLinkForDestination(
            BillingNavigationDestinationId.tenants,
            launchSnapshot: launchSnapshot,
          )!,
          billingRouteLinkForDestination(
            BillingNavigationDestinationId.invoices,
            launchSnapshot: launchSnapshot,
          )!,
        ],
        selectedDestinationId: BillingNavigationDestinationId.productWorkspace,
      );

      expect(model.isNotEmpty, isTrue);
      expect(
        model.selectedDestinationId,
        BillingNavigationDestinationId.tenants,
      );
      expect(model.sections, hasLength(2));
      expect(model.items, hasLength(3));
      expect(model.enabledItems.map((item) => item.destinationId), [
        BillingNavigationDestinationId.tenants,
      ]);
      expect(model.disabledItems.map((item) => item.destinationId), [
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.invoices,
      ]);
      expect(
        model.itemFor(BillingNavigationDestinationId.invoices)?.description,
        'Select a tenant first',
      );
      expect(
        model.isSelected(
          model.itemFor(BillingNavigationDestinationId.tenants)!,
        ),
        isTrue,
      );
    },
  );

  test('builds route-link navigation sections from destination labels', () {
    final sections = billingRouteLinkNavigationSections([
      billingRouteLinkForDestination(BillingNavigationDestinationId.tenants)!,
      billingRouteLinkForDestination(BillingNavigationDestinationId.invoices)!,
      billingRouteLinkForDestination(
        BillingNavigationDestinationId.createInvoice,
      )!,
      billingRouteLinkForDestination(
        BillingNavigationDestinationId.policyCenter,
      )!,
      billingRouteLinkForDestination(
        BillingNavigationDestinationId.diagnostics,
      )!,
    ]);

    expect(sections, hasLength(3));
    expect(sections[0].hasLabel, isFalse);
    expect(sections[0].destinationIds, [
      BillingNavigationDestinationId.tenants,
    ]);
    expect(sections[1].label, 'Billing operations');
    expect(sections[1].destinationIds, [
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.createInvoice,
    ]);
    expect(sections[2].label, 'System');
    expect(sections[2].destinationIds, [
      BillingNavigationDestinationId.policyCenter,
      BillingNavigationDestinationId.diagnostics,
    ]);
  });

  test('route-link navigation items expose disabled descriptions', () {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: false,
    ).snapshotFor(const [BillingNavigationDestinationId.productWorkspace]);
    final sections = billingRouteLinkNavigationSections([
      billingRouteLinkForDestination(
        BillingNavigationDestinationId.productWorkspace,
        launchSnapshot: launchSnapshot,
      )!,
    ]);
    final item = sections.single.items.single;

    expect(item.destinationId, BillingNavigationDestinationId.productWorkspace);
    expect(item.isEnabled, isFalse);
    expect(item.description, 'Select a tenant first');
    expect(
      sections.single.disabledItems.single.destinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
  });

  test('route-link navigation model hides non-exposed links', () {
    final launchSnapshot = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        constructionBillingDomainModule(),
      ),
    ).snapshotFor(const [
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.cartCheckout,
    ]);
    final model = BillingRouteLinkNavigationModel(
      routeLinks: [
        billingRouteLinkForDestination(
          BillingNavigationDestinationId.invoices,
          launchSnapshot: launchSnapshot,
        )!,
        billingRouteLinkForDestination(
          BillingNavigationDestinationId.cartCheckout,
          launchSnapshot: launchSnapshot,
        )!,
      ],
      selectedDestinationId: BillingNavigationDestinationId.cartCheckout,
    );

    expect(model.itemFor(BillingNavigationDestinationId.invoices), isNotNull);
    expect(model.itemFor(BillingNavigationDestinationId.cartCheckout), isNull);
    expect(
      model.selectedDestinationId,
      BillingNavigationDestinationId.invoices,
    );
  });

  test('selected route-link destination falls back to first enabled link', () {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: false,
    ).snapshotFor(const [
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.tenants,
    ]);
    final links = [
      billingRouteLinkForDestination(
        BillingNavigationDestinationId.productWorkspace,
        launchSnapshot: launchSnapshot,
      )!,
      billingRouteLinkForDestination(
        BillingNavigationDestinationId.tenants,
        launchSnapshot: launchSnapshot,
      )!,
    ];

    expect(
      billingRouteLinkSelectedDestinationIdFor(
        links,
        BillingNavigationDestinationId.productWorkspace,
      ),
      BillingNavigationDestinationId.tenants,
    );
    expect(
      billingRouteLinkSelectedDestinationIdFor(
        links,
        BillingNavigationDestinationId.tenants,
      ),
      BillingNavigationDestinationId.tenants,
    );
  });

  test(
    'selected route-link destination stays put when every link is disabled',
    () {
      final launchSnapshot = const BillingNavigationLaunchPlanner(
        hasTenant: false,
      ).snapshotFor(const [BillingNavigationDestinationId.productWorkspace]);
      final links = [
        billingRouteLinkForDestination(
          BillingNavigationDestinationId.productWorkspace,
          launchSnapshot: launchSnapshot,
        )!,
      ];

      expect(
        billingRouteLinkSelectedDestinationIdFor(
          links,
          BillingNavigationDestinationId.productWorkspace,
        ),
        BillingNavigationDestinationId.productWorkspace,
      );
    },
  );
}
