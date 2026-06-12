import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import 'product_catalog_default_saved_view_contributions.dart';
import 'product_catalog_saved_view_contribution.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

class ProductCatalogStarterSavedViewSet {
  const ProductCatalogStarterSavedViewSet({
    required this.seedKey,
    required this.views,
    this.viewSectionLabels = const <String, String>{},
  });

  final String seedKey;
  final List<InventoryProductCatalogSavedView> views;
  final Map<String, String> viewSectionLabels;

  bool get isEmpty => views.isEmpty;

  Set<String> get viewIds {
    return Set.unmodifiable(views.map((view) => view.id));
  }

  String? sectionLabelFor(InventoryProductCatalogSavedView view) {
    return viewSectionLabels[view.id];
  }
}

ProductCatalogStarterSavedViewSet buildProductCatalogStarterSavedViewSet({
  required ProductManagementPack pack,
  required ProductSalesChannelProfile channelProfile,
  ProductCatalogSavedViewContributionRegistry registry =
      defaultProductCatalogSavedViewContributionRegistry,
}) {
  final seedKey = '${pack.id.value}.${channelProfile.id.value}';
  final context = ProductCatalogSavedViewContributionContext(
    seedKey: seedKey,
    pack: pack,
    channelProfile: channelProfile,
  );
  final result = registry.starterViewResultFor(context);

  return ProductCatalogStarterSavedViewSet(
    seedKey: seedKey,
    views: result.views,
    viewSectionLabels: result.sectionLabelsByViewId,
  );
}
