import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_conformance_checklist.dart';

class RegistryHealthApiConformanceChecklistPanel extends StatelessWidget {
  const RegistryHealthApiConformanceChecklistPanel({
    super.key,
    required this.report,
    this.stepLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConformanceChecklistReport report;
  final int stepLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API conformance checklist.');
    }

    final visibleItems = report.visibleItems(limit: stepLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Conformance Checklist',
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
            _ConformanceChecklistMetricChip(
              label: 'Steps',
              value: report.stepCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceChecklistMetricChip(
              label: 'Tasks',
              value: report.taskCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceChecklistMetricChip(
              label: 'Medium Risk',
              value: report.mediumRiskCount.toString(),
              color: report.mediumRiskCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ConformanceChecklistMetricChip(
              label: 'High Risk',
              value: report.highRiskCount.toString(),
              color: report.highRiskCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ConformanceChecklistMetricChip(
              label: 'Checks',
              value: report.requiredCheckCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _ConformanceChecklistRow(item: item),
        if (report.stepCount > visibleItems.length)
          Text(
            '+${report.stepCount - visibleItems.length} more steps',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyChecklistJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(stepLimit: stepLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance checklist JSON copied')),
    );
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthApiConformanceChecklistText(
      report,
      stepLimit: stepLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance checklist copied')),
    );
  }
}

class _ConformanceChecklistMetricChip extends StatelessWidget {
  const _ConformanceChecklistMetricChip({
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
        child: Icon(Icons.checklist_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ConformanceChecklistRow extends StatelessWidget {
  const _ConformanceChecklistRow({required this.item});

  final RegistryHealthApiConformanceChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final riskColor = _conformanceChecklistRiskColor(item.risk);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.checklist_outlined, size: 18, color: riskColor),
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
                      item.statusLabel,
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
                  item.gateCoverageLabel,
                  style: Theme.of(context).textTheme.bodySmall,
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

Color _conformanceChecklistRiskColor(
  RegistryHealthApiConformanceChecklistRisk risk,
) {
  switch (risk) {
    case RegistryHealthApiConformanceChecklistRisk.low:
      return Colors.green.shade700;
    case RegistryHealthApiConformanceChecklistRisk.medium:
      return Colors.orange.shade800;
    case RegistryHealthApiConformanceChecklistRisk.high:
      return Colors.red.shade700;
  }
}
