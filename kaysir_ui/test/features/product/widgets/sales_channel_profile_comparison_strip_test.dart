import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_readiness.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/widgets/sales_channel_profile_comparison_strip.dart';

void main() {
  testWidgets('profile comparison strip previews and selects profiles', (
    tester,
  ) async {
    ProductSalesChannelProfileId? selectedProfileId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductSalesChannelProfileComparisonStrip(
            options: _options,
            onSelected: (profileId) => selectedProfileId = profileId,
          ),
        ),
      ),
    );

    expect(find.text('Omni Retail profile'), findsOneWidget);
    expect(find.text('Counter Service profile'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Current strategy'), findsOneWidget);
    expect(find.text('Best fit for this catalog'), findsOneWidget);
    expect(find.text('Active baseline'), findsOneWidget);
    expect(find.text('Coverage +50% | Gaps -2'), findsOneWidget);

    await tester.tap(find.text('Best fit for this catalog'));

    expect(selectedProfileId, ProductSalesChannelProfileId.counterService);

    await tester.tap(find.text('Current strategy'));

    expect(selectedProfileId, ProductSalesChannelProfileId.counterService);
  });
}

final _options = [
  ProductSalesChannelProfileReadinessOption(
    profile: omniRetailProductSalesChannelProfile,
    summary: summarizeProductSalesChannelProfileReadiness([
      const ProductSalesChannelReadiness(
        channel: ProductSalesChannel.posCheckout,
        title: 'POS Checkout',
        subtitle: 'Priced products with sellable stock',
        readyCount: 1,
        totalCount: 4,
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
    ]),
    isSelected: true,
    isRecommended: false,
  ),
  ProductSalesChannelProfileReadinessOption(
    profile: counterServiceProductSalesChannelProfile,
    summary: summarizeProductSalesChannelProfileReadiness([
      const ProductSalesChannelReadiness(
        channel: ProductSalesChannel.posCheckout,
        title: 'POS Checkout',
        subtitle: 'Priced products with sellable stock',
        readyCount: 3,
        totalCount: 4,
        reviewFilter: InventoryProductCatalogFilter.attention,
        issues: [
          ProductSalesChannelReadinessIssue(
            blocker: ProductSalesChannelBlocker.stockNotSellable,
            label: 'stock not sellable',
            count: 1,
            reviewFilter: InventoryProductCatalogFilter.attention,
          ),
        ],
      ),
    ]),
    isSelected: false,
    isRecommended: true,
    coverageDelta: 50,
    blockerDelta: -2,
  ),
];
