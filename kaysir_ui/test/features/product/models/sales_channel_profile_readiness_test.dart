import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_readiness.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('profile readiness summarizes channel coverage and blockers', () {
    final summary = summarizeProductSalesChannelProfileReadiness(_readiness);

    expect(summary.channelCount, 3);
    expect(summary.readyChannelCount, 1);
    expect(summary.improvingChannelCount, 1);
    expect(summary.blockedChannelCount, 1);
    expect(summary.readyProductSlotCount, 17);
    expect(summary.totalProductSlotCount, 30);
    expect(summary.blockedProductSlotCount, 13);
    expect(summary.launchPercent, 57);
    expect(summary.level, ProductSalesChannelProfileReadinessLevel.improving);
    expect(summary.statusLabel, 'Improving');
    expect(summary.channelLabel, '1/3 channels ready');
    expect(summary.coverageLabel, '57% product coverage');
    expect(summary.blockerLabel, '13 product-channel gaps');
    expect(
      summary.nextActionLabel,
      'Self-Service Kiosk: Fix missing scan code',
    );
  });

  test('profile readiness handles ready and empty profiles', () {
    final readySummary = summarizeProductSalesChannelProfileReadiness([
      _readyChannel,
    ]);

    expect(readySummary.level, ProductSalesChannelProfileReadinessLevel.ready);
    expect(readySummary.channelLabel, '1/1 channel ready');
    expect(readySummary.blockerLabel, 'No channel blockers');
    expect(readySummary.nextActionLabel, 'Launch-ready profile');

    final emptySummary = summarizeProductSalesChannelProfileReadiness(const []);

    expect(emptySummary.level, ProductSalesChannelProfileReadinessLevel.ready);
    expect(emptySummary.coverageLabel, '0% product coverage');
    expect(emptySummary.nextActionLabel, 'No channels configured');
  });

  test(
    'profile readiness options preserve profiles and recommend best fit',
    () {
      final options = buildProductSalesChannelProfileReadinessOptions(
        _catalogRecords,
        profiles: _profiles,
        selectedProfileId: ProductSalesChannelProfileId.omniRetail,
      );

      expect(options.map((option) => option.profile.title), [
        'Strict Pack',
        'Price Pack',
      ]);
      expect(options.first.isSelected, isTrue);
      expect(options.first.isRecommended, isFalse);
      expect(options.first.statusLabel, 'Active');
      expect(options.first.titleLabel, 'Strict Pack profile');
      expect(
        options.first.detailLabel,
        '50% product coverage | 0/2 channels ready',
      );
      expect(options.first.switchImpactLabel, 'Active baseline');
      expect(options.first.readyChannelDeltaLabel, 'Current channels');
      expect(options.first.actionLabel, 'Current strategy');
      expect(options.last.isRecommended, isTrue);
      expect(options.last.statusLabel, 'Recommended');
      expect(options.last.switchImpactLabel, 'Coverage same | Gaps -1');
      expect(options.last.readyChannelDeltaLabel, 'Ready channels same');
      expect(options.last.actionLabel, 'Best fit for this catalog');
    },
  );
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

final _catalogRecords = [
  InventoryProductCatalogRecord(
    product: Product(
      id: 'p1',
      name: 'Ready product',
      category: 'Retail',
      price: 10,
    ),
    stockRecords: const [],
  ),
  InventoryProductCatalogRecord(
    product: Product(id: 'p2', name: 'Draft product'),
    stockRecords: const [],
  ),
];

final _profiles = [
  ProductSalesChannelProfile(
    id: ProductSalesChannelProfileId.omniRetail,
    title: 'Strict Pack',
    subtitle: 'Price and category readiness',
    definitions: [
      ProductSalesChannelDefinition(
        channel: ProductSalesChannel.posCheckout,
        title: 'Priced',
        subtitle: 'Products need prices',
        readyWhen: (record) => record.unitPrice > 0,
        reviewFilter: InventoryProductCatalogFilter.all,
        issueDefinitions: [
          ProductSalesChannelIssueDefinition(
            blocker: ProductSalesChannelBlocker.missingPrice,
            label: 'missing price',
            reviewFilter: InventoryProductCatalogFilter.all,
            matches: (record) => record.unitPrice <= 0,
          ),
        ],
      ),
      ProductSalesChannelDefinition(
        channel: ProductSalesChannel.marketplace,
        title: 'Categorized',
        subtitle: 'Products need categories',
        readyWhen: (record) => record.categoryLabel != 'Uncategorized',
        reviewFilter: InventoryProductCatalogFilter.all,
        issueDefinitions: [
          ProductSalesChannelIssueDefinition(
            blocker: ProductSalesChannelBlocker.missingCategory,
            label: 'missing category',
            reviewFilter: InventoryProductCatalogFilter.all,
            matches: (record) => record.categoryLabel == 'Uncategorized',
          ),
        ],
      ),
    ],
  ),
  ProductSalesChannelProfile(
    id: ProductSalesChannelProfileId.counterService,
    title: 'Price Pack',
    subtitle: 'Price-only readiness',
    definitions: [
      ProductSalesChannelDefinition(
        channel: ProductSalesChannel.posCheckout,
        title: 'Priced',
        subtitle: 'Products need prices',
        readyWhen: (record) => record.unitPrice > 0,
        reviewFilter: InventoryProductCatalogFilter.all,
        issueDefinitions: [
          ProductSalesChannelIssueDefinition(
            blocker: ProductSalesChannelBlocker.missingPrice,
            label: 'missing price',
            reviewFilter: InventoryProductCatalogFilter.all,
            matches: (record) => record.unitPrice <= 0,
          ),
        ],
      ),
    ],
  ),
];
