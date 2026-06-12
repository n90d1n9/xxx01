import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_content_panel.dart';
import '../../../../widgets/ui/app_empty_state.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_registry_diagnostics.dart';
import '../models/omni_channel_activity_triage.dart';
import 'omni_channel_activity_module_registry_section.dart';
import 'omni_channel_activity_presentation.dart';
import 'omni_channel_activity_registry_card.dart';
import 'omni_channel_activity_registry_issue_section.dart';

/// Read-only diagnostics for registered activity dimensions and actions.
class OmniChannelActivityRegistryDiagnosticsPanel extends StatelessWidget {
  final OmniChannelActivityRegistryDiagnostics diagnostics;

  const OmniChannelActivityRegistryDiagnosticsPanel({
    super.key,
    required this.diagnostics,
  });

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      key: const ValueKey('omni-channel-activity-registry-diagnostics'),
      title: 'Registry diagnostics',
      subtitle: diagnostics.summaryLabel,
      leadingIcon: Icons.extension_outlined,
      trailing: _RegistryDiagnosticTotals(diagnostics: diagnostics),
      child:
          diagnostics.hasContributions
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OmniChannelActivityModuleRegistrySection(
                    modules: diagnostics.modules,
                    issues: diagnostics.moduleRegistrationIssues,
                  ),
                  const SizedBox(height: 14),
                  _RegistryDimensionSection(
                    dimensions: diagnostics.triageDimensions,
                  ),
                  if (diagnostics.hasDuplicateDimensions) ...[
                    const SizedBox(height: 14),
                    _RegistryDuplicateDimensionSection(
                      duplicates: diagnostics.duplicateDimensions,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _RegistryContributorSection(
                    contributors: diagnostics.actionContributors,
                  ),
                  if (diagnostics.hasContributorRegistrationIssues) ...[
                    const SizedBox(height: 14),
                    OmniChannelActivityRegistryIssueSection(
                      issues: diagnostics.contributorRegistrationIssues,
                    ),
                  ],
                  if (diagnostics.hasDuplicateActions) ...[
                    const SizedBox(height: 14),
                    _RegistryDuplicateActionSection(
                      duplicates: diagnostics.duplicateActions,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _RegistryActionSection(actions: diagnostics.actions),
                ],
              )
              : const AppEmptyState(
                icon: Icons.extension_off_outlined,
                title: 'No registry contributions',
                message: 'Activity extensions will appear here.',
              ),
    );
  }
}

@Preview(name: 'Omni-channel registry diagnostics panel')
Widget omniChannelActivityRegistryDiagnosticsPanelPreview() {
  final feed = OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'preview-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 11, 30),
        title: 'Order sync failed',
        detail: 'Retry the queued counter order before shift handoff.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'POS-2026-014',
      ),
      OmniChannelActivityEntry(
        id: 'preview-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Marketplace pickup needs review',
        detail: 'Confirm pickup capacity before accepting handoff.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-2026-017',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
    ],
  );
  final diagnostics = OmniChannelActivityRegistryDiagnostics.fromFeed(
    feed: feed,
    actionRegistry: OmniChannelActivityActionRegistry(
      contributors: [_previewActivityActionContributor],
      contributorDescriptors: const [
        OmniChannelActivityActionContributorDescriptor(
          id: 'preview_actions',
          label: 'Preview actions',
          description: 'Demo action contributor',
        ),
      ],
    ),
    triageDimensions: defaultOmniChannelActivityTriageDimensionDefinitions,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityRegistryDiagnosticsPanel(
          diagnostics: diagnostics,
        ),
      ),
    ),
  );
}

/// Header totals for registry diagnostics.
class _RegistryDiagnosticTotals extends StatelessWidget {
  final OmniChannelActivityRegistryDiagnostics diagnostics;

