import '../../inventory/models/inventory_product_catalog.dart';
import 'management_pack.dart';
import 'product_catalog_quality.dart';

/// Presentation state for row-level catalog quality quick-fix badges.
class ProductCatalogQualityBadgeStripViewState {
  ProductCatalogQualityBadgeStripViewState._({
    required List<ProductCatalogQualityIssue> issues,
    required List<ProductCatalogQualityIssue> visibleIssues,
    required this.maxVisibleIssues,
  }) : issues = List.unmodifiable(issues),
       visibleIssues = List.unmodifiable(visibleIssues);

  factory ProductCatalogQualityBadgeStripViewState.fromRecord({
    required InventoryProductCatalogRecord record,
    required int maxVisibleIssues,
    ProductManagementPack? pack,
  }) {
    final safeMaxVisibleIssues = maxVisibleIssues < 0 ? 0 : maxVisibleIssues;
    final issues = productCatalogQualityIssuesForRecord(record, pack: pack);

    return ProductCatalogQualityBadgeStripViewState._(
      issues: issues,
      visibleIssues: issues.take(safeMaxVisibleIssues).toList(),
      maxVisibleIssues: safeMaxVisibleIssues,
    );
  }

  final List<ProductCatalogQualityIssue> issues;
  final List<ProductCatalogQualityIssue> visibleIssues;
  final int maxVisibleIssues;

  int get totalIssueCount => issues.length;
  int get hiddenIssueCount => totalIssueCount - visibleIssues.length;

  bool get isReady => issues.isEmpty;
  bool get hasHiddenIssues => hiddenIssueCount > 0;

  String get readyLabel => 'Quality ready';

  String get summaryLabel {
    return '$totalIssueCount quality ${totalIssueCount == 1 ? 'fix' : 'fixes'}';
  }

  String get hiddenLabel => '+$hiddenIssueCount more';
}
