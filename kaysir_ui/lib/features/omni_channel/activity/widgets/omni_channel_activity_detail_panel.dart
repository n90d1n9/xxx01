import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_empty_state.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution_key.dart';
import '../models/omni_channel_activity_detail.dart';
import '../models/omni_channel_activity_relation.dart';
import 'omni_channel_activity_action_availability_notice.dart';
import 'omni_channel_activity_presentation.dart';
import 'omni_channel_related_activity_list.dart';

/// Detail surface for the currently selected omni-channel activity event.
class OmniChannelActivityDetailPanel extends StatelessWidget {
  final OmniChannelActivityEntry? entry;
  final OmniChannelActivityAction? action;
  final List<OmniChannelActivityAction> secondaryActions;
  final List<OmniChannelRelatedActivityEntry> relatedActivity;
  final OmniChannelActivityActionSelection? onActionSelected;
  final ValueChanged<OmniChannelActivityEntry>? onRelatedEntrySelected;
  final Set<String> busyActionKeys;

  const OmniChannelActivityDetailPanel({
    super.key,
    required this.entry,
    this.action,
    this.secondaryActions = const [],
    this.relatedActivity = const [],
    this.onActionSelected,
    this.onRelatedEntrySelected,
    this.busyActionKeys = const <String>{},
  });

  @override
  Widget build(BuildContext context) {
    final selectedEntry = entry;
    if (selectedEntry == null) {
      return const AppEmptyState(
        icon: Icons.touch_app_outlined,
        title: 'Select an activity',
        message:
            'Choose an event to review its channel, order, and support context.',
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final detail = OmniChannelActivityDetail.fromEntry(selectedEntry);
    final presentation = OmniChannelActivityEntryPresentation(selectedEntry);
    final severityVisuals = presentation.severityVisuals;
    final kindVisuals = presentation.kindVisuals;
    final severityColor = omniChannelActivityToneColor(
      colorScheme,
      severityVisuals.tone,
    );
    final kindColor = omniChannelActivityToneColor(
      colorScheme,
      kindVisuals.tone,
    );

    return Column(
      key: const ValueKey('omni-channel-activity-detail-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailHeading(
          title: detail.title,
          contextLabel: detail.contextLabel,
          icon: kindVisuals.icon,
          iconColor: kindColor,
        ),
        const SizedBox(height: 12),
        Text(
          detail.summary,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
              maxWidth: 154,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _DetailFieldGrid(
          fields: [
            OmniChannelActivityDetailField(
              label: 'Occurred',
              value: _timeLabel(context, selectedEntry.occurredAt),
            ),
            ...detail.primaryFields,
          ],
        ),
        if (detail.hasAttributes) ...[
          const SizedBox(height: 16),
          _DetailFieldGrid(title: 'Event data', fields: detail.attributeFields),
        ],
        if (_hasActions) ...[
          const SizedBox(height: 16),
          _DetailActionStrip(
            entry: selectedEntry,
            action: action,
            secondaryActions: secondaryActions,
            busyActionKeys: busyActionKeys,
            onActionSelected: onActionSelected!,
          ),
          if (_disabledActions.isNotEmpty) ...[
            const SizedBox(height: 10),
            OmniChannelActivityActionAvailabilityNotice(
              actions: _disabledActions,
            ),
          ],
        ],
        if (relatedActivity.isNotEmpty) ...[
          const SizedBox(height: 18),
          OmniChannelRelatedActivityList(
            entries: relatedActivity,
            onEntrySelected: onRelatedEntrySelected,
          ),
        ],
      ],
    );
  }

  bool get _hasActions {
    return onActionSelected != null &&
        (action != null || secondaryActions.isNotEmpty);
  }

  List<OmniChannelActivityAction> get _disabledActions {
    return [
      if (action != null && !action!.isEnabled) action!,
      ...secondaryActions.where((action) => !action.isEnabled),
    ];
  }
}

@Preview(name: 'Omni-channel activity detail panel')
Widget omniChannelActivityDetailPanelPreview() {
  final entry = OmniChannelActivityEntry(
    id: 'marketplace-review',
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
    fulfillmentModeLabel: 'Pickup',
    supportSummary: 'Review pickup capacity with store ops.',
    attributes: {'slaWindow': '30 min', 'reservedStock': 'Low'},
  );
  final relatedActivity = OmniChannelRelatedActivity.fromEntries(
    selectedEntry: entry,
    entries: [
      entry,
      OmniChannelActivityEntry(
        id: 'sync-preview',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 10, 45),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityDetailPanel(
          action: const OmniChannelActivityAction(
            label: 'Open orders',
            location: '/commerce/orders?order_search=ECOM-2026-017',
            tooltip: 'Open the matching ecommerce order workspace',
          ),
          secondaryActions: const [
            OmniChannelActivityAction(
              id: 'commerce-workspace',
              label: 'Open commerce',
              location: '/commerce',
              tooltip: 'Open the commerce command workspace',
            ),
          ],
          busyActionKeys: {
            OmniChannelActivityActionExecutionKey.fromAction(
              entry: entry,
              action: OmniChannelActivityAction(
                label: 'Open orders',
                location: '/commerce/orders?order_search=ECOM-2026-017',
                tooltip: 'Open the matching ecommerce order workspace',
              ),
            ).value,
          },
          onActionSelected: (_, _) {},
          onRelatedEntrySelected: (_) {},
          relatedActivity: relatedActivity.entries,
          entry: entry,
        ),
      ),
    ),
  );
}

/// Action strip for primary and secondary activity resolution paths.
class _DetailActionStrip extends StatelessWidget {
  final OmniChannelActivityEntry entry;
  final OmniChannelActivityAction? action;
  final List<OmniChannelActivityAction> secondaryActions;
  final Set<String> busyActionKeys;
  final OmniChannelActivityActionSelection onActionSelected;

