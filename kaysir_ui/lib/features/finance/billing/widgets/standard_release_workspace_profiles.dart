import 'package:flutter/material.dart';

import '../states/billing_diagnostics_release_context_provider.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_navigation_destination.dart';
import 'billing_release_workspace_action.dart';
import 'billing_release_workspace_domain_focus.dart';
import 'billing_release_workspace_profile.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';

const billingReleaseWorkspaceCommerceProfileId = 'commerce';
const billingReleaseWorkspaceConstructionProfileId = 'construction';
const billingReleaseWorkspaceSubscriptionProfileId = 'subscription';
const billingReleaseWorkspaceConstructionFocusDeckId =
    'billing-release-workspace.construction-focus.deck';
const billingReleaseWorkspaceSubscriptionFocusDeckId =
    'billing-release-workspace.subscription-focus.deck';
const billingReleaseWorkspaceConstructionFocusSavedViewId =
    'construction-focus';
const billingReleaseWorkspaceSubscriptionFocusSavedViewId =
    'subscription-focus';

const billingReleaseWorkspaceConstructionFocusSavedView =
    BillingReleaseWorkspaceSavedView(
      id: billingReleaseWorkspaceConstructionFocusSavedViewId,
      label: 'Construction focus',
      description: 'Milestone, progress claim, and route readiness',
      deckIds: {billingReleaseWorkspaceConstructionFocusDeckId},
      icon: Icons.engineering_outlined,
      accentColor: Color(0xFF0F766E),
    );

const billingReleaseWorkspaceSubscriptionFocusSavedView =
    BillingReleaseWorkspaceSavedView(
      id: billingReleaseWorkspaceSubscriptionFocusSavedViewId,
      label: 'Subscription focus',
      description: 'Plan, renewal, and usage release readiness',
      deckIds: {billingReleaseWorkspaceSubscriptionFocusDeckId},
      icon: Icons.autorenew_outlined,
      accentColor: Color(0xFF2563EB),
    );

final standardBillingReleaseWorkspaceProfileCatalog =
    BillingReleaseWorkspaceProfileCatalog(
      profiles: [
        BillingReleaseWorkspaceProfile(
          id: billingReleaseWorkspaceCommerceProfileId,
          businessDomains: const [
            'commerce',
            'retail',
            'grocery',
            'restaurant',
            'food-service',
            'kiosk',
            'omnichannel',
          ],
        ),
        BillingReleaseWorkspaceProfile(
          id: billingReleaseWorkspaceConstructionProfileId,
          businessDomains: const ['construction', 'contracting', 'projects'],
          extensions: [billingReleaseWorkspaceConstructionFocusDeckDescriptor],
          savedViews: const [billingReleaseWorkspaceConstructionFocusSavedView],
        ),
        BillingReleaseWorkspaceProfile(
          id: billingReleaseWorkspaceSubscriptionProfileId,
          businessDomains: const [
            'digital',
            'saas',
            'software',
            'subscription',
          ],
          extensions: [billingReleaseWorkspaceSubscriptionFocusDeckDescriptor],
          savedViews: const [billingReleaseWorkspaceSubscriptionFocusSavedView],
        ),
      ],
    );

final billingReleaseWorkspaceConstructionFocusDeckDescriptor =
    BillingReleaseWorkspaceDeckDescriptor(
      id: billingReleaseWorkspaceConstructionFocusDeckId,
      priority: 50,
      builder: _buildConstructionFocusDeck,
    );

final billingReleaseWorkspaceSubscriptionFocusDeckDescriptor =
    BillingReleaseWorkspaceDeckDescriptor(
      id: billingReleaseWorkspaceSubscriptionFocusDeckId,
      priority: 50,
      builder: _buildSubscriptionFocusDeck,
    );

BillingReleaseWorkspaceRegistry
billingReleaseWorkspaceRegistryForBusinessDomain(
  String businessDomain, {
  BillingReleaseWorkspaceProfileCatalog? catalog,
}) {
  return (catalog ?? standardBillingReleaseWorkspaceProfileCatalog)
      .registryForBusinessDomain(businessDomain);
}

List<BillingReleaseWorkspaceSavedView>
billingReleaseWorkspaceSavedViewsForBusinessDomain(
  String businessDomain, {
  BillingReleaseWorkspaceProfileCatalog? catalog,
}) {
  return (catalog ?? standardBillingReleaseWorkspaceProfileCatalog)
      .savedViewsForBusinessDomain(businessDomain);
}

