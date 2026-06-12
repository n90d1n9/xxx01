import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_source_queue.dart';

class RegistryHealthApiConsistencySourceQueuePanel extends StatelessWidget {
  const RegistryHealthApiConsistencySourceQueuePanel({
    super.key,
    required this.report,
    this.sourceLimit = 8,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencySourceQueueReport report;
  final int sourceLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API source queue.');
    }

    final visibleItems = report.visibleItems(limit: sourceLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Source Queue',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyQueueJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyQueue(context),
                    icon: const Icon(Icons.queue_outlined, size: 16),
                    label: const Text('Copy Queue'),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SourceQueueMetricChip(
              label: 'Sources',
              value: report.sourceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceQueueMetricChip(
              label: 'Traces',
              value: report.traceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceQueueMetricChip(
              label: 'Touches',
              value: report.traceTouchCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceQueueMetricChip(
              label: 'Actions',
              value: report.actionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceQueueMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _SourceQueueRow(item: item),
        if (report.sourceCount > visibleItems.length)
          Text(
            '+${report.sourceCount - visibleItems.length} more sources',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyQueueJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(sourceLimit: sourceLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source queue JSON copied')),
    );
  }

  void _copyQueue(BuildContext context) {
    final text = registryHealthApiConsistencySourceQueueText(
      report,
      sourceLimit: sourceLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API source queue copied')));
  }
}

class _SourceQueueMetricChip extends StatelessWidget {
  const _SourceQueueMetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(Icons.source_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourceQueueRow extends StatelessWidget {
  const _SourceQueueRow({required this.item});

  final RegistryHealthApiConsistencySourceQueueItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _sourceQueueStatusColor(item.status);
    final phaseColor = _sourceQueuePhaseColor(item.leadingPhase);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.source_outlined, size: 18, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.sourceFile,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.leadingPhaseLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.traceCount} traces',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.actionTouchCount} action touches',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.kindSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.targetSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.responsibilityLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _sourceQueueStatusColor(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Colors.red.shade700;
  }
}

Color _sourceQueuePhaseColor(RegistryHealthApiConsistencyActionPhase phase) {
  switch (phase) {
    case RegistryHealthApiConsistencyActionPhase.now:
      return Colors.red.shade700;
    case RegistryHealthApiConsistencyActionPhase.next:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyActionPhase.later:
      return Colors.blueGrey.shade600;
  }
}
