import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/models/product_workspace_action_summary.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_readiness.dart';
import 'package:kaysir/features/product/models/sales_channel_strategy_brief.dart';

void main() {
  test('workspace recommendation exposes normalized metadata', () {
    const recommendation = ProductWorkspaceRecommendation(
      id: ' coffee_menu_review ',
      title: 'Review coffee menu',
      subtitle: 'Check coffee menu launch data.',
      actionLabel: 'Open menu',
      statusLabel: 'Menu',
      priority: ProductWorkspaceRecommendationPriority.high,
      routePath: ' /products?review=Coffee ',
    );

    expect(recommendation.normalizedId, 'coffee_menu_review');
    expect(recommendation.hasTitle, isTrue);
    expect(recommendation.canNavigate, isTrue);
  });

  test('workspace recommendation contribution filters invalid outputs', () {
    final contribution = ProductWorkspaceRecommendationContribution(
      id: ' coffee_recommendations ',
      buildRecommendations:
          (context) => const [
            ProductWorkspaceRecommendation(
              id: ' ',
              title: 'Blank id',
              subtitle: 'Should be ignored.',
              actionLabel: 'Open blank',
              statusLabel: 'Invalid',
              priority: ProductWorkspaceRecommendationPriority.high,
            ),
            ProductWorkspaceRecommendation(
              id: 'coffee_blank_title',
              title: ' ',
              subtitle: 'Should be ignored.',
              actionLabel: 'Open blank title',
              statusLabel: 'Invalid',
              priority: ProductWorkspaceRecommendationPriority.high,
            ),
            ProductWorkspaceRecommendation(
              id: 'coffee_menu_review',
              title: 'Review coffee menu',
              subtitle: 'Check coffee menu launch data.',
              actionLabel: 'Open menu',
              statusLabel: 'Menu',
              priority: ProductWorkspaceRecommendationPriority.high,
            ),
          ],
    );

    final recommendations = contribution.recommendationsFor(_context);

    expect(contribution.normalizedId, 'coffee_recommendations');
    expect(contribution.isActiveFor(_context), isTrue);
    expect(recommendations.map((recommendation) => recommendation.id), [
      'coffee_menu_review',
    ]);
    expect(() => recommendations.clear(), throwsUnsupportedError);
  });

  test('workspace recommendation contribution suppresses inactive hooks', () {
    final contribution = ProductWorkspaceRecommendationContribution(
      id: 'coffee_recommendations',
      isActive: (context) => false,
      buildRecommendations:
          (context) => const [
            ProductWorkspaceRecommendation(
              id: 'coffee_menu_review',
              title: 'Review coffee menu',
              subtitle: 'Check coffee menu launch data.',
              actionLabel: 'Open menu',
              statusLabel: 'Menu',
              priority: ProductWorkspaceRecommendationPriority.high,
            ),
          ],
    );
    final blankContribution = ProductWorkspaceRecommendationContribution(
      id: ' ',
      buildRecommendations:
          (context) => const [
            ProductWorkspaceRecommendation(
              id: 'coffee_menu_review',
              title: 'Review coffee menu',
              subtitle: 'Check coffee menu launch data.',
              actionLabel: 'Open menu',
              statusLabel: 'Menu',
              priority: ProductWorkspaceRecommendationPriority.high,
            ),
          ],
    );

    expect(contribution.isActiveFor(_context), isFalse);
    expect(contribution.recommendationsFor(_context), isEmpty);
    expect(blankContribution.isActiveFor(_context), isFalse);
    expect(blankContribution.recommendationsFor(_context), isEmpty);
  });
}

final _context = ProductWorkspaceRecommendationContext(
  managementPack: coreProductManagementPack,
  summary: const InventoryProductCatalogSummary(
    productCount: 0,
    trackedProductCount: 0,
    inStockProductCount: 0,
    untrackedProductCount: 0,
    attentionProductCount: 0,
    totalQuantity: 0,
    totalInventoryValue: 0,
    categoryCount: 0,
  ),
  qualitySummary: const ProductCatalogQualitySummary(
    productCount: 0,
    completeProductCount: 0,
    issueProductCount: 0,
    totalIssueCount: 0,
    issues: [],
  ),
  actionSummary: const ProductWorkspaceActionSummary(
    groupCount: 0,
    actionCount: 0,
    enabledActionCount: 0,
    gatedActionCount: 0,
    readyGroupCount: 0,
    partialGroupCount: 0,
    gatedGroupCount: 0,
  ),
  strategyBrief: ProductSalesChannelStrategyBrief(
    profile: omniRetailProductSalesChannelProfile,
    summary: const ProductSalesChannelProfileReadinessSummary(
      channelCount: 0,
      readyChannelCount: 0,
      improvingChannelCount: 0,
      blockedChannelCount: 0,
      readyProductSlotCount: 0,
      totalProductSlotCount: 0,
      blockedProductSlotCount: 0,
      topPriority: null,
    ),
    readiness: const [],
    priorities: const [],
  ),
);
