import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/layout_spec.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/section_order.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/sections.dart';

import '../fixtures/test_fixtures.dart';
import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('primary sections render and route header and destinations', (
    tester,
  ) async {
    var openedCheckout = false;
    var openedOrders = false;
    final selectedDestinations = <String>[];

    await tester.pumpWorkspaceWidget(
      PrimarySections(
        workspace: testWorkspace(),
        onOpenCheckout: () => openedCheckout = true,
        onOpenOrders: () => openedOrders = true,
        onDestinationSelected: selectedDestinations.add,
      ),
      width: 900,
      scrollable: true,
    );

    expect(find.byKey(const ValueKey('primary_sections')), findsOneWidget);
    expect(find.text('Commerce Workspace'), findsOneWidget);
    expect(find.text('Channel strategy'), findsOneWidget);
    expect(find.text('Profile | Standard commerce'), findsOneWidget);
    expect(find.text(' POS'), findsOneWidget);

    await tester.tap(find.text('Review orders'));
    await tester.pump();
    await tester.tap(find.text('Open checkout').first);
    await tester.pump();
    await tester.ensureVisible(find.text('Open orders'));
    await tester.tap(find.text('Open orders'));
    await tester.pump();

    expect(openedOrders, isTrue);
    expect(openedCheckout, isTrue);
    expect(selectedDestinations, [Routes.ordersPath]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('section deck skips hidden slots and keeps requested order', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      SectionDeck(
        workspace: testWorkspace(),
        layoutSpec: const LayoutSpec(
          mode: LayoutMode.sidePanel,
          contentPadding: 16,
          actionPanelWidth: 360,
        ),
        sectionOrder: const SectionOrder(
          slots: [
            SectionSlot.operations,
            SectionSlot.registryNotice,
            SectionSlot.header,
          ],
        ),
        onOpenCheckout: () {},
        onOpenOrders: () {},
        onDestinationSelected: (_) {},
        onActionSelected: (_) {},
      ),
      width: 1100,
      scrollable: true,
    );

    final operationsTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_operations')),
    );
    final headerTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_header')),
    );

    expect(find.byKey(const ValueKey('section_deck')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_registryNotice')), findsNothing);
    expect(operationsTop.dy, lessThan(headerTop.dy));
    expect(tester.takeException(), isNull);
  });
}
