import '../../inventory/models/inventory_product_catalog.dart';
import '../models/sales_channel_readiness.dart';
import 'product_catalog_channel_readiness.dart';

class ProductCatalogReviewTarget {
  static const defaultTitle = 'Product review';

  const ProductCatalogReviewTarget({
    this.filter = InventoryProductCatalogFilter.all,
    this.query = '',
    this.title = defaultTitle,
    this.reasonLabel = '',
  });

  final InventoryProductCatalogFilter filter;
  final String query;
  final String title;
  final String reasonLabel;

  String get normalizedQuery => query.trim();

  String get normalizedTitle {
    final normalized = title.trim();
    if (normalized.isEmpty) return defaultTitle;

    return normalized;
  }

  String get normalizedReasonLabel => reasonLabel.trim();

  bool get hasFilter => filter != InventoryProductCatalogFilter.all;

  bool get hasQuery => normalizedQuery.isNotEmpty;

  bool get hasCatalogState => hasFilter || hasQuery;

  String get summaryLabel {
    if (normalizedReasonLabel.isEmpty) return normalizedTitle;

    return '$normalizedTitle: $normalizedReasonLabel';
  }

  String get announcementLabel => 'Reviewing $summaryLabel';

  bool hasSameCatalogStateAs(ProductCatalogReviewTarget other) {
    return filter == other.filter && normalizedQuery == other.normalizedQuery;
  }

  Map<String, String> toCatalogQueryParameters({
    String filterKey = 'filter',
    String searchKey = 'q',
    String? titleKey,
    String? reasonKey,
  }) {
    final parameters = <String, String>{};
    if (hasFilter) {
      parameters[filterKey] = inventoryProductCatalogFilterQueryValue(filter);
    }
    if (hasQuery) {
      parameters[searchKey] = normalizedQuery;
    }
    if (titleKey != null && normalizedTitle != defaultTitle) {
      parameters[titleKey] = normalizedTitle;
    }
    if (reasonKey != null && normalizedReasonLabel.isNotEmpty) {
      parameters[reasonKey] = normalizedReasonLabel;
    }

    return parameters;
  }

  ProductCatalogReviewTarget copyWith({
    InventoryProductCatalogFilter? filter,
    String? query,
    String? title,
    String? reasonLabel,
  }) {
    return ProductCatalogReviewTarget(
      filter: filter ?? this.filter,
      query: query ?? this.query,
      title: title ?? this.title,
      reasonLabel: reasonLabel ?? this.reasonLabel,
    );
  }

  static ProductCatalogReviewTarget fromCatalogQueryParameters(
    Map<String, String?> parameters, {
    String filterKey = 'filter',
    String searchKey = 'q',
    String? titleKey,
    String? reasonKey,
    String title = 'Product review',
  }) {
    return ProductCatalogReviewTarget(
      filter: inventoryProductCatalogFilterFromQuery(parameters[filterKey]),
      query: parameters[searchKey] ?? '',
      title: _parameterValue(parameters, titleKey) ?? title,
      reasonLabel: _parameterValue(parameters, reasonKey) ?? '',
    );
  }

  static ProductCatalogReviewTarget resolveForCatalogState({
    required ProductCatalogReviewTarget initialTarget,
    ProductCatalogReviewTarget? activeTarget,
    required InventoryProductCatalogFilter filter,
    required String query,
  }) {
    final currentTarget = ProductCatalogReviewTarget(
      filter: filter,
      query: query,
    );
    if (activeTarget != null &&
        activeTarget.hasSameCatalogStateAs(currentTarget)) {
      return activeTarget;
    }
    if (initialTarget.hasSameCatalogStateAs(currentTarget)) {
      return initialTarget;
    }

    return currentTarget;
  }

  static ProductCatalogReviewTarget fromReadiness(
    ProductSalesChannelReadiness readiness,
  ) {
    final issue = readiness.primaryIssue;
    if (issue != null) {
      return fromReadinessIssue(issue, title: readiness.title);
    }

    return ProductCatalogReviewTarget(
      filter: readiness.reviewFilter,
      title: readiness.title,
    );
  }

  static ProductCatalogReviewTarget fromReadinessIssue(
    ProductSalesChannelReadinessIssue issue, {
    String title = 'Channel readiness',
  }) {
    return ProductCatalogReviewTarget(
      filter: issue.reviewFilter,
      query: issue.reviewQuery,
      title: title,
      reasonLabel: issue.label,
    );
  }

  static ProductCatalogReviewTarget fromCatalogItem(
    ProductCatalogChannelReadinessItem item,
  ) {
    final issue = item.primaryIssue;
    if (issue != null) return fromCatalogIssue(issue, title: item.title);

    return ProductCatalogReviewTarget(
      filter: item.reviewFilter,
      title: item.title,
    );
  }

  static ProductCatalogReviewTarget fromCatalogIssue(
    ProductSalesChannelIssueDefinition issue, {
    String title = 'Product channel',
  }) {
    return ProductCatalogReviewTarget(
      filter: issue.reviewFilter,
      query: issue.reviewQuery,
      title: title,
      reasonLabel: issue.label,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductCatalogReviewTarget &&
            other.filter == filter &&
            other.normalizedQuery == normalizedQuery &&
            other.normalizedTitle == normalizedTitle &&
            other.normalizedReasonLabel == normalizedReasonLabel;
  }

  @override
  int get hashCode {
    return Object.hash(
      filter,
      normalizedQuery,
      normalizedTitle,
      normalizedReasonLabel,
    );
  }

  @override
  String toString() {
    return 'ProductCatalogReviewTarget('
        'filter: $filter, '
        'query: $normalizedQuery, '
        'title: $normalizedTitle, '
        'reasonLabel: $normalizedReasonLabel'
        ')';
  }
}

String? _parameterValue(Map<String, String?> parameters, String? key) {
  if (key == null) return null;

  final normalized = parameters[key]?.trim();
  if (normalized == null || normalized.isEmpty) return null;

  return normalized;
}
