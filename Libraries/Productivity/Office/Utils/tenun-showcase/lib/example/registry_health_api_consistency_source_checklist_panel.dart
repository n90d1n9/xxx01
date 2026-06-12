import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency_source_checklist.dart';

class RegistryHealthApiConsistencySourceChecklistPanel extends StatelessWidget {
  const RegistryHealthApiConsistencySourceChecklistPanel({
    super.key,
    required this.report,
    this.stageLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencySourceChecklistReport report;
  final int stageLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API source checklist.');
    }

    final visibleItems = report.visibleItems(limit: stageLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Source Checklist',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyChecklistJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyChecklist(context),
                    icon: const Icon(Icons.checklist_outlined, size: 16),
                    label: const Text('Copy Checklist'),
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
            _SourceChecklistMetricChip(
              label: 'Stages',
              value: report.stageCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceChecklistMetricChip(
              label: 'Tasks',
              value: report.taskCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceChecklistMetricChip(
              label: 'Sources',
              value: report.sourceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceChecklistMetricChip(
              label: 'High Risk',
              value: report.highRiskCount.toString(),
              color: report.highRiskCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _SourceChecklistMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _SourceChecklistRow(item: item),
        if (report.stageCount > visibleItems.length)
          Text(
            '+${report.stageCount - visibleItems.length} more stages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyChecklistJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(stageLimit: stageLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source checklist JSON copied')),
    );
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthApiConsistencySourceChecklistText(
      report,
      stageLimit: stageLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source checklist copied')),
    );
  }
}

class _SourceChecklistMetricChip extends StatelessWidget {
  const _SourceChecklistMetricChip({
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
        child: Icon(Icons.task_alt_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourceChecklistRow extends StatelessWidget {
  const _SourceChecklistRow({required this.item});

  final RegistryHealthApiConsistencySourceChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final riskColor = _sourceChecklistRiskColor(item.risk);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.task_alt_outlined, size: 18, color: riskColor),
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
                      item.titleLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.riskLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.phaseLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.taskCount} tasks',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.sourceTouchLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.actionTouchLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Review gate: ${item.reviewGateLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Handoff: ${item.handoffLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.taskSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _sourceChecklistRiskColor(
  RegistryHealthApiConsistencySourceChecklistRisk risk,
) {
  switch (risk) {
    case RegistryHealthApiConsistencySourceChecklistRisk.high:
      return Colors.red.shade700;
    case RegistryHealthApiConsistencySourceChecklistRisk.medium:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencySourceChecklistRisk.low:
      return Colors.green.shade700;
  }
}
