import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product_channel_launch_priority.dart';
import 'package:kaysir/features/product/models/sales_channel_strategy_brief.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/widgets/sales_channel_strategy_brief_panel.dart';

void main() {
  testWidgets(
    'strategy brief panel renders active strategy and delegates queue',
    (tester) async {
      ProductChannelLaunchPriority? selectedPriority;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductSalesChannelStrategyBriefPanel(
              brief: _brief,
              onPrioritySelected: (priority) => selectedPriority = priority,
            ),
          ),
        ),
      );

      expect(find.text('Active strategy'), findsOneWidget);
      expect(find.text('Omni Retail strategy'), findsOneWidget);
      expect(
        find.text(
          'Coordinate store, online, marketplace, and self-service selling',
        ),
        findsOneWidget,
      );
      expect(find.text('Omni-channel retail'), findsOneWidget);
      expect(find.text('Store checkout'), findsOneWidget);
      expect(find.text('Online catalog'), findsOneWidget);
      expect(find.text('Marketplace listing'), findsOneWidget);
      expect(find.text('Kiosk scan flow'), findsOneWidget);
      expect(
        find.text('Clear the top queue to expand product coverage.'),
        findsOneWidget,
      );
      expect(find.text('3 channels'), findsOneWidget);
      expect(
        find.text('POS Checkout, Online Store, Self-Service Kiosk'),
        findsOneWidget,
      );
      expect(find.text('1/3 channels ready'), findsOneWidget);
      expect(find.text('57% product coverage'), findsOneWidget);
      expect(find.text('13 product-channel gaps'), findsOneWidget);
      expect(find.text('Self-Service Kiosk queue'), findsOneWidget);
      expect(
        find.text('Self-Service Kiosk: Fix missing scan code'),
        findsWidgets,
      );

      await tester.tap(find.text('Review Self-Service Kiosk'));
      await tester.pump();

      expect(selectedPriority?.readiness.channel, ProductSalesChannel.kiosk);
    },
  );
}

final _brief = buildProductSalesChannelStrategyBrief(
  profile: omniRetailProductSalesChannelProfile,
  readiness: _readiness,
);

const _readyChannel = ProductSalesChannelReadiness(
  channel: ProductSalesChannel.onlineStore,
  title: 'Online Store',
  subtitle: 'SKU, product copy, and active stock',
  readyCount: 10,
  totalCount: 10,
  reviewFilter: InventoryProductCatalogFilter.all,
);

final _readiness = [
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.posCheckout,
    title: 'POS Checkout',
    subtitle: 'Priced products with sellable stock',
    readyCount: 7,
    totalCount: 10,
    reviewFilter: InventoryProductCatalogFilter.attention,
    issues: [
      ProductSalesChannelReadinessIssue(
        blocker: ProductSalesChannelBlocker.stockNotSellable,
        label: 'stock not sellable',
        count: 3,
        reviewFilter: InventoryProductCatalogFilter.attention,
      ),
    ],
  ),
  _readyChannel,
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.kiosk,
    title: 'Self-Service Kiosk',
    subtitle: 'Fast-scan products ready for assisted checkout',
    readyCount: 0,
    totalCount: 10,
    reviewFilter: InventoryProductCatalogFilter.inStock,
    issues: [
      ProductSalesChannelReadinessIssue(
        blocker: ProductSalesChannelBlocker.missingScanCode,
        label: 'missing scan code',
        count: 7,
        reviewFilter: InventoryProductCatalogFilter.inStock,
        reviewQuery: 'Missing scan code',
      ),
      ProductSalesChannelReadinessIssue(
        blocker: ProductSalesChannelBlocker.stockNotSellable,
        label: 'stock not sellable',
        count: 3,
        reviewFilter: InventoryProductCatalogFilter.attention,
      ),
    ],
  ),
];
