import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_module_contribution_manifest.dart';
import '../utils/default_product_module_contribution_manifests.dart';
import 'product_line_module_provider.dart';

final productModuleContributionManifestsProvider =
    Provider<List<ProductModuleContributionManifest>>((ref) {
      return [
        ...defaultCoreProductModuleContributionManifests,
        ...ref.watch(productLineModuleContributionManifestsProvider),
      ];
    });

final productModuleContributionRegistryProvider =
    Provider<ProductModuleContributionRegistry>((ref) {
      return ProductModuleContributionRegistry.fromManifests(
        ref.watch(productModuleContributionManifestsProvider),
      );
    });
