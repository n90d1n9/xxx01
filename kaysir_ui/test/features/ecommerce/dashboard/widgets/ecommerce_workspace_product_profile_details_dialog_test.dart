import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_details_dialog.dart';

void main() {
  testWidgets('ProductProfileDetailsDialog renders profile topology', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductProfileDetailsDialog(
            profile: ProductProfile.marketplaceOperations,
            selected: true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsOneWidget,
    );
    expect(find.text('Profile details'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Marketplace motion'), findsOneWidget);
    expect(find.text('Advanced launch | 23 pts'), findsOneWidget);
    expect(find.text('Order workspace'), findsOneWidget);
    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(find.text('Route: /commerce/orders/marketplace'), findsOneWidget);
    expect(find.text('Capabilities'), findsOneWidget);
    expect(find.text('Remote pay'), findsWidgets);
    expect(find.text('Sales channels'), findsOneWidget);
    expect(find.text('Delivery app'), findsWidgets);
    expect(find.text('Coverage rules'), findsOneWidget);
    expect(find.text('Price lists'), findsWidgets);
    expect(
      find.text('Playbook: Add price-list channel coverage'),
      findsOneWidget,
    );
    expect(find.text('Registry shape'), findsOneWidget);
    expect(find.text('Marketplace Queue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showProductProfileDetailsDialog can apply profile', (
    tester,
  ) async {
    String? selectedProfileId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showProductProfileDetailsDialog(
                    context: context,
                    profile: ProductProfile.marketplaceOperations,
                    onProfileSelected:
                        (profileId) => selectedProfileId = profileId,
                  );
                },
                child: const Text('Open details'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsOneWidget,
    );
    expect(find.byType(ActionButton), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('product_profile_use_marketplace_operations')),
    );
    await tester.pumpAndSettle();

    expect(selectedProfileId, 'marketplace_operations');
    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductProfileDetailsDialog can open order workspace', (
    tester,
  ) async {
    String? openedRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductProfileDetailsDialog(
            profile: ProductProfile.marketplaceOperations,
            onOpenOrderWorkspace: (routePath) => openedRoute = routePath,
          ),
        ),
      ),
    );

    final openOrderWorkspace = find.byKey(
      const ValueKey('order_workspace_open_marketplace_operations'),
    );
    await tester.ensureVisible(openOrderWorkspace);
    await tester.pumpAndSettle();
    await tester.tap(openOrderWorkspace);
    await tester.pumpAndSettle();

    final openedUri = Uri.parse(openedRoute ?? '');
    expect(openedUri.path, '/commerce/orders/marketplace');
    expect(
      openedUri.queryParameters['source_profile_id'],
      'marketplace_operations',
    );
    expect(
      openedUri.queryParameters['order_workspace_profile_id'],
      'marketplace_ops',
    );
    expect(openedUri.queryParameters['launch_reason'], 'profile_details');
    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
