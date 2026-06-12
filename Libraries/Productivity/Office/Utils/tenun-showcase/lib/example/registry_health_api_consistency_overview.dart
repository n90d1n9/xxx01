import 'package:flutter/material.dart';

import 'registry_health_api_consistency.dart';

class RegistryHealthApiConsistencyOverview extends StatelessWidget {
  const RegistryHealthApiConsistencyOverview({super.key, required this.report});

  final RegistryHealthApiConsistencyReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthApiConsistencySummary(report),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ApiConsistencyMetricChip(
              label: 'Status',
              value: report.statusLabel,
              color: registryHealthApiConsistencyStatusColor(report.status),
            ),
            _ApiConsistencyMetricChip(
              label: 'Contracts',
              value: report.contractCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ApiConsistencyMetricChip(
              label: 'Ready',
              value: report.readyCount.toString(),
              color: Colors.green.shade700,
            ),
            _ApiConsistencyMetricChip(
              label: 'Required Gaps',
              value: report.requiredIssueCount.toString(),
              color: report.requiredIssueCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ApiConsistencyMetricChip(
              label: 'Advisory',
              value: report.advisoryIssueCount.toString(),
              color: report.advisoryIssueCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ],
        ),
      ],
    );
  }
}

String registryHealthApiConsistencySummary(
  RegistryHealthApiConsistencyReport report,
) {
  return '${report.readyCount}/${report.contractCount} API contracts cover '
      '${report.concernCount} consistency concerns across '
      '${report.chartCount} charts. Required gaps: '
      '${report.requiredIssueCount}, advisory: ${report.advisoryIssueCount}.';
}

Color registryHealthApiConsistencyStatusColor(
  RegistryHealthApiConsistencyStatus status,
) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Colors.red.shade700;
  }
}

class _ApiConsistencyMetricChip extends StatelessWidget {
  const _ApiConsistencyMetricChip({
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
        child: Icon(Icons.schema_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
