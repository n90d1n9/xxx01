import 'package:flutter/material.dart';

import 'chart_sample_registry_audit.dart';

class RegistryHealthSampleAuditPanel extends StatelessWidget {
  const RegistryHealthSampleAuditPanel({
    super.key,
    required this.audit,
    this.issueLimit = 8,
  });

  final ChartSampleRegistryAuditReport audit;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final statusColor = registryHealthSampleAuditStatusColor(audit);
    final visibleIssues = registryHealthSampleAuditVisibleIssues(
      audit,
      limit: issueLimit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthSampleAuditSummary(audit),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SampleAuditMetricChip(
              label: 'Status',
              value: registryHealthSampleAuditStatusLabel(audit),
              color: statusColor,
            ),
            _SampleAuditMetricChip(
              label: 'Families',
              value: audit.familyCount.toString(),
            ),
            _SampleAuditMetricChip(
              label: 'Samples',
              value: audit.sampleCount.toString(),
            ),
            _SampleAuditMetricChip(
              label: 'Errors',
              value: audit.errors.length.toString(),
              color: audit.errors.isEmpty
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _SampleAuditMetricChip(
              label: 'Warnings',
              value: audit.warnings.length.toString(),
              color: audit.warnings.isEmpty
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleIssues.isEmpty)
          const Text('No sample audit issues.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final issue in visibleIssues)
                _SampleAuditIssueRow(issue: issue),
              if (audit.issues.length > visibleIssues.length)
                Text(
                  '+${audit.issues.length - visibleIssues.length} more issues',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
      ],
    );
  }
}

String registryHealthSampleAuditStatusLabel(
  ChartSampleRegistryAuditReport audit,
) {
  if (audit.errors.isNotEmpty) return 'Errors';
  if (audit.warnings.isNotEmpty) return 'Warnings';
  return 'Healthy';
}

String registryHealthSampleAuditSummary(ChartSampleRegistryAuditReport audit) {
  final familyLabel = audit.familyCount == 1 ? 'family' : 'families';
  final sampleLabel = audit.sampleCount == 1 ? 'sample' : 'samples';
  return '${audit.sampleCount} focused $sampleLabel across '
      '${audit.familyCount} $familyLabel checked for registry integrity.';
}

Color registryHealthSampleAuditStatusColor(
  ChartSampleRegistryAuditReport audit,
) {
  if (audit.errors.isNotEmpty) return Colors.red.shade700;
  if (audit.warnings.isNotEmpty) return Colors.orange.shade800;
  return Colors.green.shade700;
}

List<ChartSampleRegistryAuditIssue> registryHealthSampleAuditVisibleIssues(
  ChartSampleRegistryAuditReport audit, {
  int limit = 8,
}) {
  final sorted = List<ChartSampleRegistryAuditIssue>.from(audit.issues)
    ..sort((a, b) {
      final severity = _severityRank(a).compareTo(_severityRank(b));
      if (severity != 0) return severity;
      final family = a.familyId.compareTo(b.familyId);
      if (family != 0) return family;
      final aSample = a.sampleTitle ?? '';
      final bSample = b.sampleTitle ?? '';
      final sample = aSample.compareTo(bSample);
      if (sample != 0) return sample;
      return a.code.compareTo(b.code);
    });

  return sorted.take(limit).toList(growable: false);
}

String registryHealthSampleAuditIssueLocation(
  ChartSampleRegistryAuditIssue issue,
) {
  final sample = issue.sampleTitle?.trim();
  final type = issue.chartType?.trim();
  final location = sample == null || sample.isEmpty
      ? issue.familyTitle
      : '${issue.familyTitle} / $sample';

  if (type == null || type.isEmpty) return location;
  return '$location ($type)';
}

int _severityRank(ChartSampleRegistryAuditIssue issue) {
  switch (issue.severity) {
    case ChartSampleRegistryAuditSeverity.error:
      return 0;
    case ChartSampleRegistryAuditSeverity.warning:
      return 1;
    case ChartSampleRegistryAuditSeverity.info:
      return 2;
  }
}

class _SampleAuditMetricChip extends StatelessWidget {
  const _SampleAuditMetricChip({
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

class _SampleAuditIssueRow extends StatelessWidget {
  const _SampleAuditIssueRow({required this.issue});

  final ChartSampleRegistryAuditIssue issue;

  @override
  Widget build(BuildContext context) {
    final isError = issue.severity == ChartSampleRegistryAuditSeverity.error;
    final color = isError ? Colors.red.shade700 : Colors.orange.shade800;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.report_problem_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registryHealthSampleAuditIssueLocation(issue),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${issue.code}: ${issue.message}',
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
