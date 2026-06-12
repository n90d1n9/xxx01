import 'product_catalog_quality.dart';

/// Presentation state for the catalog quality dashboard panel.
class ProductCatalogQualityPanelViewState {
  ProductCatalogQualityPanelViewState._({
    required this.summary,
    required List<ProductCatalogQualityIssue> issues,
  }) : issues = List.unmodifiable(issues);

  factory ProductCatalogQualityPanelViewState.fromSummary(
    ProductCatalogQualitySummary summary,
  ) {
    return ProductCatalogQualityPanelViewState._(
      summary: summary,
      issues: summary.issues,
    );
  }

  final ProductCatalogQualitySummary summary;
  final List<ProductCatalogQualityIssue> issues;

  String get title => 'Catalog quality';
  String get subtitle => '${summary.completeCountLabel}, $setupLabel';
  String get completionLabel => '${summary.completePercent}% complete';
  String get emptyLabel => 'No products available for quality review.';

  int get completePercent => summary.completePercent;
  double get progressValue => completePercent / 100;
  bool get isEmpty => summary.productCount == 0;

  String get setupLabel {
    final count = summary.issueProductCount;
    if (summary.productCount == 0) return 'no products to review';
    if (count == 0) return 'all products ready';
    if (count == 1) return '1 product needs setup';

    return '$count products need setup';
  }
}
