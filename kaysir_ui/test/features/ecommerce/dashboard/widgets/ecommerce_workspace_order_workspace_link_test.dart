import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/order_workspace_link.dart';

void main() {
  testWidgets('OrderWorkspaceLink renders route bridge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderWorkspaceLink(
            profile: ProductProfile.marketplaceOperations,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_workspace_link_marketplace_operations')),
      findsOneWidget,
    );
    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(find.text('Focus: Marketplace fulfillment'), findsOneWidget);
    expect(find.text('Route: /commerce/orders/marketplace'), findsOneWidget);
    expect(find.text('Order profile: marketplace_ops'), findsOneWidget);
    expect(find.text('Presets: 4 workspace views'), findsOneWidget);
    expect(find.text('Channels: Marketplace'), findsOneWidget);
    expect(find.text('Open order workspace'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderWorkspaceLink can open route', (tester) async {
    String? openedRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderWorkspaceLink(
            profile: ProductProfile.marketplaceOperations,
            onOpenOrderWorkspace: (routePath) => openedRoute = routePath,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('order_workspace_open_marketplace_operations')),
    );
    await tester.pump();

    final openedUri = Uri.parse(openedRoute ?? '');
    expect(openedUri.path, '/commerce/orders/marketplace');
    expect(
      openedUri.queryParameters['source_profile_id'],
      'marketplace_operations',
    );
    expect(openedUri.queryParameters['launch_reason'], 'profile_details');
    expect(tester.takeException(), isNull);
  });
}
