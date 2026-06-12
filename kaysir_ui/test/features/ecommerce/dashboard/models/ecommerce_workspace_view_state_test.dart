import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_strategy.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/destination.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/health.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/registry_diagnostics.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/view_state.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';

void main() {
  test('ViewState exposes screen-level flags', () {
    final overview = _overview();
    final state = ViewState(
      productProfile: ProductProfile.standard,
      channelStrategy: ChannelStrategy.fromProfile(ProductProfile.standard),
      overview: overview,
      health: HealthSummary.fromWorkspace(
        overview: overview,
        moduleIssues: const [
          ModuleIssue(
            type: ModuleIssueType.blankModuleId,
            message: 'Blank module id',
          ),
        ],
      ),
      destinations: const [
        Destination(
          id: 'orders',
          title: 'Orders',
          subtitle: 'Open orders.',
          routePath: '/commerce/orders',
          metricLabel: 'Orders',
          metricValue: '0',
          actionLabel: 'Open',
          icon: Icons.receipt_long_outlined,
          tone: DestinationTone.secondary,
        ),
      ],
      actions: const [
        Action(
          id: 'open_orders',
          title: 'Open orders',
          description: 'Review orders.',
          actionLabel: 'Open orders',
          routePath: '/commerce/orders',
          icon: Icons.receipt_long_outlined,
          tone: ActionTone.secondary,
          priority: 1,
        ),
      ],
      registryDiagnostics: RegistryDiagnostics.fromIssues(
        moduleIssues: const [
          ModuleIssue(
            type: ModuleIssueType.blankModuleId,
            message: 'Blank module id',
          ),
        ],
        actionRuleIssues: const [],
      ),
    );

    expect(state.hasDestinations, isTrue);
    expect(state.hasChannelStrategy, isTrue);
    expect(state.hasPriorityActions, isTrue);
    expect(state.hasRegistryIssues, isTrue);
    expect(state.productProfile.id, 'standard');
    expect(state.health.moduleIssueCount, 1);
    expect(state.primaryOrderRoutePath, Routes.ordersPath);
  });

  test('primaryOrderRoutePath prefers specialized destination routes', () {
    final overview = _overview();
    final state = ViewState(
      productProfile: ProductProfile.standard,
      channelStrategy: ChannelStrategy.fromProfile(ProductProfile.standard),
      overview: overview,
      health: HealthSummary.fromWorkspace(
        overview: overview,
        moduleIssues: const [],
      ),
      destinations: const [
        Destination(
          id: 'orders',
          title: 'Orders',
          subtitle: 'Open orders.',
          routePath: Routes.ordersPath,
          metricLabel: 'Orders',
          metricValue: '0',
          actionLabel: 'Open',
          icon: Icons.receipt_long_outlined,
          tone: DestinationTone.secondary,
        ),
        Destination(
          id: 'marketplace_queue',
          title: 'Marketplace queue',
          subtitle: 'Open marketplace orders.',
          routePath: Routes.marketplaceOrdersPath,
          metricLabel: 'Orders',
          metricValue: '0',
          actionLabel: 'Open',
          icon: Icons.storefront_outlined,
          tone: DestinationTone.secondary,
        ),
      ],
      actions: const [],
      registryDiagnostics: RegistryDiagnostics.fromIssues(
        moduleIssues: const [],
        actionRuleIssues: const [],
      ),
    );

    expect(state.primaryOrderRoutePath, Routes.marketplaceOrdersPath);
  });

  test('primaryOrderRoutePath prefers explicit product order profile', () {
    final overview = _overview();
    final profile = ProductProfile.standard.copyWith(
      preferredOrderWorkspaceProfileId:
          ecommerceWholesaleOrderWorkspaceProfile.id,
    );
    final state = ViewState(
      productProfile: profile,
      channelStrategy: ChannelStrategy.fromProfile(profile),
      overview: overview,
      health: HealthSummary.fromWorkspace(
        overview: overview,
        moduleIssues: const [],
      ),
      destinations: const [
        Destination(
          id: 'marketplace_queue',
          title: 'Marketplace queue',
          subtitle: 'Open marketplace orders.',
          routePath: Routes.marketplaceOrdersPath,
          metricLabel: 'Orders',
          metricValue: '0',
          actionLabel: 'Open',
          icon: Icons.storefront_outlined,
          tone: DestinationTone.secondary,
        ),
      ],
      actions: const [],
      registryDiagnostics: RegistryDiagnostics.fromIssues(
        moduleIssues: const [],
        actionRuleIssues: const [],
      ),
    );

    expect(state.primaryOrderRoutePath, Routes.wholesaleOrdersPath);
    expect(
      Uri.parse(state.primaryOrderLaunchLocation).path,
      Routes.wholesaleOrdersPath,
    );
    expect(
      Uri.parse(
        state.primaryOrderLaunchLocation,
      ).queryParameters['source_profile_label'],
      'Standard commerce',
    );
    expect(
      Uri.parse(
        state.primaryOrderLaunchLocation,
      ).queryParameters['workspace_view_id'],
      'wholesale_all',
    );
  });

  test('primaryOrderRoutePath falls back to product profile capabilities', () {
    final overview = _overview();
    final profile = ProductProfile.standard.copyWith(
      id: 'delivery_only',
      label: 'Delivery only',
      capabilities: const [ProductCapability.pickupDelivery],
    );
    final state = ViewState(
      productProfile: profile,
      channelStrategy: ChannelStrategy.fromProfile(profile),
      overview: overview,
      health: HealthSummary.fromWorkspace(
        overview: overview,
        moduleIssues: const [],
      ),
      destinations: const [],
      actions: const [],
      registryDiagnostics: RegistryDiagnostics.fromIssues(
        moduleIssues: const [],
        actionRuleIssues: const [],
      ),
    );

    expect(state.primaryOrderRoutePath, Routes.deliveryOrdersPath);
  });
}

Overview _overview() {
  return const Overview(
    orderInsights: OrderInsights.empty,
    cartLineCount: 0,
    cartUnitCount: 0,
    cartTotal: 0,
    promisePolicyIssueCount: 0,
  );
}
