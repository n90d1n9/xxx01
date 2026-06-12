import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_commerce_channel_behavior.dart';
import '../experiences/pos_commerce_channel_provider.dart';
import '../experiences/pos_commerce_channel_registry.dart';
import '../experiences/pos_experience_diagnostics.dart';
import '../experiences/pos_experience_provider.dart';
import '../experiences/pos_experience_registry.dart';
import '../experiences/pos_feature_module.dart';
import '../states/pos_command_action_provider.dart';
import '../states/pos_layout_provider.dart';
import '../states/pos_product_runtime_pack_provider.dart';
import '../states/pos_shell_shortcut_provider.dart';
import '../utils/pos_command_actions.dart';
import '../utils/pos_shell_shortcuts.dart';
import 'pos_diagnostics_handoff_panel.dart';
import 'pos_experience_data_contract_summary.dart';
import 'pos_experience_launch_checklist_summary.dart';
import 'pos_experience_manifest_summary.dart';
import 'pos_diagnostics_activity_panel.dart';
import 'pos_layout_strategy_pack.dart';
import 'pos_layout_strategy_pack_provider.dart';
import 'pos_layout_strategy_host.dart';
import 'pos_product_profile_catalog_diagnostics.dart';
import 'pos_runtime_pack_diagnostics.dart';
import 'pos_switch_action_history_panel.dart';
import 'pos_ui.dart';

class POSExperienceDiagnosticsButton extends ConsumerWidget {
  final double viewportWidth;
  final POSLayoutPreference layoutPreference;
  final POSLayoutStrategy resolvedStrategy;
  final POSLayoutStrategyRegistry? layoutStrategyRegistry;
  final POSLayoutStrategyRendererRegistry? layoutRendererRegistry;
  final POSLayoutStrategyPack? layoutPack;

