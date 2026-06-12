import 'package:flutter/material.dart';

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_concern_summary.dart';

class RegistryHealthApiConsistencyConcernSummaryPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyConcernSummaryPanel({
    super.key,
    required this.report,
    this.summaryLimit = 6,
  });

  final RegistryHealthApiConsistencyConcernSummaryReport report;
  final int summaryLimit;

  @override
  Widget build(BuildContext context) {
    final rows = report.attentionSummaries
        .take(summaryLimit)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Concern Coverage', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ConcernSummaryMetricChip(
              label: 'Concerns',
              value: report.concernCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConcernSummaryMetricChip(
              label: 'Ready',
              value: report.readyCount.toString(),
              color: Colors.green.shade700,
            ),
            _ConcernSummaryMetricChip(
              label: 'Required',
              value: report.requiredGapConcernCount.toString(),
              color: report.requiredGapConcernCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ConcernSummaryMetricChip(
              label: 'Advisory',
              value: report.advisoryGapConcernCount.toString(),
              color: report.advisoryGapConcernCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          const Text('All consistency concerns are covered.')
        else
          for (final row in rows) _ConcernSummaryRow(summary: row),
        if (report.attentionSummaries.length > rows.length)
          Text(
            '+${report.attentionSummaries.length - rows.length} more concerns',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _ConcernSummaryMetricChip extends StatelessWidget {
  const _ConcernSummaryMetricChip({
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
        child: Icon(Icons.fact_check_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ConcernSummaryRow extends StatelessWidget {
  const _ConcernSummaryRow({required this.summary});

  final RegistryHealthApiConsistencyConcernSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(summary.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_statusIcon(summary.status), color: color, size: 18),
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
                      summary.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _summaryStatusLabel(summary),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      summary.priorityLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _summaryContractsLabel(summary),
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

Color _statusColor(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Colors.red.shade700;
  }
}

IconData _statusIcon(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Icons.check_circle_outline;
    case RegistryHealthApiConsistencyStatus.warning:
      return Icons.info_outline;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Icons.error_outline;
  }
}

String _summaryStatusLabel(RegistryHealthApiConsistencyConcernSummary summary) {
  if (summary.requiredMissingCount > 0) {
    return 'Required: ${summary.requiredMissingCount}';
  }
  return 'Advisory: ${summary.advisoryMissingCount}';
}

String _summaryContractsLabel(
  RegistryHealthApiConsistencyConcernSummary summary,
) {
  final parts = <String>[];
  if (summary.requiredMissingContracts.isNotEmpty) {
    parts.add('Required ${summary.requiredMissingContracts.join(', ')}');
  }
  if (summary.advisoryMissingContracts.isNotEmpty) {
    parts.add('Advisory ${summary.advisoryMissingContracts.join(', ')}');
  }
  return parts.join(' · ');
}
