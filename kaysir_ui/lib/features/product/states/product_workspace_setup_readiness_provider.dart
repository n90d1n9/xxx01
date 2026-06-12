import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_workspace_setup_readiness_contribution.dart';
import '../models/product_workspace_setup_readiness.dart';
import '../utils/product_workspace_setup_readiness_evaluators.dart';
import 'management_pack_provider.dart';
import 'product_module_contribution_manifest_provider.dart';
import 'product_workspace_action_provider.dart';
import 'product_workspace_overview_provider.dart';

final productWorkspaceSetupReadinessContributionBundleProvider =
    Provider<ProductWorkspaceSetupReadinessContributionBundle>((ref) {
      final managementPack = ref.watch(productManagementPackProvider);
      final contributionReadiness = [
        for (final contribution in ref.watch(
          productWorkspaceActionContributionsProvider,
        ))
          ...contribution.setupReadinessContributionsFor(managementPack),
      ];

      return ProductWorkspaceSetupReadinessContributionBundle(
        contributions: [
          ...ref
              .watch(productModuleContributionRegistryProvider)
              .setupReadinessContributions,
          ...contributionReadiness,
        ],
      );
    });

final productWorkspaceSetupReadinessContributionsProvider =
    Provider<List<ProductWorkspaceSetupReadinessContribution>>((ref) {
      return ref
          .watch(productWorkspaceSetupReadinessContributionBundleProvider)
          .contributions;
    });

final productWorkspaceSetupReadinessEvaluatorRegistryProvider =
    Provider<ProductWorkspaceSetupReadinessEvaluatorRegistry>((ref) {
      return buildProductWorkspaceSetupReadinessEvaluatorRegistry(
        records: ref.watch(productWorkspaceOverviewProvider).records,
        contributions: ref.watch(
          productWorkspaceSetupReadinessContributionsProvider,
        ),
      );
    });
