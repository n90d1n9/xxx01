import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_content_panel.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_relation.dart';
import '../omni_channel_activity_action_registry.dart';
import 'omni_channel_activity_detail_panel.dart';
import 'omni_channel_activity_timeline.dart';

/// Responsive workspace that pairs the activity feed with selected event detail.
class OmniChannelActivityWorkspace extends StatelessWidget {
  final OmniChannelActivityFeed feed;
  final List<OmniChannelActivityEntry> entries;
  final OmniChannelActivityEntry? selectedEntry;
  final bool hasActiveFilters;
  final OmniChannelActivityActionRegistry actionRegistry;
  final ValueChanged<OmniChannelActivityEntry> onEntrySelected;
  final OmniChannelActivityActionSelection onActionSelected;
  final Set<String> busyActionKeys;

  const OmniChannelActivityWorkspace({
    super.key,
    required this.feed,
    required this.entries,
    required this.selectedEntry,
    required this.hasActiveFilters,
    this.actionRegistry = omniChannelDefaultActivityActionRegistry,
    required this.onEntrySelected,
    required this.onActionSelected,
    this.busyActionKeys = const <String>{},
  });

  @override
  Widget build(BuildContext context) {
    final detailActionSet =
        selectedEntry == null
            ? const OmniChannelActivityActionSet.empty()
            : actionRegistry.actionSetFor(selectedEntry!);
    final relatedActivity =
        selectedEntry == null
            ? const <OmniChannelRelatedActivityEntry>[]
            : OmniChannelRelatedActivity.fromEntries(
              selectedEntry: selectedEntry!,
              entries: feed.entries,
            ).entries;
    final feedPanel = AppContentPanel(
      title: 'Activity feed',
      subtitle: _feedSubtitle(feed, entries.length),
      leadingIcon: Icons.timeline_outlined,
      trailing: _ActivityMetrics(feed: feed),
      child: OmniChannelActivityTimeline(
        entries: entries,
        hasActiveFilters: hasActiveFilters,
        selectedEntryId: selectedEntry?.id,
        busyActionKeys: busyActionKeys,
        actionResolver: actionRegistry.primaryActionFor,
        onEntrySelected: onEntrySelected,
        onActionSelected: onActionSelected,
      ),
    );
    final detailPanel = AppContentPanel(
      title: 'Activity detail',
      subtitle: selectedEntry?.sourceLabel ?? 'Review selected event context',
      leadingIcon: Icons.article_outlined,
      child: OmniChannelActivityDetailPanel(
        entry: selectedEntry,
        action: detailActionSet.primary,
        secondaryActions: detailActionSet.secondary,
        relatedActivity: relatedActivity,
        busyActionKeys: busyActionKeys,
        onActionSelected: onActionSelected,
        onRelatedEntrySelected: onEntrySelected,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [detailPanel, const SizedBox(height: 14), feedPanel],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: feedPanel),
            const SizedBox(width: 14),
            Expanded(flex: 4, child: detailPanel),
          ],
        );
      },
    );
  }
}

@Preview(name: 'Omni-channel activity workspace')
Widget omniChannelActivityWorkspacePreview() {
  final feed = OmniChannelActivityFeed(
    entries: [
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
        supportSummary: 'Review pickup capacity with store ops.',
      ),
      OmniChannelActivityEntry(
        id: 'preview-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 10, 30),
        title: 'Order sync failed',
        detail: 'Retry the queued counter order before shift handoff.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-2026-017',
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityWorkspace(
          feed: feed,
          entries: feed.entries,
          selectedEntry: feed.entries.first,
          hasActiveFilters: false,
          onEntrySelected: (_) {},
          onActionSelected: (_, _) {},
        ),
      ),
    ),
  );
}

/// Compact metric strip for the activity center feed panel.
class _ActivityMetrics extends StatelessWidget {
  final OmniChannelActivityFeed feed;

  const _ActivityMetrics({required this.feed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: _countLabel(feed.entries.length, 'event'),
          color: colorScheme.primary,
          icon: Icons.timeline_outlined,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: _countLabel(feed.attentionCount, 'attention'),
          color: colorScheme.error,
          icon: Icons.priority_high_outlined,
          maxWidth: 154,
        ),
        AppStatusPill(
          label: _countLabel(feed.reviewCount, 'review'),
          color: colorScheme.tertiary,
          icon: Icons.pending_actions_outlined,
          maxWidth: 132,
        ),
      ],
    );
  }
}

String _feedSubtitle(OmniChannelActivityFeed feed, int visibleCount) {
  if (feed.isEmpty) return 'No activity recorded';
  return '${_countLabel(visibleCount, 'visible event')} from '
      '${_countLabel(feed.entries.length, 'total event')}';
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
