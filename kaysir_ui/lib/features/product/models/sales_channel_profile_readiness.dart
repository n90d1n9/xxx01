import '../../inventory/models/inventory_product_catalog.dart';
import 'product_channel_launch_priority.dart';
import 'sales_channel_readiness.dart';

/// Highest readiness state reached across a sales-channel profile.
enum ProductSalesChannelProfileReadinessLevel { blocked, improving, ready }

/// Aggregated readiness metrics for one sales-channel profile.
class ProductSalesChannelProfileReadinessSummary {
  const ProductSalesChannelProfileReadinessSummary({
    required this.channelCount,
    required this.readyChannelCount,
    required this.improvingChannelCount,
    required this.blockedChannelCount,
    required this.readyProductSlotCount,
    required this.totalProductSlotCount,
    required this.blockedProductSlotCount,
    required this.topPriority,
  });

  final int channelCount;
  final int readyChannelCount;
  final int improvingChannelCount;
  final int blockedChannelCount;
  final int readyProductSlotCount;
  final int totalProductSlotCount;
  final int blockedProductSlotCount;
  final ProductChannelLaunchPriority? topPriority;

  int get launchPercent {
    if (totalProductSlotCount == 0) return 0;

    return ((readyProductSlotCount / totalProductSlotCount) * 100).round();
  }

  ProductSalesChannelProfileReadinessLevel get level {
    if (channelCount == 0 || readyChannelCount == channelCount) {
      return ProductSalesChannelProfileReadinessLevel.ready;
    }
    if (blockedChannelCount == channelCount) {
      return ProductSalesChannelProfileReadinessLevel.blocked;
    }

    return ProductSalesChannelProfileReadinessLevel.improving;
  }

  String get statusLabel {
    switch (level) {
      case ProductSalesChannelProfileReadinessLevel.blocked:
        return 'Blocked';
      case ProductSalesChannelProfileReadinessLevel.improving:
        return 'Improving';
      case ProductSalesChannelProfileReadinessLevel.ready:
        return 'Ready';
    }
  }

  String get channelLabel {
    if (channelCount == 1) return '$readyChannelCount/1 channel ready';

    return '$readyChannelCount/$channelCount channels ready';
  }

  String get coverageLabel => '$launchPercent% product coverage';

  String get blockerLabel {
    if (blockedProductSlotCount == 0) return 'No channel blockers';
    if (blockedProductSlotCount == 1) return '1 product-channel gap';

    return '$blockedProductSlotCount product-channel gaps';
  }

  String get nextActionLabel {
    final priority = topPriority;
    if (priority == null) return 'No channels configured';
    if (!priority.hasIssues) return 'Launch-ready profile';

    return '${priority.readiness.title}: ${priority.actionLabel}';
  }
}

/// Comparable profile option used when switching sales-channel strategies.
class ProductSalesChannelProfileReadinessOption {
  const ProductSalesChannelProfileReadinessOption({
    required this.profile,
    required this.summary,
    required this.isSelected,
    required this.isRecommended,
    this.coverageDelta = 0,
    this.blockerDelta = 0,
    this.readyChannelDelta = 0,
  });

  final ProductSalesChannelProfile profile;
  final ProductSalesChannelProfileReadinessSummary summary;
  final bool isSelected;
  final bool isRecommended;
  final int coverageDelta;
  final int blockerDelta;
  final int readyChannelDelta;

  bool get canSelect => !isSelected;

  String get statusLabel {
    if (isSelected) return 'Active';
    if (isRecommended) return 'Recommended';

    return summary.statusLabel;
  }

  String get titleLabel => '${profile.title} profile';

  String get detailLabel {
    return '${summary.coverageLabel} | ${summary.channelLabel}';
  }

  String get switchImpactLabel {
    if (isSelected) return 'Active baseline';

    return '${_signedPercentLabel('Coverage', coverageDelta)} | '
        '${_signedCountLabel('Gaps', blockerDelta)}';
  }

  String get readyChannelDeltaLabel {
    if (isSelected) return 'Current channels';

    return _signedCountLabel('Ready channels', readyChannelDelta);
  }

  String get actionLabel {
    if (isSelected) return 'Current strategy';
    if (isRecommended) return 'Best fit for this catalog';

    return summary.nextActionLabel;
  }
}