  const _DetailActionStrip({
    required this.entry,
    required this.action,
    required this.secondaryActions,
    required this.busyActionKeys,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (action != null)
          _PrimaryDetailActionButton(
            action: action!,
            entry: entry,
            colorScheme: colorScheme,
            busy: _isActionBusy(entry, action!),
            onActionSelected: onActionSelected,
          ),
        for (final secondaryAction in secondaryActions)
          _SecondaryDetailActionButton(
            action: secondaryAction,
            entry: entry,
            colorScheme: colorScheme,
            busy: _isActionBusy(entry, secondaryAction),
            onActionSelected: onActionSelected,
          ),
      ],
    );
  }

  bool _isActionBusy(
    OmniChannelActivityEntry entry,
    OmniChannelActivityAction action,
  ) {
    return busyActionKeys.contains(
      OmniChannelActivityActionExecutionKey.fromAction(
        entry: entry,
        action: action,
      ).value,
    );
  }
}

/// Primary action button for the selected activity detail surface.
class _PrimaryDetailActionButton extends StatelessWidget {
  final OmniChannelActivityEntry entry;
  final OmniChannelActivityAction action;
  final ColorScheme colorScheme;
  final bool busy;
  final OmniChannelActivityActionSelection onActionSelected;

  const _PrimaryDetailActionButton({
    required this.entry,
    required this.action,
    required this.colorScheme,
    required this.busy,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = OmniChannelActivityActionPresentation(action);
    final backgroundColor = _actionBackgroundColor(
      colorScheme,
      presentation.tone,
    );

    return Tooltip(
      message: busy ? 'Action is already running' : presentation.tooltip,
      child: FilledButton.icon(
        key: ValueKey('omni-channel-activity-detail-action-${action.location}'),
        onPressed:
            presentation.isEnabled && !busy
                ? () => onActionSelected(entry, action)
                : null,
        icon: _ActionProgressIcon(busy: busy, icon: presentation.icon),
        label: Text(busy ? 'Working...' : presentation.label),
        style: FilledButton.styleFrom(
          backgroundColor:
              presentation.isEnabled && !busy ? backgroundColor : null,
          foregroundColor:
              presentation.isEnabled && !busy
                  ? _actionForegroundColor(colorScheme, presentation.tone)
                  : null,
        ),
      ),
    );
  }
}

/// Secondary action button for alternative activity resolution paths.
class _SecondaryDetailActionButton extends StatelessWidget {
  final OmniChannelActivityEntry entry;
  final OmniChannelActivityAction action;
  final ColorScheme colorScheme;
  final bool busy;
  final OmniChannelActivityActionSelection onActionSelected;

