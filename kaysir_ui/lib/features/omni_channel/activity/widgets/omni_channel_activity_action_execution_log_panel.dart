import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_content_panel.dart';
import '../../../../widgets/ui/app_empty_state.dart';
import '../../../../widgets/ui/app_filter_chip_group.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution.dart';
import '../models/omni_channel_activity_action_execution_key.dart';
import '../models/omni_channel_activity_action_execution_log.dart';
import 'omni_channel_activity_action_execution_record_tile.dart';

/// Compact activity-center panel that keeps recent action outcomes visible.
class OmniChannelActivityActionExecutionLogPanel extends StatelessWidget {
  final OmniChannelActivityActionExecutionLog log;
  final OmniChannelActivityActionExecutionLogFilter filter;
  final String? selectedEntryId;
  final Set<String> busyActionKeys;
  final ValueChanged<OmniChannelActivityActionExecutionLogFilter>?
  onFilterChanged;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>?
  onRecordSelected;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>? onOpenRecord;
  final ValueChanged<OmniChannelActivityActionExecutionRecord>? onRetryRecord;
  final VoidCallback? onRetryAttention;
  final VoidCallback? onClearCompleted;
  final VoidCallback? onClear;

  const OmniChannelActivityActionExecutionLogPanel({
    super.key,
    required this.log,
    this.filter = OmniChannelActivityActionExecutionLogFilter.all,
    this.selectedEntryId,
    this.busyActionKeys = const <String>{},
    this.onFilterChanged,
    this.onRecordSelected,
    this.onOpenRecord,
    this.onRetryRecord,
    this.onRetryAttention,
    this.onClearCompleted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRecords = log
        .entriesFor(filter)
        .take(4)
        .toList(growable: false);

    return AppContentPanel(
      title: 'Recent action outcomes',
      subtitle: _subtitle(log, filter),
      leadingIcon: Icons.task_alt_outlined,
      trailing:
          log.isEmpty
              ? null
              : _ExecutionLogActions(
                log: log,
                busyActionKeys: busyActionKeys,
                onRetryAttention: onRetryAttention,
                onClearCompleted: onClearCompleted,
                onClear: onClear,
              ),
      child:
          log.isEmpty
              ? const AppEmptyState(
                icon: Icons.task_alt_outlined,
                title: 'No handled actions yet',
                message: 'Completed and blocked activity actions appear here.',
              )
              : Column(
                key: const ValueKey('omni-channel-action-execution-log'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ExecutionLogFilterBar(
                    log: log,
                    filter: filter,
                    onFilterChanged: onFilterChanged,
                  ),
                  const SizedBox(height: 12),
                  if (visibleRecords.isEmpty)
                    const AppEmptyState(
                      icon: Icons.filter_alt_off_outlined,
                      title: 'No matching outcomes',
                      message:
                          'Choose another outcome filter to review actions.',
                    )
                  else
                    for (final record in visibleRecords) ...[
                      OmniChannelActivityActionExecutionRecordTile(
                        record: record,
                        selected: record.entryId == selectedEntryId,
                        retrying: busyActionKeys.contains(
                          OmniChannelActivityActionExecutionKey.fromRecord(
                            record,
                          ).value,
                        ),
                        onRecordSelected: onRecordSelected,
                        onOpenRecord: onOpenRecord,
                        onRetryRecord: onRetryRecord,
                      ),
                      if (record != visibleRecords.last)
                        const Divider(height: 18),
                    ],
                ],
              ),
    );
  }
}

@Preview(name: 'Omni-channel action execution log panel')
Widget omniChannelActivityActionExecutionLogPanelPreview() {
  final action = const OmniChannelActivityAction(
    label: 'Open orders',
    location: '/commerce/orders',
    tooltip: 'Open orders',
  );
  final log = OmniChannelActivityActionExecutionLog(
    entries: [
      OmniChannelActivityActionExecutionRecord(
        id: 'preview-2',
        result: OmniChannelActivityActionExecutionResult.failed(
          action: action,
          message: 'Order workspace failed to open for ECOM-2026-018.',
          location: '/commerce/orders',
        ),
        entryId: 'preview-failed-order',
        entryTitle: 'Marketplace sync needs retry',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11, 12),
        sequence: 2,
      ),
      OmniChannelActivityActionExecutionRecord(
        id: 'preview-1',
        result: OmniChannelActivityActionExecutionResult.completed(
          action: action,
          message: 'Order workspace opened for ECOM-2026-017.',
          location: '/commerce/orders',
        ),
        entryId: 'preview-order',
        entryTitle: 'Marketplace pickup needs review',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11, 8),
        sequence: 1,
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityActionExecutionLogPanel(
          log: log,
          filter: OmniChannelActivityActionExecutionLogFilter.all,
          selectedEntryId: 'preview-order',
          busyActionKeys: {
            OmniChannelActivityActionExecutionKey.fromRecord(
              log.entries.first,
            ).value,
          },
          onFilterChanged: (_) {},
          onRecordSelected: (_) {},
          onOpenRecord: (_) {},
          onRetryRecord: (_) {},
          onRetryAttention: () {},
          onClearCompleted: () {},
          onClear: () {},
        ),
      ),
    ),
  );
}

