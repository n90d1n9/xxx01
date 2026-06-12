import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_management_navigation_context_provider.dart';

void main() {
  test('navigation context requests normalize no-tenant domains', () {
    final request = BillingManagementNavigationContextRequest.noTenant(
      businessDomain: ' Construction ',
      selectedDestinationId: BillingNavigationDestinationId.productWorkspace,
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    expect(request.hasTenant, isFalse);
    expect(request.routeLinkRequest.businessDomain, 'construction');
    expect(request.launchPlannerRequest.hasTenant, isFalse);
    expect(
      request.dispatchSnapshotRequest.currentSurface,
      BillingNavigationSurface.productWorkspace,
    );
    expect(
      request,
      BillingManagementNavigationContextRequest.noTenant(
        businessDomain: 'construction',
        selectedDestinationId: BillingNavigationDestinationId.productWorkspace,
        currentSurface: BillingNavigationSurface.productWorkspace,
      ),
    );
  });

  test('dashboard request uses tenant context when available', () {
    final request = BillingManagementNavigationContextRequest.dashboard(
      preferences: const BillingTenantPreferences(businessDomain: 'digital'),
      tenantId: ' tenant-a ',
      noTenantBusinessDomain: 'construction',
      selectedDestinationId: BillingNavigationDestinationId.invoices,
    );

    expect(request.hasTenant, isTrue);
    expect(request.routeLinkRequest.tenantId, 'tenant-a');
    expect(request.routeLinkRequest.businessDomain, 'digital');
    expect(request.currentSurface, BillingNavigationSurface.dashboard);
    expect(
      request.selectedDestinationId,
      BillingNavigationDestinationId.invoices,
    );
  });

  test(
    'surface request factories encode expected destinations and surfaces',
    () {
      final productRequest =
          BillingManagementNavigationContextRequest.productWorkspace(
            preferences: const BillingTenantPreferences(),
            tenantId: 'tenant-a',
            selectedDestinationId: BillingNavigationDestinationId.cartCheckout,
          );
      final tenantRequest =
          BillingManagementNavigationContextRequest.tenantSelection(
            businessDomain: 'construction',
          );

      expect(
        productRequest.currentSurface,
        BillingNavigationSurface.productWorkspace,
      );
      expect(productRequest.hasTenant, isTrue);
      expect(
        productRequest.selectedDestinationId,
        BillingNavigationDestinationId.cartCheckout,
      );
      expect(
        tenantRequest.currentSurface,
        BillingNavigationSurface.tenantSelection,
      );
      expect(tenantRequest.hasTenant, isFalse);
      expect(tenantRequest.routeLinkRequest.businessDomain, 'construction');
      expect(
        tenantRequest.selectedDestinationId,
        BillingNavigationDestinationId.tenants,
      );
    },
  );

  test('no-tenant navigation context carries domain-specific visibility', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final context = container.read(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.noTenant(
          businessDomain: 'construction',
          selectedDestinationId:
              BillingNavigationDestinationId.productWorkspace,
          currentSurface: BillingNavigationSurface.productWorkspace,
        ),
      ),
    );

    expect(context.hasTenant, isFalse);
    expect(
      context.destinationDispatchSnapshot.currentSurface,
      BillingNavigationSurface.productWorkspace,
    );
    expect(
      context.quickActionDispatchSnapshot.currentSurface,
      BillingNavigationSurface.productWorkspace,
    );
    expect(
      context.routeLinkNavigationModel.selectedDestinationId,
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      context.routeLinkNavigationModel.itemFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      isNull,
    );
  });

  test('tenant navigation context builds reusable route and action state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final context = container.read(
      billingManagementNavigationContextProvider(
        BillingManagementNavigationContextRequest.fromTenant(
          preferences: const BillingTenantPreferences(),
          tenantId: 'tenant-a',
          selectedDestinationId: BillingNavigationDestinationId.cartCheckout,
          currentSurface: BillingNavigationSurface.productWorkspace,
        ),
      ),
    );
    final checkout = context.routeLinkNavigationModel.itemFor(
      BillingNavigationDestinationId.cartCheckout,
    );
    final invoices = context.routeLinkNavigationModel.itemFor(
      BillingNavigationDestinationId.invoices,
    );

    expect(context.hasTenant, isTrue);
    expect(
      context.routeLinkNavigationModel.selectedDestinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(checkout?.isEnabled, isTrue);
    expect(
      invoices?.routeLink.location,
      '${BillingRoutes.invoicesPath}?tenant=tenant-a&domain=commerce',
    );
    expect(
      context.quickActionLaunchSnapshot.destinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
  });
}
