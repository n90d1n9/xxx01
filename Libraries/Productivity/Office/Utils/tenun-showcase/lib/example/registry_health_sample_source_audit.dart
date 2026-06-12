import 'package:flutter/material.dart';

import 'chart_sample_source_audit.dart';

class RegistryHealthSampleSourceAuditPanel extends StatelessWidget {
  const RegistryHealthSampleSourceAuditPanel({
    super.key,
    required this.audit,
    this.issueLimit = 8,
  });

  final ChartSampleSourceAuditReport audit;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final statusColor = registryHealthSampleSourceAuditStatusColor(audit);
    final visibleIssues = registryHealthSampleSourceAuditVisibleIssues(
      audit,
      limit: issueLimit,
    );
    final visibleIssueCodes = registryHealthSampleSourceAuditVisibleIssueCodes(
      audit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthSampleSourceAuditSummary(audit),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SourceAuditMetricChip(
              label: 'Status',
              value: registryHealthSampleSourceAuditStatusLabel(audit),
              color: statusColor,
            ),
            _SourceAuditMetricChip(
              label: 'Sources',
              value: audit.checkedSourceCount.toString(),
            ),
            _SourceAuditMetricChip(
              label: 'Samples',
              value: audit.sampleCount.toString(),
            ),
            _SourceAuditMetricChip(
              label: 'Cases',
              value: audit.caseCount.toString(),
            ),
            _SourceAuditMetricChip(
              label: 'Issues',
              value: audit.issues.length.toString(),
              color: audit.issues.isEmpty
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (audit.caseResults.isNotEmpty) ...[
          _SourceAuditChipGroup(
            title: 'Case Health',
            children: [
              for (final result in audit.caseResults)
                _SourceAuditBreakdownChip(
                  label: result.label,
                  value: registryHealthSampleSourceAuditResultLabel(
                    checkedSourceCount: result.checkedSourceCount,
                    issueCount: result.issueCount,
                  ),
                  color: registryHealthSampleSourceAuditResultColor(
                    result.issueCount,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (audit.familyResults.isNotEmpty) ...[
          _SourceAuditChipGroup(
            title: 'Family Health',
            children: [
              for (final result in audit.familyResults)
                _SourceAuditBreakdownChip(
                  label: result.title,
                  value: registryHealthSampleSourceAuditResultLabel(
                    checkedSourceCount: result.checkedSourceCount,
                    issueCount: result.issueCount,
                  ),
                  color: registryHealthSampleSourceAuditResultColor(
                    result.issueCount,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (visibleIssueCodes.isNotEmpty) ...[
          _SourceAuditChipGroup(
            title: 'Issue Breakdown',
            children: [
              for (final entry in visibleIssueCodes)
                _SourceAuditBreakdownChip(
                  label: entry.key,
                  value: entry.value.toString(),
                  color: Colors.red.shade700,
                ),
              if (audit.issueCodeCounts.length > visibleIssueCodes.length)
                _SourceAuditBreakdownChip(
                  label: 'More',
                  value:
                      '+${audit.issueCodeCounts.length - visibleIssueCodes.length}',
                  color: Colors.orange.shade800,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (visibleIssues.isEmpty)
          const Text('No source audit issues.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final issue in visibleIssues)
                _SourceAuditIssueRow(issue: issue),
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

String registryHealthSampleSourceAuditStatusLabel(
  ChartSampleSourceAuditReport audit,
) {
  return audit.isValid ? 'Ready' : 'Issues';
}

String registryHealthSampleSourceAuditSummary(
  ChartSampleSourceAuditReport audit,
) {
  final sampleLabel = audit.sampleCount == 1 ? 'sample' : 'samples';
  final sourceLabel = audit.checkedSourceCount == 1 ? 'source' : 'sources';
  return '${audit.checkedSourceCount} generated $sourceLabel across '
      '${audit.sampleCount} focused $sampleLabel checked for copy-ready JSON '
      'and code.';
}

Color registryHealthSampleSourceAuditStatusColor(
  ChartSampleSourceAuditReport audit,
) {
  return audit.isValid ? Colors.green.shade700 : Colors.red.shade700;
}

String registryHealthSampleSourceAuditResultLabel({
  required int checkedSourceCount,
  required int issueCount,
}) {
  final checkLabel = checkedSourceCount == 1 ? 'check' : 'checks';
  if (issueCount == 0) {
    return '$checkedSourceCount $checkLabel';
  }

  final issueLabel = issueCount == 1 ? 'issue' : 'issues';
  return '$checkedSourceCount $checkLabel, $issueCount $issueLabel';
}

Color registryHealthSampleSourceAuditResultColor(int issueCount) {
  return issueCount == 0 ? Colors.green.shade700 : Colors.red.shade700;
}

List<MapEntry<String, int>> registryHealthSampleSourceAuditVisibleIssueCodes(
  ChartSampleSourceAuditReport audit, {
  int limit = 6,
}) {
  final sorted = audit.issueCodeCounts.entries.toList(growable: false)
    ..sort((a, b) {
      final count = b.value.compareTo(a.value);
      if (count != 0) return count;
      return a.key.compareTo(b.key);
    });

  return sorted.take(limit).toList(growable: false);
}

List<ChartSampleSourceAuditIssue> registryHealthSampleSourceAuditVisibleIssues(
  ChartSampleSourceAuditReport audit, {
  int limit = 8,
}) {
  final sorted = List<ChartSampleSourceAuditIssue>.from(audit.issues)
    ..sort((a, b) {
      final family = a.familyId.compareTo(b.familyId);
      if (family != 0) return family;
      final sample = (a.sampleTitle ?? '').compareTo(b.sampleTitle ?? '');
      if (sample != 0) return sample;
      final auditCase = a.caseId.compareTo(b.caseId);
      if (auditCase != 0) return auditCase;
      return a.code.compareTo(b.code);
    });

  return sorted.take(limit).toList(growable: false);
}

String registryHealthSampleSourceAuditIssueLocation(
  ChartSampleSourceAuditIssue issue,
) {
  final sample = issue.sampleTitle?.trim();
  final type = issue.chartType?.trim();
  final location = sample == null || sample.isEmpty
      ? issue.familyTitle
      : '${issue.familyTitle} / $sample';
  final typedLocation = type == null || type.isEmpty
      ? location
      : '$location ($type)';
  return '$typedLocation / ${issue.caseLabel}';
}

class _SourceAuditMetricChip extends StatelessWidget {
  const _SourceAuditMetricChip({
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

class _SourceAuditChipGroup extends StatelessWidget {
  const _SourceAuditChipGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _SourceAuditBreakdownChip extends StatelessWidget {
  const _SourceAuditBreakdownChip({
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
      label: Text('$label: $value'),
      side: BorderSide(color: color.withValues(alpha: 0.38)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourceAuditIssueRow extends StatelessWidget {
  const _SourceAuditIssueRow({required this.issue});

  final ChartSampleSourceAuditIssue issue;

  @override
  Widget build(BuildContext context) {
    final color = Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registryHealthSampleSourceAuditIssueLocation(issue),
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