  const POSExperienceDiagnosticsButton({
    super.key,
    required this.viewportWidth,
    required this.layoutPreference,
    required this.resolvedStrategy,
    this.layoutStrategyRegistry,
    this.layoutRendererRegistry,
    this.layoutPack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedLayoutPack = _resolveLayoutPack(ref);
    final layoutValidation = resolvedLayoutPack.validate();
    final diagnostics = POSExperienceDiagnostics.from(
      resolution: ref.watch(posExperienceResolutionProvider),
      viewportWidth: viewportWidth,
      layoutPreference: layoutPreference,
      resolvedLayout: resolvedStrategy,
      registryIssues: ref.watch(posExperienceRegistryIssuesProvider),
      runtimePackResolution: ref.watch(posProductRuntimePackResolutionProvider),
      runtimePackRegistryIssues: ref.watch(
        posProductRuntimePackRegistryIssuesProvider,
      ),
      runtimePackIssues: ref.watch(posProductRuntimePackIssuesProvider),
      layoutStrategyRegistry: resolvedLayoutPack.strategyRegistry,
      layoutStrategyIssues: layoutValidation.strategyIssues,
      layoutRendererIssues: layoutValidation.rendererIssues,
      productProfile: ref.watch(posProductProfileProvider),
      productProfileValidationReport: ref.watch(
        posProductProfileValidationReportProvider,
      ),
      launchChecklist: ref.watch(posProductProfileLaunchChecklistProvider),
      commerceChannel: ref.watch(posCommerceChannelProvider),
      commerceChannelRegistryIssues: ref.watch(
        posCommerceChannelRegistryIssuesProvider,
      ),
      commerceChannelBehaviorRegistryIssues: ref.watch(
        posCommerceChannelBehaviorRegistryIssuesProvider,
      ),
      commandActionRegistryIssues: ref.watch(
        posCommandActionRegistryIssuesProvider,
      ),
      shortcutRegistryIssues: ref.watch(posShellShortcutRegistryIssuesProvider),
    );

    final icon = Icon(_readinessIcon(diagnostics.readiness.level));

    return IconButton(
      tooltip: 'POS diagnostics',
      icon:
          diagnostics.hasWarnings
              ? Badge.count(count: diagnostics.warningCount, child: icon)
              : icon,
      onPressed: () {
        showDialog<void>(
          context: context,
          builder:
              (context) =>
                  POSExperienceDiagnosticsDialog(diagnostics: diagnostics),
        );
      },
    );
  }

  POSLayoutStrategyPack _resolveLayoutPack(WidgetRef ref) {
    final explicitPack = layoutPack;
    if (explicitPack != null) return explicitPack;

    if (layoutStrategyRegistry == null && layoutRendererRegistry == null) {
      return ref.watch(posLayoutStrategyPackProvider);
    }

    return POSLayoutStrategyPack(
      strategyRegistry:
          layoutStrategyRegistry ?? defaultPOSLayoutStrategyRegistry,
      rendererRegistry:
          layoutRendererRegistry ?? defaultPOSLayoutStrategyRendererRegistry,
    );
  }
}

class POSExperienceDiagnosticsDialog extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const POSExperienceDiagnosticsDialog({super.key, required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readinessVisuals = _readinessVisuals(
      theme.colorScheme,
      diagnostics.readiness.level,
    );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      title: Row(
        children: [
          POSIconBadge(
            icon: readinessVisuals.icon,
            backgroundColor: readinessVisuals.background,
            foregroundColor: readinessVisuals.foreground,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Text(
              'POS mode diagnostics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DiagnosticsStatus(diagnostics: diagnostics),
              const SizedBox(height: 18),
              _DiagnosticsOverview(diagnostics: diagnostics),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Support handoff',
                child: POSDiagnosticsHandoffPanel(diagnostics: diagnostics),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Runtime pack',
                child: POSRuntimePackDiagnosticsRows(diagnostics: diagnostics),
              ),
              if (diagnostics.runtimePackIssueCount > 0) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Runtime pack issues',
                  child: POSRuntimePackIssueList(diagnostics: diagnostics),
                ),
              ],
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Manifest',
                child: POSExperienceManifestSummary(
                  manifest: diagnostics.manifest,
                ),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Product catalog',
                child: POSProductProfileCatalogDiagnosticsRows(
                  diagnostics: diagnostics,
                ),
              ),
              if (diagnostics.productProfileCatalogIssueCount > 0) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Product catalog issues',
                  child: POSProductProfileCatalogIssueList(
                    issues: diagnostics.productProfileCatalogIssues,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Data contracts',
                child: POSExperienceDataContractSummary(
                  contracts: diagnostics.dataContracts,
                ),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Modules',
                child: _ModuleWrap(modules: diagnostics.modules),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Capabilities',
                child: _CapabilityWrap(capabilities: diagnostics.capabilities),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Runtime fit',
                child: _ScreenFitRows(screenFit: diagnostics.screenFit),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Commerce channel',
                child: _CommerceChannelRows(diagnostics: diagnostics),
              ),
              const SizedBox(height: 18),
              const _DiagnosticsSection(
                title: 'Switch attempts',
                child: POSSwitchActionHistoryPanel(maxEntries: 4),
              ),
              const SizedBox(height: 18),
              const _DiagnosticsSection(
                title: 'Activity',
                child: POSDiagnosticsActivityPanel(),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Layout strategy',
                child: _LayoutStrategyRows(diagnostics: diagnostics),
              ),
              if (diagnostics.layoutIssueCount > 0) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Layout issues',
                  child: _LayoutIssueList(diagnostics: diagnostics),
                ),
              ],
              if (diagnostics.shortcutIssueCount > 0) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Shortcut issues',
                  child: _ShortcutIssueList(
                    issues: diagnostics.shortcutRegistryIssues,
                  ),
                ),
              ],
              if (diagnostics.commandActionIssueCount > 0) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Command issues',
                  child: _CommandIssueList(
                    issues: diagnostics.commandActionRegistryIssues,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Launch checklist',
                child: POSExperienceLaunchChecklistSummary(
                  checklist: diagnostics.launchChecklist,
                ),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Actions',
                child: _ActionAvailabilityGrid(actions: diagnostics.actions),
              ),
              const SizedBox(height: 18),
              _DiagnosticsSection(
                title: 'Behaviors',
                child: _BehaviorList(behaviors: diagnostics.behaviors),
              ),
              if (diagnostics.registryIssues.isNotEmpty) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Registry issues',
                  child: _RegistryIssueList(issues: diagnostics.registryIssues),
                ),
              ],
              if (diagnostics.commerceChannelRegistryIssues.isNotEmpty) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Channel issues',
                  child: _CommerceChannelIssueList(
                    issues: diagnostics.commerceChannelRegistryIssues,
                  ),
                ),
              ],
              if (diagnostics
                  .commerceChannelBehaviorRegistryIssues
                  .isNotEmpty) ...[
                const SizedBox(height: 18),
                _DiagnosticsSection(
                  title: 'Channel behavior issues',
                  child: _CommerceChannelBehaviorIssueList(
                    issues: diagnostics.commerceChannelBehaviorRegistryIssues,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

IconData _readinessIcon(POSExperienceReadinessLevel level) {
  switch (level) {
    case POSExperienceReadinessLevel.ready:
      return Icons.check_circle_outline;
    case POSExperienceReadinessLevel.preview:
      return Icons.visibility_outlined;
    case POSExperienceReadinessLevel.experimental:
      return Icons.science_outlined;
    case POSExperienceReadinessLevel.screenMismatch:
      return Icons.phonelink_off_outlined;
    case POSExperienceReadinessLevel.fallback:
      return Icons.swap_horiz;
    case POSExperienceReadinessLevel.degraded:
      return Icons.extension_off_outlined;
    case POSExperienceReadinessLevel.needsAttention:
      return Icons.error_outline;
  }
}

_ReadinessVisuals _readinessVisuals(
  ColorScheme colorScheme,
  POSExperienceReadinessLevel level,
) {
  switch (level) {
    case POSExperienceReadinessLevel.ready:
      return _ReadinessVisuals(
        icon: _readinessIcon(level),
        background: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
        border: colorScheme.secondary.withValues(alpha: 0.22),
      );
    case POSExperienceReadinessLevel.preview:
      return _ReadinessVisuals(
        icon: _readinessIcon(level),
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
        border: colorScheme.primary.withValues(alpha: 0.2),
      );
    case POSExperienceReadinessLevel.experimental:
      return _ReadinessVisuals(
        icon: _readinessIcon(level),
        background: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
        border: colorScheme.tertiary.withValues(alpha: 0.22),
      );
    case POSExperienceReadinessLevel.screenMismatch:
    case POSExperienceReadinessLevel.fallback:
    case POSExperienceReadinessLevel.degraded:
    case POSExperienceReadinessLevel.needsAttention:
      return _ReadinessVisuals(
        icon: _readinessIcon(level),
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
        border: colorScheme.error.withValues(alpha: 0.24),
      );
  }
}

class _ReadinessVisuals {
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;

  const _ReadinessVisuals({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });
}

class _DiagnosticsStatus extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const _DiagnosticsStatus({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readiness = diagnostics.readiness;
    final visuals = _readinessVisuals(theme.colorScheme, readiness.level);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: visuals.background.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: visuals.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(visuals.icon, color: visuals.foreground),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnostics.statusLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: visuals.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    readiness.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: visuals.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticsOverview extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const _DiagnosticsOverview({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        _OverviewTile(label: 'Mode', value: diagnostics.experience.label),
        _OverviewTile(label: 'Pack', value: diagnostics.runtimePackLabel),
        _OverviewTile(label: 'Product', value: diagnostics.productProfileLabel),
        _OverviewTile(
          label: 'Pack health',
          value: diagnostics.runtimePackHealthLabel,
        ),
        _OverviewTile(
          label: 'Profile catalog',
          value: diagnostics.productProfileCatalogLabel,
        ),
        _OverviewTile(
          label: 'Channel',
          value: diagnostics.commerceChannelLabel,
        ),
        _OverviewTile(label: 'Readiness', value: diagnostics.readiness.label),
        _OverviewTile(
          label: 'Launch',
          value: diagnostics.launchChecklist.statusLabel,
        ),
        _OverviewTile(
          label: 'Screen',
          value:
              '${diagnostics.screenFit.formFactorLabel} / ${diagnostics.screenFit.statusLabel}',
        ),
        _OverviewTile(label: 'Mode ID', value: diagnostics.experience.id),
        _OverviewTile(
          label: 'Requested',
          value:
              diagnostics.requestedExperienceId.isEmpty
                  ? 'none'
                  : diagnostics.requestedExperienceId,
        ),
        _OverviewTile(label: 'Layout', value: diagnostics.layoutSummary),
        _OverviewTile(
          label: 'Layout health',
          value:
              diagnostics.layoutIssueCount == 0
                  ? 'Valid'
                  : '${diagnostics.layoutIssueCount} issues',
        ),
        _OverviewTile(
          label: 'Shortcuts',
          value:
              diagnostics.shortcutIssueCount == 0
                  ? 'Valid'
                  : '${diagnostics.shortcutIssueCount} issues',
        ),
        _OverviewTile(
          label: 'Commands',
          value:
              diagnostics.commandActionIssueCount == 0
                  ? 'Valid'
                  : '${diagnostics.commandActionIssueCount} issues',
        ),
        _OverviewTile(
          label: 'Preferred',
          value: diagnostics.experience.preferredLayout.label,
        ),
        _OverviewTile(
          label: 'Channel layout',
          value: diagnostics.commerceChannelLayoutLabel,
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 136,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DiagnosticsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: POSUiTokens.gap),
        child,
      ],
    );
  }
}

class _ModuleWrap extends StatelessWidget {
  final List<POSFeatureModule> modules;

  const _ModuleWrap({required this.modules});

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const Text('No modules registered');
    }

    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          modules
              .map(
                (module) => Chip(
                  avatar: Icon(_moduleAreaIcon(module.area), size: 16),
                  label: Text(module.label),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
    );
  }

  IconData _moduleAreaIcon(POSFeatureModuleArea area) {
    switch (area) {
      case POSFeatureModuleArea.catalog:
        return Icons.inventory_2_outlined;
      case POSFeatureModuleArea.order:
        return Icons.shopping_cart_outlined;
      case POSFeatureModuleArea.customer:
        return Icons.person_outline;
      case POSFeatureModuleArea.promotion:
        return Icons.discount_outlined;
      case POSFeatureModuleArea.payment:
        return Icons.payments_outlined;
      case POSFeatureModuleArea.layout:
        return Icons.dashboard_customize_outlined;
    }
  }
}

class _CapabilityWrap extends StatelessWidget {
  final List<POSCapabilityDiagnostic> capabilities;

  const _CapabilityWrap({required this.capabilities});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          capabilities
              .map((capability) => _CapabilityPill(capability: capability))
              .toList(),
    );
  }
}