  const _RegistryDiagnosticTotals({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: _countLabel(diagnostics.moduleCount, 'module'),
          color: colorScheme.primary,
          icon: Icons.view_module_outlined,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: _countLabel(
            diagnostics.activeDimensionCount,
            'active dimension',
          ),
          color: colorScheme.secondary,
          icon: Icons.account_tree_outlined,
          maxWidth: 190,
        ),
        AppStatusPill(
          label: _countLabel(
            diagnostics.activeActionContributorCount,
            'active contributor',
          ),
          color: colorScheme.primary,
          icon: Icons.extension_outlined,
          maxWidth: 190,
        ),
        if (diagnostics.hasDuplicateActions)
          AppStatusPill(
            label: _countLabel(diagnostics.duplicateActionCount, 'duplicate'),
            color: colorScheme.error,
            icon: Icons.warning_amber_outlined,
            maxWidth: 142,
          ),
        if (diagnostics.hasContributorRegistrationIssues)
          AppStatusPill(
            label: _countLabel(
              diagnostics.contributorRegistrationIssueCount,
              'registration issue',
            ),
            color: colorScheme.error,
            icon: Icons.report_problem_outlined,
            maxWidth: 190,
          ),
        if (diagnostics.hasModuleRegistrationIssues)
          AppStatusPill(
            label: _countLabel(
              diagnostics.moduleRegistrationIssueCount,
              'module issue',
            ),
            color: colorScheme.error,
            icon: Icons.view_module_outlined,
            maxWidth: 164,
          ),
        if (diagnostics.hasDuplicateDimensions)
          AppStatusPill(
            label: _countLabel(
              diagnostics.duplicateDimensionCount,
              'dimension duplicate',
            ),
            color: colorScheme.error,
            icon: Icons.warning_amber_outlined,
            maxWidth: 194,
          ),
      ],
    );
  }
}

/// Section that lists each registered triage dimension.
class _RegistryDimensionSection extends StatelessWidget {
  final List<OmniChannelActivityTriageDimensionDiagnostic> dimensions;

  const _RegistryDimensionSection({required this.dimensions});

  @override
  Widget build(BuildContext context) {
    return OmniChannelActivityRegistrySection(
      title: 'Triage dimensions',
      icon: Icons.account_tree_outlined,
      child: Wrap(
        key: const ValueKey('omni-channel-registry-dimensions'),
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final dimension in dimensions)
            _RegistryDimensionTile(diagnostic: dimension),
        ],
      ),
    );
  }
}

/// Section that lists triage dimension keys registered more than once.
class _RegistryDuplicateDimensionSection extends StatelessWidget {
  final List<OmniChannelActivityTriageDimensionDuplicateDiagnostic> duplicates;

  const _RegistryDuplicateDimensionSection({required this.duplicates});

  @override
  Widget build(BuildContext context) {
    return OmniChannelActivityRegistrySection(
      title: 'Duplicate triage dimensions',
      icon: Icons.warning_amber_outlined,
      child: Wrap(
        key: const ValueKey('omni-channel-registry-duplicate-dimensions'),
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final duplicate in duplicates)
            _RegistryDuplicateDimensionTile(diagnostic: duplicate),
        ],
      ),
    );
  }
}

/// Section that lists each registered action contributor.
class _RegistryContributorSection extends StatelessWidget {
  final List<OmniChannelActivityActionContributorDiagnostic> contributors;

  const _RegistryContributorSection({required this.contributors});

  @override
  Widget build(BuildContext context) {
    return OmniChannelActivityRegistrySection(
      title: 'Action contributors',
      icon: Icons.extension_outlined,
      child: Wrap(
        key: const ValueKey('omni-channel-registry-contributors'),
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final contributor in contributors)
            _RegistryContributorTile(diagnostic: contributor),
        ],
      ),
    );
  }
}

/// Section that lists action identities emitted by multiple contributors.
class _RegistryDuplicateActionSection extends StatelessWidget {
  final List<OmniChannelActivityActionDuplicateDiagnostic> duplicates;

  const _RegistryDuplicateActionSection({required this.duplicates});

  @override
  Widget build(BuildContext context) {
    return OmniChannelActivityRegistrySection(
      title: 'Duplicate action identities',
      icon: Icons.warning_amber_outlined,
      child: Wrap(
        key: const ValueKey('omni-channel-registry-duplicate-actions'),
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final duplicate in duplicates)
            _RegistryDuplicateActionTile(diagnostic: duplicate),
        ],
      ),
    );
  }
}

