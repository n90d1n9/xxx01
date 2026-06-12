import 'dart:math';

import 'product_catalog_quality.dart';
import 'management_pack_contribution_bundle.dart';
import 'sales_channel_profile_readiness.dart';
import 'product_workspace_action_summary.dart';

/// Highest launch-readiness level reached by a management pack assessment.
enum ProductManagementPackReadinessLevel { blocked, improving, ready }

/// One scored section in a product management pack readiness assessment.
class ProductManagementPackReadinessSection {
  const ProductManagementPackReadinessSection({
    required this.id,
    required this.title,
    required this.detailLabel,
    required this.scorePercent,
    required this.level,
  });

  final String id;
  final String title;
  final String detailLabel;
  final int scorePercent;
  final ProductManagementPackReadinessLevel level;

  String get statusLabel {
    switch (level) {
      case ProductManagementPackReadinessLevel.blocked:
        return 'Blocked';
      case ProductManagementPackReadinessLevel.improving:
        return 'Improving';
      case ProductManagementPackReadinessLevel.ready:
        return 'Ready';
    }
  }
}

/// Weighted readiness result for a product management pack and its extensions.
class ProductManagementPackReadiness {
  ProductManagementPackReadiness({
    required this.bundle,
    required List<ProductManagementPackReadinessSection> sections,
  }) : sections = List.unmodifiable(sections);

  final ProductManagementPackContributionBundle bundle;
  final List<ProductManagementPackReadinessSection> sections;

  int get scorePercent {
    if (sections.isEmpty) return 0;

    final weightedScore = sections.fold<double>(
      0,
      (score, section) => score + section.scorePercent * _weightFor(section.id),
    );
    final totalWeight = sections.fold<double>(
      0,
      (total, section) => total + _weightFor(section.id),
    );
    if (totalWeight == 0) return 0;

    return max(0, min(100, (weightedScore / totalWeight).round()));
  }

  ProductManagementPackReadinessLevel get level {
    if (scorePercent >= 85 &&
        sections.every((section) => section.scorePercent >= 70)) {
      return ProductManagementPackReadinessLevel.ready;
    }
    if (scorePercent >= 50) {
      return ProductManagementPackReadinessLevel.improving;
    }

    return ProductManagementPackReadinessLevel.blocked;
  }

  ProductManagementPackReadinessSection? get primarySection {
    if (sections.isEmpty) return null;

    final ranked =
        sections.toList()..sort((left, right) {
          final scoreRank = left.scorePercent.compareTo(right.scorePercent);
          if (scoreRank != 0) return scoreRank;

          return _weightFor(right.id).compareTo(_weightFor(left.id));
        });

    return ranked.first;
  }

  String get statusLabel {
    switch (level) {
      case ProductManagementPackReadinessLevel.blocked:
        return 'Blocked';
      case ProductManagementPackReadinessLevel.improving:
        return 'Improving';
      case ProductManagementPackReadinessLevel.ready:
        return 'Ready';
    }
  }

  String get scoreLabel => '$scorePercent% ready';

  String get titleLabel => '${bundle.managementPack.title} readiness';

  String get subtitleLabel {
    final focus = primarySection;
    if (focus == null) return bundle.managementPack.operatorFocusLabel;
    if (focus.level == ProductManagementPackReadinessLevel.ready) {
      return bundle.managementPack.operatorFocusLabel;
    }

    return '${focus.title}: ${focus.detailLabel}';
  }

  String get primaryActionLabel {
    final focus = primarySection;
    if (focus == null) return 'Review catalog';

    switch (focus.id) {
      case productManagementPackReadinessDataSectionId:
        return 'Review data';
      case productManagementPackReadinessChannelSectionId:
        return 'Review channels';
      case productManagementPackReadinessWorkflowSectionId:
        return 'Review workflows';
      case productManagementPackReadinessExtensionSectionId:
        return 'Review hooks';
    }

    return 'Review catalog';
  }
}

