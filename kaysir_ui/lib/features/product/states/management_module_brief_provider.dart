import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/management_module_brief.dart';
import 'management_pack_provider.dart';
import 'product_module_contribution_manifest_provider.dart';

/// Active module brief resolvers contributed by the selected management pack.
final productManagementModuleBriefResolversProvider =
    Provider<List<ProductManagementModuleBriefResolver>>((ref) {
      final managementPack = ref.watch(productManagementPackProvider);
      final contributionRegistry = ref.watch(
        productModuleContributionRegistryProvider,
      );

      return contributionRegistry.moduleBriefResolversFor(managementPack);
    });

/// Registry provider for product management module brief action resolvers.
final productManagementModuleBriefRegistryProvider =
    Provider<ProductManagementModuleBriefRegistry>((ref) {
      return defaultProductManagementModuleBriefRegistry.mergedWith(
        ref.watch(productManagementModuleBriefResolversProvider),
      );
    });
