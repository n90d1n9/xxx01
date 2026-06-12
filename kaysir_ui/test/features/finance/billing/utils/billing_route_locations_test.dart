import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_filter_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_diagnostics_route_location.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_context.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_locations.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('billingRouteLocationForDestination maps sidebar destinations', () {
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.dashboard,
      ),
      BillingRoutes.managementPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.workCenter,
      ),
      BillingRoutes.workCenterPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.tenants,
      ),
      BillingRoutes.workspacesPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.invoices,
      ),
      BillingRoutes.invoicesPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.createInvoice,
      ),
      BillingRoutes.createInvoicePath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.reports,
      ),
      BillingRoutes.insightsPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.issueOutbox,
      ),
      BillingRoutes.issueOutboxPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.productWorkspace,
      ),
      BillingRoutes.productsPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingRoutes.checkoutPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.diagnostics,
      ),
      BillingRoutes.diagnosticsPath,
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.policyCenter,
      ),
      BillingRoutes.policyPath,
    );
  });

  test('billingRouteLocationForTarget maps route targets', () {
    expect(
      billingRouteLocationForTarget(
        const BillingNavigationRouteTarget.dashboard(
          initialDestinationId: BillingNavigationDestinationId.reports,
          screenKey: 'core.reports',
        ),
      ),
      BillingRoutes.insightsPath,
    );
    expect(
      billingRouteLocationForTarget(
        const BillingNavigationRouteTarget.productWorkspace(
          initialDestinationId: BillingNavigationDestinationId.cartCheckout,
          screenKey: 'commerce.cart_checkout',
        ),
      ),
      BillingRoutes.checkoutPath,
    );
    expect(
      billingRouteLocationForTarget(
        const BillingNavigationRouteTarget.tenantSelection(
          screenKey: 'core.tenant_selection',
        ),
      ),
      BillingRoutes.workspacesPath,
    );
    expect(
      billingRouteLocationForTarget(const BillingNavigationRouteTarget.none()),
      isNull,
    );
  });

  test('billing route locations preserve tenant query context', () {
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.invoices,
        tenantId: 'tenant-a',
        businessDomain: ' Construction ',
      ),
      '${BillingRoutes.invoicesPath}?${BillingRoutes.tenantQueryKey}=tenant-a&${BillingRoutes.businessDomainQueryKey}=construction',
    );
    expect(
      billingRouteLocationForTarget(
        const BillingNavigationRouteTarget.productWorkspace(
          initialDestinationId: BillingNavigationDestinationId.cartCheckout,
          screenKey: 'commerce.cart_checkout',
        ),
        tenantId: ' tenant-b ',
        businessDomain: 'digital',
      ),
      '${BillingRoutes.checkoutPath}?${BillingRoutes.tenantQueryKey}=tenant-b&${BillingRoutes.businessDomainQueryKey}=digital',
    );
    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.reports,
        tenantId: '   ',
        businessDomain: '   ',
      ),
      BillingRoutes.insightsPath,
    );
  });

  test('billing route locations accept reusable route context', () {
    final routeContext = BillingRouteContext(
      tenantId: ' tenant-c ',
      businessDomain: ' Digital ',
    );

    expect(
      billingRouteLocationForDestination(
        BillingNavigationDestinationId.createInvoice,
        routeContext: routeContext,
      ),
      '${BillingRoutes.createInvoicePath}?${BillingRoutes.tenantQueryKey}=tenant-c&${BillingRoutes.businessDomainQueryKey}=digital',
    );
    expect(
      billingRouteLocationForTarget(
        const BillingNavigationRouteTarget.tenantSelection(
          screenKey: 'core.tenant_selection',
        ),
        routeContext: routeContext,
      ),
      '${BillingRoutes.workspacesPath}?${BillingRoutes.tenantQueryKey}=tenant-c&${BillingRoutes.businessDomainQueryKey}=digital',
    );
  });

  test('billing route locations accept extra query parameters', () {
    expect(
      billingRouteLocation(
        BillingRoutes.diagnosticsPath,
        routeContext: BillingRouteContext(
          tenantId: 'tenant-a',
          businessDomain: 'commerce',
        ),
        extraQueryParameters: const {'releaseProfileStatus': 'standard'},
      ),
      '${BillingRoutes.diagnosticsPath}?${BillingRoutes.tenantQueryKey}=tenant-a&${BillingRoutes.businessDomainQueryKey}=commerce&releaseProfileStatus=standard',
    );
  });

  test('billing route locations keep route context ahead of extras', () {
    expect(
      billingRouteLocation(
        BillingRoutes.diagnosticsPath,
        tenantId: 'tenant-a',
        businessDomain: 'commerce',
        extraQueryParameters: const {
          BillingRoutes.tenantQueryKey: 'tenant-b',
          BillingRoutes.businessDomainQueryKey: 'retail',
          'releaseProfileStatus': 'standard',
        },
      ),
      '${BillingRoutes.diagnosticsPath}?'
      '${BillingRoutes.tenantQueryKey}=tenant-a&'
      '${BillingRoutes.businessDomainQueryKey}=commerce&'
      'releaseProfileStatus=standard',
    );
  });

  test(
    'billing diagnostics route locations preserve release profile filters',
    () {
      final filterState = BillingDiagnosticsReleaseProfileFilterState(
        statusOption: BillingReleaseProfileStatusFilterOption.standard,
        domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
          'retail',
        ),
      );

      expect(
        billingDiagnosticsRouteLocation(
          tenantId: ' tenant-a ',
          businessDomain: ' Commerce ',
          releaseProfileFilterState: filterState,
        ),
        '${BillingRoutes.diagnosticsPath}?'
        '${BillingRoutes.tenantQueryKey}=tenant-a&'
        '${BillingRoutes.businessDomainQueryKey}=commerce&'
        '$billingDiagnosticsReleaseProfileStatusQueryKey=standard&'
        '$billingDiagnosticsReleaseProfileDomainQueryKey=retail',
      );
      expect(
        billingDiagnosticsRouteLocation(
          releaseProfileFilterState:
              const BillingDiagnosticsReleaseProfileFilterState(),
        ),
        BillingRoutes.diagnosticsPath,
      );
    },
  );

  test('billing diagnostics browser links preserve route fragments', () {
    final filterState = BillingDiagnosticsReleaseProfileFilterState(
      statusOption: BillingReleaseProfileStatusFilterOption.standard,
      domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
        'retail',
      ),
    );

    final link = billingDiagnosticsBrowserLink(
      tenantId: 'tenant-a',
      businessDomain: 'commerce',
      releaseProfileFilterState: filterState,
      baseUri: Uri.parse('https://billing.example/app/'),
    );
    final browserUri = Uri.parse(link);
    final fragmentUri = Uri.parse(browserUri.fragment);

    expect(browserUri.scheme, 'https');
    expect(browserUri.host, 'billing.example');
    expect(browserUri.path, '/app/');
    expect(fragmentUri.path, BillingRoutes.diagnosticsPath);
    expect(
      fragmentUri.queryParameters[BillingRoutes.tenantQueryKey],
      'tenant-a',
    );
    expect(
      fragmentUri.queryParameters[BillingRoutes.businessDomainQueryKey],
      'commerce',
    );
    expect(
      fragmentUri
          .queryParameters[billingDiagnosticsReleaseProfileStatusQueryKey],
      'standard',
    );
    expect(
      fragmentUri
          .queryParameters[billingDiagnosticsReleaseProfileDomainQueryKey],
      'retail',
    );
  });
}
