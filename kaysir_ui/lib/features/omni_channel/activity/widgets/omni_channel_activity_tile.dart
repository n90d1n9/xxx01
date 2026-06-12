import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import 'omni_channel_activity_presentation.dart';

/// Timeline row for a single omni-channel activity event.
class OmniChannelActivityTile extends StatelessWidget {
  final OmniChannelActivityEntry entry;
  final OmniChannelActivityAction? action;
  final OmniChannelActivityActionSelection? onActionSelected;
  final bool selected;
  final bool actionBusy;
  final ValueChanged<OmniChannelActivityEntry>? onSelected;

  const OmniChannelActivityTile({
    super.key,
    required this.entry,
    this.action,
    this.onActionSelected,
    this.selected = false,
    this.actionBusy = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = OmniChannelActivityEntryPresentation(entry);
    final severityVisuals = presentation.severityVisuals;
    final kindVisuals = presentation.kindVisuals;
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = omniChannelActivityToneColor(
      colorScheme,
      severityVisuals.tone,
    );
    final kindColor = omniChannelActivityToneColor(
      colorScheme,
      kindVisuals.tone,
    );

    return Semantics(
      label: '${severityVisuals.label} ${kindVisuals.label}: ${entry.title}',
      button: onSelected != null,
      selected: selected,
      child: Material(
        color:
            selected
                ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onSelected == null ? null : () => onSelected!(entry),
          child: Padding(
            padding: EdgeInsets.all(onSelected == null && !selected ? 0 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityIconBadge(
                  visuals: severityVisuals,
                  color: severityColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ActivityTileHeader(
                        title: presentation.title,
                        occurredAt: entry.occurredAt,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        presentation.detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          AppStatusPill(
                            label: severityVisuals.label,
                            color: severityColor,
                            icon: severityVisuals.icon,
                            maxWidth: 132,
                          ),
                          AppStatusPill(
                            label: kindVisuals.label,
                            color: kindColor,
                            icon: kindVisuals.icon,
                            maxWidth: 148,
                          ),
                          AppStatusPill(
                            label: entry.sourceLabel,
                            color: colorScheme.secondary,
                            icon: Icons.hub_outlined,
                            maxWidth: 160,
                          ),
                          if (_hasValue(entry.channelLabel ?? entry.channelId))
                            AppStatusPill(
                              label: entry.channelLabel ?? entry.channelId!,
                              color: colorScheme.tertiary,
                              icon: Icons.storefront_outlined,
                              maxWidth: 160,
                            ),
                          if (_hasValue(entry.orderId))
                            AppStatusPill(
                              label: entry.orderId!,
                              color: colorScheme.primary,
                              icon: Icons.receipt_long_outlined,
                              maxWidth: 160,
                            ),
                        ],
                      ),
                      if (action != null && onActionSelected != null) ...[
                        const SizedBox(height: 8),
                        _ActivityActionButton(
                          action: action!,
                          busy: actionBusy,
                          onPressed: () => onActionSelected!(entry, action!),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Omni-channel activity tile')
Widget omniChannelActivityTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityTile(
          selected: true,
          actionBusy: true,
          action: const OmniChannelActivityAction(
            label: 'Open sync queue',
            location: '/cashier',
            tooltip: 'Open the cashier workspace',
          ),
          onSelected: (_) {},
          onActionSelected: (_, _) {},
          entry: OmniChannelActivityEntry(
            id: 'preview',
            kind: OmniChannelActivityKind.orderSync,
            sourceId: 'point_of_sales',
            sourceLabel: 'Point of sale',
            occurredAt: DateTime(2026, 6, 9, 11, 30),
            title: 'Order sync failed',
            detail: 'Retry the queued counter order before shift handoff.',
            severity: OmniChannelActivitySeverity.attention,
            channelId: 'web_store',
            channelLabel: 'Web store',
            orderId: 'POS-2026-014',
          ),
        ),
      ),
    ),
  );
}

/// Inline action button that opens the most relevant workspace for the event.
class _ActivityActionButton extends StatelessWidget {
  final OmniChannelActivityAction action;
  final bool busy;
  final VoidCallback onPressed;

  const _ActivityActionButton({
    required this.action,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = OmniChannelActivityActionPresentation(action);
    final color = omniChannelActivityToneColor(
      Theme.of(context).colorScheme,
      presentation.tone,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: busy ? 'Action is already running' : presentation.tooltip,
        child: TextButton.icon(
          key: ValueKey('omni-channel-activity-action-${action.location}'),
          onPressed: presentation.isEnabled && !busy ? onPressed : null,
          icon:
              busy
                  ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Icon(presentation.icon, size: 18),
          label: Text(busy ? 'Working...' : presentation.label),
          style: TextButton.styleFrom(
            foregroundColor: presentation.isEnabled && !busy ? color : null,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}

/// Rounded icon badge used by activity timeline rows.
class _ActivityIconBadge extends StatelessWidget {
  final OmniChannelActivityVisuals visuals;
  final Color color;

  const _ActivityIconBadge({required this.visuals, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(visuals.icon, color: color, size: 20),
    );
  }
}

/// Header row that keeps the event title and time readable on narrow widths.
class _ActivityTileHeader extends StatelessWidget {
  final String title;
  final DateTime occurredAt;

  const _ActivityTileHeader({required this.title, required this.occurredAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          _timeLabel(context, occurredAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _timeLabel(BuildContext context, DateTime occurredAt) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatShortDate(occurredAt);
  final time = TimeOfDay.fromDateTime(occurredAt).format(context);
  return '$date $time';
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}
