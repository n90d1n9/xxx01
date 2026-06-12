import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_table_column_contribution.dart';
import 'package:kaysir/features/product/models/product_catalog_table_column_contribution.dart';
import 'package:kaysir/features/product/models/product_catalog_table_column_ids.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_definition.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/states/product_catalog_table_column_contribution_provider.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/sales_channel_definition_provider.dart';

void main() {
  test('exposes default product catalog table column contributions', () {
    final container = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          coreProductManagementPack,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
      ],
    );
    addTearDown(container.dispose);

    final contributions = container.read(
      productCatalogTableColumnContributionsProvider,
    );

    expect(contributions.map((contribution) => contribution.id), [
      'product-catalog-quality',
      'product-channel-fit',
    ]);
    expect(contributions.map((contribution) => contribution.sectionLabel), [
      'Readiness',
      'Readiness',
    ]);
    expect(contributions.map((contribution) => contribution.priority), [
      10,
      20,
    ]);
  });

  test('adds default fresh goods columns only for grocery packs', () {
    final coreContainer = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          coreProductManagementPack,
        ),
        productSalesChannelProfileProvider.overrideWithValue(
          omniRetailProductSalesChannelProfile,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
      ],
    );
    final groceryContainer = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          groceryFreshGoodsProductManagementPack,
        ),
        productSalesChannelProfileProvider.overrideWithValue(
          groceryFreshGoodsProductSalesChannelProfile,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
      ],
    );
    addTearDown(coreContainer.dispose);
    addTearDown(groceryContainer.dispose);

    expect(
      coreContainer
          .read(productCatalogTableColumnContributionsProvider)
          .map((contribution) => contribution.id),
      isNot(contains(productFreshGoodsFreshnessColumnId)),
    );

    final groceryContributions = groceryContainer.read(
      productCatalogTableColumnContributionsProvider,
    );

    expect(groceryContributions.map((contribution) => contribution.id), [
      'product-catalog-quality',
      productFreshGoodsFreshnessColumnId,
      'product-channel-fit',
    ]);

    final freshnessColumn = groceryContributions.firstWhere(
      (contribution) => contribution.id == productFreshGoodsFreshnessColumnId,
    );
    expect(freshnessColumn.label, 'Freshness');
    expect(freshnessColumn.sectionLabel, 'Fresh goods');
    expect(freshnessColumn.defaultVisible, isFalse);
  });

  test(
    'composes and orders default and extension table column contributions',
    () {
      final container = ProviderContainer(
        overrides: [
          productManagementPackProvider.overrideWithValue(
            coreProductManagementPack,
          ),
          productSalesChannelDefinitionsProvider.overrideWithValue(
            defaultProductSalesChannelDefinitions,
          ),
          productCatalogTableColumnExtensionContributionsProvider
              .overrideWithValue([
                const InventoryProductCatalogTableColumnContribution(
                  id: 'test-launch-column',
                  label: 'Launch fit',
                  sectionLabel: 'Launch',
                  priority: 5,
                  cellBuilder: _testCell,
                ),
              ]),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container
            .read(productCatalogTableColumnContributionsProvider)
            .map((contribution) => contribution.id),
        [
          'test-launch-column',
          'product-catalog-quality',
          'product-channel-fit',
        ],
      );
    },
  );

  test('extension table column contributions override duplicate ids', () {
    final container = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          coreProductManagementPack,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
        productCatalogTableColumnExtensionContributionsProvider
            .overrideWithValue([
              const InventoryProductCatalogTableColumnContribution(
                id: 'product-channel-fit',
                label: 'Custom channel fit',
                priority: 15,
                cellBuilder: _testCell,
              ),
              const InventoryProductCatalogTableColumnContribution(
                id: '',
                label: 'Ignored',
                cellBuilder: _testCell,
              ),
            ]),
      ],
    );
    addTearDown(container.dispose);

    final contributions = container.read(
      productCatalogTableColumnContributionsProvider,
    );

    expect(contributions.map((contribution) => contribution.id), [
      'product-catalog-quality',
      'product-channel-fit',
    ]);
    expect(
      contributions
          .firstWhere(
            (contribution) => contribution.id == 'product-channel-fit',
          )
          .label,
      'Custom channel fit',
    );
  });

  test('module table column contributions can be scoped to product mode', () {
    final coreContainer = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          coreProductManagementPack,
        ),
        productSalesChannelProfileProvider.overrideWithValue(
          omniRetailProductSalesChannelProfile,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
        productCatalogTableColumnModuleContributionsProvider.overrideWithValue([
          _groceryExpiryContribution,
        ]),
      ],
    );
    final groceryContainer = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          groceryFreshGoodsProductManagementPack,
        ),
        productSalesChannelProfileProvider.overrideWithValue(
          groceryFreshGoodsProductSalesChannelProfile,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
        productCatalogTableColumnModuleContributionsProvider.overrideWithValue([
          _groceryExpiryContribution,
        ]),
      ],
    );
    addTearDown(coreContainer.dispose);
    addTearDown(groceryContainer.dispose);

    expect(
      coreContainer
          .read(productCatalogTableColumnContributionsProvider)
          .map((contribution) => contribution.id),
      isNot(contains('grocery-expiry-risk')),
    );
    expect(
      groceryContainer
          .read(productCatalogTableColumnContributionsProvider)
          .map((contribution) => contribution.id),
      ['product-catalog-quality', 'grocery-expiry-risk', 'product-channel-fit'],
    );
  });

  test('module table column contributions can override default columns', () {
    final container = ProviderContainer(
      overrides: [
        productManagementPackProvider.overrideWithValue(
          coreProductManagementPack,
        ),
        productSalesChannelProfileProvider.overrideWithValue(
          omniRetailProductSalesChannelProfile,
        ),
        productSalesChannelDefinitionsProvider.overrideWithValue(
          defaultProductSalesChannelDefinitions,
        ),
        productCatalogTableColumnModuleContributionsProvider.overrideWithValue([
          const ProductCatalogTableColumnContribution(
            id: 'mode-channel-fit',
            buildColumns: _moduleChannelFitColumns,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final contributions = container.read(
      productCatalogTableColumnContributionsProvider,
    );

    expect(contributions.map((contribution) => contribution.id), [
      'product-catalog-quality',
      'product-channel-fit',
    ]);
    expect(
      contributions
          .firstWhere(
            (contribution) => contribution.id == 'product-channel-fit',
          )
          .label,
      'Module channel fit',
    );
  });

  test('supports replacing product catalog table column contributions', () {
    final container = ProviderContainer(
      overrides: [
        productCatalogTableColumnContributionsProvider.overrideWithValue([
          const InventoryProductCatalogTableColumnContribution(
            id: 'test-launch-column',
            label: 'Launch fit',
            cellBuilder: _testCell,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final contributions = container.read(
      productCatalogTableColumnContributionsProvider,
    );

    expect(contributions.map((contribution) => contribution.id), [
      'test-launch-column',
    ]);
    expect(contributions.single.label, 'Launch fit');
  });
}

Widget _testCell(BuildContext context, InventoryProductCatalogRecord record) {
  return Text(record.productName);
}

const _groceryExpiryContribution = ProductCatalogTableColumnContribution(
  id: 'grocery-expiry',
  appliesTo: _isGroceryFreshGoodsPack,
  buildColumns: _groceryExpiryColumns,
);

bool _isGroceryFreshGoodsPack(
  ProductCatalogTableColumnContributionContext context,
) {
  return context.pack.id == ProductManagementPackId.groceryFreshGoods;
}

Iterable<InventoryProductCatalogTableColumnContribution> _groceryExpiryColumns(
  ProductCatalogTableColumnContributionContext context,
) {
  return const [
    InventoryProductCatalogTableColumnContribution(
      id: 'grocery-expiry-risk',
      label: 'Expiry risk',
      sectionLabel: 'Fresh goods',
      priority: 15,
      defaultVisible: false,
      cellBuilder: _testCell,
    ),
  ];
}

Iterable<InventoryProductCatalogTableColumnContribution>
_moduleChannelFitColumns(ProductCatalogTableColumnContributionContext context) {
  return const [
    InventoryProductCatalogTableColumnContribution(
      id: 'product-channel-fit',
      label: 'Module channel fit',
      sectionLabel: 'Readiness',
      priority: 20,
      cellBuilder: _testCell,
    ),
  ];
}
