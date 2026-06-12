import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_line_module_definition.dart';
import '../models/product_line_module_registry.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_workspace_setup_target.dart';
import '../utils/default_product_line_module_manifests.dart';
import 'management_pack_provider.dart';

/// Product-line definitions available to this product management workspace.
final productLineModuleDefinitionsProvider =
    Provider<List<ProductLineModuleDefinition>>((ref) {
      return defaultProductLineModuleDefinitions;
    });

/// Registry that resolves product-line definitions and generated manifests.
final productLineModuleRegistryProvider = Provider<ProductLineModuleRegistry>((
  ref,
) {
  return ProductLineModuleRegistry(
    definitions: ref.watch(productLineModuleDefinitionsProvider),
  );
});

/// Generated contribution manifests for all registered product-line modules.
final productLineModuleContributionManifestsProvider =
    Provider<List<ProductModuleContributionManifest>>((ref) {
      return ref.watch(productLineModuleRegistryProvider).manifests;
    });

/// Product-line definitions active for the currently selected management pack.
final activeProductLineModuleDefinitionsProvider =
    Provider<List<ProductLineModuleDefinition>>((ref) {
      return ref
          .watch(productLineModuleRegistryProvider)
          .activeDefinitionsFor(ref.watch(productManagementPackProvider));
    });

/// Setup targets contributed by active product-line modules.
final activeProductLineModuleSetupTargetsProvider =
    Provider<List<ProductWorkspaceSetupTarget>>((ref) {
      return ref
          .watch(productLineModuleRegistryProvider)
          .setupTargetsFor(ref.watch(productManagementPackProvider));
    });
