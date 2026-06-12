import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_navigation_session.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_snapshot.dart';

void main() {
  test('dashboard sessions carry tenant account route context', () {
    final session = BillingManagementNavigationSession.dashboard(
      dispatchSnapshot: _snapshot(BillingNavigationSurface.dashboard),
      tenant: const BillingTenantAccount(
        id: ' tenant-a ',
        name: 'Acme',
        logoUrl: '',
        planName: 'Pro',
        currentBalance: 0,
        preferences: BillingTenantPreferences(businessDomain: 'Construction'),
      ),
    );

    expect(session.currentSurface, BillingNavigationSurface.dashboard);
    expect(session.tenantId, 'tenant-a');
    expect(session.businessDomain, 'construction');
    expect(session.hasTenant, isTrue);
  });

  test('product workspace sessions carry product tenant route context', () {
    final session = BillingManagementNavigationSession.productWorkspace(
      dispatchSnapshot: _snapshot(BillingNavigationSurface.productWorkspace),
      tenant: const Tenant(
        id: 'tenant-b',
        name: 'Store',
        logoUrl: '',
        preferences: BillingTenantPreferences(businessDomain: 'saas'),
      ),
    );

    expect(session.currentSurface, BillingNavigationSurface.productWorkspace);
    expect(session.tenantId, 'tenant-b');
    expect(session.businessDomain, 'saas');
  });

  test('tenant selection sessions preserve business domain without tenant', () {
    final session = BillingManagementNavigationSession.tenantSelection(
      dispatchSnapshot: _snapshot(BillingNavigationSurface.tenantSelection),
      businessDomain: ' Retail ',
    );

    expect(session.currentSurface, BillingNavigationSurface.tenantSelection);
    expect(session.tenantId, isNull);
    expect(session.businessDomain, 'retail');
    expect(session.hasTenant, isFalse);
  });
}

BillingNavigationDispatchSnapshot _snapshot(BillingNavigationSurface surface) {
  return BillingNavigationDispatchSnapshot(
    currentSurface: surface,
    defaultDestinationId: BillingNavigationDestinationId.dashboard,
    plans: const [],
  );
}
