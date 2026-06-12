import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_channel_launch_priority.dart';
import '../models/experience_profile_launch_target.dart';
import '../models/experience_profile_readiness.dart';
import '../models/management_pack_readiness.dart';
import '../product_routes.dart';
import '../states/edition_provider.dart';
import '../states/edition_readiness_provider.dart';
import '../states/experience_profile_readiness_provider.dart';
import '../states/management_pack_contribution_bundle_provider.dart';
import '../states/management_pack_readiness_provider.dart';
import '../utils/product_catalog_review_target.dart';
import '../utils/management_route_mode.dart';
import '../widgets/edition_launcher_panel.dart';
import '../widgets/experience_profile_readiness_panel.dart';
import '../widgets/management_pack_contribution_panel.dart';
import '../widgets/management_pack_readiness_panel.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/sales_channel_strategy_brief_panel.dart';

class ProductStrategyScreen extends StatelessWidget {
  const ProductStrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Product Strategy',
      activeDestination: ProductManagementSuiteDestination.strategy,
      builder: (context, ref, suiteContext) {
        final overview = suiteContext.overview;
        final contributionBundle = ref.watch(
          productManagementPackContributionBundleProvider,
        );
        final packReadiness = ref.watch(productManagementPackReadinessProvider);
        final profileReadiness = ref.watch(
          productExperienceProfileReadinessProvider,
        );
        final editions = ref.watch(productEditionsProvider);
        final editionReadiness = ref.watch(productEditionReadinessProvider);
        final experienceProfileRegistry = ref.watch(
          productExperienceProfileRegistryProvider,
        );

        return [
          ProductSalesChannelStrategyBriefPanel(
            brief: overview.strategyBrief,
            onPrioritySelected:
                (priority) => _openLaunchPriority(
                  context,
                  priority: priority,
                  routeMode: suiteContext.routeMode,
                ),
          ),
          ProductEditionLauncherPanel(
            editions: editions,
            experienceProfileRegistry: experienceProfileRegistry,
            readiness: editionReadiness,
            onEditionSelected:
                (edition, launchTarget) => context.go(launchTarget.uri),
          ),
          ProductExperienceProfileReadinessPanel(
            readiness: profileReadiness,
            onProfileSelected:
                (profile) => _openExperienceProfile(
                  context,
                  readiness: profile,
                  routeMode: suiteContext.routeMode,
                ),
            onReviewProfiles:
                () => context.go(
                  productRouteWithManagementMode(
                    ProductRoutes.packContractsPath,
                    mode: suiteContext.routeMode,
                  ),
                ),
          ),
          ProductManagementPackReadinessPanel(
            readiness: packReadiness,
            onPrimaryAction:
                () => _openPackReadinessFocus(
                  context,
                  readiness: packReadiness,
                  routeMode: suiteContext.routeMode,
                ),
          ),
          ProductManagementPackContributionPanel(bundle: contributionBundle),
        ];
      },
    );
  }
}

void _openExperienceProfile(
  BuildContext context, {
  required ProductExperienceProfileReadiness readiness,
  required ProductManagementRouteMode routeMode,
}) {
  final launchTarget = ProductExperienceProfileLaunchTarget.forProfile(
    readiness.profile,
    fallbackPackId: routeMode.packId,
    fallbackChannelProfileId: routeMode.channelProfileId,
  );

  context.go(launchTarget.uri);
}

void _openLaunchPriority(
  BuildContext context, {
  required ProductChannelLaunchPriority priority,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(
        ProductCatalogReviewTarget.fromReadiness(priority.readiness),
      ),
      mode: routeMode,
    ),
  );
}

void _openPackReadinessFocus(
  BuildContext context, {
  required ProductManagementPackReadiness readiness,
  required ProductManagementRouteMode routeMode,
}) {
  final focus = readiness.primarySection;
  if (focus?.id == productManagementPackReadinessChannelSectionId) {
    context.go(
      productRouteWithManagementMode(
        ProductRoutes.channelReadinessPath,
        mode: routeMode,
      ),
    );
    return;
  }

  context.go(
    productRouteWithManagementMode(ProductRoutes.catalogPath, mode: routeMode),
  );
}
