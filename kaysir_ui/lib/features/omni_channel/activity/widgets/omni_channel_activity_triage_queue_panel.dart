import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_content_panel.dart';
import '../../../../widgets/ui/app_empty_state.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_filter.dart';
import '../models/omni_channel_activity_triage.dart';
import 'omni_channel_activity_presentation.dart';

/// Compact queue for jumping into the busiest attention and review groups.
class OmniChannelActivityTriageQueuePanel extends StatelessWidget {
  final OmniChannelActivityTriageQueue queue;
  final OmniChannelActivityFilter filter;
  final bool expanded;
  final ValueChanged<OmniChannelActivityTriageGroup>? onGroupSelected;
  final ValueChanged<bool>? onExpandedChanged;

  const OmniChannelActivityTriageQueuePanel({
    super.key,
    required this.queue,
    this.filter = const OmniChannelActivityFilter(),
    this.expanded = false,
    this.onGroupSelected,
    this.onExpandedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final summary = queue.summary;
    final canToggleExpansion =
        onExpandedChanged != null && (queue.hasHiddenGroups || expanded);

    return AppContentPanel(
      title: 'Triage queue',
      subtitle: summary.headline,
      leadingIcon: Icons.fact_check_outlined,
      trailing: queue.isEmpty ? null : _TriageQueueTotals(queue: queue),
      child:
          queue.isEmpty
              ? const AppEmptyState(
                icon: Icons.fact_check_outlined,
                title: 'All queues clear',
                message: 'Attention and review groups will appear here.',
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TriageFocusBanner(
                    summary: summary,
                    onPressed:
                        onGroupSelected == null || summary.focusGroup == null
                            ? null
                            : () => onGroupSelected!(summary.focusGroup!),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    key: const ValueKey('omni-channel-activity-triage-queue'),
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final group in queue.groups)
                        _TriageGroupButton(
                          group: group,
                          selected: group.isSelectedBy(filter),
                          onPressed:
                              onGroupSelected == null
                                  ? null
                                  : () => onGroupSelected!(group),
                        ),
                    ],
                  ),
                  if (canToggleExpansion) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _TriageQueueExpansionButton(
                        queue: queue,
                        expanded: expanded,
                        onPressed: () => onExpandedChanged!(!expanded),
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Omni-channel activity triage queue panel')
Widget omniChannelActivityTriageQueuePanelPreview() {
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
        orderId: 'ECOM-2026-017',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
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
      ),
    ],
  );
  final queue = feed.triageQueueFor(const OmniChannelActivityFilter());

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityTriageQueuePanel(
          queue: queue,
          onGroupSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Focus recommendation shown before individual triage queue shortcuts.
class _TriageFocusBanner extends StatelessWidget {
  final OmniChannelActivityTriageSummary summary;
  final VoidCallback? onPressed;

  const _TriageFocusBanner({required this.summary, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visuals = omniChannelActivitySeverityVisuals(summary.severity);
    final color = omniChannelActivityToneColor(colorScheme, visuals.tone);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final copy = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TriageFocusIcon(visuals: visuals, color: color),
            const SizedBox(width: 10),
            Expanded(child: _TriageFocusCopy(summary: summary, color: color)),
          ],
        );
        final action =
            onPressed == null
                ? null
                : OutlinedButton.icon(
                  key: const ValueKey(
                    'omni-channel-activity-triage-open-focus',
                  ),
                  icon: const Icon(Icons.arrow_forward_outlined),
                  label: Text(summary.actionLabel),
                  onPressed: onPressed,
                );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                compact || action == null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        copy,
                        if (action != null) ...[
                          const SizedBox(height: 10),
                          action,
                        ],
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: copy),
                        const SizedBox(width: 10),
                        action,
                      ],
                    ),
          ),
        );
      },
    );
  }
}

/// Tone-aware leading icon for the current triage focus.
class _TriageFocusIcon extends StatelessWidget {
  final OmniChannelActivityVisuals visuals;
  final Color color;

  const _TriageFocusIcon({required this.visuals, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(visuals.icon, size: 18, color: color),
    );
  }
}

