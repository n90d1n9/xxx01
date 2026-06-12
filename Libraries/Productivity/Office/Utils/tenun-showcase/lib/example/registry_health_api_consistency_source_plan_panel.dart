import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_source_plan.dart';

class RegistryHealthApiConsistencySourcePlanPanel extends StatelessWidget {
  const RegistryHealthApiConsistencySourcePlanPanel({
    super.key,
    required this.report,
    this.batchLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencySourcePlanReport report;
  final int batchLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API source batches.');
    }

    final visibleItems = report.visibleItems(limit: batchLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Source Plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyPlanJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyPlan(context),
                    icon: const Icon(Icons.view_timeline_outlined, size: 16),
                    label: const Text('Copy Plan'),
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
            _SourcePlanMetricChip(
              label: 'Batches',
              value: report.batchCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourcePlanMetricChip(
              label: 'Sources',
              value: report.sourceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourcePlanMetricChip(
              label: 'Touches',
              value: report.traceTouchCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourcePlanMetricChip(
              label: 'Actions',
              value: report.actionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourcePlanMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _SourcePlanRow(item: item),
        if (report.batchCount > visibleItems.length)
          Text(
            '+${report.batchCount - visibleItems.length} more batches',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyPlanJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(batchLimit: batchLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source plan JSON copied')),
    );
  }

  void _copyPlan(BuildContext context) {
    final text = registryHealthApiConsistencySourcePlanText(
      report,
      batchLimit: batchLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API source plan copied')));
  }
}

class _SourcePlanMetricChip extends StatelessWidget {
  const _SourcePlanMetricChip({
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
        child: Icon(Icons.view_timeline_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourcePlanRow extends StatelessWidget {
  const _SourcePlanRow({required this.item});

  final RegistryHealthApiConsistencySourcePlanItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _sourcePlanStatusColor(item.status);
    final phaseColor = _sourcePlanPhaseColor(item.leadingPhase);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.view_timeline_outlined, size: 18, color: statusColor),
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
                      item.areaLabel,
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
                      '${item.sourceCount} sources',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.traceTouchCount} trace touches',
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
                  item.implementationLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.kindSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.sourceSummaryLabel,
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

Color _sourcePlanStatusColor(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Colors.red.shade700;
  }
}

Color _sourcePlanPhaseColor(RegistryHealthApiConsistencyActionPhase phase) {
  switch (phase) {
    case RegistryHealthApiConsistencyActionPhase.now:
      return Colors.red.shade700;
    case RegistryHealthApiConsistencyActionPhase.next:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyActionPhase.later:
      return Colors.blueGrey.shade600;
  }
}
