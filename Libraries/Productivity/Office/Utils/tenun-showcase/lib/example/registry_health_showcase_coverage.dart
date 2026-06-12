import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'registry_health_showcase_backlog.dart';
import 'registry_health_showcase_gap_matrix.dart';
import 'registry_health_showcase_thresholds.dart';

class RegistryHealthShowcaseCoveragePanel extends StatelessWidget {
  const RegistryHealthShowcaseCoveragePanel({
    super.key,
    required this.coverage,
    this.thresholdReport,
    this.backlogVisibleLimit = 6,
    this.backlogOptions = const RegistryHealthShowcaseBacklogPanelOptions(),
  });

  final ChartFamilyShowcaseCoverageReport coverage;
  final RegistryHealthShowcaseThresholdReport? thresholdReport;
  final int backlogVisibleLimit;
  final RegistryHealthShowcaseBacklogPanelOptions backlogOptions;

  @override
  Widget build(BuildContext context) {
    final thresholds =
        thresholdReport ?? registryHealthShowcaseThresholdReport(coverage);
    final progress = coverage.coverageRatio.clamp(0, 1).toDouble();
    final statusColor = coverage.unknownExampleKeys.isNotEmpty
        ? Colors.red.shade700
        : coverage.missingEntries.isEmpty
        ? Colors.green.shade700
        : Colors.orange.shade800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${coverage.coveredCount} of ${coverage.expectedCount} chart families are represented by focused showcase samples.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: progress, color: statusColor),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _CoverageMetricChip(
              label: 'Coverage',
              value: registryHealthCoverageRatioLabel(coverage.coverageRatio),
              color: statusColor,
            ),
            _CoverageMetricChip(
              label: 'Provided',
              value: coverage.providedCount.toString(),
            ),
            _CoverageMetricChip(
              label: 'Missing',
              value: coverage.missingCount.toString(),
              color: coverage.missingCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _CoverageMetricChip(
              label: 'Unknown',
              value: coverage.unknownCount.toString(),
              color: coverage.unknownCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _CoverageMetricChip(
              label: 'Duplicates',
              value: coverage.duplicateCount.toString(),
              color: coverage.duplicateCount == 0
                  ? Colors.green.shade700
                  : Colors.blueGrey.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _CoverageIssuePreview(coverage: coverage),
        const SizedBox(height: 14),
        Text(
          'Coverage Thresholds',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        RegistryHealthShowcaseThresholdPanel(report: thresholds),
        if (coverage.missingEntries.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Missing Chart Families',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          RegistryHealthShowcaseGapMatrix(entries: coverage.missingEntries),
          const SizedBox(height: 14),
          Text(
            'Starter Template Backlog',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          RegistryHealthShowcaseBacklogPanel(
            entries: coverage.missingEntries,
            visibleLimit: backlogVisibleLimit,
            options: backlogOptions,
          ),
        ],
        const SizedBox(height: 14),
        Text('Bundle Coverage', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        RegistryHealthCoverageTable(
          rows: registryHealthCoverageRows(coverage.bundleCoverage),
        ),
        const SizedBox(height: 14),
        Text(
          'Data Shape Coverage',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        RegistryHealthCoverageTable(
          rows: registryHealthCoverageRows(coverage.dataShapeCoverage),
        ),
      ],
    );
  }
}

class RegistryHealthCoverageTable extends StatelessWidget {
  const RegistryHealthCoverageTable({super.key, required this.rows});

  final List<RegistryHealthCoverageRow> rows;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 44,
              columns: const [
                DataColumn(label: Text('Group')),
                DataColumn(label: Text('Coverage')),
                DataColumn(label: Text('Covered')),
                DataColumn(label: Text('Missing')),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(Text(row.name)),
                      DataCell(
                        Text(registryHealthCoverageRatioLabel(row.ratio)),
                      ),
                      DataCell(Text('${row.covered}/${row.expected}')),
                      DataCell(Text(row.missing.toString())),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RegistryHealthCoverageRow {
  final String name;
  final int expected;
  final int covered;
  final int missing;

  const RegistryHealthCoverageRow({
    required this.name,
    required this.expected,
    required this.covered,
    required this.missing,
  });

  double get ratio => expected == 0 ? 1 : covered / expected;
}

List<RegistryHealthCoverageRow> registryHealthCoverageRows(
  Map<String, Map<String, int>> counts,
) {
  final rows = [
    for (final entry in counts.entries)
      RegistryHealthCoverageRow(
        name: entry.key,
        expected: entry.value['expected'] ?? 0,
        covered: entry.value['covered'] ?? 0,
        missing: entry.value['missing'] ?? 0,
      ),
  ];

  return rows..sort((a, b) {
    final missing = b.missing.compareTo(a.missing);
    if (missing != 0) return missing;
    return a.name.compareTo(b.name);
  });
}

String registryHealthCoverageRatioLabel(double ratio) {
  if (ratio.isNaN || ratio.isInfinite) return '0%';
  final bounded = ratio.clamp(0, 1).toDouble();
  return '${(bounded * 100).round()}%';
}

String registryHealthCoveragePreview(
  Iterable<String> values, {
  int visibleLimit = 8,
}) {
  final items = [
    for (final value in values)
      if (value.trim().isNotEmpty) value.trim(),
  ];
  if (items.isEmpty) return '-';
  if (items.length <= visibleLimit) return items.join(', ');

  final remaining = items.length - visibleLimit;
  return '${items.take(visibleLimit).join(', ')} +$remaining';
}

class _CoverageIssuePreview extends StatelessWidget {
  const _CoverageIssuePreview({required this.coverage});

  final ChartFamilyShowcaseCoverageReport coverage;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CoveragePreviewChip(
          label: 'Missing',
          value: registryHealthCoveragePreview(coverage.missingExampleKeys),
        ),
        if (coverage.unknownExampleKeys.isNotEmpty)
          _CoveragePreviewChip(
            label: 'Unknown',
            value: registryHealthCoveragePreview(coverage.unknownExampleKeys),
            color: Colors.red.shade700,
          ),
        if (coverage.duplicateExampleKeys.isNotEmpty)
          _CoveragePreviewChip(
            label: 'Duplicates',
            value: registryHealthCoveragePreview(coverage.duplicateExampleKeys),
            color: Colors.blueGrey.shade700,
          ),
      ],
    );
  }
}

class _CoverageMetricChip extends StatelessWidget {
  const _CoverageMetricChip({
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

class _CoveragePreviewChip extends StatelessWidget {
  const _CoveragePreviewChip({
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
      avatar: Icon(Icons.visibility_outlined, color: effectiveColor, size: 16),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
