import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution.dart';
import '../models/omni_channel_activity_action_execution_log.dart';

/// Scan-friendly row for one recorded omni-channel activity action outcome.
class OmniChannelActivityActionExecutionRecordTile extends StatelessWidget {
  final OmniChannelActivityActionExecutionRecord record;
  final bool selected;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>?
  onRecordSelected;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>? onOpenRecord;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>? onRetryRecord;
  final bool retrying;

  const OmniChannelActivityActionExecutionRecordTile({
    super.key,
    required this.record,
    this.selected = false,
    this.onRecordSelected,
    this.onOpenRecord,
    this.onRetryRecord,
    this.retrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final outcomeColor = _outcomeColor(colorScheme, record.result.outcome);
    final body = _RecordTileBody(
      record: record,
      outcomeColor: outcomeColor,
      selected: selected,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RecordTileInteractionFrame(
            record: record,
            selected: selected,
            onRecordSelected: onRecordSelected,
            child: body,
          ),
        ),
        if (_hasTrailingActions) ...[
          const SizedBox(width: 8),
          _RecordTileActionButtons(
            record: record,
            onOpenRecord: onOpenRecord,
            onRetryRecord: onRetryRecord,
            retrying: retrying,
          ),
        ],
      ],
    );
  }

  bool get _hasTrailingActions {
    return (onOpenRecord != null && record.canOpenLocation) ||
        (onRetryRecord != null && record.requiresAttention);
  }
}

@Preview(name: 'Omni-channel action execution record tile')
Widget omniChannelActivityActionExecutionRecordTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityActionExecutionRecordTile(
          selected: true,
          record: OmniChannelActivityActionExecutionRecord(
            id: 'preview-1',
            result: const OmniChannelActivityActionExecutionResult.failed(
              action: OmniChannelActivityAction(
                label: 'Open sync queue',
                location: '/cashier',
                tooltip: 'Retry failed POS sync',
              ),
              message: 'Sync queue could not be opened.',
              location: '/cashier',
            ),
            entryId: 'preview-sync',
            entryTitle: 'Order sync failed',
            sourceLabel: 'Point of sale',
            occurredAt: DateTime(2026, 6, 9, 11, 8),
            sequence: 1,
          ),
          onRecordSelected: (_) {},
          onOpenRecord: (_) {},
          onRetryRecord: (_) {},
          retrying: true,
        ),
      ),
    ),
  );
}

/// Compact trailing controls for a recorded activity action outcome.
class _RecordTileActionButtons extends StatelessWidget {
  final OmniChannelActivityActionExecutionRecord record;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>? onOpenRecord;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>? onRetryRecord;
  final bool retrying;

  const _RecordTileActionButtons({
    required this.record,
    required this.onOpenRecord,
    required this.onRetryRecord,
    required this.retrying,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRetryRecord != null && record.requiresAttention)
          IconButton(
            key: ValueKey('omni-channel-action-log-retry-record-${record.id}'),
            tooltip: retrying ? 'Retrying action' : 'Retry action',
            onPressed: retrying ? null : () => onRetryRecord!(record),
            icon:
                retrying
                    ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.replay_outlined),
          ),
        if (onOpenRecord != null && record.canOpenLocation)
          IconButton(
            key: ValueKey('omni-channel-action-log-open-record-${record.id}'),
            tooltip: 'Open related workspace',
            onPressed: () => onOpenRecord!(record),
            icon: const Icon(Icons.open_in_new_outlined),
          ),
      ],
    );
  }
}

/// Selection and tap surface for a recorded activity action outcome.
class _RecordTileInteractionFrame extends StatelessWidget {
  final OmniChannelActivityActionExecutionRecord record;
  final bool selected;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>?
  onRecordSelected;
  final Widget child;

  const _RecordTileInteractionFrame({
    required this.record,
    required this.selected,
    required this.onRecordSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(8);
    final canSelect = onRecordSelected != null;

    return Semantics(
      button: canSelect,
      selected: selected,
      label:
          '${_outcomeLabel(record.result.outcome)} '
          '${record.actionLabel}: ${record.entryTitle}',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color:
                selected
                    ? colorScheme.primaryContainer.withValues(alpha: 0.42)
                    : Colors.transparent,
            border:
                selected
                    ? Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.38),
                    )
                    : null,
            borderRadius: radius,
          ),
          child: InkWell(
            key:
                canSelect
                    ? ValueKey(
                      'omni-channel-action-log-select-record-${record.id}',
                    )
                    : null,
            borderRadius: radius,
            onTap: canSelect ? () => onRecordSelected!(record) : null,
            child: Padding(
              padding: EdgeInsets.all(canSelect || selected ? 8 : 0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Non-interactive content for one recorded activity action outcome.
class _RecordTileBody extends StatelessWidget {
  final OmniChannelActivityActionExecutionRecord record;
  final Color outcomeColor;
  final bool selected;

  const _RecordTileBody({
    required this.record,
    required this.outcomeColor,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: outcomeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _outcomeIcon(record.result.outcome),
            color: outcomeColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      record.result.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AppStatusPill(
                    label: _outcomeLabel(record.result.outcome),
                    color: outcomeColor,
                    icon: _outcomeIcon(record.result.outcome),
                    maxWidth: 128,
                  ),
                  if (selected)
                    AppStatusPill(
                      label: 'Current activity',
                      color: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      backgroundColor: colorScheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderColor: colorScheme.primary.withValues(alpha: 0.42),
                      icon: Icons.my_location_outlined,
                      maxWidth: 164,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${record.actionLabel} - ${record.entryTitle}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  AppStatusPill(
                    label: record.sourceLabel,
                    color: colorScheme.secondary,
                    icon: Icons.hub_outlined,
                    maxWidth: 150,
                  ),
                  AppStatusPill(
                    label: _timeLabel(context, record.occurredAt),
                    color: colorScheme.primary,
                    icon: Icons.schedule_outlined,
                    maxWidth: 150,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _outcomeLabel(OmniChannelActivityActionOutcome outcome) {
  switch (outcome) {
    case OmniChannelActivityActionOutcome.completed:
      return 'Completed';
    case OmniChannelActivityActionOutcome.blocked:
      return 'Blocked';
    case OmniChannelActivityActionOutcome.failed:
      return 'Failed';
  }
}

IconData _outcomeIcon(OmniChannelActivityActionOutcome outcome) {
  switch (outcome) {
    case OmniChannelActivityActionOutcome.completed:
      return Icons.check_circle_outline;
    case OmniChannelActivityActionOutcome.blocked:
      return Icons.block_outlined;
    case OmniChannelActivityActionOutcome.failed:
      return Icons.error_outline;
  }
}

Color _outcomeColor(
  ColorScheme colorScheme,
  OmniChannelActivityActionOutcome outcome,
) {
  switch (outcome) {
    case OmniChannelActivityActionOutcome.completed:
      return colorScheme.primary;
    case OmniChannelActivityActionOutcome.blocked:
      return colorScheme.tertiary;
    case OmniChannelActivityActionOutcome.failed:
      return colorScheme.error;
  }
}

String _timeLabel(BuildContext context, DateTime occurredAt) {
  return TimeOfDay.fromDateTime(occurredAt).format(context);
}
