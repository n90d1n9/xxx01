import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_conformance_evidence.dart';
import 'registry_health_api_conformance_gate.dart';

class RegistryHealthApiConformanceEvidencePanel extends StatelessWidget {
  const RegistryHealthApiConformanceEvidencePanel({
    super.key,
    required this.report,
    this.evidenceLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConformanceEvidenceReport report;
  final int evidenceLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API conformance evidence.');
    }

    final visibleItems = report.visibleItems(limit: evidenceLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Conformance Evidence',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyEvidenceJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyEvidence(context),
                    icon: const Icon(Icons.inventory_2_outlined, size: 16),
                    label: const Text('Copy Evidence'),
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
            _ConformanceEvidenceMetricChip(
              label: 'Evidence',
              value: report.evidenceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceEvidenceMetricChip(
              label: 'Steps',
              value: report.stepCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceEvidenceMetricChip(
              label: 'Review',
              value: report.reviewEvidenceCount.toString(),
              color: report.reviewEvidenceCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ConformanceEvidenceMetricChip(
              label: 'Blocked',
              value: report.blockedEvidenceCount.toString(),
              color: report.blockedEvidenceCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ConformanceEvidenceMetricChip(
              label: 'Medium Risk',
              value: report.mediumRiskCount.toString(),
              color: report.mediumRiskCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _ConformanceEvidenceRow(item: item),
        if (report.evidenceCount > visibleItems.length)
          Text(
            '+${report.evidenceCount - visibleItems.length} more evidence items',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyEvidenceJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(evidenceLimit: evidenceLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance evidence JSON copied')),
    );
  }

  void _copyEvidence(BuildContext context) {
    final text = registryHealthApiConformanceEvidenceText(
      report,
      evidenceLimit: evidenceLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance evidence copied')),
    );
  }
}

class _ConformanceEvidenceMetricChip extends StatelessWidget {
  const _ConformanceEvidenceMetricChip({
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
        child: Icon(Icons.inventory_2_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ConformanceEvidenceRow extends StatelessWidget {
  const _ConformanceEvidenceRow({required this.item});

  final RegistryHealthApiConformanceEvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _conformanceEvidenceStatusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.inventory_2_outlined, size: 18, color: statusColor),
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
                      '${item.stepCount} steps',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.riskSummaryLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.summaryLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.stepSummaryLabel,
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
                  item.checkSummaryLabel,
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

Color _conformanceEvidenceStatusColor(
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
