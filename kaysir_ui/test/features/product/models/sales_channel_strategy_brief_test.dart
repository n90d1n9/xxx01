import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/sales_channel_strategy_brief.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('strategy brief derives active profile labels and top queue', () {
    final brief = buildProductSalesChannelStrategyBrief(
      profile: omniRetailProductSalesChannelProfile,
      readiness: _readiness,
    );

    expect(brief.titleLabel, 'Omni Retail strategy');
    expect(brief.businessModelLabel, 'Omni-channel retail');
    expect(
      brief.profileFocusLabel,
      'Coordinate store, online, marketplace, and self-service selling',
    );
    expect(
      brief.capabilitySummaryLabel,
      'Store checkout, Online catalog + 2 more',
    );
    expect(brief.channelCountLabel, '3 channels');
    expect(
      brief.channelMixLabel,
      'POS Checkout, Online Store, Self-Service Kiosk',
    );
    expect(brief.readinessLabel, '1/3 channels ready');
    expect(brief.coverageLabel, '57% product coverage');
    expect(brief.gapLabel, '13 product-channel gaps');
    expect(brief.nextQueueLabel, 'Self-Service Kiosk queue');
    expect(brief.nextActionLabel, 'Self-Service Kiosk: Fix missing scan code');
    expect(brief.actionButtonLabel, 'Review Self-Service Kiosk');
    expect(
      brief.operatorCueLabel,
      'Clear the top queue to expand product coverage.',
    );
    expect(brief.primaryPriority?.readiness.channel, ProductSalesChannel.kiosk);
  });

  test('strategy brief handles ready and empty profiles', () {
    final readyBrief = buildProductSalesChannelStrategyBrief(
      profile: digitalCommerceProductSalesChannelProfile,
      readiness: [_readyChannel],
    );

    expect(readyBrief.channelCountLabel, '1 channel');
    expect(readyBrief.channelMixLabel, 'Online Store');
    expect(readyBrief.nextQueueLabel, 'Launch-ready catalog');
    expect(readyBrief.nextActionLabel, 'Review launch-ready products');
    expect(readyBrief.actionButtonLabel, 'Review catalog');
    expect(
      readyBrief.operatorCueLabel,
      'Profile is launch-ready across 1 channel.',
    );

    final emptyBrief = buildProductSalesChannelStrategyBrief(
      profile: counterServiceProductSalesChannelProfile,
      readiness: const [],
    );

    expect(emptyBrief.channelCountLabel, '0 channels');
    expect(emptyBrief.channelMixLabel, 'No channels enabled');
    expect(emptyBrief.nextQueueLabel, 'No launch queue');
    expect(emptyBrief.nextActionLabel, 'Configure channel definitions');
    expect(emptyBrief.primaryPriority, isNull);
  });
}

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