Widget _buildConstructionFocusDeck({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  final queue = releaseContext.releaseChannelLaunchQueue;
  final portfolio = releaseContext.packagePortfolio;

  return BillingReleaseWorkspaceDomainFocusPanel(
    onDestinationSelected: onDestinationSelected,
    focus: BillingReleaseWorkspaceDomainFocus(
      title: 'Construction release focus',
      summary:
          'Milestone billing, progress claims, and channel routes for '
          '${releaseContext.scopeLabel.toLowerCase()}.',
      icon: Icons.engineering_outlined,
      iconColor: const Color(0xFF0F766E),
      iconBackgroundColor: const Color(0xFFECFDF5),
      metrics: [
        BillingReadinessMetric(
          label: 'Packages',
          value: '${portfolio.packageCount}',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Ready',
          value: '${queue.readyNowCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Routing',
          value: '${queue.needsRoutingCount}',
          icon: Icons.near_me_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${queue.blockedCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
      items: const [
        BillingReleaseWorkspaceFocusItem(
          label: 'Milestone packages',
          detail:
              'Keep progress billing bundles aligned with contract stages and '
              'project handover points.',
          icon: Icons.account_tree_outlined,
          color: Color(0xFF0F766E),
        ),
        BillingReleaseWorkspaceFocusItem(
          label: 'Progress claims',
          detail:
              'Prioritize release actions that unblock claim review, retention, '
              'and approved billing evidence.',
          icon: Icons.fact_check_outlined,
          color: Color(0xFF2563EB),
        ),
        BillingReleaseWorkspaceFocusItem(
          label: 'Route readiness',
          detail:
              'Surface channel tasks that still need project, customer, or '
              'approval route mapping.',
          icon: Icons.alt_route_outlined,
          color: Color(0xFFD97706),
        ),
      ],
      actions: const [
        BillingReleaseWorkspaceAction(
          id: 'construction.open-packages',
          label: 'Open packages',
          tooltip: 'Open billing product packages for this release.',
          icon: Icons.inventory_2_outlined,
          destinationId: BillingNavigationDestinationId.productWorkspace,
          isPrimary: true,
        ),
        BillingReleaseWorkspaceAction(
          id: 'construction.review-reports',
          label: 'Review reports',
          tooltip: 'Open billing reports and collection insight.',
          icon: Icons.insights_outlined,
          destinationId: BillingNavigationDestinationId.reports,
        ),
        BillingReleaseWorkspaceAction(
          id: 'construction.resolve-outbox',
          label: 'Resolve outbox',
          tooltip: 'Open issue outbox commands that need attention.',
          icon: Icons.outbox_outlined,
          destinationId: BillingNavigationDestinationId.issueOutbox,
        ),
      ],
    ),
  );
}

Widget _buildSubscriptionFocusDeck({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  final launchPlan = releaseContext.releaseChannelLaunchPlan;
  final queue = releaseContext.releaseChannelLaunchQueue;

  return BillingReleaseWorkspaceDomainFocusPanel(
    onDestinationSelected: onDestinationSelected,
    focus: BillingReleaseWorkspaceDomainFocus(
      title: 'Subscription release focus',
      summary:
          'Plan entitlements, renewal paths, and metered usage routes for '
          '${releaseContext.scopeLabel.toLowerCase()}.',
      icon: Icons.autorenew_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      metrics: [
        BillingReadinessMetric(
          label: 'Actions',
          value: '${launchPlan.actionCount}',
          icon: Icons.checklist_rtl_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Publish',
          value: '${launchPlan.publishNowCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Review',
          value: '${launchPlan.reviewCount}',
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Queued',
          value: '${queue.itemCount}',
          icon: Icons.queue_outlined,
          color: const Color(0xFF7C3AED),
        ),
      ],
      items: const [
        BillingReleaseWorkspaceFocusItem(
          label: 'Plan entitlements',
          detail:
              'Keep package releases tied to plan limits, feature access, and '
              'customer lifecycle states.',
          icon: Icons.verified_user_outlined,
          color: Color(0xFF2563EB),
        ),
        BillingReleaseWorkspaceFocusItem(
          label: 'Renewal paths',
          detail:
              'Watch renewal, trial, upgrade, downgrade, and cancellation '
              'flows before channel rollout.',
          icon: Icons.sync_outlined,
          color: Color(0xFF059669),
        ),
        BillingReleaseWorkspaceFocusItem(
          label: 'Usage channels',
          detail:
              'Route usage capture, overage review, and invoice issue tasks '
              'through the launch queue.',
          icon: Icons.query_stats_outlined,
          color: Color(0xFF7C3AED),
        ),
      ],
      actions: const [
        BillingReleaseWorkspaceAction(
          id: 'subscription.open-products',
          label: 'Open products',
          tooltip: 'Open products and checkout for plan release work.',
          icon: Icons.storefront_outlined,
          destinationId: BillingNavigationDestinationId.productWorkspace,
          isPrimary: true,
        ),
        BillingReleaseWorkspaceAction(
          id: 'subscription.inspect-invoices',
          label: 'Inspect invoices',
          tooltip: 'Open invoices affected by subscription release state.',
          icon: Icons.article_outlined,
          destinationId: BillingNavigationDestinationId.invoices,
        ),
        BillingReleaseWorkspaceAction(
          id: 'subscription.resolve-outbox',
          label: 'Resolve outbox',
          tooltip: 'Open issue outbox commands that need attention.',
          icon: Icons.outbox_outlined,
          destinationId: BillingNavigationDestinationId.issueOutbox,
        ),
      ],
    ),
  );
}
