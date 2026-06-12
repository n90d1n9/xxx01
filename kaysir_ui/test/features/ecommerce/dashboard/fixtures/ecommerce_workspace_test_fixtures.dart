import 'package:flutter/material.dart' hide Action;
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

const testRenewalsRoute = '/commerce/renewals';

const testOverview = Overview(
  orderInsights: OrderInsights.empty,
  cartLineCount: 0,
  cartUnitCount: 0,
  cartTotal: 0,
  promisePolicyIssueCount: 0,
);

const testRenewalsAction = Action(
  id: 'renewals',
  title: 'Review renewals',
  description: 'Subscription renewals are ready to confirm.',
  actionLabel: 'Open renewals',
  routePath: testRenewalsRoute,
  icon: Icons.autorenew_outlined,
  tone: ActionTone.secondary,
  priority: 1,
);

const testActions = [testRenewalsAction];

ViewState testWorkspace({
  ProductProfile? productProfile,
  Overview overview = testOverview,
  ChannelStrategy? channelStrategy,
  HealthSummary? health,
  Iterable<Destination>? destinations,
  Iterable<Module>? modules,
  Iterable<Action>? actions,
  RegistryDiagnostics? registryDiagnostics,
  Iterable<ProductProfileIssue> productProfileIssues = const [],
  Iterable<ModuleIssue> moduleIssues = const [],
  Iterable<ActionRuleIssue> actionRuleIssues = const [],
  int channelCoverageGapCount = 0,
}) {
  final resolvedProfile = productProfile ?? ProductProfile.standard;
  final resolvedModules = modules ?? resolvedProfile.modules;
  final resolvedHealth =
      health ??
      HealthSummary.fromWorkspace(
        overview: overview,
        productProfileIssues: productProfileIssues,
        moduleIssues: moduleIssues,
        actionRuleIssues: actionRuleIssues,
        channelCoverageGapCount: channelCoverageGapCount,
      );

  return ViewState(
    productProfile: resolvedProfile,
    channelStrategy:
        channelStrategy ?? ChannelStrategy.fromProfile(resolvedProfile),
    overview: overview,
    health: resolvedHealth,
    destinations:
        destinations?.toList(growable: false) ??
        destinationsForModules(
          overview: overview,
          modules: resolvedModules,
          capabilities: resolvedProfile.capabilities,
        ),
    actions: actions?.toList(growable: false) ?? testActions,
    registryDiagnostics:
        registryDiagnostics ??
        RegistryDiagnostics.fromIssues(
          productProfileIssues: productProfileIssues,
          moduleIssues: moduleIssues,
          actionRuleIssues: actionRuleIssues,
        ),
  );
}