/// Section that lists unique actions resolved by the current registry.
class _RegistryActionSection extends StatelessWidget {
  final List<OmniChannelActivityActionDiagnostic> actions;

  const _RegistryActionSection({required this.actions});

  @override
  Widget build(BuildContext context) {
    return OmniChannelActivityRegistrySection(
      title: 'Action coverage',
      icon: Icons.bolt_outlined,
      child:
          actions.isEmpty
              ? const AppEmptyState(
                icon: Icons.bolt_outlined,
                title: 'No actions resolved',
                message:
                    'Registered actions will appear with matching activity.',
              )
              : Wrap(
                key: const ValueKey('omni-channel-registry-actions'),
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final action in actions)
                    _RegistryActionTile(diagnostic: action),
                ],
              ),
    );
  }
}

/// Compact coverage tile for one action contributor.
class _RegistryContributorTile extends StatelessWidget {
  final OmniChannelActivityActionContributorDiagnostic diagnostic;

  const _RegistryContributorTile({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        diagnostic.hasResolvedActions
            ? colorScheme.primary
            : colorScheme.outline;
    final description = diagnostic.description.trim();

    return OmniChannelActivityRegistryTile(
      key: ValueKey('omni-channel-registry-contributor-${diagnostic.id}'),
      icon: Icons.extension_outlined,
      color: color,
      title: diagnostic.label,
      subtitle:
          description.isEmpty ? 'Registered action contributor' : description,
      children: [
        AppStatusPill(
          label: _countLabel(diagnostic.actionCount, 'action'),
          color: color,
          icon: Icons.bolt_outlined,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: _countLabel(diagnostic.matchedEntryCount, 'matched event'),
          color: colorScheme.secondary,
          icon: Icons.timeline_outlined,
          maxWidth: 168,
        ),
      ],
    );
  }
}

/// Compact warning tile for one duplicate action identity.
class _RegistryDuplicateActionTile extends StatelessWidget {
  final OmniChannelActivityActionDuplicateDiagnostic diagnostic;

  const _RegistryDuplicateActionTile({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contributors = diagnostic.contributorLabel;

    return OmniChannelActivityRegistryTile(
      key: ValueKey('omni-channel-registry-duplicate-${diagnostic.identity}'),
      icon: Icons.warning_amber_outlined,
      color: colorScheme.error,
      title: diagnostic.label,
      subtitle: contributors.isEmpty ? diagnostic.identity : contributors,
      children: [
        AppStatusPill(
          label: _countLabel(diagnostic.contributorCount, 'contributor'),
          color: colorScheme.error,
          icon: Icons.extension_outlined,
          maxWidth: 164,
        ),
        AppStatusPill(
          label: _countLabel(diagnostic.eventCount, 'event'),
          color: colorScheme.tertiary,
          icon: Icons.timeline_outlined,
          maxWidth: 132,
        ),
      ],
    );
  }
}

/// Compact warning tile for one duplicate triage dimension key.
class _RegistryDuplicateDimensionTile extends StatelessWidget {
  final OmniChannelActivityTriageDimensionDuplicateDiagnostic diagnostic;

  const _RegistryDuplicateDimensionTile({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = diagnostic.label.trim();

    return OmniChannelActivityRegistryTile(
      key: ValueKey(
        'omni-channel-registry-duplicate-dimension-${diagnostic.key}',
      ),
      icon: Icons.account_tree_outlined,
      color: colorScheme.error,
      title: label.isEmpty ? diagnostic.key : label,
      subtitle: 'Key: ${diagnostic.key}',
      children: [
        AppStatusPill(
          label: _countLabel(diagnostic.definitionCount, 'definition'),
          color: colorScheme.error,
          icon: Icons.account_tree_outlined,
          maxWidth: 154,
        ),
      ],
    );
  }
}

/// Compact coverage tile for one triage dimension.
class _RegistryDimensionTile extends StatelessWidget {
  final OmniChannelActivityTriageDimensionDiagnostic diagnostic;