/// Bounded headline and detail copy for the triage focus recommendation.
class _TriageFocusCopy extends StatelessWidget {
  final OmniChannelActivityTriageSummary summary;
  final Color color;

  const _TriageFocusCopy({required this.summary, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          summary.headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          summary.detail,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (summary.hasHiddenQueues) ...[
          const SizedBox(height: 3),
          Text(
            summary.overflowLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact action for switching between compact and expanded queue density.
class _TriageQueueExpansionButton extends StatelessWidget {
  final OmniChannelActivityTriageQueue queue;
  final bool expanded;
  final VoidCallback onPressed;

  const _TriageQueueExpansionButton({
    required this.queue,
    required this.expanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const ValueKey('omni-channel-activity-triage-toggle-expanded'),
      icon: Icon(
        expanded ? Icons.unfold_less_outlined : Icons.unfold_more_outlined,
      ),
      label: Text(_label),
      onPressed: onPressed,
    );
  }

  String get _label {
    if (expanded) return 'Show fewer queues';

    return 'Show all ${_countLabel(queue.totalGroupCount, 'queue')}';
  }
}

/// Header totals for visible triage work.
class _TriageQueueTotals extends StatelessWidget {
  final OmniChannelActivityTriageQueue queue;

  const _TriageQueueTotals({required this.queue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: _countLabel(queue.attentionCount, 'attention'),
          color: colorScheme.error,
          icon: Icons.priority_high_outlined,
          maxWidth: 154,
        ),
        AppStatusPill(
          label: _countLabel(queue.reviewCount, 'review'),
          color: colorScheme.tertiary,
          icon: Icons.pending_actions_outlined,
          maxWidth: 132,
        ),
      ],
    );
  }
}

/// Selectable queue item with urgency, dimension, and compact counts.
class _TriageGroupButton extends StatelessWidget {
  final OmniChannelActivityTriageGroup group;
  final bool selected;
  final VoidCallback? onPressed;

  const _TriageGroupButton({
    required this.group,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visuals = omniChannelActivitySeverityVisuals(group.severity);
    final color = omniChannelActivityToneColor(colorScheme, visuals.tone);

    return Tooltip(
      message: _tooltip(group),
      child: OutlinedButton(
        key: ValueKey(
          'omni-channel-activity-triage-${group.dimension.key}-${group.id}',
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: selected ? color.withValues(alpha: 0.1) : null,
          foregroundColor: colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          side: BorderSide(
            color: selected ? color : colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 188, maxWidth: 246),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TriageGroupIcon(group: group, color: color),
              const SizedBox(width: 10),
              Expanded(child: _TriageGroupCopy(group: group, color: color)),
              const SizedBox(width: 8),
              _TriageGroupCount(group: group, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dimension-aware icon used by each triage queue item.
class _TriageGroupIcon extends StatelessWidget {
  final OmniChannelActivityTriageGroup group;
  final Color color;

  const _TriageGroupIcon({required this.group, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_dimensionIcon(group.dimension), size: 18, color: color),
    );
  }
}

/// Text labels for a queue group, bounded for compact responsive layouts.
class _TriageGroupCopy extends StatelessWidget {
  final OmniChannelActivityTriageGroup group;
  final Color color;

  const _TriageGroupCopy({required this.group, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          group.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${_dimensionLabel(group.dimension)} / ${_workLabel(group)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Stable count badge for the total visible work in a group.
class _TriageGroupCount extends StatelessWidget {
  final OmniChannelActivityTriageGroup group;
  final Color color;

  const _TriageGroupCount({required this.group, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        group.totalCount.toString(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _tooltip(OmniChannelActivityTriageGroup group) {
  return '${group.label}: ${_workLabel(group)}';
}

String _workLabel(OmniChannelActivityTriageGroup group) {
  final parts = <String>[
    if (group.attentionCount > 0)
      _countLabel(group.attentionCount, 'attention'),
    if (group.reviewCount > 0) _countLabel(group.reviewCount, 'review'),
  ];

  return parts.join(' / ');
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}

String _dimensionLabel(OmniChannelActivityTriageDimension dimension) {
  return dimension.label;
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
      return Icons.category_outlined;
  }
}
