import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/widgets/inventory_product_catalog_table_column_contribution.dart';
import '../models/product_catalog_table_column_contribution.dart';
import '../widgets/product_catalog_table_column_contributions.dart';
import '../widgets/product_fresh_goods_table_column_contributions.dart';
import 'management_pack_provider.dart';
import 'sales_channel_definition_provider.dart';

final productCatalogDefaultTableColumnContributionsProvider =
    Provider<List<InventoryProductCatalogTableColumnContribution>>((ref) {
      return buildDefaultProductCatalogTableColumnContributions(
        pack: ref.watch(productManagementPackProvider),
        channelDefinitions: ref.watch(productSalesChannelDefinitionsProvider),
      );
    });

final productCatalogTableColumnExtensionContributionsProvider =
    Provider<List<InventoryProductCatalogTableColumnContribution>>((ref) {
      return const <InventoryProductCatalogTableColumnContribution>[];
    });

final productCatalogDefaultTableColumnModuleContributionsProvider =
    Provider<List<ProductCatalogTableColumnContribution>>((ref) {
      return buildDefaultProductCatalogTableColumnModuleContributions();
    });

final productCatalogTableColumnModuleExtensionContributionsProvider =
    Provider<List<ProductCatalogTableColumnContribution>>((ref) {
      return const <ProductCatalogTableColumnContribution>[];
    });

final productCatalogTableColumnModuleContributionsProvider = Provider<
  List<ProductCatalogTableColumnContribution>
>((ref) {
  return [
    ...ref.watch(productCatalogDefaultTableColumnModuleContributionsProvider),
    ...ref.watch(productCatalogTableColumnModuleExtensionContributionsProvider),
  ];
});

final productCatalogTableColumnContributionRegistryProvider =
    Provider<ProductCatalogTableColumnContributionRegistry>((ref) {
      return ProductCatalogTableColumnContributionRegistry(
        contributions: ref.watch(
          productCatalogTableColumnModuleContributionsProvider,
        ),
      );
    });

final productCatalogTableColumnContributionsProvider =
    Provider<List<InventoryProductCatalogTableColumnContribution>>((ref) {
      final context = ProductCatalogTableColumnContributionContext(
        pack: ref.watch(productManagementPackProvider),
        channelProfile: ref.watch(productSalesChannelProfileProvider),
        channelDefinitions: ref.watch(productSalesChannelDefinitionsProvider),
      );

      return normalizeInventoryProductCatalogTableColumnContributions([
        ...ref.watch(productCatalogDefaultTableColumnContributionsProvider),
        ...ref
            .watch(productCatalogTableColumnContributionRegistryProvider)
            .columnsFor(context),
        ...ref.watch(productCatalogTableColumnExtensionContributionsProvider),
      ]);
    });
