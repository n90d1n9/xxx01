import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/management_pack_readiness.dart';
import 'management_pack_contribution_bundle_provider.dart';
import 'product_workspace_overview_provider.dart';

/// Readiness provider for the selected product management pack.
final productManagementPackReadinessProvider =
    Provider<ProductManagementPackReadiness>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductManagementPackReadiness(
        bundle: ref.watch(productManagementPackContributionBundleProvider),
        qualitySummary: overview.qualitySummary,
        profileReadinessSummary: overview.profileReadinessSummary,
        actionSummary: overview.actionSummary,
      );
    });
