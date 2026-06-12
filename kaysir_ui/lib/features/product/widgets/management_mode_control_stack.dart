import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/management_pack.dart';
import '../models/management_pack_preset.dart';
import '../models/sales_channel_profile.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../states/management_pack_provider.dart';
import '../states/management_pack_preset_provider.dart';
import '../states/management_workspace_preferences_controller.dart';
import '../states/sales_channel_definition_provider.dart';
import '../states/product_workspace_overview_provider.dart';
import '../utils/management_mode_feedback.dart';
import 'management_mode_status_panel.dart';
import 'management_pack_preset_panel.dart';
import 'management_pack_selector_panel.dart';
import 'sales_channel_profile_pack_overview_panel.dart';
import 'sales_channel_profile_selector_panel.dart';
import 'sales_channel_profile_switch_dialog.dart';

/// Provider-backed control stack for changing product pack and channel mode.
class ProductManagementModeControlStack extends ConsumerStatefulWidget {
  const ProductManagementModeControlStack({
    super.key,
    this.includeStatus = true,
    this.includePackSelector = true,
    this.includePresets = true,
    this.includeChannelSelector = true,
    this.includeProfilePackOverview = true,
    this.spacing = 16,
  });

  final bool includeStatus;
  final bool includePackSelector;
  final bool includePresets;
  final bool includeChannelSelector;
  final bool includeProfilePackOverview;
  final double spacing;

  @override
  ConsumerState<ProductManagementModeControlStack> createState() =>
      _ProductManagementModeControlStackState();
}

class _ProductManagementModeControlStackState
    extends ConsumerState<ProductManagementModeControlStack> {
  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(productWorkspaceOverviewProvider);
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
    final children = <Widget>[
      if (widget.includeStatus)
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
      if (widget.includePackSelector)
        ProductManagementPackSelectorPanel(
          packs: managementPackOptions,
          selectedPack: managementPack,
          onChanged: _switchManagementPack,
        ),
      if (widget.includePresets)
        ProductManagementPackPresetPanel(
          presets: managementPackPresets,
          activePreset: activeManagementPackPreset,
          onSelected: _applyManagementPackPreset,
        ),
      if (widget.includeChannelSelector)
        ProductSalesChannelProfileSelectorPanel(
          profiles: overview.channelProfiles,
          selectedProfile: overview.channelProfile,
          readinessSummary: overview.profileReadinessSummary,
          readinessOptions: overview.profileReadinessOptions,
          onChanged: (profileId) {
            _requestProfileSwitch(profileId, overview.profileReadinessOptions);
          },
        ),
      if (widget.includeProfilePackOverview)
        ProductSalesChannelProfilePackOverviewPanel(
          overview: overview.channelProfilePackOverview,
        ),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index += 1) ...[
          if (index > 0) SizedBox(height: widget.spacing),
          children[index],
        ],
      ],
    );
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
}

bool _canResetManagementMode({
  required ProductManagementPack defaultPack,
  required ProductManagementPack activePack,
  required ProductSalesChannelProfile activeProfile,
}) {
  return activePack.id != defaultPack.id ||
      activeProfile.id != defaultPack.defaultChannelProfileId;
}
