import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_route_contract_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_route_link_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_context.dart';

void main() {
  test('route link request normalizes tenant and business domain context', () {
    final request = BillingManagementRouteLinkRequest.fromTenant(
      preferences: const BillingTenantPreferences(
        businessDomain: ' Construction ',
      ),
      tenantId: ' tenant-a ',
    );

    expect(request.hasTenant, isTrue);
    expect(request.tenantId, 'tenant-a');
    expect(request.businessDomain, 'construction');
    expect(
      request.routeContext,
      BillingRouteContext(tenantId: 'tenant-a', businessDomain: 'construction'),
    );
    expect(
      request,
      BillingManagementRouteLinkRequest.fromTenant(
        preferences: const BillingTenantPreferences(
          businessDomain: 'construction',
        ),
        tenantId: 'tenant-a',
      ),
    );
  });

  test('default route link provider decorates commerce availability', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final links = container.read(
      billingDefaultManagementRouteLinksProvider(false),
    );
    final workspaces = links.firstWhere(
      (link) => link.destinationId == BillingNavigationDestinationId.tenants,
    );
    final products = links.firstWhere(
      (link) =>
          link.destinationId == BillingNavigationDestinationId.productWorkspace,
    );

    expect(links, hasLength(BillingRoutes.sidebarRoutes.length));
    expect(workspaces.isEnabled, isTrue);
    expect(
      workspaces.location,
      '${BillingRoutes.workspacesPath}?domain=commerce',
    );
    expect(products.isDisabled, isTrue);
    expect(products.disabledReason, 'Select a tenant first');
    expect(products.carriesBusinessDomainContext, isTrue);
    expect(products.carriesTenantContext, isFalse);
  });

  test('default route link provider includes extension route definitions', () {
    final container = ProviderContainer(
      overrides: [
        billingRouteContractExtensionRouteDefinitionsProvider.overrideWithValue(
          [_entitlementsRoute],
        ),
      ],
    );
    addTearDown(container.dispose);

    final links = container.read(
      billingDefaultManagementRouteLinksProvider(false),
    );
    final entitlements = links.singleWhere(
      (link) => link.routeIdentityKey == _entitlementsRoute.routeIdentityKey,
    );

    expect(links, hasLength(BillingRoutes.sidebarRoutes.length + 1));
    expect(entitlements.title, _entitlementsRoute.title);
    expect(
      entitlements.destinationId,
      BillingNavigationDestinationId.diagnostics,
    );
    expect(entitlements.location, '${_entitlementsRoute.path}?domain=commerce');
  });

  test('tenant route link provider preserves tenant and domain deep links', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final request = BillingManagementRouteLinkRequest.fromTenant(
      preferences: const BillingTenantPreferences(
        businessDomain: 'construction',
      ),
      tenantId: 'tenant-a',
    );
    final links = container.read(
      billingTenantManagementRouteLinksProvider(request),
    );
    final invoices = links.firstWhere(
      (link) => link.destinationId == BillingNavigationDestinationId.invoices,
    );
    final checkout = links.firstWhere(
      (link) =>
          link.destinationId == BillingNavigationDestinationId.cartCheckout,
    );

    expect(invoices.isEnabled, isTrue);
    expect(
      invoices.location,
      '${BillingRoutes.invoicesPath}?tenant=tenant-a&domain=construction',
    );
    expect(invoices.carriesTenantContext, isTrue);
    expect(invoices.carriesBusinessDomainContext, isTrue);
    expect(checkout.isDisabled, isTrue);
    expect(checkout.isExposed, isFalse);
    expect(
      checkout.disabledReason,
      'This destination is not available for this billing domain.',
    );
    expect(
      checkout.location,
      '${BillingRoutes.checkoutPath}?tenant=tenant-a&domain=construction',
    );
  });

  test(
    'tenant route-link navigation model exposes extension identity lookup',
    () {
      final container = ProviderContainer(
        overrides: [
          billingRouteContractExtensionRouteDefinitionsProvider
              .overrideWithValue([_entitlementsRoute]),
        ],
      );
      addTearDown(container.dispose);

      final model = container.read(
        billingTenantManagementRouteLinkNavigationModelProvider(
          BillingTenantManagementNavigationModelRequest.fromTenant(
            preferences: const BillingTenantPreferences(
              businessDomain: 'digital',
            ),
            tenantId: 'tenant-a',
            selectedDestinationId: BillingNavigationDestinationId.diagnostics,
          ),
        ),
      );
      final item = model.itemForRouteIdentityKey('billingEntitlements');

      expect(item, isNotNull);
      expect(item?.routeLink.title, 'Entitlements');
      expect(
        item?.routeLink.location,
        '${_entitlementsRoute.path}?tenant=tenant-a&domain=digital',
      );
      expect(item?.destinationId, BillingNavigationDestinationId.diagnostics);
    },
  );

  test('default route-link navigation model falls back to enabled links', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final model = container.read(
      billingDefaultManagementRouteLinkNavigationModelProvider(
        const BillingDefaultManagementNavigationModelRequest(
          hasTenant: false,
          selectedDestinationId:
              BillingNavigationDestinationId.productWorkspace,
        ),
      ),
    );

    expect(model.routeLinks, hasLength(BillingRoutes.sidebarRoutes.length));
    expect(
      model.selectedDestinationId,
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      model.itemFor(BillingNavigationDestinationId.productWorkspace)?.isEnabled,
      isFalse,
    );
    expect(
      model
          .itemFor(BillingNavigationDestinationId.productWorkspace)
          ?.description,
      'Select a tenant first',
    );
  });

  test('tenant route-link navigation model hides non-exposed screens', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final model = container.read(
      billingTenantManagementRouteLinkNavigationModelProvider(
        BillingTenantManagementNavigationModelRequest.fromTenant(
          preferences: const BillingTenantPreferences(
            businessDomain: 'construction',
          ),
          tenantId: 'tenant-a',
          selectedDestinationId: BillingNavigationDestinationId.invoices,
        ),
      ),
    );
    final invoices = model.itemFor(BillingNavigationDestinationId.invoices);
    final checkout = model.itemFor(BillingNavigationDestinationId.cartCheckout);

    expect(
      model.selectedDestinationId,
      BillingNavigationDestinationId.invoices,
    );
    expect(invoices?.isEnabled, isTrue);
    expect(
      invoices?.routeLink.location,
      '${BillingRoutes.invoicesPath}?tenant=tenant-a&domain=construction',
    );
    expect(checkout, isNull);
  });
}

const _entitlementsRoute = BillingManagementRouteDefinition(
  name: 'Billing Entitlements',
  routeName: 'billingEntitlements',
  title: 'Entitlements',
  subtitle: 'Access billing',
  description:
      'Review entitlement billing policies for the selected workspace.',
  icon: 'billing-entitlements',
  path: '${BillingRoutes.managementPath}/entitlements',
  destinationId: BillingNavigationDestinationId.diagnostics,
  routeIdentityKey: 'billingEntitlements',
  surface: BillingManagementRouteSurface.dashboard,
);