class _CapabilityPill extends StatelessWidget {
  final POSCapabilityDiagnostic capability;

  const _CapabilityPill({required this.capability});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = capability.enabled;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color:
            enabled
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(
          color:
              enabled
                  ? theme.colorScheme.secondary.withValues(alpha: 0.22)
                  : theme.dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.block,
            size: 16,
            color:
                enabled
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            capability.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color:
                  enabled
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorList extends StatelessWidget {
  final List<POSBehaviorDiagnostic> behaviors;

  const _BehaviorList({required this.behaviors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          behaviors
              .map(
                (behavior) => _DiagnosticsRow(
                  label: behavior.label,
                  value: behavior.summary,
                ),
              )
              .toList(),
    );
  }
}

class _ScreenFitRows extends StatelessWidget {
  final POSExperienceScreenFitDiagnostic screenFit;

  const _ScreenFitRows({required this.screenFit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DiagnosticsRow(
          label: 'Current',
          value:
              '${screenFit.formFactorLabel} (${screenFit.viewportWidth.round()}px)',
        ),
        _DiagnosticsRow(label: 'Fit', value: screenFit.statusLabel),
        _DiagnosticsRow(
          label: 'Supported',
          value: screenFit.supportedFormFactorLabel,
        ),
      ],
    );
  }
}

class _LayoutStrategyRows extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const _LayoutStrategyRows({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final strategy = diagnostics.resolvedLayoutSpec;

    return Column(
      children: [
        _DiagnosticsRow(label: 'Strategy', value: strategy.label),
        _DiagnosticsRow(label: 'Slots', value: strategy.slotSummary),
        _DiagnosticsRow(label: 'Traits', value: strategy.traitSummary),
        _DiagnosticsRow(label: 'Use', value: strategy.description),
        _DiagnosticsRow(
          label: 'Validation',
          value:
              diagnostics.layoutIssueCount == 0
                  ? 'Strategy and renderer contracts valid.'
                  : '${diagnostics.layoutIssueCount} layout issues found.',
        ),
      ],
    );
  }
}

class _CommerceChannelRows extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const _CommerceChannelRows({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final channel = diagnostics.commerceChannel;
    if (channel == null) {
      return const Text('No commerce channel selected.');
    }

    return Column(
      children: [
        _DiagnosticsRow(label: 'Channel', value: channel.label),
        _DiagnosticsRow(label: 'Kind', value: channel.kind.label),
        _DiagnosticsRow(label: 'Use', value: channel.description),
        _DiagnosticsRow(label: 'Layout', value: channel.preferredLayout.label),
        _DiagnosticsRow(
          label: 'Fulfillment',
          value: channel.fulfillmentSummary,
        ),
        _DiagnosticsRow(
          label: 'Capabilities',
          value: channel.capabilitySummary,
        ),
        _DiagnosticsRow(label: 'Traits', value: channel.traitSummary),
        _DiagnosticsRow(
          label: 'Validation',
          value:
              diagnostics.commerceChannelIssueCount == 0
                  ? 'Commerce channel contracts valid.'
                  : '${diagnostics.commerceChannelIssueCount} channel issues found.',
        ),
      ],
    );
  }
}

class _LayoutIssueList extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const _LayoutIssueList({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...diagnostics.layoutStrategyIssues.map(
          (issue) => _DiagnosticsRow(
            label: _strategyIssueTypeLabel(issue.type),
            value: issue.message,
          ),
        ),
        ...diagnostics.layoutRendererIssues.map(
          (issue) => _DiagnosticsRow(
            label: _rendererIssueTypeLabel(issue.type),
            value: issue.message,
          ),
        ),
      ],
    );
  }

  String _strategyIssueTypeLabel(POSLayoutStrategyRegistryIssueType type) {
    switch (type) {
      case POSLayoutStrategyRegistryIssueType.emptyRegistry:
        return 'Empty layouts';
      case POSLayoutStrategyRegistryIssueType.blankStrategyId:
        return 'Blank layout ID';
      case POSLayoutStrategyRegistryIssueType.duplicateStrategyId:
        return 'Duplicate ID';
      case POSLayoutStrategyRegistryIssueType.duplicateStrategy:
        return 'Duplicate layout';
      case POSLayoutStrategyRegistryIssueType.duplicatePreference:
        return 'Duplicate preference';
      case POSLayoutStrategyRegistryIssueType.emptySlots:
        return 'Missing slots';
      case POSLayoutStrategyRegistryIssueType.blankTrait:
        return 'Blank trait';
    }
  }

  String _rendererIssueTypeLabel(
    POSLayoutStrategyRendererRegistryIssueType type,
  ) {
    switch (type) {
      case POSLayoutStrategyRendererRegistryIssueType.missingRenderer:
        return 'Missing renderer';
      case POSLayoutStrategyRendererRegistryIssueType.duplicateRenderer:
        return 'Duplicate renderer';
      case POSLayoutStrategyRendererRegistryIssueType.unknownStrategy:
        return 'Unknown layout';
    }
  }
}

