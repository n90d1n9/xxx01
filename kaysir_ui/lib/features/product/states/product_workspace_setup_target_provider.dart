import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_workspace_setup_action.dart';
import '../models/product_workspace_setup_overview.dart';
import '../models/product_workspace_setup_target.dart';
import 'management_pack_provider.dart';
import 'product_workspace_action_provider.dart';
import 'product_workspace_overview_provider.dart';
import 'product_workspace_setup_readiness_provider.dart';

final productWorkspaceSetupTargetsProvider =
    Provider<List<ProductWorkspaceSetupTarget>>((ref) {
      final contributionTargets = [
        for (final contribution in ref.watch(
          productWorkspaceActionContributionsProvider,
        ))
          ...contribution.setupTargets,
      ];

      return _mergeSetupTargets([
        ...ProductWorkspaceSetupTarget.builtInTargets,
        ...contributionTargets,
      ]);
    });

final productWorkspaceActiveSetupTargetsProvider =
    Provider<List<ProductWorkspaceSetupTarget>>((ref) {
      final managementPack = ref.watch(productManagementPackProvider);
      final contributionTargets = [
        for (final contribution in ref.watch(
          productWorkspaceActionContributionsProvider,
        ))
          ...contribution.setupTargetsFor(managementPack),
      ];

      return _mergeSetupTargets(contributionTargets);
    });

final productWorkspaceSetupTargetRegistryProvider =
    Provider<ProductWorkspaceSetupTargetRegistry>((ref) {
      return ProductWorkspaceSetupTargetRegistry(
        ref.watch(productWorkspaceSetupTargetsProvider),
        activeTargetIds:
            ref
                .watch(productWorkspaceActiveSetupTargetsProvider)
                .map((target) => target.normalizedId)
                .where((id) => id.isNotEmpty)
                .toSet(),
        tracksAvailability: true,
      );
    });

final productWorkspaceSetupActivationsProvider =
    Provider<List<ProductWorkspaceSetupActivation>>((ref) {
      final contributions = ref.watch(
        productWorkspaceActionContributionsProvider,
      );
      final activations = <ProductWorkspaceSetupActivation>[];
      final seenKeys = <String>{};

      for (final pack in ref.watch(productManagementPackOptionsProvider)) {
        for (final contribution in contributions) {
          for (final target in contribution.setupTargetsFor(pack)) {
            final targetId = target.normalizedId;
            if (targetId.isEmpty) continue;

            final key = '$targetId:${pack.id.value}';
            if (seenKeys.contains(key)) continue;

            seenKeys.add(key);
            activations.add(
              ProductWorkspaceSetupActivation(
                targetId: targetId,
                packId: pack.id,
                packTitle: pack.title,
                packFocusLabel: pack.operatorFocusLabel,
              ),
            );
          }
        }
      }

      return List.unmodifiable(activations);
    });

final productWorkspaceSetupActionResolverProvider =
    Provider<ProductWorkspaceSetupActionResolver>((ref) {
      return ProductWorkspaceSetupActionResolver(
        recommendations:
            ref.watch(productWorkspaceOverviewProvider).recommendations,
        activations: ref.watch(productWorkspaceSetupActivationsProvider),
      );
    });

final productWorkspaceSetupOverviewProvider =
    Provider<ProductWorkspaceSetupOverview>((ref) {
      final registry = ref.watch(productWorkspaceSetupTargetRegistryProvider);
      final resolver = ref.watch(productWorkspaceSetupActionResolverProvider);
      final prompts = <ProductWorkspaceSetupPrompt>[];

      for (final target in ref.watch(productWorkspaceSetupTargetsProvider)) {
        final resolution = registry.resolveWithAvailability(
          target.normalizedId,
        );
        if (resolution == null) continue;

        prompts.add(resolver.promptForResolution(resolution));
      }

      return ProductWorkspaceSetupOverview.fromPrompts(
        prompts,
        readinessRegistry: ref.watch(
          productWorkspaceSetupReadinessEvaluatorRegistryProvider,
        ),
      );
    });

List<ProductWorkspaceSetupTarget> _mergeSetupTargets(
  List<ProductWorkspaceSetupTarget> targets,
) {
  final seenIds = <String>{};
  final merged = <ProductWorkspaceSetupTarget>[];

  for (final target in targets) {
    final normalizedId = target.normalizedId;
    if (normalizedId.isEmpty || seenIds.contains(normalizedId)) continue;

    seenIds.add(normalizedId);
    merged.add(target);
  }

  return List.unmodifiable(merged);
}
