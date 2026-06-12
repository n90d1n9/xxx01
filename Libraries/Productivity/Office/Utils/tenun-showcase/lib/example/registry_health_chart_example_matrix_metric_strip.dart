import 'package:flutter/material.dart';

import 'registry_health_chart_example_matrix_model.dart';

Color registryHealthChartExampleMatrixStatusColor(
  RegistryHealthChartExampleMatrixReport report,
) {
  if (report.unknownRowCount > 0 || report.issueRowCount > 0) {
    return Colors.red.shade700;
  }
  if (report.missingSampleCount > 0) return Colors.orange.shade800;
  return Colors.green.shade700;
}

class RegistryHealthChartExampleMatrixMetricStrip extends StatelessWidget {
  const RegistryHealthChartExampleMatrixMetricStrip({
    super.key,
    required this.report,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final RegistryHealthChartExampleMatrixReport report;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final statusColor = registryHealthChartExampleMatrixStatusColor(report);
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        _ChartExampleMatrixMetricChip(
          label: 'Status',
          value: registryHealthChartExampleMatrixStatusLabel(report),
          color: statusColor,
        ),
        _ChartExampleMatrixMetricChip(
          label: 'Readiness',
          value: report.readinessLabel,
          color: statusColor,
        ),
        _ChartExampleMatrixMetricChip(
          label: 'Ready',
          value: report.readyCount.toString(),
          color: Colors.green.shade700,
        ),
        _ChartExampleMatrixMetricChip(
          label: 'Gaps',
          value: report.missingSampleCount.toString(),
          color: report.missingSampleCount == 0
              ? Colors.green.shade700
              : Colors.orange.shade800,
        ),
        _ChartExampleMatrixMetricChip(
          label: 'Issues',
          value: report.issueRowCount.toString(),
          color: report.issueRowCount == 0
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
        _ChartExampleMatrixMetricChip(
          label: 'Unknown',
          value: report.unknownRowCount.toString(),
          color: report.unknownRowCount == 0
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ],
    );
  }
}

class _ChartExampleMatrixMetricChip extends StatelessWidget {
  const _ChartExampleMatrixMetricChip({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Chip(
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: effectiveColor.withValues(alpha: 0.12),
        foregroundColor: effectiveColor,
        child: Text(value, style: const TextStyle(fontSize: 10)),
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