/// Header actions for batch recovery and log maintenance.
class _ExecutionLogActions extends StatelessWidget {
  final OmniChannelActivityActionExecutionLog log;
  final Set<String> busyActionKeys;
  final VoidCallback? onRetryAttention;
  final VoidCallback? onClearCompleted;
  final VoidCallback? onClear;

  const _ExecutionLogActions({
    required this.log,
    required this.busyActionKeys,
    required this.onRetryAttention,
    required this.onClearCompleted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final attentionEntries = log.attentionEntries;
    final allAttentionBusy =
        attentionEntries.isNotEmpty &&
        attentionEntries.every(
          (record) => busyActionKeys.contains(
            OmniChannelActivityActionExecutionKey.fromRecord(record).value,
          ),
        );

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        if (onRetryAttention != null && attentionEntries.isNotEmpty)
          IconButton(
            key: const ValueKey('omni-channel-action-log-retry-attention'),
            tooltip:
                allAttentionBusy
                    ? 'Attention outcomes are retrying'
                    : 'Retry attention outcomes',
            onPressed: allAttentionBusy ? null : onRetryAttention,
            icon:
                allAttentionBusy
                    ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.replay_outlined),
          ),
        if (onClearCompleted != null && log.completedCount > 0)
          IconButton(
            key: const ValueKey('omni-channel-action-log-clear-completed'),
            tooltip: 'Clear completed outcomes',
            onPressed: onClearCompleted,
            icon: const Icon(Icons.done_all_outlined),
          ),
        if (onClear != null)
          IconButton(
            key: const ValueKey('omni-channel-action-log-clear'),
            tooltip: 'Clear recent action outcomes',
            onPressed: onClear,
            icon: const Icon(Icons.clear_all_outlined),
          ),
      ],
    );
  }
}

/// Outcome filter controls for recent action records.
class _ExecutionLogFilterBar extends StatelessWidget {
  final OmniChannelActivityActionExecutionLog log;
  final OmniChannelActivityActionExecutionLogFilter filter;
  final ValueChanged<OmniChannelActivityActionExecutionLogFilter>?
  onFilterChanged;

  const _ExecutionLogFilterBar({
    required this.log,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppFilterChipGroup<OmniChannelActivityActionExecutionLogFilter>(
      value: filter,
      enabled: onFilterChanged != null,
      options: [
        for (final option in OmniChannelActivityActionExecutionLogFilter.values)
          AppFilterChipOption<OmniChannelActivityActionExecutionLogFilter>(
            value: option,
            label: _filterLabel(option),
            count: log.countFor(option),
            icon: _filterIcon(option),
            chipKey: ValueKey('omni-channel-action-log-filter-${option.name}'),
            tooltip: '${log.countFor(option)} ${_filterTooltipLabel(option)}',
          ),
      ],
      onChanged: onFilterChanged ?? (_) {},
    );
  }
}

String _subtitle(
  OmniChannelActivityActionExecutionLog log,
  OmniChannelActivityActionExecutionLogFilter filter,
) {
  if (log.isEmpty) return 'No action outcomes recorded';
  final visibleCount = log.countFor(filter);
  if (filter == OmniChannelActivityActionExecutionLogFilter.all) {
    return '${log.entries.length} recent, ${log.attentionCount} need attention';
  }

  return '$visibleCount ${_filterLabel(filter).toLowerCase()} from '
      '${log.entries.length} recent';
}

String _filterLabel(OmniChannelActivityActionExecutionLogFilter filter) {
  switch (filter) {
    case OmniChannelActivityActionExecutionLogFilter.all:
      return 'All';
    case OmniChannelActivityActionExecutionLogFilter.attention:
      return 'Needs attention';
    case OmniChannelActivityActionExecutionLogFilter.completed:
      return 'Completed';
    case OmniChannelActivityActionExecutionLogFilter.blocked:
      return 'Blocked';
    case OmniChannelActivityActionExecutionLogFilter.failed:
      return 'Failed';
  }
}

String _filterTooltipLabel(OmniChannelActivityActionExecutionLogFilter filter) {
  switch (filter) {
    case OmniChannelActivityActionExecutionLogFilter.all:
      return 'recent outcomes';
    case OmniChannelActivityActionExecutionLogFilter.attention:
      return 'outcomes that need attention';
    case OmniChannelActivityActionExecutionLogFilter.completed:
      return 'completed outcomes';
    case OmniChannelActivityActionExecutionLogFilter.blocked:
      return 'blocked outcomes';
    case OmniChannelActivityActionExecutionLogFilter.failed:
      return 'failed outcomes';
  }
}

IconData _filterIcon(OmniChannelActivityActionExecutionLogFilter filter) {
  switch (filter) {
    case OmniChannelActivityActionExecutionLogFilter.all:
      return Icons.all_inclusive_outlined;
    case OmniChannelActivityActionExecutionLogFilter.attention:
      return Icons.priority_high_outlined;
    case OmniChannelActivityActionExecutionLogFilter.completed:
      return Icons.check_circle_outline;
    case OmniChannelActivityActionExecutionLogFilter.blocked:
      return Icons.block_outlined;
    case OmniChannelActivityActionExecutionLogFilter.failed:
      return Icons.error_outline;
  }
}
