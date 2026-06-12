import '../inventory/models/inventory_product_catalog.dart';
import 'models/product_catalog_view_preset.dart';
import 'models/management_pack.dart';
import 'models/sales_channel_readiness.dart';
import 'models/product_workspace_setup_target.dart';
import 'utils/product_catalog_review_target.dart';

enum ProductScanReturnTarget { stockOpname, discrepancyReport }

class ProductRoutes {
  static const workspaceRouteName = 'productWorkspace';
  static const strategyRouteName = 'productStrategy';
  static const assortmentPlanningRouteName = 'productAssortmentPlanning';
  static const categoryManagementRouteName = 'productCategoryManagement';
  static const pricingManagementRouteName = 'productPricingManagement';
  static const sourcingManagementRouteName = 'productSourcingManagement';
  static const lifecycleManagementRouteName = 'productLifecycleManagement';
  static const variantManagementRouteName = 'productVariantManagement';
  static const relationshipManagementRouteName =
      'productRelationshipManagement';
  static const availabilityManagementRouteName =
      'productAvailabilityManagement';
  static const channelReadinessRouteName = 'productChannelReadiness';
  static const setupTargetsRouteName = 'productSetupTargets';
  static const packContractsRouteName = 'productPackContracts';
  static const catalogRouteName = 'productCatalog';
  static const freshnessReviewRouteName = 'productFreshnessReview';
  static const addProductRouteName = 'productAddProduct';
  static const editProductRouteName = 'productEditProduct';
  static const stockMovementsRouteName = 'productStockMovements';
  static const addStockMovementRouteName = 'productAddStockMovement';
  static const stockOpnameRouteName = 'productStockOpname';
  static const scanProductRouteName = 'productScanProduct';
  static const discrepancyReportRouteName = 'productDiscrepancyReport';

  static const workspacePath = '/product-workspace';
  static const strategyPath = '/products/strategy';
  static const assortmentPlanningPath = '/products/assortment-planning';
  static const categoryManagementPath = '/products/categories';
  static const pricingManagementPath = '/products/pricing';
  static const sourcingManagementPath = '/products/sourcing';
  static const lifecycleManagementPath = '/products/lifecycle';
  static const variantManagementPath = '/products/variants';
  static const relationshipManagementPath = '/products/relationships';
  static const availabilityManagementPath = '/products/availability';
  static const channelReadinessPath = '/products/channel-readiness';
  static const setupTargetsPath = '/products/setup-targets';
  static const packContractsPath = '/products/pack-contracts';
  static const catalogPath = '/products';
  static const freshnessReviewPath = '/products/freshness';
  static const addProductPath = '/products/new';
  static const editProductPath = '/products/:productId/edit';
  static const stockMovementsPath = '/products/stock-movements';
  static const addStockMovementPath = '/products/stock-movements/new';
  static const stockOpnamePath = '/products/stock-opname';
  static const scanProductPath = '/products/stock-opname/scan';
  static const discrepancyReportPath = '/products/discrepancy-report';
  static const workspaceExperienceQueryKey = 'experience';
  static const productModePackQueryKey = 'pack';
  static const productModeProfileQueryKey = 'profile';
  static const workspacePackQueryKey = productModePackQueryKey;
  static const workspaceProfileQueryKey = productModeProfileQueryKey;
  static const workspaceSetupQueryKey = 'setup';
  static const catalogPackQueryKey = productModePackQueryKey;
  static const catalogProfileQueryKey = productModeProfileQueryKey;
  static const catalogFilterQueryKey = 'filter';
  static const catalogSearchQueryKey = 'q';
  static const catalogReviewTitleQueryKey = 'review';
  static const catalogReviewReasonQueryKey = 'reason';
  static const productEditorFocusQueryKey = 'field';
  static const productIdPathParameter = 'productId';
  static const scanProductQueryKey = 'q';
  static const scanProductReturnTargetQueryKey = 'returnTo';

  const ProductRoutes._();

  static String workspaceUri({
    String experience = '',
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
    ProductWorkspaceSetupTarget? setupTarget,
  }) {
    final parameters = <String, String>{};
    final normalizedExperience = productExperienceProfileQueryValue(experience);
    if (normalizedExperience != null) {
      parameters[workspaceExperienceQueryKey] = normalizedExperience;
    }
    if (pack != null) {
      parameters[workspacePackQueryKey] = productManagementPackQueryValue(pack);
    }
    if (profile != null) {
      parameters[workspaceProfileQueryKey] =
          productSalesChannelProfileQueryValue(profile);
    }
    final setupTargetId = setupTarget?.id.trim();
    if (setupTargetId != null && setupTargetId.isNotEmpty) {
      parameters[workspaceSetupQueryKey] = setupTargetId;
    }

    return Uri(
      path: workspacePath,
      queryParameters: parameters.isEmpty ? null : parameters,
    ).toString();
  }

