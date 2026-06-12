import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/layout_spec.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/section_order.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/content.dart';

import '../fixtures/test_fixtures.dart';
import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('Content renders dashboard sections and actions', (tester) async {
    var openedCheckout = false;
    var openedOrders = false;
    final selectedDestinations = <String>[];
    final selectedActions = <String>[];
    final workspace = testWorkspace();

    await tester.pumpWorkspaceWidget(
      Content(
        workspace: workspace,
        onOpenCheckout: () => openedCheckout = true,
        onOpenOrders: () => openedOrders = true,
        onDestinationSelected: selectedDestinations.add,
        onActionSelected: selectedActions.add,
      ),
      width: 1100,
    );

    expect(find.text('Commerce Workspace'), findsOneWidget);
    expect(find.text('Channel strategy'), findsOneWidget);
    expect(find.text('Profile | Standard commerce'), findsOneWidget);
    expect(find.text('Storefront'), findsOneWidget);
    expect(find.text('Web store'), findsWidgets);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Ready to sell'), findsOneWidget);
    expect(find.text(' POS'), findsOneWidget);
    expect(find.text('Channel and fulfillment mix'), findsOneWidget);

    await tester.tap(find.text('Review orders'));
    await tester.pump();
    await tester.tap(find.text('Open checkout').first);
    await tester.pump();

    expect(openedOrders, isTrue);
    expect(openedCheckout, isTrue);

    await tester.ensureVisible(find.text('Review policy'));
    await tester.tap(find.text('Review policy'));
    await tester.pump();

    await tester.ensureVisible(find.text('Open renewals'));
    await tester.tap(find.text('Open renewals'));
    await tester.pump();

    expect(selectedDestinations, [Routes.ordersPath]);
    expect(selectedActions, ['/commerce/renewals']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Content accepts custom layout strategy', (tester) async {
    double? capturedWidth;

    await tester.pumpWorkspaceWidget(
      Content(
        workspace: testWorkspace(),
        onOpenCheckout: () {},
        onOpenOrders: () {},
        onDestinationSelected: (_) {},
        onActionSelected: (_) {},
        layoutSpecBuilder: (width) {
          capturedWidth = width;
          return const LayoutSpec(
            mode: LayoutMode.compact,
            contentPadding: 10,
            actionPanelWidth: 300,
          );
        },
      ),
      width: 500,
    );

    expect(capturedWidth, 500);
    expect(find.text('Priority actions'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Content accepts product section ordering', (tester) async {
    await tester.pumpWorkspaceWidget(
      Content(
        workspace: testWorkspace(),
        onOpenCheckout: () {},
        onOpenOrders: () {},
        onDestinationSelected: (_) {},
        onActionSelected: (_) {},
        sectionOrder: const SectionOrder(
          slots: [
            SectionSlot.operations,
            SectionSlot.header,
            SectionSlot.destinations,
          ],
        ),
      ),
      width: 1100,
    );

    final operationsTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_operations')),
    );
    final headerTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_header')),
    );

    expect(operationsTop.dy, lessThan(headerTop.dy));
    expect(find.text('Order volume'), findsNothing);
    expect(find.text('Ready to sell'), findsNothing);
    expect(find.text(' POS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
