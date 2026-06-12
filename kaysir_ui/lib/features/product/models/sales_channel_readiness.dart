import '../../inventory/models/inventory_product_catalog.dart';
import 'sales_channel_definition.dart';
import 'sales_channel_types.dart';

export 'sales_channel_definition.dart'
    show
        ProductSalesChannelDefinition,
        ProductSalesChannelIssueDefinition,
        ProductSalesChannelRecordMatcher,
        defaultProductSalesChannelDefinitions,
        productSalesChannelDefinitionFor;
export 'sales_channel_profile.dart';
export 'sales_channel_types.dart';

/// Counted issue that blocks products from being ready for a sales channel.
class ProductSalesChannelReadinessIssue {
  const ProductSalesChannelReadinessIssue({
    required this.blocker,
    required this.label,
    required this.count,
    required this.reviewFilter,
    this.reviewQuery = '',
  });

  final ProductSalesChannelBlocker blocker;
  final String label;
  final int count;
  final InventoryProductCatalogFilter reviewFilter;
  final String reviewQuery;

  String get countLabel => '$count $label';
}

/// Product readiness summary for one sales channel.
class ProductSalesChannelReadiness {
  const ProductSalesChannelReadiness({
    required this.channel,
    required this.title,
    required this.subtitle,
    required this.readyCount,
    required this.totalCount,
    required this.reviewFilter,
    this.issues = const [],
  });

  final ProductSalesChannel channel;
  final String title;
  final String subtitle;
  final int readyCount;
  final int totalCount;
  final InventoryProductCatalogFilter reviewFilter;
  final List<ProductSalesChannelReadinessIssue> issues;

  int get issueCount => totalCount - readyCount;

  int get readyPercent {
    if (totalCount == 0) return 0;
    return ((readyCount / totalCount) * 100).round();
  }

  String get countLabel => '$readyCount/$totalCount ready';

  String get percentLabel => '$readyPercent%';

  String get actionLabel => issueCount == 0 ? 'Ready' : '$issueCount to fix';

  List<ProductSalesChannelReadinessIssue> get activeIssues {
    final active =
        issues.where((issue) => issue.count > 0).toList()..sort((left, right) {
          final countComparison = right.count.compareTo(left.count);
          if (countComparison != 0) return countComparison;

          return left.label.compareTo(right.label);
        });

    return List.unmodifiable(active);
  }

  List<ProductSalesChannelReadinessIssue> topIssues({int limit = 2}) {
    if (limit <= 0) return const [];

    return activeIssues.take(limit).toList(growable: false);
  }

  int hiddenIssueCount({int visibleLimit = 2}) {
    final hiddenCount = activeIssues.length - visibleLimit;
    return hiddenCount > 0 ? hiddenCount : 0;
  }

  String get issueSummaryLabel {
    final active = activeIssues;
    if (active.isEmpty) return 'No blockers';
    if (active.length == 1) return active.first.countLabel;

    return '${active.length} blocker types';
  }

  ProductSalesChannelReadinessIssue? get primaryIssue {
    final active = activeIssues;
    return active.isEmpty ? null : active.first;
  }
}

/// Builds sales-channel readiness summaries from product catalog records.
List<ProductSalesChannelReadiness> buildProductSalesChannelReadiness(
  List<InventoryProductCatalogRecord> records, {
  List<ProductSalesChannelDefinition>? definitions,
}) {
  final resolvedDefinitions =
      definitions ?? defaultProductSalesChannelDefinitions;

  return [
    for (final definition in resolvedDefinitions)
      ProductSalesChannelReadiness(
        channel: definition.channel,
        title: definition.title,
        subtitle: definition.subtitle,
        readyCount: _count(records, definition.readyWhen),
        totalCount: records.length,
        reviewFilter: definition.reviewFilter,
        issues: [
          for (final issue in definition.issueDefinitions)
            ProductSalesChannelReadinessIssue(
              blocker: issue.blocker,
              label: issue.label,
              count: _count(records, issue.matches),
              reviewFilter: issue.reviewFilter,
              reviewQuery: issue.reviewQuery,
            ),
        ],
      ),
  ];
}

int _count(
  List<InventoryProductCatalogRecord> records,
  ProductSalesChannelRecordMatcher predicate,
) {
  return records.where(predicate).length;
}
