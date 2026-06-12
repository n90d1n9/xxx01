import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_readiness.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/widgets/sales_channel_profile_switch_dialog.dart';

void main() {
  testWidgets('profile switch dialog shows impact and returns decision', (
    tester,
  ) async {
    bool? confirmed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => FilledButton(
                  onPressed: () async {
                    confirmed =
                        await showProductSalesChannelProfileSwitchDialog(
                          context,
                          option: _option,
                        );
                  },
                  child: const Text('Open switch'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open switch'));
    await tester.pumpAndSettle();

    expect(find.text('Switch channel strategy?'), findsOneWidget);
    expect(find.text('Counter Service profile'), findsOneWidget);
    expect(find.text('Coverage +50% | Gaps -2'), findsOneWidget);
    expect(find.text('Ready channels same'), findsOneWidget);
    expect(find.text('1 product-channel gap'), findsOneWidget);
    expect(find.text('Next action'), findsOneWidget);
    expect(find.text('POS Checkout: Fix stock not sellable'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);

    await tester.tap(find.text('Open switch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch profile'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}

final _option = ProductSalesChannelProfileReadinessOption(
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
);
