import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

enum RegistryHealthShowcaseThresholdStatus { pass, warn, fail }

class RegistryHealthShowcaseThresholdCheck {
  final String key;
  final String label;
  final String scope;
  final String targetLabel;
  final String actualLabel;
  final RegistryHealthShowcaseThresholdStatus status;
  final String message;

  const RegistryHealthShowcaseThresholdCheck({
    required this.key,
    required this.label,
    required this.scope,
    required this.targetLabel,
    required this.actualLabel,
    required this.status,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'scope': scope,
    'targetLabel': targetLabel,
    'actualLabel': actualLabel,
    'status': status.name,
    'message': message,
  };
}

class RegistryHealthShowcaseThresholdReport {
  final int expectedCount;
  final int coveredCount;
  final int unknownCount;
  final int duplicateCount;
  final double coverageRatio;
  final List<RegistryHealthShowcaseThresholdCheck> checks;

  const RegistryHealthShowcaseThresholdReport({
    required this.expectedCount,
    required this.coveredCount,
    required this.unknownCount,
    required this.duplicateCount,
    required this.coverageRatio,
    required this.checks,
  });

  int get passCount =>
      _countByStatus(RegistryHealthShowcaseThresholdStatus.pass);
  int get warnCount =>
      _countByStatus(RegistryHealthShowcaseThresholdStatus.warn);
  int get failCount =>
      _countByStatus(RegistryHealthShowcaseThresholdStatus.fail);

  bool get isPassing => failCount == 0;

  RegistryHealthShowcaseThresholdStatus get status {
    if (failCount > 0) return RegistryHealthShowcaseThresholdStatus.fail;
    if (warnCount > 0) return RegistryHealthShowcaseThresholdStatus.warn;
    return RegistryHealthShowcaseThresholdStatus.pass;
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'statusLabel': registryHealthShowcaseThresholdReportLabel(this),
    'expectedCount': expectedCount,
    'coveredCount': coveredCount,
    'unknownCount': unknownCount,
    'duplicateCount': duplicateCount,
    'coverageRatio': coverageRatio,
    'passCount': passCount,
    'warnCount': warnCount,
    'failCount': failCount,
    'checks': [for (final check in checks) check.toJson()],
  };

  int _countByStatus(RegistryHealthShowcaseThresholdStatus status) {
    return checks.where((check) => check.status == status).length;
  }
}

RegistryHealthShowcaseThresholdReport registryHealthShowcaseThresholdReport(
  ChartFamilyShowcaseCoverageReport coverage, {
  int maximumUnknownExamples = 0,
  int maximumDuplicateExamples = 0,
  double minimumOverallCoverage = 0.5,
  Map<String, double> bundleMinimums = const <String, double>{},
  Map<String, double> dataShapeMinimums = const <String, double>{},
}) {
  final checks = <RegistryHealthShowcaseThresholdCheck>[
    _countThresholdCheck(
      key: 'unknown_examples',
      label: 'Unknown Examples',
      scope: 'showcase',
      actualCount: coverage.unknownCount,
      maximumCount: maximumUnknownExamples,
      failingStatus: RegistryHealthShowcaseThresholdStatus.fail,
    ),
    _countThresholdCheck(
      key: 'duplicate_examples',
      label: 'Duplicate Examples',
      scope: 'showcase',
      actualCount: coverage.duplicateCount,
      maximumCount: maximumDuplicateExamples,
      failingStatus: RegistryHealthShowcaseThresholdStatus.fail,
    ),
    _ratioThresholdCheck(
      key: 'overall_coverage',
      label: 'Overall Coverage',
      scope: 'showcase',
      actualRatio: coverage.coverageRatio,
      minimumRatio: minimumOverallCoverage,
      failingStatus: RegistryHealthShowcaseThresholdStatus.warn,
    ),
  ];

  for (final entry in bundleMinimums.entries) {
    final counts = coverage.bundleCoverage[entry.key];
    checks.add(
      _ratioThresholdCheck(
        key: 'bundle_${entry.key}',
        label: 'Bundle ${entry.key}',
        scope: 'bundle',
        actualRatio: _coverageRatioForCounts(counts),
        minimumRatio: entry.value,
        failingStatus: RegistryHealthShowcaseThresholdStatus.warn,
      ),
    );
  }

  for (final entry in dataShapeMinimums.entries) {
    final counts = coverage.dataShapeCoverage[entry.key];
    checks.add(
      _ratioThresholdCheck(
        key: 'shape_${entry.key}',
        label: 'Shape ${entry.key}',
        scope: 'dataShape',
        actualRatio: _coverageRatioForCounts(counts),
        minimumRatio: entry.value,
        failingStatus: RegistryHealthShowcaseThresholdStatus.warn,
      ),
    );
  }

  return RegistryHealthShowcaseThresholdReport(
    expectedCount: coverage.expectedCount,
    coveredCount: coverage.coveredCount,
    unknownCount: coverage.unknownCount,
    duplicateCount: coverage.duplicateCount,
    coverageRatio: coverage.coverageRatio,
    checks: List<RegistryHealthShowcaseThresholdCheck>.unmodifiable(checks),
  );
}

String registryHealthShowcaseThresholdReportLabel(
  RegistryHealthShowcaseThresholdReport report,
) {
  switch (report.status) {
    case RegistryHealthShowcaseThresholdStatus.pass:
      return 'Passing';
    case RegistryHealthShowcaseThresholdStatus.warn:
      return 'Warnings';
    case RegistryHealthShowcaseThresholdStatus.fail:
      return 'Failing';
  }
}

Color registryHealthShowcaseThresholdReportColor(
  RegistryHealthShowcaseThresholdReport report,
) {
  return registryHealthShowcaseThresholdStatusColor(report.status);
}

Color registryHealthShowcaseThresholdStatusColor(
  RegistryHealthShowcaseThresholdStatus status,
) {
  switch (status) {
    case RegistryHealthShowcaseThresholdStatus.pass:
      return Colors.green.shade700;
    case RegistryHealthShowcaseThresholdStatus.warn:
      return Colors.orange.shade800;
    case RegistryHealthShowcaseThresholdStatus.fail:
      return Colors.red.shade700;
  }
}

String registryHealthShowcaseThresholdRatioLabel(double ratio) {
  if (ratio.isNaN || ratio.isInfinite) return '0%';
  return '${(ratio.clamp(0, 1).toDouble() * 100).round()}%';
}

class RegistryHealthShowcaseThresholdPanel extends StatelessWidget {
  const RegistryHealthShowcaseThresholdPanel({super.key, required this.report});

  final RegistryHealthShowcaseThresholdReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ThresholdMetricChip(
              label: 'Status',
              value: registryHealthShowcaseThresholdReportLabel(report),
              color: registryHealthShowcaseThresholdReportColor(report),
            ),
            _ThresholdMetricChip(
              label: 'Pass',
              value: report.passCount.toString(),
              color: Colors.green.shade700,
            ),
            _ThresholdMetricChip(
              label: 'Warn',
              value: report.warnCount.toString(),
              color: report.warnCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ThresholdMetricChip(
              label: 'Fail',
              value: report.failCount.toString(),
              color: report.failCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowHeight: 34,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 54,
                  columns: const [
                    DataColumn(label: Text('Check')),
                    DataColumn(label: Text('Target')),
                    DataColumn(label: Text('Actual')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: [
                    for (final check in report.checks)
                      DataRow(
                        cells: [
                          DataCell(Text(check.label)),
                          DataCell(Text(check.targetLabel)),
                          DataCell(Text(check.actualLabel)),
                          DataCell(_ThresholdStatusChip(check.status)),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

RegistryHealthShowcaseThresholdCheck _countThresholdCheck({
  required String key,
  required String label,
  required String scope,
  required int actualCount,
  required int maximumCount,
  required RegistryHealthShowcaseThresholdStatus failingStatus,
}) {
  final passed = actualCount <= maximumCount;
  return RegistryHealthShowcaseThresholdCheck(
    key: key,
    label: label,
    scope: scope,
    targetLabel: '<= $maximumCount',
    actualLabel: actualCount.toString(),
    status: passed ? RegistryHealthShowcaseThresholdStatus.pass : failingStatus,
    message: passed
        ? '$label is within threshold.'
        : '$label is above threshold.',
  );
}

RegistryHealthShowcaseThresholdCheck _ratioThresholdCheck({
  required String key,
  required String label,
  required String scope,
  required double actualRatio,
  required double minimumRatio,
  required RegistryHealthShowcaseThresholdStatus failingStatus,
}) {
  final passed = actualRatio >= minimumRatio;
  return RegistryHealthShowcaseThresholdCheck(
    key: key,
    label: label,
    scope: scope,
    targetLabel:
        '>= ${registryHealthShowcaseThresholdRatioLabel(minimumRatio)}',
    actualLabel: registryHealthShowcaseThresholdRatioLabel(actualRatio),
    status: passed ? RegistryHealthShowcaseThresholdStatus.pass : failingStatus,
    message: passed
        ? '$label meets the minimum threshold.'
        : '$label is below the minimum threshold.',
  );
}

double _coverageRatioForCounts(Map<String, int>? counts) {
  if (counts == null) return 0;
  final expected = counts['expected'] ?? 0;
  if (expected == 0) return 1;
  return (counts['covered'] ?? 0) / expected;
}

class _ThresholdMetricChip extends StatelessWidget {
  const _ThresholdMetricChip({
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
        radius: 11,
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Text(value, style: const TextStyle(fontSize: 10)),
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ThresholdStatusChip extends StatelessWidget {
  const _ThresholdStatusChip(this.status);

  final RegistryHealthShowcaseThresholdStatus status;

  @override
  Widget build(BuildContext context) {
    final color = registryHealthShowcaseThresholdStatusColor(status);
    return Chip(
      label: Text(status.name),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}
