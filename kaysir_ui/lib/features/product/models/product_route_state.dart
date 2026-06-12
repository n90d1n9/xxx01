import 'management_pack.dart';
import 'sales_channel_profile.dart';
import '../product_routes.dart';
import '../utils/product_catalog_review_target.dart';

class ProductManagementRouteState {
  const ProductManagementRouteState({this.packId, this.channelProfileId});

  factory ProductManagementRouteState.fromQueryParameters(
    Map<String, String?> parameters, {
    String packKey = ProductRoutes.productModePackQueryKey,
    String profileKey = ProductRoutes.productModeProfileQueryKey,
    ProductManagementPackId? fallbackPackId,
    ProductSalesChannelProfileId? fallbackChannelProfileId,
  }) {
    return ProductManagementRouteState(
      packId:
          ProductRoutes.productManagementPackIdFromQuery(parameters[packKey]) ??
          fallbackPackId,
      channelProfileId:
          ProductRoutes.productSalesChannelProfileIdOrNullFromQuery(
            parameters[profileKey],
          ) ??
          fallbackChannelProfileId,
    );
  }

  final ProductManagementPackId? packId;
  final ProductSalesChannelProfileId? channelProfileId;

  bool get hasSelection => packId != null || channelProfileId != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductManagementRouteState &&
            other.packId == packId &&
            other.channelProfileId == channelProfileId;
  }

  @override
  int get hashCode => Object.hash(packId, channelProfileId);
}

class ProductWorkspaceRouteState {
  const ProductWorkspaceRouteState({
    this.managementMode = const ProductManagementRouteState(),
    this.experienceProfileValue,
    this.setupTargetId,
  });

  factory ProductWorkspaceRouteState.fromQueryParameters(
    Map<String, String?> parameters, {
    ProductManagementPackId? fallbackPackId,
    ProductSalesChannelProfileId? fallbackChannelProfileId,
  }) {
    return ProductWorkspaceRouteState(
      managementMode: ProductManagementRouteState.fromQueryParameters(
        parameters,
        packKey: ProductRoutes.workspacePackQueryKey,
        profileKey: ProductRoutes.workspaceProfileQueryKey,
        fallbackPackId: fallbackPackId,
        fallbackChannelProfileId: fallbackChannelProfileId,
      ),
      experienceProfileValue:
          ProductRoutes.productExperienceProfileValueFromQuery(
            parameters[ProductRoutes.workspaceExperienceQueryKey],
          ),
      setupTargetId: ProductRoutes.workspaceSetupTargetIdFromQuery(
        parameters[ProductRoutes.workspaceSetupQueryKey],
      ),
    );
  }

  final ProductManagementRouteState managementMode;
  final String? experienceProfileValue;
  final String? setupTargetId;

  ProductManagementPackId? get packId => managementMode.packId;
  ProductSalesChannelProfileId? get channelProfileId =>
      managementMode.channelProfileId;
  bool get hasExperienceProfile => experienceProfileValue != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductWorkspaceRouteState &&
            other.managementMode == managementMode &&
            other.experienceProfileValue == experienceProfileValue &&
            other.setupTargetId == setupTargetId;
  }

  @override
  int get hashCode {
    return Object.hash(managementMode, experienceProfileValue, setupTargetId);
  }
}

class ProductCatalogRouteState {
  const ProductCatalogRouteState({
    this.managementMode = const ProductManagementRouteState(),
    required this.reviewTarget,
  });

  factory ProductCatalogRouteState.fromQueryParameters(
    Map<String, String?> parameters, {
    ProductManagementPackId? fallbackPackId,
    ProductSalesChannelProfileId? fallbackChannelProfileId,
  }) {
    return ProductCatalogRouteState(
      managementMode: ProductManagementRouteState.fromQueryParameters(
        parameters,
        packKey: ProductRoutes.catalogPackQueryKey,
        profileKey: ProductRoutes.catalogProfileQueryKey,
        fallbackPackId: fallbackPackId,
        fallbackChannelProfileId: fallbackChannelProfileId,
      ),
      reviewTarget: ProductRoutes.catalogReviewTargetFromQueryParameters(
        parameters,
      ),
    );
  }

  final ProductManagementRouteState managementMode;
  final ProductCatalogReviewTarget reviewTarget;

  ProductManagementPackId? get packId => managementMode.packId;
  ProductSalesChannelProfileId? get channelProfileId =>
      managementMode.channelProfileId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductCatalogRouteState &&
            other.managementMode == managementMode &&
            other.reviewTarget == reviewTarget;
  }

  @override
  int get hashCode => Object.hash(managementMode, reviewTarget);
}

class ProductEditorRouteState {
  const ProductEditorRouteState({
    this.managementMode = const ProductManagementRouteState(),
    this.productId,
    this.focusFieldId,
  });

  factory ProductEditorRouteState.fromRoute({
    required Map<String, String?> pathParameters,
    required Map<String, String?> queryParameters,
  }) {
    return ProductEditorRouteState(
      managementMode: ProductManagementRouteState.fromQueryParameters(
        queryParameters,
      ),
      productId: pathParameters[ProductRoutes.productIdPathParameter],
      focusFieldId: ProductRoutes.productEditorFocusFieldFromQuery(
        queryParameters[ProductRoutes.productEditorFocusQueryKey],
      ),
    );
  }

  final ProductManagementRouteState managementMode;
  final String? productId;
  final ProductManagementFieldId? focusFieldId;

  ProductManagementPackId? get packId => managementMode.packId;
  ProductSalesChannelProfileId? get channelProfileId =>
      managementMode.channelProfileId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductEditorRouteState &&
            other.managementMode == managementMode &&
            other.productId == productId &&
            other.focusFieldId == focusFieldId;
  }

  @override
  int get hashCode => Object.hash(managementMode, productId, focusFieldId);
}

class ProductScanRouteState {
  const ProductScanRouteState({
    this.initialQuery = '',
    this.returnTarget = ProductScanReturnTarget.stockOpname,
  });

  factory ProductScanRouteState.fromQueryParameters(
    Map<String, String?> parameters,
  ) {
    return ProductScanRouteState(
      initialQuery: parameters[ProductRoutes.scanProductQueryKey] ?? '',
      returnTarget: productScanReturnTargetFromQuery(
        parameters[ProductRoutes.scanProductReturnTargetQueryKey],
      ),
    );
  }

  final String initialQuery;
  final ProductScanReturnTarget returnTarget;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductScanRouteState &&
            other.initialQuery == initialQuery &&
            other.returnTarget == returnTarget;
  }

  @override
  int get hashCode => Object.hash(initialQuery, returnTarget);
}
