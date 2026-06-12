import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_empty_state.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution_key.dart';
import '../omni_channel_activity_action_registry.dart';
import 'omni_channel_activity_tile.dart';

/// Vertical list of filtered omni-channel activity events.
class OmniChannelActivityTimeline extends StatelessWidget {
  final List<OmniChannelActivityEntry> entries;
  final bool hasActiveFilters;
  final OmniChannelActivityActionResolver actionResolver;
  final OmniChannelActivityActionSelection? onActionSelected;
  final String? selectedEntryId;
  final ValueChanged<OmniChannelActivityEntry>? onEntrySelected;
  final Set<String> busyActionKeys;

  const OmniChannelActivityTimeline({
    super.key,
    required this.entries,
    this.hasActiveFilters = false,
    this.actionResolver = omniChannelActivityActionFor,
    this.onActionSelected,
    this.selectedEntryId,
    this.onEntrySelected,
    this.busyActionKeys = const <String>{},
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return AppEmptyState(
        icon:
            hasActiveFilters
                ? Icons.search_off_outlined
                : Icons.manage_search_outlined,
        title:
            hasActiveFilters
                ? 'No matching activity'
                : 'No omni-channel activity yet',
        message:
            hasActiveFilters
                ? 'Adjust the search or activity status filter.'
                : 'POS, ecommerce, sync, and channel activity will appear here.',
      );
    }

    final rows = <Widget>[];
    for (var index = 0; index < entries.length; index++) {
      if (index > 0) rows.add(const Divider(height: 22));

      final entry = entries[index];
      final action = actionResolver(entry);
      rows.add(
        OmniChannelActivityTile(
          entry: entry,
          action: action,
          actionBusy: _isActionBusy(entry, action),
          onActionSelected: onActionSelected,
          selected: entry.id == selectedEntryId,
          onSelected: onEntrySelected,
        ),
      );
    }

    return Column(
      key: const ValueKey('omni-channel-activity-timeline'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  bool _isActionBusy(
    OmniChannelActivityEntry entry,
    OmniChannelActivityAction? action,
  ) {
    if (action == null) return false;

    return busyActionKeys.contains(
      OmniChannelActivityActionExecutionKey.fromAction(
        entry: entry,
        action: action,
      ).value,
    );
  }
}

@Preview(name: 'Omni-channel activity timeline')
Widget omniChannelActivityTimelinePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityTimeline(
          entries: [
            OmniChannelActivityEntry(
              id: 'preview-1',
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
          selectedEntryId: 'preview-1',
          onEntrySelected: (_) {},
          onActionSelected: (_, _) {},
        ),
      ),
    ),
  );
}