  const _RegistryDimensionTile({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color =
        diagnostic.hasResolvedQueues
            ? colorScheme.primary
            : colorScheme.outline;
    final topQueueLabel = diagnostic.topQueueLabel?.trim();

    return OmniChannelActivityRegistryTile(
      key: ValueKey(
        'omni-channel-registry-dimension-${diagnostic.dimension.key}',
      ),
      icon: _dimensionIcon(diagnostic.dimension),
      color: color,
      title: diagnostic.dimension.label,
      subtitle:
          topQueueLabel == null || topQueueLabel.isEmpty
              ? 'No queues resolved'
              : 'Top queue: $topQueueLabel',
      children: [
        AppStatusPill(
          label: _countLabel(diagnostic.queueCount, 'queue'),
          color: color,
          icon: Icons.format_list_bulleted_outlined,
          maxWidth: 132,
        ),
        if (diagnostic.attentionCount > 0)
          AppStatusPill(
            label: _countLabel(diagnostic.attentionCount, 'attention'),
            color: colorScheme.error,
            icon: Icons.priority_high_outlined,
            maxWidth: 154,
          ),
        if (diagnostic.reviewCount > 0)
          AppStatusPill(
            label: _countLabel(diagnostic.reviewCount, 'review'),
            color: colorScheme.tertiary,
            icon: Icons.pending_actions_outlined,
            maxWidth: 132,
          ),
      ],
    );
  }
}

/// Compact coverage tile for one unique resolved action identity.
class _RegistryActionTile extends StatelessWidget {
  final OmniChannelActivityActionDiagnostic diagnostic;

  const _RegistryActionTile({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visuals = _intentVisuals(diagnostic.intent);
    final color = omniChannelActivityToneColor(colorScheme, visuals.tone);

    return OmniChannelActivityRegistryTile(
      key: ValueKey('omni-channel-registry-action-${diagnostic.identity}'),
      icon: visuals.icon,
      color: color,
      title: diagnostic.label,
      subtitle: visuals.label,
      children: [
        AppStatusPill(
          label: _countLabel(diagnostic.eventCount, 'event'),
          color: color,
          icon: Icons.timeline_outlined,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: _countLabel(diagnostic.primaryEventCount, 'primary'),
          color: colorScheme.secondary,
          icon: Icons.star_border_outlined,
          maxWidth: 132,
        ),
        if (diagnostic.hasDisabledEvents)
          AppStatusPill(
            label: _countLabel(diagnostic.disabledEventCount, 'disabled'),
            color: colorScheme.error,
            icon: Icons.block_outlined,
            maxWidth: 132,
          ),
      ],
    );
  }
}

Iterable<OmniChannelActivityAction> _previewActivityActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  if (entry.requiresAttention) {
    yield const OmniChannelActivityAction(
      id: 'preview-retry',
      label: 'Retry sync',
      location: '/cashier',
      tooltip: 'Retry failed sync',
      intent: OmniChannelActivityActionIntent.retry,
    );
  }

  yield const OmniChannelActivityAction(
    id: 'preview-review',
    label: 'Review order',
    location: '/commerce/orders',
    tooltip: 'Review order workspace',
    intent: OmniChannelActivityActionIntent.review,
    priority: 20,
  );
}

OmniChannelActivityVisuals _intentVisuals(
  OmniChannelActivityActionIntent intent,
) {
  return OmniChannelActivityActionPresentation(
    OmniChannelActivityAction(
      label: '',
      location: '',
      tooltip: '',
      intent: intent,
    ),
  ).visuals;
}

IconData _dimensionIcon(OmniChannelActivityTriageDimension dimension) {
  switch (dimension.key) {
    case OmniChannelActivityTriageDimension.sourceKey:
      return Icons.hub_outlined;
    case OmniChannelActivityTriageDimension.channelKey:
      return Icons.storefront_outlined;
    case OmniChannelActivityTriageDimension.fulfillmentKey:
      return Icons.local_shipping_outlined;
    default:
      return Icons.account_tree_outlined;
  }
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