  static String workspaceSetupUri(
    ProductWorkspaceSetupTarget target, {
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return workspaceUri(pack: pack, profile: profile, setupTarget: target);
  }

  static String? productExperienceProfileValueFromQuery(String? value) {
    return _normalizedProductModeQueryValue(value);
  }

  static String strategyUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: strategyPath,
      pack: pack,
      profile: profile,
    );
  }

  static String channelReadinessUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: channelReadinessPath,
      pack: pack,
      profile: profile,
    );
  }

  static String assortmentPlanningUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: assortmentPlanningPath,
      pack: pack,
      profile: profile,
    );
  }

  static String categoryManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: categoryManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String pricingManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: pricingManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String sourcingManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: sourcingManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String lifecycleManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: lifecycleManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String variantManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: variantManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String relationshipManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: relationshipManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String availabilityManagementUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: availabilityManagementPath,
      pack: pack,
      profile: profile,
    );
  }

  static String setupTargetsUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: setupTargetsPath,
      pack: pack,
      profile: profile,
    );
  }

  static String packContractsUri({
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productManagementUri(
      path: packContractsPath,
      pack: pack,
      profile: profile,
    );
  }

  static ProductManagementPackId? productManagementPackIdFromQuery(
    String? value,
  ) {
    final normalized = _normalizedProductModeQueryValue(value);
    if (normalized == null) return null;

    switch (normalized) {
      case 'core':
      case 'catalog':
      case 'core_catalog':
      case 'corecatalog':
        return ProductManagementPackId.coreCatalog;
      case 'fresh_goods':
      case 'grocery':
      case 'grocery_fresh_goods':
      case 'groceryfreshgoods':
        return ProductManagementPackId.groceryFreshGoods;
    }

    return ProductManagementPackId(normalized);
  }

  static ProductSalesChannelProfileId?
  productSalesChannelProfileIdOrNullFromQuery(String? value) {
    final normalized = _normalizedProductModeQueryValue(value);
    if (normalized == null) return null;

    return productSalesChannelProfileIdFromQuery(normalized);
  }

  static ProductWorkspaceSetupTarget? workspaceSetupTargetFromQuery(
    String? value,
  ) {
    return ProductWorkspaceSetupTarget.fromQuery(value);
  }

  static String? workspaceSetupTargetIdFromQuery(String? value) {
    final normalizedValue = value?.trim();
    return normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;
  }

  static String catalogUri({
    InventoryProductCatalogFilter filter = InventoryProductCatalogFilter.all,
    String query = '',
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return catalogUriForReviewTarget(
      ProductCatalogReviewTarget(filter: filter, query: query),
      pack: pack,
      profile: profile,
    );
  }

  static String catalogUriForReviewTarget(
    ProductCatalogReviewTarget target, {
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    final parameters = <String, String>{};
    if (pack != null) {
      parameters[catalogPackQueryKey] = productManagementPackQueryValue(pack);
    }
    if (profile != null) {
      parameters[catalogProfileQueryKey] = productSalesChannelProfileQueryValue(
        profile,
      );
    }
    parameters.addAll(
      target.toCatalogQueryParameters(
        filterKey: catalogFilterQueryKey,
        searchKey: catalogSearchQueryKey,
        titleKey: catalogReviewTitleQueryKey,
        reasonKey: catalogReviewReasonQueryKey,
      ),
    );

    return Uri(
      path: catalogPath,
      queryParameters: parameters.isEmpty ? null : parameters,
    ).toString();
  }

  static ProductManagementPackId? catalogPackIdFromQueryParameters(
    Map<String, String?> parameters,
  ) {
    return productManagementPackIdFromQuery(parameters[catalogPackQueryKey]);
  }

  static ProductSalesChannelProfileId? catalogProfileIdFromQueryParameters(
    Map<String, String?> parameters,
  ) {
    return productSalesChannelProfileIdOrNullFromQuery(
      parameters[catalogProfileQueryKey],
    );
  }

  static ProductCatalogReviewTarget catalogReviewTargetFromQueryParameters(
    Map<String, String?> parameters,
  ) {
    return ProductCatalogReviewTarget.fromCatalogQueryParameters(
      parameters,
      filterKey: catalogFilterQueryKey,
      searchKey: catalogSearchQueryKey,
      titleKey: catalogReviewTitleQueryKey,
      reasonKey: catalogReviewReasonQueryKey,
    );
  }

  static String addProductUri({
    ProductManagementFieldId? focusField,
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productEditorUri(
      pathSegments: const ['products', 'new'],
      focusField: focusField,
      pack: pack,
      profile: profile,
    );
  }

  static String editProductUri({
    required String productId,
    ProductManagementFieldId? focusField,
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return _productEditorUri(
      pathSegments: ['products', productId.trim(), 'edit'],
      focusField: focusField,
      pack: pack,
      profile: profile,
    );
  }

  static ProductManagementFieldId? productEditorFocusFieldFromQuery(
    String? value,
  ) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    for (final fieldId in ProductManagementFieldId.values) {
      if (fieldId.value == normalized) return fieldId;
    }

    return null;
  }

  static String catalogUriForPreset(
    ProductCatalogViewPreset preset, {
    String query = '',
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return catalogUriForReviewTarget(
      ProductCatalogReviewTarget(
        filter: preset.filter,
        query: query,
        title: preset.title,
      ),
      pack: pack,
      profile: profile,
    );
  }

  static String catalogUriForChannelReadiness(
    ProductSalesChannelReadiness readiness, {
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return catalogUriForReviewTarget(
      ProductCatalogReviewTarget.fromReadiness(readiness),
      pack: pack,
      profile: profile,
    );
  }

  static String catalogUriForChannelReadinessIssue(
    ProductSalesChannelReadinessIssue issue, {
    String title = 'Channel readiness',
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    return catalogUriForReviewTarget(
      ProductCatalogReviewTarget.fromReadinessIssue(issue, title: title),
      pack: pack,
      profile: profile,
    );
  }

  static String freshnessReviewUri() => freshnessReviewPath;

  static String stockMovementsUri() => stockMovementsPath;

  static String addStockMovementUri() => addStockMovementPath;

  static String stockOpnameUri() => stockOpnamePath;

  static String scanProductUri({
    String query = '',
    ProductScanReturnTarget returnTarget = ProductScanReturnTarget.stockOpname,
  }) {
    final parameters = <String, String>{};
    final normalizedQuery = query.trim();
    if (normalizedQuery.isNotEmpty) {
      parameters[scanProductQueryKey] = normalizedQuery;
    }
    if (returnTarget != ProductScanReturnTarget.stockOpname) {
      parameters[scanProductReturnTargetQueryKey] =
          productScanReturnTargetQueryValue(returnTarget);
    }

    return Uri(
      path: scanProductPath,
      queryParameters: parameters.isEmpty ? null : parameters,
    ).toString();
  }

  static String scanReturnUri(ProductScanReturnTarget target) {
    switch (target) {
      case ProductScanReturnTarget.stockOpname:
        return stockOpnameUri();
      case ProductScanReturnTarget.discrepancyReport:
        return discrepancyReportUri();
    }
  }

  static String discrepancyReportUri() => discrepancyReportPath;

  static String _productEditorUri({
    required List<String> pathSegments,
    ProductManagementFieldId? focusField,
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    final queryParameters = <String, String>{};
    if (pack != null) {
      queryParameters[productModePackQueryKey] =
          productManagementPackQueryValue(pack);
    }
    if (profile != null) {
      queryParameters[productModeProfileQueryKey] =
          productSalesChannelProfileQueryValue(profile);
    }
    if (focusField != null) {
      queryParameters[productEditorFocusQueryKey] = focusField.value;
    }

    return Uri(
      path: '/${pathSegments.map(Uri.encodeComponent).join('/')}',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String _productManagementUri({
    required String path,
    ProductManagementPackId? pack,
    ProductSalesChannelProfileId? profile,
  }) {
    final parameters = <String, String>{};
    if (pack != null) {
      parameters[productModePackQueryKey] = productManagementPackQueryValue(
        pack,
      );
    }
    if (profile != null) {
      parameters[productModeProfileQueryKey] =
          productSalesChannelProfileQueryValue(profile);
    }

    return Uri(
      path: path,
      queryParameters: parameters.isEmpty ? null : parameters,
    ).toString();
  }
}

String productManagementPackQueryValue(ProductManagementPackId id) {
  return id.value;
}

String? productExperienceProfileQueryValue(String value) {
  return _normalizedProductModeQueryValue(value);
}

String productScanReturnTargetQueryValue(ProductScanReturnTarget target) {
  switch (target) {
    case ProductScanReturnTarget.stockOpname:
      return 'stock_opname';
    case ProductScanReturnTarget.discrepancyReport:
      return 'discrepancy_report';
  }
}

String? _normalizedProductModeQueryValue(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );
  return normalized == null || normalized.isEmpty ? null : normalized;
}

ProductScanReturnTarget productScanReturnTargetFromQuery(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'discrepancy_report':
      return ProductScanReturnTarget.discrepancyReport;
    case 'stock_opname':
    default:
      return ProductScanReturnTarget.stockOpname;
  }
}
