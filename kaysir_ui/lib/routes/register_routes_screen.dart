import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/ecommerce/dashboard/profile_registry_screen.dart';
import 'package:kaysir/features/ecommerce/dashboard/screen.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_route.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_query_state.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_route_resolution.dart';
import 'package:kaysir/features/ecommerce/order/order_screen.dart'
    as ecommerce_orders;
import 'package:kaysir/features/ecommerce/order/pos_screen.dart'
    as ecommerce_pos;
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_center_query_state.dart';
import 'package:kaysir/features/omni_channel/activity/screens/omni_channel_activity_center_screen.dart';
import 'package:kaysir/features/project_management/project/project_management_routes.dart';
import 'package:ky_website_builder/ky_website_builder.dart';
import 'package:ky_ppt/ky_ppt.dart';

import '../app/screens/auth/login.dart';
import '../features/dashboard/screens/dashboard_main.dart';
import '../features/layout_builder/screens/layout_screen.dart';
import '../features/point_of_sales/cashier/screens/pos_screen.dart';
import '../core/features/feature_routes.dart';

List<FeatureRoutes> registerScreens() => [
  FeatureRoutes(
    name: 'Dashboard',
    title: 'Dashboard',
    subtitle: 'Workspace dashboards',
    description:
        'Dashboard hub for business pulse, portfolio dashboards, planning dashboards, and focused detail workspaces.',
    icon: 'dashboard',
    path: '/dashboard',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return MaterialPage(child: DashboardMainScreen());
    },
    items: ProjectManagementRoutes.dashboardItems(),
  ),
  FeatureRoutes(
    name: 'Login',
    path: '/login',
    position: const [MenuPosition.account],
    screenType: ScreenType.singlePage,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return MaterialPage(child: LoginScreen());
    },
  ),
  // Point of Sales (PoS)
  FeatureRoutes(
    name: 'Cashier',
    path: '/cashier',
    screenType: ScreenType.singlePage,
    pageBuilder:
        (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: POSScreen()),
  ),

  FeatureRoutes(
    name: 'Commerce',
    title: 'Commerce Workspace',
    subtitle: 'Omnichannel command',
    description:
        ' hub for online sales, marketplace operations, checkout, orders, fulfillment, and promise policy review.',
    icon: 'commerce',
    path: Routes.routePath,
    pageBuilder:
        (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: Screen()),
    items: [
      FeatureRoutes(
        name: 'Commerce Profiles',
        title: 'Commerce Profiles',
        subtitle: 'Product profile registry',
        description:
            'Reusable ecommerce and POS product profile presets for channels, checkout behavior, fulfillment rules, layout strategy, search keywords, and playbooks.',
        icon: 'commerce-profiles',
        path: Routes.profileRegistryPath,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                const MaterialPage(child: ProfileRegistryScreen()),
      ),
      FeatureRoutes(
        name: 'Omni-channel Activity',
        title: 'Omni-channel Activity',
        subtitle: 'POS and ecommerce events',
        description:
            'Shared activity center for order, sync, fulfillment, payment, and channel switch events.',
        icon: 'sync_alt',
        position: const [MenuPosition.sidebar],
        path: OmniChannelActivityCenterScreen.routePath,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final queryState =
              OmniChannelActivityCenterQueryState.fromQueryParameters(
                state.uri.queryParameters,
              );

          return MaterialPage(
            child: OmniChannelActivityCenterScreen(
              initialQueryState: queryState,
              onOpenLocation: (location) => context.go(location),
            ),
          );
        },
      ),
      FeatureRoutes(
        name: ' POS',
        title: ' POS',
        subtitle: 'Storefront checkout',
        description:
            'Online, marketplace, mobile, and remote selling checkout workspace.',
        icon: 'ecommerce-pos',
        path: Routes.checkoutPath,
        pageBuilder:
            (BuildContext context, GoRouterState state) =>
                const MaterialPage(child: ecommerce_pos.PosScreen()),
      ),
      FeatureRoutes(
        name: ecommerceAllCommerceOrderWorkspaceRoute.name,
        title: ecommerceAllCommerceOrderWorkspaceRoute.title,
        subtitle: ecommerceAllCommerceOrderWorkspaceRoute.subtitle,
        description: ecommerceAllCommerceOrderWorkspaceRoute.description,
        icon: ecommerceAllCommerceOrderWorkspaceRoute.icon,
        path: ecommerceAllCommerceOrderWorkspaceRoute.path,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final launchContext = OrderWorkspaceLaunchContext.fromQueryParameters(
            state.uri.queryParameters,
          );
          final routeResolution =
              ecommerceOrderWorkspaceRouteResolutionForLaunch(
                path: state.uri.path,
                launchContext: launchContext,
              );
          final workspaceQueryState =
              OrderWorkspaceQueryState.fromQueryParameters(
                state.uri.queryParameters,
              );

          return MaterialPage(
            child: ecommerce_orders.OrdersScreen(
              profile: routeResolution.route.profile,
              launchContext: launchContext,
              workspaceQueryState: workspaceQueryState,
              routeResolution: routeResolution,
              onOpenLocation: (location) => context.go(location),
              onOpenCanonicalRoute: (location) => context.go(location),
            ),
          );
        },
        items: ecommerceSpecializedOrderWorkspaceRouteDefinitions
            .map(
              (route) => FeatureRoutes(
                name: route.name,
                title: route.title,
                subtitle: route.subtitle,
                description: route.description,
                icon: route.icon,
                path: route.path,
                pageBuilder: (BuildContext context, GoRouterState state) {
                  final launchContext =
                      OrderWorkspaceLaunchContext.fromQueryParameters(
                        state.uri.queryParameters,
                      );
                  final routeResolution =
                      ecommerceOrderWorkspaceRouteResolutionForLaunch(
                        path: state.uri.path,
                        launchContext: launchContext,
                      );
                  final workspaceQueryState =
                      OrderWorkspaceQueryState.fromQueryParameters(
                        state.uri.queryParameters,
                      );

                  return MaterialPage(
                    child: ecommerce_orders.OrdersScreen(
                      profile: routeResolution.route.profile,
                      launchContext: launchContext,
                      workspaceQueryState: workspaceQueryState,
                      routeResolution: routeResolution,
                      onOpenLocation: (location) => context.go(location),
                      onOpenCanonicalRoute: (location) => context.go(location),
                    ),
                  );
                },
              ),
            )
            .toList(growable: false),
      ),
    ],
  ),

  FeatureRoutes(
    name: 'Layout Builder',
    title: 'Layout Builder',
    subtitle: 'POS layout canvas',
    description:
        'Build and tune reusable Kaysir POS layouts with grid, tabular column, and auto-grid rules.',
    icon: 'layout-builder',
    path: LayoutCustomizerScreen.routePath,
    pageBuilder:
        (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: LayoutCustomizerScreen()),
  ),

  FeatureRoutes(
    name: 'Website Builder',
    title: 'Website Builder',
    subtitle: 'Web page canvas',
    description:
        'Compose website pages with reusable sections, media blocks, commerce cards, shared canvas rules, and JSON export.',
    icon: 'website-builder',
    path: '/website-builder',
    pageBuilder:
        (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: WebsiteBuilderScreen()),
  ),

  FeatureRoutes(
    name: 'Presentation Editor',
    title: 'Presentation Editor',
    subtitle: 'Slide deck canvas',
    description:
        'Build, edit, import, export, and present slide decks with a modern Office-style presentation workspace.',
    icon: 'presentation-editor',
    path: '/presentation-editor',
    pageBuilder:
        (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: PresentationEditor()),
  ),

  ProjectManagementRoutes.menu(),
];
