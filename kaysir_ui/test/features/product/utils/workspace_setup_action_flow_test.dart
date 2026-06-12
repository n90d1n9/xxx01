import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/states/management_workspace_preferences_controller.dart';
import 'package:kaysir/features/product/utils/management_route_mode.dart';
import 'package:kaysir/features/product/utils/workspace_setup_action_flow.dart';

void main() {
  testWidgets('setup action routes preserve active management mode', (
    tester,
  ) async {
    var selectedPackCount = 0;
    const routeMode = ProductManagementRouteMode(
      packId: ProductManagementPackId.groceryFreshGoods,
      channelProfileId: groceryFreshGoodsProfileId,
    );
    const action = ProductWorkspaceSetupAction(
      targetId: productWorkspaceFreshnessSetupTargetId,
      label: 'Review freshness data',
      routePath: ProductRoutes.catalogPath,
      source: ProductWorkspaceSetupActionSource.fallback,
    );
    final router = _setupActionRouter(
      action: action,
      routeMode: routeMode,
      selectPack: (packId) async {
        selectedPackCount += 1;

        return ProductManagementWorkspaceSelection(
          pack: groceryFreshGoodsProductManagementPack,
          channelProfile: groceryFreshGoodsProductSalesChannelProfile,
        );
      },
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open setup action'));
    await tester.pumpAndSettle();

    final uri = router.routerDelegate.currentConfiguration.uri;
    expect(uri.path, ProductRoutes.catalogPath);
    expect(
      uri.queryParameters[ProductRoutes.catalogPackQueryKey],
      productManagementPackQueryValue(
        ProductManagementPackId.groceryFreshGoods,
      ),
    );
    expect(
      uri.queryParameters[ProductRoutes.catalogProfileQueryKey],
      productSalesChannelProfileQueryValue(groceryFreshGoodsProfileId),
    );
    expect(selectedPackCount, 0);
    expect(find.text('Catalog route reached'), findsOneWidget);
  });

  testWidgets('setup action activation selects pack and shows feedback', (
    tester,
  ) async {
    ProductManagementPackId? selectedPackId;
    const routeMode = ProductManagementRouteMode(
      packId: ProductManagementPackId.coreCatalog,
      channelProfileId: ProductSalesChannelProfileId.omniRetail,
    );
    const action = ProductWorkspaceSetupAction(
      targetId: productWorkspaceFreshnessSetupTargetId,
      label: 'Switch to Grocery Fresh Goods',
      routePath: ProductRoutes.workspacePath,
      source: ProductWorkspaceSetupActionSource.inactiveTarget,
      activation: ProductWorkspaceSetupActivation(
        targetId: productWorkspaceFreshnessSetupTargetId,
        packId: ProductManagementPackId.groceryFreshGoods,
        packTitle: 'Grocery Fresh Goods',
      ),
    );
    final router = _setupActionRouter(
      action: action,
      routeMode: routeMode,
      selectPack: (packId) async {
        selectedPackId = packId;

        return ProductManagementWorkspaceSelection(
          pack: groceryFreshGoodsProductManagementPack,
          channelProfile: groceryFreshGoodsProductSalesChannelProfile,
        );
      },
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open setup action'));
    await tester.pumpAndSettle();

    expect(selectedPackId, ProductManagementPackId.groceryFreshGoods);
    expect(
      find.text('Grocery Fresh Goods activated for setup.'),
      findsOneWidget,
    );
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
  });
}

GoRouter _setupActionRouter({
  required ProductWorkspaceSetupAction action,
  required ProductManagementRouteMode routeMode,
  required ProductWorkspaceSetupPackSelector selectPack,
}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => _SetupActionFlowHarness(
              action: action,
              routeMode: routeMode,
              selectPack: selectPack,
            ),
      ),
      GoRoute(
        path: ProductRoutes.catalogPath,
        builder:
            (context, state) => const Scaffold(
              body: Center(child: Text('Catalog route reached')),
            ),
      ),
    ],
  );
}

/// Minimal widget harness for exercising setup-action flow callbacks.
class _SetupActionFlowHarness extends StatelessWidget {
  const _SetupActionFlowHarness({
    required this.action,
    required this.routeMode,
    required this.selectPack,
  });

  final ProductWorkspaceSetupAction action;
  final ProductManagementRouteMode routeMode;
  final ProductWorkspaceSetupPackSelector selectPack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            unawaited(
              openProductWorkspaceSetupAction(
                context: context,
                action: action,
                routeMode: routeMode,
                selectPack: selectPack,
              ),
            );
          },
          child: const Text('Open setup action'),
        ),
      ),
    );
  }
}
