import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_dashboard_header_section.dart';

void main() {
  testWidgets('BillingDashboardHeaderSection composes tenant controls', (
    tester,
  ) async {
    String? selectedTenantId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingDashboardHeaderSection(
            tenants: _tenants(),
            selectedTenant: _tenants().first,
            onTenantChanged: (tenantId) {
              selectedTenantId = tenantId;
            },
          ),
        ),
      ),
    );

    expect(find.text('Tenant'), findsOneWidget);
    expect(find.text('Acme Corp'), findsWidgets);
    expect(find.text('Billing Statistics'), findsOneWidget);
    expect(find.text('Rp 4,750'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Globex').last);
    await tester.pumpAndSettle();

    expect(selectedTenantId, 'tenant-002');
  });
}

List<BillingTenantAccount> _tenants() {
  return const [
    BillingTenantAccount(
      id: 'tenant-001',
      name: 'Acme Corp',
      logoUrl: '',
      planName: 'Enterprise',
      currentBalance: 4750,
      preferences: BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
      ),
    ),
    BillingTenantAccount(
      id: 'tenant-002',
      name: 'Globex',
      logoUrl: '',
      planName: 'Professional',
      currentBalance: 2100,
    ),
  ];
}