class _ShortcutIssueList extends StatelessWidget {
  final List<POSShellShortcutRegistryIssue> issues;

  const _ShortcutIssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          issues
              .map(
                (issue) => _DiagnosticsRow(
                  label: _issueTypeLabel(issue.type),
                  value: issue.message,
                ),
              )
              .toList(),
    );
  }

  String _issueTypeLabel(POSShellShortcutRegistryIssueType type) {
    switch (type) {
      case POSShellShortcutRegistryIssueType.blankShortcutId:
        return 'Blank shortcut ID';
      case POSShellShortcutRegistryIssueType.blankShortcutLabel:
        return 'Blank label';
      case POSShellShortcutRegistryIssueType.duplicateShortcutId:
        return 'Duplicate ID';
      case POSShellShortcutRegistryIssueType.duplicateShortcutActivator:
        return 'Duplicate binding';
    }
  }
}

class _CommandIssueList extends StatelessWidget {
  final List<POSCommandActionRegistryIssue> issues;

  const _CommandIssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          issues
              .map(
                (issue) => _DiagnosticsRow(
                  label: _issueTypeLabel(issue.type),
                  value: issue.message,
                ),
              )
              .toList(),
    );
  }

  String _issueTypeLabel(POSCommandActionRegistryIssueType type) {
    switch (type) {
      case POSCommandActionRegistryIssueType.blankActionId:
        return 'Blank action ID';
      case POSCommandActionRegistryIssueType.blankActionLabel:
        return 'Blank label';
      case POSCommandActionRegistryIssueType.duplicateActionId:
        return 'Duplicate ID';
      case POSCommandActionRegistryIssueType.duplicateShortcut:
        return 'Duplicate shortcut';
    }
  }
}

