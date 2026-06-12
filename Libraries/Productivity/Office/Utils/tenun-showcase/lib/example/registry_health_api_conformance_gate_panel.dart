import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_conformance_gate_text.dart';

class RegistryHealthApiConformanceGatePanel extends StatelessWidget {
  const RegistryHealthApiConformanceGatePanel({
    super.key,
    required this.report,
    this.gateLimit = 4,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConformanceGateReport report;
  final int gateLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API conformance gates.');
    }

    final visibleItems = report.visibleItems(limit: gateLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Conformance Gates',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyGateJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyGates(context),
                    icon: const Icon(Icons.policy_outlined, size: 16),
                    label: const Text('Copy Gates'),
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
            _ConformanceGateMetricChip(
              label: 'Gates',
              value: report.gateCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceGateMetricChip(
              label: 'Ready',
              value: report.readyGateCount.toString(),
              color: Colors.green.shade700,
            ),
            _ConformanceGateMetricChip(
              label: 'Review',
              value: report.reviewGateCount.toString(),
              color: report.reviewGateCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ConformanceGateMetricChip(
              label: 'Blocked',
              value: report.blockedGateCount.toString(),
              color: report.blockedGateCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ConformanceGateMetricChip(
              label: 'Checks',
              value: report.requiredCheckCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _ConformanceGateRow(item: item),
        if (report.gateCount > visibleItems.length)
          Text(
            '+${report.gateCount - visibleItems.length} more gates',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyGateJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(gateLimit: gateLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance gates JSON copied')),
    );
  }

  void _copyGates(BuildContext context) {
    final text = registryHealthApiConformanceGateText(
      report,
      gateLimit: gateLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance gates copied')),
    );
  }
}

class _ConformanceGateMetricChip extends StatelessWidget {
  const _ConformanceGateMetricChip({
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
        child: Icon(Icons.policy_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ConformanceGateRow extends StatelessWidget {
  const _ConformanceGateRow({required this.item});

  final RegistryHealthApiConformanceGateItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _conformanceGateStatusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.policy_outlined, size: 18, color: statusColor),
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
                      item.gateLabel,
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
                      '${item.checkCount} checks',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.caseScopeLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.summaryLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.checkSummaryLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Acceptance: ${item.acceptanceCriteria.first}',
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

Color _conformanceGateStatusColor(
  RegistryHealthApiConformanceGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConformanceGateStatus.review:
      return Colors.orange.shade800;
    case RegistryHealthApiConformanceGateStatus.blocked:
      return Colors.red.shade700;
  }
}
