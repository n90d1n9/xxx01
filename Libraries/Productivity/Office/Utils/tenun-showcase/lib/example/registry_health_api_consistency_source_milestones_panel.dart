import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency_source_checklist.dart';
import 'registry_health_api_consistency_source_milestones.dart';

class RegistryHealthApiConsistencySourceMilestonesPanel
    extends StatelessWidget {
  const RegistryHealthApiConsistencySourceMilestonesPanel({
    super.key,
    required this.report,
    this.milestoneLimit = 4,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencySourceMilestonesReport report;
  final int milestoneLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API source milestones.');
    }

    final visibleItems = report.visibleItems(limit: milestoneLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Source Milestones',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyMilestonesJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyRoadmap(context),
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: const Text('Copy Roadmap'),
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
            _SourceMilestoneMetricChip(
              label: 'Milestones',
              value: report.milestoneCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceMilestoneMetricChip(
              label: 'Stages',
              value: report.stageCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceMilestoneMetricChip(
              label: 'Tasks',
              value: report.taskCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceMilestoneMetricChip(
              label: 'High Risk',
              value: report.highRiskCount.toString(),
              color: report.highRiskCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _SourceMilestoneMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _SourceMilestoneRow(item: item),
        if (report.milestoneCount > visibleItems.length)
          Text(
            '+${report.milestoneCount - visibleItems.length} more milestones',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyMilestonesJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(milestoneLimit: milestoneLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source milestones JSON copied')),
    );
  }

  void _copyRoadmap(BuildContext context) {
    final text = registryHealthApiConsistencySourceMilestonesText(
      report,
      milestoneLimit: milestoneLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API source roadmap copied')));
  }
}

class _SourceMilestoneMetricChip extends StatelessWidget {
  const _SourceMilestoneMetricChip({
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
        child: Icon(Icons.flag_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourceMilestoneRow extends StatelessWidget {
  const _SourceMilestoneRow({required this.item});

  final RegistryHealthApiConsistencySourceMilestoneItem item;

  @override
  Widget build(BuildContext context) {
    final riskColor = _sourceMilestoneRiskColor(item.risk);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_outlined, size: 18, color: riskColor),
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
                      item.milestoneLabel,
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
                      item.stageNumbersLabel,
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
                  item.implementationLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.scopeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.actionTouchLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.stageSummaryLabel,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _sourceMilestoneRiskColor(
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
