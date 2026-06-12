import 'sales_channel_readiness.dart';

enum ProductChannelLaunchPriorityLevel { blocked, improving, ready }

class ProductChannelLaunchPriority {
  const ProductChannelLaunchPriority({required this.readiness});

  final ProductSalesChannelReadiness readiness;

  ProductSalesChannelReadinessIssue? get primaryIssue => readiness.primaryIssue;

  int get issueCount => readiness.issueCount;

  bool get hasIssues => issueCount > 0;

  ProductChannelLaunchPriorityLevel get level {
    if (!hasIssues) return ProductChannelLaunchPriorityLevel.ready;
    if (readiness.readyPercent >= 50) {
      return ProductChannelLaunchPriorityLevel.improving;
    }

    return ProductChannelLaunchPriorityLevel.blocked;
  }

  String get statusLabel {
    switch (level) {
      case ProductChannelLaunchPriorityLevel.blocked:
        return 'Priority';
      case ProductChannelLaunchPriorityLevel.improving:
        return 'Improve';
      case ProductChannelLaunchPriorityLevel.ready:
        return 'Ready';
    }
  }

  String get actionLabel {
    final issue = primaryIssue;
    if (issue == null) return 'Review launch-ready catalog';

    return 'Fix ${issue.label}';
  }

  String get impactLabel {
    final issue = primaryIssue;
    if (issue == null) return readiness.countLabel;

    return '${issue.countLabel} first';
  }

  String get blockedProductLabel {
    if (issueCount == 0) return 'No blockers';
    if (issueCount == 1) return '1 product blocked';

    return '$issueCount products blocked';
  }
}

List<ProductChannelLaunchPriority> buildProductChannelLaunchPriorities(
  List<ProductSalesChannelReadiness> readiness, {
  int? limit,
}) {
  if (limit != null && limit <= 0) return const [];

  final priorities = [
    for (var index = 0; index < readiness.length; index += 1)
      _IndexedProductChannelLaunchPriority(
        index: index,
        priority: ProductChannelLaunchPriority(readiness: readiness[index]),
      ),
  ]..sort(_comparePriorities);

  final resolvedLimit = limit ?? priorities.length;

  return List.unmodifiable(
    priorities
        .take(resolvedLimit)
        .map((entry) => entry.priority)
        .toList(growable: false),
  );
}

int _comparePriorities(
  _IndexedProductChannelLaunchPriority left,
  _IndexedProductChannelLaunchPriority right,
) {
  final levelComparison = left.priority.level.index.compareTo(
    right.priority.level.index,
  );
  if (levelComparison != 0) return levelComparison;

  final issueComparison = right.priority.issueCount.compareTo(
    left.priority.issueCount,
  );
  if (issueComparison != 0) return issueComparison;

  final percentComparison = left.priority.readiness.readyPercent.compareTo(
    right.priority.readiness.readyPercent,
  );
  if (percentComparison != 0) return percentComparison;

  return left.index.compareTo(right.index);
}

class _IndexedProductChannelLaunchPriority {
  const _IndexedProductChannelLaunchPriority({
    required this.index,
    required this.priority,
  });

  final int index;
  final ProductChannelLaunchPriority priority;
}
