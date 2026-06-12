import '../models/management_pack.dart';
import '../models/sales_channel_profile.dart';
import '../product_routes.dart';

/// Route payload used to preserve product pack and channel-profile context.
class ProductManagementRouteMode {
  const ProductManagementRouteMode({
    required this.packId,
    required this.channelProfileId,
  });

  final ProductManagementPackId packId;
  final ProductSalesChannelProfileId channelProfileId;

  bool get isDefault {
    return packId == ProductManagementPackId.coreCatalog &&
        channelProfileId == ProductSalesChannelProfileId.omniRetail;
  }
}

ProductManagementRouteMode productManagementRouteModeFor({
  required ProductManagementPack pack,
  required ProductSalesChannelProfile channelProfile,
}) {
  return ProductManagementRouteMode(
    packId: pack.id,
    channelProfileId: channelProfile.id,
  );
}

String productRouteWithManagementMode(
  String routePath, {
  required ProductManagementRouteMode mode,
}) {
  final trimmedPath = routePath.trim();
  if (trimmedPath.isEmpty || mode.isDefault) return routePath;

  final uri = Uri.parse(trimmedPath);
  if (!_supportsProductManagementMode(uri.path)) return routePath;

  final queryParameters = Map<String, String>.from(uri.queryParameters);
  queryParameters.putIfAbsent(
    ProductRoutes.productModePackQueryKey,
    () => productManagementPackQueryValue(mode.packId),
  );
  queryParameters.putIfAbsent(
    ProductRoutes.productModeProfileQueryKey,
    () => productSalesChannelProfileQueryValue(mode.channelProfileId),
  );

  return uri
      .replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      )
      .toString();
}

bool _supportsProductManagementMode(String path) {
  if (path == ProductRoutes.addProductPath) return true;
  if (_isEditProductPath(path)) return true;

  return switch (path) {
    ProductRoutes.workspacePath ||
    ProductRoutes.catalogPath ||
    ProductRoutes.strategyPath ||
    ProductRoutes.assortmentPlanningPath ||
    ProductRoutes.categoryManagementPath ||
    ProductRoutes.pricingManagementPath ||
    ProductRoutes.sourcingManagementPath ||
    ProductRoutes.lifecycleManagementPath ||
    ProductRoutes.variantManagementPath ||
    ProductRoutes.relationshipManagementPath ||
    ProductRoutes.availabilityManagementPath ||
    ProductRoutes.channelReadinessPath ||
    ProductRoutes.setupTargetsPath ||
    ProductRoutes.packContractsPath ||
    ProductRoutes.freshnessReviewPath => true,
    _ => false,
  };
}

bool _isEditProductPath(String path) {
  final segments = Uri(path: path).pathSegments;
  return segments.length == 3 &&
      segments.first == 'products' &&
      segments.last == 'edit' &&
      segments[1].trim().isNotEmpty;
}
