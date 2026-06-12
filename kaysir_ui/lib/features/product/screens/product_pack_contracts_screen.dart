import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/management_pack_readiness.dart';
import '../product_routes.dart';
import '../states/management_pack_contribution_bundle_provider.dart';
import '../states/management_pack_readiness_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/management_pack_contribution_panel.dart';
import '../widgets/management_pack_readiness_panel.dart';
import '../widgets/management_suite_screen.dart';

class ProductPackContractsScreen extends StatelessWidget {
  const ProductPackContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Pack Contracts',
      activeDestination: ProductManagementSuiteDestination.packContracts,
      modeControlConfig: const ProductManagementSuiteModeControlConfig(
        includePresets: false,
        includeChannelSelector: false,
      ),
      builder: (context, ref, suiteContext) {
        final contributionBundle = ref.watch(
          productManagementPackContributionBundleProvider,
        );
        final packReadiness = ref.watch(productManagementPackReadinessProvider);

        return [
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

void _openPackReadinessFocus(
  BuildContext context, {
  required ProductManagementPackReadiness readiness,
  required ProductManagementRouteMode routeMode,
}) {
  final focus = readiness.primarySection;
  final routePath =
      focus?.id == productManagementPackReadinessChannelSectionId
          ? ProductRoutes.channelReadinessPath
          : ProductRoutes.catalogPath;

  context.go(productRouteWithManagementMode(routePath, mode: routeMode));
}