class _ActionAvailabilityGrid extends StatelessWidget {
  final List<POSActionDiagnostic> actions;

  const _ActionAvailabilityGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          actions
              .map((action) => _ActionAvailabilityTile(action: action))
              .toList(),
    );
  }
}

class _ActionAvailabilityTile extends StatelessWidget {
  final POSActionDiagnostic action;

  const _ActionAvailabilityTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(theme.colorScheme);

    return Container(
      width: 168,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(), size: 18, color: colors.foreground),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  action.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action.detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.foreground.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    if (action.available) return Icons.check_circle_outline;
    if (!action.capabilityEnabled) return Icons.block;
    if (!action.channelAllowed) return Icons.link_off_outlined;
    return Icons.extension_off_outlined;
  }

  _ActionTileColors _colors(ColorScheme colorScheme) {
    if (action.available) {
      return _ActionTileColors(
        background: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
        border: colorScheme.secondary.withValues(alpha: 0.22),
      );
    }

    if (!action.capabilityEnabled || !action.channelAllowed) {
      return _ActionTileColors(
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
        border: colorScheme.outlineVariant,
      );
    }

    return _ActionTileColors(
      background: colorScheme.errorContainer,
      foreground: colorScheme.onErrorContainer,
      border: colorScheme.error.withValues(alpha: 0.22),
    );
  }
}

