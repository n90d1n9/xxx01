import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_workspace_setup_action.dart';
import '../states/management_pack_provider.dart';
import '../states/management_workspace_preferences_controller.dart';
import '../states/sales_channel_definition_provider.dart';
import '../states/product_workspace_setup_target_provider.dart';
import '../utils/management_route_mode.dart';
import '../utils/workspace_setup_action_flow.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/workspace_setup_overview_panel.dart';

/// Suite screen for reviewing and opening product workspace setup targets.
class ProductSetupTargetsScreen extends ConsumerStatefulWidget {
  const ProductSetupTargetsScreen({super.key});

  @override
  ConsumerState<ProductSetupTargetsScreen> createState() =>
      _ProductSetupTargetsScreenState();
}

class _ProductSetupTargetsScreenState
    extends ConsumerState<ProductSetupTargetsScreen> {
  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Setup Targets',
      activeDestination: ProductManagementSuiteDestination.setupTargets,
      modeControlConfig: const ProductManagementSuiteModeControlConfig(
        includePresets: false,
        includeChannelSelector: false,
        includeProfilePackOverview: false,
      ),
      builder: (context, ref, suiteContext) {
        final setupOverview = ref.watch(productWorkspaceSetupOverviewProvider);

        return [
          ProductWorkspaceSetupOverviewPanel(
            overview: setupOverview,
            onActionSelected: (prompt) => _openSetupAction(prompt.action),
          ),
        ];
      },
    );
  }

  void _openSetupAction(ProductWorkspaceSetupAction action) {
    unawaited(
      openProductWorkspaceSetupAction(
        context: context,
        action: action,
        routeMode: _activeRouteMode(),
        selectPack:
            (packId) => ref
                .read(productManagementWorkspacePreferencesControllerProvider)
                .selectPack(packId),
      ),
    );
  }

  ProductManagementRouteMode _activeRouteMode() {
    return productManagementRouteModeFor(
      pack: ref.read(productManagementPackProvider),
      channelProfile: ref.read(productSalesChannelProfileProvider),
    );
  }
}
