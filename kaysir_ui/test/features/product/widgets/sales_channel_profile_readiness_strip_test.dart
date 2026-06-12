import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_readiness.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/widgets/sales_channel_profile_readiness_strip.dart';

void main() {
  testWidgets('profile readiness strip renders summary labels', (tester) async {
    final summary = summarizeProductSalesChannelProfileReadiness(_readiness);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductSalesChannelProfileReadinessStrip(summary: summary),
        ),
      ),
    );

    expect(find.text('Improving'), findsOneWidget);
    expect(find.text('1/2 channels ready'), findsOneWidget);
    expect(find.text('75% product coverage'), findsOneWidget);
    expect(find.text('5 product-channel gaps'), findsOneWidget);
    expect(find.text('POS Checkout: Fix stock not sellable'), findsOneWidget);
  });
}

final _readiness = [
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.posCheckout,
    title: 'POS Checkout',
    subtitle: 'Priced products with sellable stock',
    readyCount: 5,
    totalCount: 10,
    reviewFilter: InventoryProductCatalogFilter.attention,
    issues: [
      ProductSalesChannelReadinessIssue(
        blocker: ProductSalesChannelBlocker.stockNotSellable,
        label: 'stock not sellable',
        count: 5,
        reviewFilter: InventoryProductCatalogFilter.attention,
      ),
    ],
  ),
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.onlineStore,
    title: 'Online Store',
    subtitle: 'SKU, product copy, and active stock',
    readyCount: 10,
    totalCount: 10,
    reviewFilter: InventoryProductCatalogFilter.all,
  ),
];