/// Summarizes channel readiness into one profile-level health result.
ProductSalesChannelProfileReadinessSummary
summarizeProductSalesChannelProfileReadiness(
  List<ProductSalesChannelReadiness> readiness,
) {
  var readyChannelCount = 0;
  var improvingChannelCount = 0;
  var blockedChannelCount = 0;
  var readyProductSlotCount = 0;
  var totalProductSlotCount = 0;
  var blockedProductSlotCount = 0;

  for (final item in readiness) {
    final priority = ProductChannelLaunchPriority(readiness: item);
    switch (priority.level) {
      case ProductChannelLaunchPriorityLevel.ready:
        readyChannelCount += 1;
      case ProductChannelLaunchPriorityLevel.improving:
        improvingChannelCount += 1;
      case ProductChannelLaunchPriorityLevel.blocked:
        blockedChannelCount += 1;
    }

    readyProductSlotCount += item.readyCount;
    totalProductSlotCount += item.totalCount;
    blockedProductSlotCount += item.issueCount;
  }

  final priorities = buildProductChannelLaunchPriorities(readiness, limit: 1);

  return ProductSalesChannelProfileReadinessSummary(
    channelCount: readiness.length,
    readyChannelCount: readyChannelCount,
    improvingChannelCount: improvingChannelCount,
    blockedChannelCount: blockedChannelCount,
    readyProductSlotCount: readyProductSlotCount,
    totalProductSlotCount: totalProductSlotCount,
    blockedProductSlotCount: blockedProductSlotCount,
    topPriority: priorities.isEmpty ? null : priorities.first,
  );
}

/// Builds selectable profile readiness options from catalog records.
List<ProductSalesChannelProfileReadinessOption>
buildProductSalesChannelProfileReadinessOptions(
  List<InventoryProductCatalogRecord> records, {
  required List<ProductSalesChannelProfile> profiles,
  required ProductSalesChannelProfileId selectedProfileId,
}) {
  if (profiles.isEmpty) return const [];

  final entries = [
    for (var index = 0; index < profiles.length; index += 1)
      _IndexedProductSalesChannelProfileReadinessSummary(
        index: index,
        profile: profiles[index],
        summary: summarizeProductSalesChannelProfileReadiness(
          buildProductSalesChannelReadiness(
            records,
            definitions: profiles[index].definitions,
          ),
        ),
      ),
  ];
  final recommendedProfileId = _recommendedProfileId(entries);
  final selectedEntry = entries.firstWhere(
    (entry) => entry.profile.id == selectedProfileId,
    orElse: () => entries.first,
  );

  return List.unmodifiable([
    for (final entry in entries)
      ProductSalesChannelProfileReadinessOption(
        profile: entry.profile,
        summary: entry.summary,
        isSelected: entry.profile.id == selectedProfileId,
        isRecommended: entry.profile.id == recommendedProfileId,
        coverageDelta:
            entry.summary.launchPercent - selectedEntry.summary.launchPercent,
        blockerDelta:
            entry.summary.blockedProductSlotCount -
            selectedEntry.summary.blockedProductSlotCount,
        readyChannelDelta:
            entry.summary.readyChannelCount -
            selectedEntry.summary.readyChannelCount,
      ),
  ]);
}

/// Finds the readiness option for a specific sales-channel profile.
ProductSalesChannelProfileReadinessOption?
productSalesChannelProfileReadinessOptionFor(
  List<ProductSalesChannelProfileReadinessOption> options,
  ProductSalesChannelProfileId profileId,
) {
  for (final option in options) {
    if (option.profile.id == profileId) return option;
  }

  return null;
}

String _signedPercentLabel(String label, int value) {
  if (value == 0) return '$label same';
  if (value > 0) return '$label +$value%';

  return '$label $value%';
}

String _signedCountLabel(String label, int value) {
  if (value == 0) return '$label same';
  if (value > 0) return '$label +$value';

  return '$label $value';
}

ProductSalesChannelProfileId? _recommendedProfileId(
  List<_IndexedProductSalesChannelProfileReadinessSummary> entries,
) {
  if (entries.isEmpty) return null;

  final ranked = entries.toList()..sort(_compareProfileReadiness);

  return ranked.first.profile.id;
}

int _compareProfileReadiness(
  _IndexedProductSalesChannelProfileReadinessSummary left,
  _IndexedProductSalesChannelProfileReadinessSummary right,
) {
  final coverageComparison = right.summary.launchPercent.compareTo(
    left.summary.launchPercent,
  );
  if (coverageComparison != 0) return coverageComparison;

  final blockerComparison = left.summary.blockedProductSlotCount.compareTo(
    right.summary.blockedProductSlotCount,
  );
  if (blockerComparison != 0) return blockerComparison;

  final readyChannelComparison = right.summary.readyChannelCount.compareTo(
    left.summary.readyChannelCount,
  );
  if (readyChannelComparison != 0) return readyChannelComparison;

  return left.index.compareTo(right.index);
}

class _IndexedProductSalesChannelProfileReadinessSummary {
  const _IndexedProductSalesChannelProfileReadinessSummary({
    required this.index,
    required this.profile,
    required this.summary,
  });

  final int index;
  final ProductSalesChannelProfile profile;
  final ProductSalesChannelProfileReadinessSummary summary;
}
