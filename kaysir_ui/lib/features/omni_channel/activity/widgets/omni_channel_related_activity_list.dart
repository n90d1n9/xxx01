import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_relation.dart';
import 'omni_channel_activity_presentation.dart';

/// Compact list of activity events related to the selected event.
class OmniChannelRelatedActivityList extends StatelessWidget {
  final List<OmniChannelRelatedActivityEntry> entries;
  final ValueChanged<OmniChannelActivityEntry>? onEntrySelected;

  const OmniChannelRelatedActivityList({
    super.key,
    required this.entries,
    this.onEntrySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      key: const ValueKey('omni-channel-related-activity-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Related activity',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _RelatedActivityTile(
            relatedEntry: entries[index],
            onSelected:
                onEntrySelected == null
                    ? null
                    : () => onEntrySelected!(entries[index].entry),
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Omni-channel related activity list')
Widget omniChannelRelatedActivityListPreview() {
  final selectedEntry = OmniChannelActivityEntry(
    id: 'preview-order',
    kind: OmniChannelActivityKind.order,
    sourceId: 'ecommerce',
    sourceLabel: 'Ecommerce',
    occurredAt: DateTime(2026, 6, 9, 11),
    title: 'Marketplace pickup needs review',
    detail: 'Confirm pickup capacity before accepting handoff.',
    channelId: 'marketplace',
    channelLabel: 'Marketplace',
    orderId: 'ECOM-2026-017',
  );
  final related = OmniChannelRelatedActivity.fromEntries(
    selectedEntry: selectedEntry,
    entries: [
      selectedEntry,
      OmniChannelActivityEntry(
        id: 'preview-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 10, 40),
        title: 'Counter sync completed',
        detail: 'The POS handoff reached ecommerce.',
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-2026-017',
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: OmniChannelRelatedActivityList(
          entries: related.entries,
          onEntrySelected: (_) {},
        ),
      ),
    ),
  );
}

/// Selectable row for one related activity item.
class _RelatedActivityTile extends StatelessWidget {
  final OmniChannelRelatedActivityEntry relatedEntry;
  final VoidCallback? onSelected;

  const _RelatedActivityTile({required this.relatedEntry, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final entry = relatedEntry.entry;
    final presentation = OmniChannelActivityEntryPresentation(entry);
    final kindVisuals = presentation.kindVisuals;
    final colorScheme = Theme.of(context).colorScheme;
    final kindColor = omniChannelActivityToneColor(
      colorScheme,
      kindVisuals.tone,
    );

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppStatusPill(
                    label: relatedEntry.relation.label,
                    color: colorScheme.primary,
                    icon: Icons.link_outlined,
                    maxWidth: 150,
                  ),
                  AppStatusPill(
                    label: kindVisuals.label,
                    color: kindColor,
                    icon: kindVisuals.icon,
                    maxWidth: 148,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                _contextLine(context, entry),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _contextLine(BuildContext context, OmniChannelActivityEntry entry) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatShortDate(entry.occurredAt);
  final time = TimeOfDay.fromDateTime(entry.occurredAt).format(context);
  final parts = [
    entry.sourceLabel,
    if (_hasValue(entry.channelLabel ?? entry.channelId))
      entry.channelLabel ?? entry.channelId!,
    if (_hasValue(entry.orderId)) entry.orderId!,
    '$date $time',
  ];

  return parts.join(' / ');
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}