  const _SecondaryDetailActionButton({
    required this.entry,
    required this.action,
    required this.colorScheme,
    required this.busy,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = OmniChannelActivityActionPresentation(action);
    final color = omniChannelActivityToneColor(colorScheme, presentation.tone);

    return Tooltip(
      message: busy ? 'Action is already running' : presentation.tooltip,
      child: OutlinedButton.icon(
        key: ValueKey('omni-channel-activity-detail-action-${action.identity}'),
        onPressed:
            presentation.isEnabled && !busy
                ? () => onActionSelected(entry, action)
                : null,
        icon: _ActionProgressIcon(busy: busy, icon: presentation.icon),
        label: Text(busy ? 'Working...' : presentation.label),
        style: OutlinedButton.styleFrom(
          foregroundColor: presentation.isEnabled && !busy ? color : null,
          side:
              presentation.isEnabled && !busy
                  ? BorderSide(color: color.withValues(alpha: 0.45))
                  : null,
        ),
      ),
    );
  }
}

/// Fixed-size icon slot that swaps an action icon for progress feedback.
class _ActionProgressIcon extends StatelessWidget {
  final bool busy;
  final IconData icon;

  const _ActionProgressIcon({required this.busy, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (!busy) return Icon(icon);

    return const SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

Color _actionBackgroundColor(
  ColorScheme colorScheme,
  OmniChannelActivityTone tone,
) {
  if (tone == OmniChannelActivityTone.neutral) return colorScheme.primary;
  return omniChannelActivityToneColor(colorScheme, tone);
}

Color _actionForegroundColor(
  ColorScheme colorScheme,
  OmniChannelActivityTone tone,
) {
  switch (tone) {
    case OmniChannelActivityTone.danger:
      return colorScheme.onError;
    case OmniChannelActivityTone.warning:
      return colorScheme.onTertiary;
    case OmniChannelActivityTone.info:
      return colorScheme.onSecondary;
    case OmniChannelActivityTone.success:
    case OmniChannelActivityTone.neutral:
      return colorScheme.onPrimary;
  }
}

/// Header block for the selected activity detail panel.
class _DetailHeading extends StatelessWidget {
  final String title;
  final String contextLabel;
  final IconData icon;
  final Color iconColor;

  const _DetailHeading({
    required this.title,
    required this.contextLabel,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contextLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Responsive collection of activity detail fields.
class _DetailFieldGrid extends StatelessWidget {
  final String? title;
  final List<OmniChannelActivityDetailField> fields;

  const _DetailFieldGrid({required this.fields, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final field in fields) _DetailFieldTile(field: field),
          ],
        ),
      ],
    );
  }
}

/// Compact field tile for the activity detail panel.
class _DetailFieldTile extends StatelessWidget {
  final OmniChannelActivityDetailField field;

  const _DetailFieldTile({required this.field});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 148, maxWidth: 230),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.62),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                field.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                field.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _timeLabel(BuildContext context, DateTime occurredAt) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatShortDate(occurredAt);
  final time = TimeOfDay.fromDateTime(occurredAt).format(context);
  return '$date $time';
}
