import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

import '../models/management_pack.dart';
import '../models/management_module_brief.dart';
import '../models/product_workspace_overview.dart';
import '../product_routes.dart';
import '../states/management_pack_provider.dart';
import '../states/management_module_brief_provider.dart';
import '../states/product_workspace_overview_provider.dart';
import '../utils/management_route_mode.dart';
import 'experience_profile_scope.dart';
import 'management_mode_control_stack.dart';
import 'management_suite_command_strip.dart';
import 'management_suite_header.dart';
import 'management_suite_module_brief.dart';
import 'management_suite_navigation.dart';

export 'management_suite_navigation.dart'
    show
        ProductManagementSuiteDestination,
        ProductManagementSuiteNavigationSection,
        ProductManagementSuiteNavigationProfile,
        productManagementFullSuiteNavigationProfile,
        productManagementCatalogOperationsNavigationProfile,
        productManagementFreshGoodsNavigationProfile,
        productManagementCommercialNavigationProfile,
        productManagementSetupContractsNavigationProfile,
        productManagementSuiteNavigationProfiles,
        productManagementSuiteNavigationProfileForDestination,
        productManagementSuiteNavigationProfileForExperienceProfile,
        productManagementSuiteNavigationSections;

typedef ProductManagementSuiteScreenBuilder =
    List<Widget> Function(
      BuildContext context,
      WidgetRef ref,
      ProductManagementSuiteScreenContext suiteContext,
    );

/// Shared product management state exposed to suite screen builders.
class ProductManagementSuiteScreenContext {
  const ProductManagementSuiteScreenContext({
    required this.overview,
    required this.managementPack,
    required this.routeMode,
  });

  final ProductWorkspaceOverview overview;
  final ProductManagementPack managementPack;
  final ProductManagementRouteMode routeMode;
}

/// Configuration for reusable product mode controls inside suite screens.
class ProductManagementSuiteModeControlConfig {
  const ProductManagementSuiteModeControlConfig({
    this.includeStatus = true,
    this.includePackSelector = true,
    this.includePresets = true,
    this.includeChannelSelector = true,
    this.includeProfilePackOverview = true,
    this.spacing = 16,
  });

  static const full = ProductManagementSuiteModeControlConfig();

  static const focused = ProductManagementSuiteModeControlConfig(
    includePresets: false,
    includeProfilePackOverview: false,
  );

  final bool includeStatus;
  final bool includePackSelector;
  final bool includePresets;
  final bool includeChannelSelector;
  final bool includeProfilePackOverview;
  final double spacing;

  Widget build() {
    return ProductManagementModeControlStack(
      includeStatus: includeStatus,
      includePackSelector: includePackSelector,
      includePresets: includePresets,
      includeChannelSelector: includeChannelSelector,
      includeProfilePackOverview: includeProfilePackOverview,
      spacing: spacing,
    );
  }
}

/// Shared shell for standalone product management modules.
class ProductManagementSuiteScreen extends ConsumerWidget {
  const ProductManagementSuiteScreen({
    super.key,
    required this.title,
    required this.activeDestination,
    required this.builder,
    this.modeControlConfig = ProductManagementSuiteModeControlConfig.full,
    this.moduleBriefRegistry,
    this.navigationProfile,
    this.navigationSections,
    this.padding = const EdgeInsets.all(20),
    this.sectionSpacing = 20,
  });

  final String title;
  final ProductManagementSuiteDestination activeDestination;
  final ProductManagementSuiteScreenBuilder builder;
  final ProductManagementSuiteModeControlConfig? modeControlConfig;
  final ProductManagementModuleBriefRegistry? moduleBriefRegistry;
  final ProductManagementSuiteNavigationProfile? navigationProfile;
  final List<ProductManagementSuiteNavigationSection>? navigationSections;
  final EdgeInsetsGeometry padding;
  final double sectionSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(productWorkspaceOverviewProvider);
    final managementPack = ref.watch(productManagementPackProvider);
    final routeMode = productManagementRouteModeFor(
      pack: managementPack,
      channelProfile: overview.channelProfile,
    );
    final suiteContext = ProductManagementSuiteScreenContext(
      overview: overview,
      managementPack: managementPack,
      routeMode: routeMode,
    );
    final scopedExperienceProfile = ProductExperienceProfileScope.maybeOf(
      context,
    );
    final resolvedNavigationProfile =
        navigationProfile ??
        (scopedExperienceProfile == null
            ? productManagementSuiteNavigationProfileForDestination(
              activeDestination,
            )
            : productManagementSuiteNavigationProfileForExperienceProfile(
              scopedExperienceProfile,
              activeDestination: activeDestination,
            ));
    final resolvedNavigationSections =
        navigationSections ?? resolvedNavigationProfile.sections;
    final activeNavigationItem = productManagementSuiteNavigationItemFor(
      activeDestination,
      sections: resolvedNavigationSections,
    );
    final activeNavigationSection = productManagementSuiteNavigationSectionFor(
      activeDestination,
      sections: resolvedNavigationSections,
    );
    final workspaceRoute = ProductRoutes.workspaceUri(
      experience: scopedExperienceProfile?.id.value ?? '',
      pack: routeMode.packId,
      profile: routeMode.channelProfileId,
    );
    final catalogRoute = productRouteWithManagementMode(
      ProductRoutes.catalogPath,
      mode: routeMode,
    );
    final addProductRoute = productRouteWithManagementMode(
      ProductRoutes.addProductPath,
      mode: routeMode,
    );
    final ProductManagementModuleBriefRegistry resolvedModuleBriefRegistry =
        moduleBriefRegistry ??
        ref.watch(productManagementModuleBriefRegistryProvider);
    final moduleBriefAction = resolvedModuleBriefRegistry.resolve(
      activeDestination: activeDestination,
      overview: overview,
    );
    final moduleBriefActionRoute = productRouteWithManagementMode(
      moduleBriefAction.routePath ??
          productManagementSuiteDestinationRoute(
            moduleBriefAction.destination,
            mode: routeMode,
          ),
      mode: routeMode,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: AppListSurface(
        padding: padding,
        sectionSpacing: sectionSpacing,
        header: ProductManagementSuiteHeader(
          title: title,
          activeItem: activeNavigationItem,
          activeSection: activeNavigationSection,
          navigationProfile: resolvedNavigationProfile,
          managementPack: managementPack,
          channelProfile: overview.channelProfile,
          experienceProfile: scopedExperienceProfile,
        ),
        children: [
          ProductManagementSuiteCommandStrip(
            onOpenWorkspace: () => context.go(workspaceRoute),
            onOpenCatalog: () => context.go(catalogRoute),
            onAddProduct: () => context.go(addProductRoute),
          ),
          ProductManagementSuiteModuleBrief(
            activeItem: activeNavigationItem,
            overview: overview,
            action: moduleBriefAction,
            onActionPressed: () => context.go(moduleBriefActionRoute),
          ),
          ProductManagementSuiteNavigation(
            activeDestination: activeDestination,
            sections: resolvedNavigationSections,
            onSelected:
                (destination) => context.go(
                  productManagementSuiteDestinationRoute(
                    destination,
                    mode: routeMode,
                  ),
                ),
          ),
          if (modeControlConfig case final config?) config.build(),
          ...builder(context, ref, suiteContext),
        ],
      ),
    );
  }
}
