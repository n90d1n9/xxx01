import '../../inventory/models/inventory_product_catalog.dart';
import '../models/sales_channel_definition.dart';
import '../models/sales_channel_types.dart';

class ProductCatalogChannelReadinessItem {
  const ProductCatalogChannelReadinessItem({
    required this.channel,
    required this.title,
    required this.reviewFilter,
    required this.ready,
    required this.issues,
  });

  final ProductSalesChannel channel;
  final String title;
  final InventoryProductCatalogFilter reviewFilter;
  final bool ready;
  final List<ProductSalesChannelIssueDefinition> issues;

  int get issueCount => issues.length;

  ProductSalesChannelIssueDefinition? get primaryIssue {
    if (issues.isEmpty) return null;

    return issues.first;
  }

  String get statusLabel {
    if (ready) return 'Ready';
    if (issueCount == 0) return 'Needs review';
    if (issueCount == 1) return '1 issue';

    return '$issueCount issues';
  }

  String get issueSummaryLabel {
    if (ready) return 'Ready for $title';
    if (issues.isEmpty) return 'Needs review for $title';

    return issues.map((issue) => issue.label).join(', ');
  }
}

List<ProductCatalogChannelReadinessItem> buildProductCatalogChannelReadiness({
  required InventoryProductCatalogRecord record,
  required List<ProductSalesChannelDefinition> definitions,
}) {
  return [
    for (final definition in definitions)
      ProductCatalogChannelReadinessItem(
        channel: definition.channel,
        title: definition.title,
        reviewFilter: definition.reviewFilter,
        ready: definition.readyWhen(record),
        issues: List.unmodifiable(
          definition.issueDefinitions.where((issue) => issue.matches(record)),
        ),
      ),
  ];
}
