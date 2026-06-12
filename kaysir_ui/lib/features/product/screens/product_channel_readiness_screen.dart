import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_channel_launch_priority.dart';
import '../models/sales_channel_readiness.dart';
import '../product_routes.dart';
import '../utils/product_catalog_review_target.dart';
import '../utils/management_route_mode.dart';
import '../widgets/product_channel_launch_priority_panel.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/sales_channel_readiness_panel.dart';
import '../widgets/sales_channel_strategy_brief_panel.dart';

class ProductChannelReadinessScreen extends StatelessWidget {
  const ProductChannelReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Channel Readiness',
      activeDestination: ProductManagementSuiteDestination.channelReadiness,
      modeControlConfig: const ProductManagementSuiteModeControlConfig(
        includePackSelector: false,
        includePresets: false,
        includeProfilePackOverview: false,
      ),
      builder: (context, ref, suiteContext) {
        final overview = suiteContext.overview;

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
          ProductChannelLaunchPriorityPanel(
            priorities: overview.launchPriorities,
            onSelected:
                (priority) => _openLaunchPriority(
                  context,
                  priority: priority,
                  routeMode: suiteContext.routeMode,
                ),
          ),
          ProductSalesChannelReadinessPanel(
            readiness: overview.channelReadiness,
            onSelected:
                (readiness) => _openChannelReadiness(
                  context,
                  readiness: readiness,
                  routeMode: suiteContext.routeMode,
                ),
            onIssueSelected:
                (readiness, issue) => _openChannelReadinessIssue(
                  context,
                  readiness: readiness,
                  issue: issue,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
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

void _openChannelReadiness(
  BuildContext context, {
  required ProductSalesChannelReadiness readiness,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForChannelReadiness(readiness),
      mode: routeMode,
    ),
  );
}

void _openChannelReadinessIssue(
  BuildContext context, {
  required ProductSalesChannelReadiness readiness,
  required ProductSalesChannelReadinessIssue issue,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForChannelReadinessIssue(
        issue,
        title: readiness.title,
      ),
      mode: routeMode,
    ),
  );
}
