import '../../inventory/models/inventory_product_catalog.dart';
import 'experience_profile.dart';
import 'management_pack.dart';
import 'product_module_destination.dart';
import 'product_workspace_action_contribution.dart';
import 'product_workspace_action_group.dart';

class ProductWorkspaceActionRegistry {
  ProductWorkspaceActionRegistry({
    required this.pack,
    List<ProductWorkspaceActionContribution>? contributions,
    ProductExperienceProfile? experienceProfile,
    ProductModuleDestinationRegistry destinationRegistry =
        defaultProductModuleDestinationRegistry,
    List<ProductModuleDestination>? destinations,
    bool? includeAttentionReview,
  }) : contributions = List.unmodifiable(
         contributions ?? defaultProductWorkspaceActionContributions,
       ),
       destinations = List.unmodifiable(
         destinations ??
             experienceProfile?.destinationsIn(destinationRegistry) ??
             destinationRegistry.destinations,
       ),
       includeAttentionReview =
           includeAttentionReview ??
           experienceProfile?.includeAttentionReviewShortcut ??
           true;

  final ProductManagementPack pack;
  final List<ProductWorkspaceActionContribution> contributions;
  final List<ProductModuleDestination> destinations;
  final bool includeAttentionReview;

  List<ProductWorkspaceActionGroup> groupsFor(
    InventoryProductCatalogSummary summary,
  ) {
    return _mergeGroups([
      ...buildProductWorkspaceActionGroups(
        summary,
        destinations: destinations,
        includeAttentionReview: includeAttentionReview,
      ),
      for (final contribution in contributions)
        ...contribution.groupsFor(pack, summary),
    ]);
  }
}

List<ProductWorkspaceActionGroup> _mergeGroups(
  List<ProductWorkspaceActionGroup> groups,
) {
  final order = <String>[];
  final merged = <String, ProductWorkspaceActionGroup>{};

  for (final group in groups) {
    if (!group.hasShortcuts) continue;

    final existing = merged[group.id];
    if (existing == null) {
      order.add(group.id);
      merged[group.id] = group;
      continue;
    }

    merged[group.id] = ProductWorkspaceActionGroup(
      id: existing.id,
      title: existing.title,
      subtitle: existing.subtitle,
      shortcuts: [...existing.shortcuts, ...group.shortcuts],
    );
  }

  return List.unmodifiable([
    for (final id in productWorkspaceDefaultActionGroupOrder)
      if (merged.containsKey(id)) merged[id]!,
    for (final id in order)
      if (!productWorkspaceDefaultActionGroupOrder.contains(id)) merged[id]!,
  ]);
}
