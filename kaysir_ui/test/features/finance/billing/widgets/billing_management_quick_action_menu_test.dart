import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_management_navigation_context_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_quick_action_menu.dart';

void main() {
  testWidgets(
    'BillingManagementQuickActionMenu forwards quick action context',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final navigationContext = container.read(
        billingManagementNavigationContextProvider(
          BillingManagementNavigationContextRequest.productWorkspace(
            preferences: const BillingTenantPreferences(),
            tenantId: 'tenant-a',
            selectedDestinationId: BillingNavigationDestinationId.cartCheckout,
          ),
        ),
      );
      BillingNavigationDestinationId? selectedDestination;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                BillingManagementQuickActionMenu(
                  navigationContext: navigationContext,
                  onDestinationSelected: (destination) {
                    selectedDestination = destination;
                  },
                ),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('billing-quick-action-invoices')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('billing-quick-action-invoices')),
      );
      await tester.pumpAndSettle();

      expect(selectedDestination, BillingNavigationDestinationId.invoices);
    },
  );
}
