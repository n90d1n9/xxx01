import 'product_channel_launch_priority.dart';
import 'sales_channel_profile_readiness.dart';
import 'sales_channel_readiness.dart';

/// Operator-facing sales-channel strategy summary for the active profile.
class ProductSalesChannelStrategyBrief {
  const ProductSalesChannelStrategyBrief({
    required this.profile,
    required this.summary,
    required this.readiness,
    required this.priorities,
  });

  final ProductSalesChannelProfile profile;
  final ProductSalesChannelProfileReadinessSummary summary;
  final List<ProductSalesChannelReadiness> readiness;
  final List<ProductChannelLaunchPriority> priorities;

  ProductChannelLaunchPriority? get primaryPriority {
    if (priorities.isEmpty) return null;

    return priorities.first;
  }

  String get titleLabel => '${profile.title} strategy';

  String get businessModelLabel => profile.behavior.businessModelLabel;

  String get profileFocusLabel => profile.behavior.operatorFocusLabel;

  List<String> get capabilityLabels => profile.behavior.capabilityLabels;

  String get capabilitySummaryLabel {
    return profile.behavior.capabilitySummaryLabel;
  }

  String get channelCountLabel {
    final count = readiness.length;
    if (count == 1) return '1 channel';

    return '$count channels';
  }

  String get channelMixLabel {
    if (readiness.isEmpty) return 'No channels enabled';
    if (readiness.length == 1) return readiness.single.title;
    if (readiness.length <= 3) {
      return readiness.map((item) => item.title).join(', ');
    }

    return '${readiness.first.title}, ${readiness[1].title} + '
        '${readiness.length - 2} more';
  }

  String get readinessLabel => summary.channelLabel;

  String get coverageLabel => summary.coverageLabel;

  String get gapLabel => summary.blockerLabel;

  String get nextQueueLabel {
    final priority = primaryPriority;
    if (priority == null) return 'No launch queue';
    if (!priority.hasIssues) return 'Launch-ready catalog';

    return '${priority.readiness.title} queue';
  }

  String get nextActionLabel {
    final priority = primaryPriority;
    if (priority == null) return 'Configure channel definitions';
    if (!priority.hasIssues) return 'Review launch-ready products';

    return '${priority.readiness.title}: ${priority.actionLabel}';
  }

  String get actionButtonLabel {
    final priority = primaryPriority;
    if (priority == null) return 'Open catalog';
    if (!priority.hasIssues) return 'Review catalog';

    return 'Review ${priority.readiness.title}';
  }

  String get operatorCueLabel {
    if (readiness.isEmpty) {
      return 'No channel modules are attached to this profile yet.';
    }

    switch (summary.level) {
      case ProductSalesChannelProfileReadinessLevel.blocked:
        return 'Unlock the first ready channel before launch.';
      case ProductSalesChannelProfileReadinessLevel.improving:
        return 'Clear the top queue to expand product coverage.';
      case ProductSalesChannelProfileReadinessLevel.ready:
        return 'Profile is launch-ready across $channelCountLabel.';
    }
  }
}

/// Builds a channel strategy brief from readiness and launch priorities.
ProductSalesChannelStrategyBrief buildProductSalesChannelStrategyBrief({
  required ProductSalesChannelProfile profile,
  required List<ProductSalesChannelReadiness> readiness,
  ProductSalesChannelProfileReadinessSummary? summary,
  List<ProductChannelLaunchPriority>? priorities,
}) {
  final resolvedSummary =
      summary ?? summarizeProductSalesChannelProfileReadiness(readiness);
  final resolvedPriorities =
      priorities ?? buildProductChannelLaunchPriorities(readiness);

  return ProductSalesChannelStrategyBrief(
    profile: profile,
    summary: resolvedSummary,
    readiness: List.unmodifiable(readiness),
    priorities: List.unmodifiable(resolvedPriorities),
  );
}