class _ActionTileColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _ActionTileColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

class _RegistryIssueList extends StatelessWidget {
  final List<POSExperienceRegistryIssue> issues;

  const _RegistryIssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          issues
              .map(
                (issue) => _DiagnosticsRow(
                  label: _issueTypeLabel(issue.type),
                  value: issue.message,
                ),
              )
              .toList(),
    );
  }

  String _issueTypeLabel(POSExperienceRegistryIssueType type) {
    switch (type) {
      case POSExperienceRegistryIssueType.emptyRegistry:
        return 'Empty registry';
      case POSExperienceRegistryIssueType.blankExperienceId:
        return 'Blank mode ID';
      case POSExperienceRegistryIssueType.duplicateExperienceId:
        return 'Duplicate mode ID';
      case POSExperienceRegistryIssueType.duplicateModuleId:
        return 'Duplicate module ID';
      case POSExperienceRegistryIssueType.enabledCapabilityMissingModule:
        return 'Missing module';
      case POSExperienceRegistryIssueType.disabledCapabilityHasModule:
        return 'Disabled capability';
      case POSExperienceRegistryIssueType.blankManifestProductLine:
        return 'Blank product line';
      case POSExperienceRegistryIssueType.blankManifestArchetypeKey:
        return 'Blank archetype key';
      case POSExperienceRegistryIssueType.blankManifestArchetypeLabel:
        return 'Blank archetype label';
      case POSExperienceRegistryIssueType.emptyManifestFormFactors:
        return 'Missing form factors';
      case POSExperienceRegistryIssueType.blankManifestTrait:
        return 'Blank manifest trait';
      case POSExperienceRegistryIssueType.blankModuleId:
        return 'Blank module ID';
    }
  }
}

