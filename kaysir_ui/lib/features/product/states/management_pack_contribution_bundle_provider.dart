import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/management_pack_contribution_bundle.dart';
import 'management_pack_provider.dart';
import 'product_module_contribution_manifest_provider.dart';
import 'product_workspace_action_provider.dart';
import 'product_workspace_overview_provider.dart';
import 'product_workspace_recommendation_provider.dart';
import 'product_workspace_setup_readiness_provider.dart';

/// Builds the contribution bundle for the active product management pack.
final productManagementPackContributionBundleProvider =
    Provider<ProductManagementPackContributionBundle>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductManagementPackContributionBundle(
        managementPack: ref.watch(productManagementPackProvider),
        summary: overview.summary,
        qualitySummary: overview.qualitySummary,
        actionSummary: overview.actionSummary,
        strategyBrief: overview.strategyBrief,
        workspaceActionGroups: overview.actionGroups,
        primaryLaunchPriority: overview.primaryLaunchPriority,
        actionContributions: ref.watch(
          productWorkspaceActionContributionsProvider,
        ),
        setupReadinessContributionBundle: ref.watch(
          productWorkspaceSetupReadinessContributionBundleProvider,
        ),
        recommendationContributions: ref.watch(
          productWorkspaceRecommendationContributionsProvider,
        ),
        moduleContributionRegistry: ref.watch(
          productModuleContributionRegistryProvider,
        ),
      );
    });
