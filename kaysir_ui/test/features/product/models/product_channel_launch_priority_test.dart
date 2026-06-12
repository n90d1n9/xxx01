import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product_channel_launch_priority.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('channel launch priorities rank blocked channel work first', () {
    final priorities = buildProductChannelLaunchPriorities(_readiness);

    expect(priorities.map((priority) => priority.readiness.channel), [
      ProductSalesChannel.kiosk,
      ProductSalesChannel.posCheckout,
      ProductSalesChannel.marketplace,
      ProductSalesChannel.onlineStore,
    ]);
    expect(priorities.first.level, ProductChannelLaunchPriorityLevel.blocked);
    expect(priorities.first.statusLabel, 'Priority');
    expect(priorities.first.actionLabel, 'Fix missing scan code');
    expect(priorities.first.impactLabel, '4 missing scan code first');
    expect(priorities.first.blockedProductLabel, '10 products blocked');
    expect(priorities.last.level, ProductChannelLaunchPriorityLevel.ready);
    expect(priorities.last.actionLabel, 'Review launch-ready catalog');
    expect(priorities.last.blockedProductLabel, 'No blockers');
  });

  test('channel launch priorities can be limited', () {
    final priorities = buildProductChannelLaunchPriorities(
      _readiness,
      limit: 2,
    );

    expect(priorities, hasLength(2));
    expect(priorities.map((priority) => priority.readiness.channel), [
      ProductSalesChannel.kiosk,
      ProductSalesChannel.posCheckout,
    ]);
    expect(buildProductChannelLaunchPriorities(_readiness, limit: 0), isEmpty);
  });
}

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
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.onlineStore,
    title: 'Online Store',
    subtitle: 'SKU, product copy, and active stock',
    readyCount: 10,
    totalCount: 10,
    reviewFilter: InventoryProductCatalogFilter.all,
  ),
  const ProductSalesChannelReadiness(
    channel: ProductSalesChannel.marketplace,
    title: 'Marketplace',
    subtitle: 'Complete listing basics for syndication',
    readyCount: 7,
    totalCount: 10,
    reviewFilter: InventoryProductCatalogFilter.all,
    issues: [
      ProductSalesChannelReadinessIssue(
        blocker: ProductSalesChannelBlocker.missingCategory,
        label: 'missing category',
        count: 3,
        reviewFilter: InventoryProductCatalogFilter.all,
        reviewQuery: 'Uncategorized',
      ),
    ],
  ),
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
        count: 4,
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
