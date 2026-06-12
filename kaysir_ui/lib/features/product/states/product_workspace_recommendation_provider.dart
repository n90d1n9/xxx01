import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_workspace_recommendation.dart';
import 'product_module_contribution_manifest_provider.dart';

final productWorkspaceRecommendationContributionsProvider =
    Provider<List<ProductWorkspaceRecommendationContribution>>((ref) {
      return ref
          .watch(productModuleContributionRegistryProvider)
          .recommendationContributions;
    });
