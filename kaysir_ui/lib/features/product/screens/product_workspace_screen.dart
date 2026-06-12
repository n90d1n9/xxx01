import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/widgets/inventory_product_catalog_components.dart';
import '../models/product_channel_launch_priority.dart';
import '../models/management_pack.dart';
import '../models/management_pack_preset.dart';
import '../models/management_pack_readiness.dart';
import '../models/sales_channel_profile.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/product_workspace_action_summary.dart';
import '../models/product_workspace_recommendation.dart';
import '../models/product_workspace_setup_action.dart';
import '../models/product_workspace_setup_target.dart';
import '../models/product_workspace_shortcut.dart';
import '../product_routes.dart';
import '../states/management_pack_contribution_bundle_provider.dart';
import '../states/management_pack_provider.dart';
import '../states/management_pack_preset_provider.dart';
import '../states/management_pack_readiness_provider.dart';
import '../states/management_workspace_preferences_controller.dart';
import '../states/sales_channel_definition_provider.dart';
import '../states/product_workspace_overview_provider.dart';
import '../states/product_workspace_setup_target_provider.dart';
import '../utils/product_catalog_review_target.dart';
import '../utils/management_mode_feedback.dart';
import '../utils/management_route_mode.dart';
import '../utils/workspace_setup_action_flow.dart';
import '../widgets/product_channel_launch_priority_panel.dart';
import '../widgets/product_catalog_quality_panel.dart';
import '../widgets/product_catalog_view_preset_panel.dart';
import '../widgets/experience_profile_scope.dart';
import '../widgets/management_pack_contribution_panel.dart';
import '../widgets/management_mode_status_panel.dart';
import '../widgets/management_pack_preset_panel.dart';
import '../widgets/management_pack_selector_panel.dart';
import '../widgets/management_pack_readiness_panel.dart';
import '../widgets/sales_channel_profile_selector_panel.dart';
import '../widgets/sales_channel_profile_pack_overview_panel.dart';
import '../widgets/sales_channel_profile_switch_dialog.dart';
import '../widgets/sales_channel_readiness_panel.dart';
import '../widgets/sales_channel_strategy_brief_panel.dart';
import '../widgets/workspace_header.dart';
import '../widgets/workspace_pulse_panel.dart';
import '../widgets/workspace_recommendation_panel.dart';
import '../widgets/workspace_actions.dart';
import '../widgets/workspace_attention_panel.dart';
import '../widgets/workspace_setup_notice.dart';
import '../widgets/workspace_setup_overview_panel.dart';

class ProductWorkspaceScreen extends ConsumerStatefulWidget {
  const ProductWorkspaceScreen({
    super.key,
    this.initialPackId,
    this.initialChannelProfileId,
    this.initialSetupTargetId,
    this.initialSetupTarget,
  });

  final ProductManagementPackId? initialPackId;
  final ProductSalesChannelProfileId? initialChannelProfileId;
  final String? initialSetupTargetId;
  final ProductWorkspaceSetupTarget? initialSetupTarget;

  @override
  ConsumerState<ProductWorkspaceScreen> createState() =>
      _ProductWorkspaceScreenState();
}

