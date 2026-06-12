import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/experience_profile.dart';
import '../models/product_workspace_action_contribution.dart';
import '../models/product_workspace_action_registry.dart';
import 'management_pack_provider.dart';
import 'product_module_contribution_manifest_provider.dart';

final productWorkspaceActionContributionsProvider =
    Provider<List<ProductWorkspaceActionContribution>>((ref) {
      return ref
          .watch(productModuleContributionRegistryProvider)
          .actionContributions;
    });

final productWorkspaceActionRegistryProvider =
    Provider<ProductWorkspaceActionRegistry>((ref) {
      final managementPack = ref.watch(productManagementPackProvider);
      return ProductWorkspaceActionRegistry(
        pack: managementPack,
        contributions: ref.watch(productWorkspaceActionContributionsProvider),
        experienceProfile: productExperienceProfileForManagementPackId(
          managementPack.id,
        ),
      );
    });
