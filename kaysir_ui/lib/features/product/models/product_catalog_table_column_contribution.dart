import '../../inventory/widgets/inventory_product_catalog_table_column_contribution.dart';
import 'management_pack.dart';
import 'sales_channel_definition.dart';
import 'sales_channel_profile.dart';

typedef ProductCatalogTableColumnContributionPredicate =
    bool Function(ProductCatalogTableColumnContributionContext context);

typedef ProductCatalogTableColumnContributionBuilder =
    Iterable<InventoryProductCatalogTableColumnContribution> Function(
      ProductCatalogTableColumnContributionContext context,
    );

class ProductCatalogTableColumnContributionContext {
  const ProductCatalogTableColumnContributionContext({
    required this.pack,
    required this.channelProfile,
    required this.channelDefinitions,
  });

  final ProductManagementPack pack;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductSalesChannelDefinition> channelDefinitions;
}

class ProductCatalogTableColumnContribution {
  const ProductCatalogTableColumnContribution({
    required this.id,
    required this.buildColumns,
    this.appliesTo = productCatalogTableColumnContributionAlwaysApplies,
  });

  final String id;
  final ProductCatalogTableColumnContributionPredicate appliesTo;
  final ProductCatalogTableColumnContributionBuilder buildColumns;

  Iterable<InventoryProductCatalogTableColumnContribution> columnsFor(
    ProductCatalogTableColumnContributionContext context,
  ) {
    if (!appliesTo(context)) {
      return const <InventoryProductCatalogTableColumnContribution>[];
    }

    return buildColumns(context);
  }
}

class ProductCatalogTableColumnContributionRegistry {
  const ProductCatalogTableColumnContributionRegistry({
    this.contributions = const <ProductCatalogTableColumnContribution>[],
  });

  final List<ProductCatalogTableColumnContribution> contributions;

  List<String> get contributionIds {
    return List.unmodifiable(
      contributions.map((contribution) => contribution.id),
    );
  }

  List<InventoryProductCatalogTableColumnContribution> columnsFor(
    ProductCatalogTableColumnContributionContext context,
  ) {
    return normalizeInventoryProductCatalogTableColumnContributions([
      for (final contribution in contributions)
        ...contribution.columnsFor(context),
    ]);
  }
}

bool productCatalogTableColumnContributionAlwaysApplies(
  ProductCatalogTableColumnContributionContext context,
) {
  return true;
}
