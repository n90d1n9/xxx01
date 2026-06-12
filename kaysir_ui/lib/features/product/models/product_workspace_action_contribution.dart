import '../../inventory/models/inventory_product_catalog.dart';
import '../product_routes.dart';
import 'management_pack.dart';
import 'product_workspace_action_group.dart';
import 'product_workspace_setup_readiness_contribution.dart';
import 'product_workspace_setup_target.dart';
import 'product_workspace_shortcut.dart';
import 'product_workspace_shortcut_intent.dart';

/// Predicate that decides whether a contribution applies to a management pack.
typedef ProductWorkspaceActionContributionPredicate =
    bool Function(ProductManagementPack pack);

/// Builds workspace action groups for the active pack and catalog summary.
typedef ProductWorkspaceActionGroupBuilder =
    List<ProductWorkspaceActionGroup> Function(
      ProductManagementPack pack,
      InventoryProductCatalogSummary summary,
    );

/// Extension hook for product modules to add workspace actions and setup work.
class ProductWorkspaceActionContribution {
  const ProductWorkspaceActionContribution({
    required this.id,
    required this.isActive,
    required this.buildGroups,
    this.setupTargets = const [],
    this.setupReadinessContributions = const [],
  });

  final String id;
  final ProductWorkspaceActionContributionPredicate isActive;
  final ProductWorkspaceActionGroupBuilder buildGroups;
  final List<ProductWorkspaceSetupTarget> setupTargets;
  final List<ProductWorkspaceSetupReadinessContribution>
  setupReadinessContributions;

  String get normalizedId => id.trim();

  bool get hasSetupTargets {
    return setupTargets.any((target) => target.normalizedId.isNotEmpty);
  }

  bool get hasSetupReadinessContributions {
    return setupReadinessContributions.any(
      (contribution) => contribution.id.trim().isNotEmpty,
    );
  }

  bool isActiveFor(ProductManagementPack pack) {
    return normalizedId.isNotEmpty && isActive(pack);
  }

  List<ProductWorkspaceActionGroup> groupsFor(
    ProductManagementPack pack,
    InventoryProductCatalogSummary summary,
  ) {
    if (!isActiveFor(pack)) return const [];

    return List.unmodifiable(
      buildGroups(pack, summary).where((group) => group.hasShortcuts),
    );
  }

  List<ProductWorkspaceSetupTarget> setupTargetsFor(
    ProductManagementPack pack,
  ) {
    if (!isActiveFor(pack)) return const [];

    return List.unmodifiable(
      setupTargets.where((target) => target.normalizedId.isNotEmpty),
    );
  }

  List<ProductWorkspaceSetupReadinessContribution>
  setupReadinessContributionsFor(ProductManagementPack pack) {
    if (!isActiveFor(pack)) return const [];

    return List.unmodifiable(
      setupReadinessContributions.where(
        (contribution) => contribution.id.trim().isNotEmpty,
      ),
    );
  }
}

const productWorkspaceFreshnessContributionId = 'freshness_queue';

const freshnessProductWorkspaceActionContribution =
    ProductWorkspaceActionContribution(
      id: productWorkspaceFreshnessContributionId,
      isActive: _supportsFreshnessQueue,
      setupTargets: [ProductWorkspaceSetupTarget.freshness],
      buildGroups: _buildFreshnessQueueGroups,
    );

const defaultProductWorkspaceActionContributions = [
  freshnessProductWorkspaceActionContribution,
];

bool _supportsFreshnessQueue(ProductManagementPack pack) {
  return pack.hasCapability(ProductManagementCapability.freshnessQueue);
}

List<ProductWorkspaceActionGroup> _buildFreshnessQueueGroups(
  ProductManagementPack pack,
  InventoryProductCatalogSummary summary,
) {
  return [
    ProductWorkspaceActionGroup(
      id: productWorkspaceFreshnessActionGroupId,
      title: 'Freshness control',
      subtitle: 'Track expiry, batch, and freshness-sensitive workflows',
      shortcuts: [
        ProductWorkspaceShortcut(
          id: ProductWorkspaceShortcutId.freshnessQueue,
          title: 'Freshness Queue',
          subtitle: 'Prioritize expiry, batch, and pull-from-shelf work',
          status: 'Pack setup',
          setupIntent: ProductWorkspaceShortcutIntent.route(
            ProductRoutes.workspaceSetupUri(
              ProductWorkspaceSetupTarget.freshness,
            ),
          ),
          isEnabled: false,
          disabledReason: 'Connect a freshness workflow route to enable',
        ),
      ],
    ),
  ];
}