const productManagementPackReadinessDataSectionId = 'data_contract';
const productManagementPackReadinessChannelSectionId = 'channel_coverage';
const productManagementPackReadinessWorkflowSectionId = 'workflow_availability';
const productManagementPackReadinessExtensionSectionId = 'extension_hooks';

/// Builds pack readiness from catalog quality, channel, workflow, and hook signals.
ProductManagementPackReadiness buildProductManagementPackReadiness({
  required ProductManagementPackContributionBundle bundle,
  required ProductCatalogQualitySummary qualitySummary,
  required ProductSalesChannelProfileReadinessSummary profileReadinessSummary,
  required ProductWorkspaceActionSummary actionSummary,
}) {
  return ProductManagementPackReadiness(
    bundle: bundle,
    sections: [
      _dataSection(qualitySummary),
      _channelSection(profileReadinessSummary),
      _workflowSection(actionSummary),
      _extensionSection(bundle),
    ],
  );
}

ProductManagementPackReadinessSection _dataSection(
  ProductCatalogQualitySummary summary,
) {
  final score = summary.productCount == 0 ? 0 : summary.completePercent;
  final detail =
      summary.productCount == 0
          ? 'No catalog products yet'
          : summary.totalIssueCount == 0
          ? summary.completeCountLabel
          : '${summary.completeCountLabel}, ${summary.totalIssueCount} gaps';

  return ProductManagementPackReadinessSection(
    id: productManagementPackReadinessDataSectionId,
    title: 'Data contract',
    detailLabel: detail,
    scorePercent: score,
    level: _levelForScore(score),
  );
}

ProductManagementPackReadinessSection _channelSection(
  ProductSalesChannelProfileReadinessSummary summary,
) {
  final score = summary.totalProductSlotCount == 0 ? 0 : summary.launchPercent;
  final detail =
      summary.channelCount == 0
          ? 'No sales channels attached'
          : '${summary.channelLabel}, ${summary.blockerLabel}';

  return ProductManagementPackReadinessSection(
    id: productManagementPackReadinessChannelSectionId,
    title: 'Channel coverage',
    detailLabel: detail,
    scorePercent: score,
    level: _levelForScore(score),
  );
}

ProductManagementPackReadinessSection _workflowSection(
  ProductWorkspaceActionSummary summary,
) {
  final score =
      summary.hasActions
          ? ((summary.enabledActionCount / summary.actionCount) * 100).round()
          : 0;

  return ProductManagementPackReadinessSection(
    id: productManagementPackReadinessWorkflowSectionId,
    title: 'Workflow availability',
    detailLabel: summary.readinessTooltip,
    scorePercent: score,
    level: _levelForScore(score),
  );
}

ProductManagementPackReadinessSection _extensionSection(
  ProductManagementPackContributionBundle bundle,
) {
  final active = bundle.activeModuleContributions;
  final score =
      active.isEmpty
          ? 100
          : ((active.where((item) => item.outputCount > 0).length /
                      active.length) *
                  100)
              .round();
  final detail =
      active.isEmpty
          ? 'No active extension hooks required'
          : '${active.where((item) => item.outputCount > 0).length}/'
              '${active.length} active hooks producing output';

  return ProductManagementPackReadinessSection(
    id: productManagementPackReadinessExtensionSectionId,
    title: 'Extension hooks',
    detailLabel: detail,
    scorePercent: score,
    level: _levelForScore(score),
  );
}

ProductManagementPackReadinessLevel _levelForScore(int score) {
  if (score >= 85) return ProductManagementPackReadinessLevel.ready;
  if (score >= 50) return ProductManagementPackReadinessLevel.improving;

  return ProductManagementPackReadinessLevel.blocked;
}

double _weightFor(String sectionId) {
  switch (sectionId) {
    case productManagementPackReadinessDataSectionId:
      return 0.35;
    case productManagementPackReadinessChannelSectionId:
      return 0.30;
    case productManagementPackReadinessWorkflowSectionId:
      return 0.20;
    case productManagementPackReadinessExtensionSectionId:
      return 0.15;
  }

  return 0;
}