class _CommerceChannelIssueList extends StatelessWidget {
  final List<POSCommerceChannelRegistryIssue> issues;

  const _CommerceChannelIssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          issues
              .map(
                (issue) => _DiagnosticsRow(
                  label: _issueTypeLabel(issue.type),
                  value: issue.message,
                ),
              )
              .toList(),
    );
  }

  String _issueTypeLabel(POSCommerceChannelRegistryIssueType type) {
    switch (type) {
      case POSCommerceChannelRegistryIssueType.emptyRegistry:
        return 'Empty channels';
      case POSCommerceChannelRegistryIssueType.blankChannelId:
        return 'Blank channel ID';
      case POSCommerceChannelRegistryIssueType.duplicateChannelId:
        return 'Duplicate channel ID';
      case POSCommerceChannelRegistryIssueType.missingDefaultChannel:
        return 'Missing default';
      case POSCommerceChannelRegistryIssueType.blankLabel:
        return 'Blank label';
      case POSCommerceChannelRegistryIssueType.emptyFulfillmentModes:
        return 'Missing fulfillment';
      case POSCommerceChannelRegistryIssueType.emptyCapabilities:
        return 'Missing capabilities';
      case POSCommerceChannelRegistryIssueType.blankTrait:
        return 'Blank trait';
    }
  }
}

class _CommerceChannelBehaviorIssueList extends StatelessWidget {
  final List<POSCommerceChannelBehaviorRegistryIssue> issues;

  const _CommerceChannelBehaviorIssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          issues
              .map(
                (issue) => _DiagnosticsRow(
                  label: _issueTypeLabel(issue.type),
                  value: issue.message,
                ),
              )
              .toList(),
    );
  }

  String _issueTypeLabel(POSCommerceChannelBehaviorRegistryIssueType type) {
    switch (type) {
      case POSCommerceChannelBehaviorRegistryIssueType.emptyRegistry:
        return 'Empty behaviors';
      case POSCommerceChannelBehaviorRegistryIssueType.blankChannelId:
        return 'Blank channel ID';
      case POSCommerceChannelBehaviorRegistryIssueType.duplicateChannelId:
        return 'Duplicate channel';
      case POSCommerceChannelBehaviorRegistryIssueType.missingChannelBehavior:
        return 'Missing behavior';
      case POSCommerceChannelBehaviorRegistryIssueType.emptyModules:
        return 'Missing modules';
      case POSCommerceChannelBehaviorRegistryIssueType.blankModuleId:
        return 'Blank module ID';
      case POSCommerceChannelBehaviorRegistryIssueType.blankModuleLabel:
        return 'Blank module';
      case POSCommerceChannelBehaviorRegistryIssueType.duplicateModuleId:
        return 'Duplicate module';
      case POSCommerceChannelBehaviorRegistryIssueType.blankTrait:
        return 'Blank trait';
    }
  }
}

class _DiagnosticsRow extends StatelessWidget {
  final String label;
  final String value;

  const _DiagnosticsRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
