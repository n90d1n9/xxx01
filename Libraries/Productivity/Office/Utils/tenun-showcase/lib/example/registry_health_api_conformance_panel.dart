import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_conformance.dart';

class RegistryHealthApiConformancePanel extends StatelessWidget {
  const RegistryHealthApiConformancePanel({
    super.key,
    required this.report,
    this.caseLimit = 8,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConformanceReport report;
  final int caseLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API conformance cases.');
    }

    final visibleCases = report.visibleCases(limit: caseLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Conformance Harness',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyConformanceJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyCases(context),
                    icon: const Icon(Icons.rule_outlined, size: 16),
                    label: const Text('Copy Cases'),
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
            _ApiConformanceMetricChip(
              label: 'Cases',
              value: report.caseCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ApiConformanceMetricChip(
              label: 'Pass',
              value: report.passCount.toString(),
              color: Colors.green.shade700,
            ),
            _ApiConformanceMetricChip(
              label: 'Warnings',
              value: report.warningCount.toString(),
              color: report.warningCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ApiConformanceMetricChip(
              label: 'Failures',
              value: report.failCount.toString(),
              color: report.failCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ApiConformanceMetricChip(
              label: 'Skipped',
              value: report.skippedCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleCases) _ApiConformanceCaseRow(item: item),
        if (report.attentionCases.length > visibleCases.length)
          Text(
            '+${report.attentionCases.length - visibleCases.length} more cases',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyConformanceJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(caseLimit: caseLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance JSON copied')),
    );
  }

  void _copyCases(BuildContext context) {
    final text = registryHealthApiConformanceText(report, caseLimit: caseLimit);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance cases copied')),
    );
  }
}

class _ApiConformanceMetricChip extends StatelessWidget {
  const _ApiConformanceMetricChip({
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
        child: Icon(Icons.rule_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ApiConformanceCaseRow extends StatelessWidget {
  const _ApiConformanceCaseRow({required this.item});

  final RegistryHealthApiConformanceCase item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _apiConformanceStatusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.rule_outlined, size: 18, color: statusColor),
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
                      item.statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.levelLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.priorityLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.fieldSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.chartSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.concern.action,
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

Color _apiConformanceStatusColor(
  RegistryHealthApiConformanceCaseStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceCaseStatus.pass:
      return Colors.green.shade700;
    case RegistryHealthApiConformanceCaseStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConformanceCaseStatus.fail:
      return Colors.red.shade700;
    case RegistryHealthApiConformanceCaseStatus.skipped:
      return Colors.blueGrey.shade600;
  }
}