class _ProductWorkspaceScreenState
    extends ConsumerState<ProductWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_syncInitialProductMode());
  }

  @override
  void didUpdateWidget(ProductWorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPackId != widget.initialPackId ||
        oldWidget.initialChannelProfileId != widget.initialChannelProfileId) {
      unawaited(_syncInitialProductMode());
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(productWorkspaceOverviewProvider);
    final contributionBundle = ref.watch(
      productManagementPackContributionBundleProvider,
    );
    final packReadiness = ref.watch(productManagementPackReadinessProvider);
    final managementPackOptions = ref.watch(
      productManagementPackOptionsProvider,
    );
    final managementPack = ref.watch(productManagementPackProvider);
    final managementPackPresets = ref.watch(
      productManagementPackPresetsProvider,
    );
    final activeManagementPackPreset = ref.watch(
      activeProductManagementPackPresetProvider,
    );
    final defaultManagementPack =
        ref.watch(productManagementPackRegistryProvider).fallbackPack;
    final setupResolution = _resolveInitialSetupTarget();
    final setupPrompt =
        setupResolution == null
            ? null
            : ref
                .watch(productWorkspaceSetupActionResolverProvider)
                .promptForResolution(setupResolution);
    final setupOverview = ref.watch(productWorkspaceSetupOverviewProvider);
    final routeMode = productManagementRouteModeFor(
      pack: managementPack,
      channelProfile: overview.channelProfile,
    );
    final experienceProfile = ProductExperienceProfileScope.maybeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(experienceProfile?.workspaceTitle ?? 'Product Workspace'),
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: ProductWorkspaceHeader(
          summary: overview.summary,
          eyebrow: experienceProfile?.workspaceSubtitle ?? 'Product Operations',
          title: experienceProfile?.workspaceTitle ?? 'Catalog command center',
          description: experienceProfile?.workspaceDescription,
          onOpenCatalog:
              () => context.go(
                productRouteWithManagementMode(
                  ProductRoutes.catalogPath,
                  mode: routeMode,
                ),
              ),
        ),
        metrics: InventoryProductCatalogSummaryGrid(summary: overview.summary),
        children: [
          if (setupPrompt != null)
            ProductWorkspaceSetupNotice(
              prompt: setupPrompt,
              onActionPressed: () => _openSetupAction(setupPrompt.action),
            ),
          ProductWorkspaceSetupOverviewPanel(
            overview: setupOverview,
            onActionSelected: (prompt) => _openSetupAction(prompt.action),
          ),
          ProductWorkspaceActions(
            groups: overview.actionGroups,
            onShortcutSelected: _openShortcut,
            onSetupFocusSelected: _openSetupFocus,
          ),
          ProductWorkspacePulsePanel(
            overview: overview,
            onReviewLaunchQueue: _openLaunchQueue,
            onReviewAttention: _openAttentionReview,
          ),
          ProductWorkspaceRecommendationPanel(
            recommendations: overview.recommendations,
            onRecommendationSelected: _openRecommendation,
          ),
          ProductCatalogViewPresetPanel(
            summary: overview.summary,
            onSelected:
                (preset) => context.go(
                  productRouteWithManagementMode(
                    ProductRoutes.catalogUriForPreset(preset),
                    mode: routeMode,
                  ),
                ),
          ),
          ProductCatalogQualityPanel(
            summary: overview.qualitySummary,
            onIssueSelected:
                (issue) => context.go(
                  productRouteWithManagementMode(
                    ProductRoutes.catalogUriForReviewTarget(issue.reviewTarget),
                    mode: routeMode,
                  ),
                ),
          ),
          ProductManagementModeStatusPanel(
            pack: managementPack,
            channelProfile: overview.channelProfile,
            canReset: _canResetManagementMode(
              defaultPack: defaultManagementPack,
              activePack: managementPack,
              activeProfile: overview.channelProfile,
            ),
            onReset: _resetManagementMode,
          ),
          ProductManagementPackSelectorPanel(
            packs: managementPackOptions,
            selectedPack: managementPack,
            onChanged: _switchManagementPack,
          ),
          ProductManagementPackPresetPanel(
            presets: managementPackPresets,
            activePreset: activeManagementPackPreset,
            onSelected: _applyManagementPackPreset,
          ),
          ProductSalesChannelProfileSelectorPanel(
            profiles: overview.channelProfiles,
            selectedProfile: overview.channelProfile,
            readinessSummary: overview.profileReadinessSummary,
            readinessOptions: overview.profileReadinessOptions,
            onChanged: (profileId) {
              _requestProfileSwitch(
                profileId,
                overview.profileReadinessOptions,
              );
            },
          ),
          ProductSalesChannelProfilePackOverviewPanel(
            overview: overview.channelProfilePackOverview,
          ),
          ProductManagementPackContributionPanel(bundle: contributionBundle),
          ProductManagementPackReadinessPanel(
            readiness: packReadiness,
            onPrimaryAction: () => _openPackReadinessFocus(packReadiness),
          ),
          ProductSalesChannelStrategyBriefPanel(
            brief: overview.strategyBrief,
            onPrioritySelected: _openLaunchPriority,
          ),
          ProductChannelLaunchPriorityPanel(
            priorities: overview.launchPriorities,
            onSelected: _openLaunchPriority,
          ),
          ProductSalesChannelReadinessPanel(
            readiness: overview.channelReadiness,
            onSelected:
                (readiness) => context.go(
                  productRouteWithManagementMode(
                    ProductRoutes.catalogUriForChannelReadiness(readiness),
                    mode: routeMode,
                  ),
                ),
            onIssueSelected:
                (readiness, issue) => context.go(
                  productRouteWithManagementMode(
                    ProductRoutes.catalogUriForChannelReadinessIssue(
                      issue,
                      title: readiness.title,
                    ),
                    mode: routeMode,
                  ),
                ),
          ),
          ProductWorkspaceAttentionPanel(
            records: overview.records,
            onReviewCatalog: _openAttentionReview,
          ),
        ],
      ),
    );
  }

  void _openLaunchPriority(ProductChannelLaunchPriority priority) {
    final routeMode = _activeRouteMode();
    context.go(
      productRouteWithManagementMode(
        ProductRoutes.catalogUriForReviewTarget(
          ProductCatalogReviewTarget.fromReadiness(priority.readiness),
        ),
        mode: routeMode,
      ),
    );
  }

  void _openLaunchQueue() {
    final priority =
        ref.read(productWorkspaceOverviewProvider).primaryLaunchPriority;
    if (priority == null) {
      context.go(
        productRouteWithManagementMode(
          ProductRoutes.catalogPath,
          mode: _activeRouteMode(),
        ),
      );
      return;
    }

    _openLaunchPriority(priority);
  }

  Future<void> _requestProfileSwitch(
    ProductSalesChannelProfileId profileId,
    List<ProductSalesChannelProfileReadinessOption> options,
  ) async {
    final option = productSalesChannelProfileReadinessOptionFor(
      options,
      profileId,
    );
    if (option?.isSelected ?? false) return;

    final confirmed =
        option == null
            ? true
            : await showProductSalesChannelProfileSwitchDialog(
              context,
              option: option,
            );
    if (!mounted || !confirmed) return;

    ref.read(productSalesChannelProfileIdProvider.notifier).state = profileId;
    unawaited(
      _applyManagementModeChange(
        feedbackLabel: 'Channel strategy switched',
        apply: (controller) => controller.selectChannelProfile(profileId),
      ),
    );
  }

  void _openShortcut(ProductWorkspaceShortcut shortcut) {
    if (!shortcut.canNavigate) return;

    context.go(
      productRouteWithManagementMode(
        shortcut.routePath!,
        mode: _activeRouteMode(),
      ),
    );
  }

  void _openSetupFocus(ProductWorkspaceActionSetupFocus focus) {
    if (focus.hasRoutePath) {
      context.go(focus.routePath!);
      return;
    }

    final reason = focus.reason?.trim();
    final message =
        reason == null || reason.isEmpty
            ? '${focus.actionTitle} needs setup before it can open.'
            : '${focus.actionTitle}: $reason';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _openRecommendation(ProductWorkspaceRecommendation recommendation) {
    if (!recommendation.canNavigate) return;

    context.go(
      productRouteWithManagementMode(
        recommendation.routePath!,
        mode: _activeRouteMode(),
      ),
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
        showDefaultActivationFeedback: false,
      ),
    );
  }

  ProductWorkspaceSetupTargetResolution? _resolveInitialSetupTarget() {
    final explicitTarget = widget.initialSetupTarget;
    if (explicitTarget != null) {
      return ProductWorkspaceSetupTargetResolution(
        target: explicitTarget,
        availability: ProductWorkspaceSetupTargetAvailability.active,
      );
    }

    return ref
        .watch(productWorkspaceSetupTargetRegistryProvider)
        .resolveWithAvailability(widget.initialSetupTargetId);
  }

  void _openPackReadinessFocus(ProductManagementPackReadiness readiness) {
    final focus = readiness.primarySection;
    if (focus?.id == productManagementPackReadinessChannelSectionId) {
      _openLaunchQueue();
      return;
    }

    context.go(
      productRouteWithManagementMode(
        ProductRoutes.catalogPath,
        mode: _activeRouteMode(),
      ),
    );
  }

  void _switchManagementPack(
    ProductManagementPackId packId, {
    bool showFeedback = true,
  }) {
    unawaited(
      _applyManagementModeChange(
        feedbackLabel: 'Product mode switched',
        showFeedback: showFeedback,
        apply: (controller) => controller.selectPack(packId),
      ),
    );
  }

  void _applyManagementPackPreset(ProductManagementPackPreset preset) {
    unawaited(
      _applyManagementModeChange(
        feedbackLabel: 'Product-line preset applied',
        apply: (controller) => controller.selectPreset(preset),
      ),
    );
  }

  void _resetManagementMode() {
    unawaited(_resetManagementModeWithFeedback());
  }

  Future<void> _resetManagementModeWithFeedback() async {
    final selection =
        await ref
            .read(productManagementWorkspacePreferencesControllerProvider)
            .resetToDefault();
    if (!mounted) return;

    showProductManagementModeFeedback(
      context,
      label: 'Product mode reset',
      selection: selection,
    );
  }

  Future<void> _applyManagementModeChange({
    required String feedbackLabel,
    required Future<ProductManagementWorkspaceSelection> Function(
      ProductManagementWorkspacePreferencesController controller,
    )
    apply,
    bool showFeedback = true,
  }) async {
    final selection = await apply(
      ref.read(productManagementWorkspacePreferencesControllerProvider),
    );
    if (!mounted || !showFeedback) return;

    showProductManagementModeFeedback(
      context,
      label: feedbackLabel,
      selection: selection,
      action: SnackBarAction(label: 'Reset', onPressed: _resetManagementMode),
    );
  }

  void _openAttentionReview() {
    final routeMode = _activeRouteMode();
    context.go(
      productRouteWithManagementMode(
        ProductRoutes.catalogUriForReviewTarget(
          const ProductCatalogReviewTarget(
            filter: InventoryProductCatalogFilter.attention,
            title: 'Attention Review',
          ),
        ),
        mode: routeMode,
      ),
    );
  }

  ProductManagementRouteMode _activeRouteMode() {
    return productManagementRouteModeFor(
      pack: ref.read(productManagementPackProvider),
      channelProfile: ref.read(productSalesChannelProfileProvider),
    );
  }

  Future<void> _syncInitialProductMode() async {
    final initialPackId = widget.initialPackId;
    final initialProfileId = widget.initialChannelProfileId;
    final hasInitialProductMode =
        initialPackId != null || initialProfileId != null;
    final controller = ref.read(
      productManagementWorkspacePreferencesControllerProvider,
    );

    if (!hasInitialProductMode) {
      await controller.hydrate();
      return;
    }

    await controller.hydrate(applyChannelProfile: false);
    if (!mounted) return;

    await controller.applyRouteSelection(
      packId: initialPackId,
      channelProfileId: initialProfileId,
    );
  }
}

bool _canResetManagementMode({
  required ProductManagementPack defaultPack,
  required ProductManagementPack activePack,
  required ProductSalesChannelProfile activeProfile,
}) {
  return activePack.id != defaultPack.id ||
      activeProfile.id != defaultPack.defaultChannelProfileId;
}
