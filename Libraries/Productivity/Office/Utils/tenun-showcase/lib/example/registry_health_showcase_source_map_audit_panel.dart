import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'registry_health_showcase_source_map_audit.dart';

class RegistryHealthShowcaseSourceMapAuditPanel extends StatelessWidget {
  const RegistryHealthShowcaseSourceMapAuditPanel({
    super.key,
    required this.report,
    this.issueLimit = 8,
  });

  final RegistryHealthShowcaseSourceMapAuditReport report;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final visibleIssues = registryHealthShowcaseSourceMapAuditVisibleIssues(
      report,
      limit: issueLimit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthShowcaseSourceMapAuditSummary(report),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SourceMapMetricChip(
              label: 'Status',
              value: registryHealthShowcaseSourceMapAuditReportLabel(report),
              color: registryHealthShowcaseSourceMapAuditStatusColor(report),
            ),
            _SourceMapMetricChip(
              label: 'Mapped',
              value:
                  '${report.mappedSampleCount}/${report.expectedSampleCount}',
            ),
            _SourceMapMetricChip(
              label: 'Exact',
              value: registryHealthShowcaseSourceMapAuditRatioLabel(
                report.exactTypePositionRatio,
              ),
            ),
            _SourceMapMetricChip(
              label: 'Issues',
              value: report.issueCount.toString(),
              color: report.issueCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _SourceMapMetricChip(
              label: 'File',
              value: report.sourceFile.split('/').last,
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _copyAuditJson(context),
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy Source Map Audit JSON'),
        ),
        const SizedBox(height: 12),
        if (visibleIssues.isEmpty)
          const Text('No source-map drift detected.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final issue in visibleIssues)
                _SourceMapAuditIssueRow(issue: issue),
              if (report.issues.length > visibleIssues.length)
                Text(
                  '+${report.issues.length - visibleIssues.length} more issues',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
      ],
    );
  }

  void _copyAuditJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    Clipboard.setData(ClipboardData(text: encoder.convert(report.toJson())));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Source map audit JSON copied')),
    );
  }
}

String registryHealthShowcaseSourceMapAuditSummary(
  RegistryHealthShowcaseSourceMapAuditReport report,
) {
  final sampleLabel = report.expectedSampleCount == 1 ? 'sample' : 'samples';
  return '${report.mappedSampleCount}/${report.expectedSampleCount} focused '
      '$sampleLabel mapped to registry source, with '
      '${report.exactTypePositionCount} exact json.type positions.';
}

String registryHealthShowcaseSourceMapAuditRatioLabel(double ratio) {
  if (ratio.isNaN || ratio.isInfinite) return '0%';
  final safeRatio = ratio.clamp(0, 1).toDouble();
  return '${(safeRatio * 100).round()}%';
}

Color registryHealthShowcaseSourceMapAuditStatusColor(
  RegistryHealthShowcaseSourceMapAuditReport report,
) {
  switch (report.status) {
    case RegistryHealthShowcaseSourceMapAuditStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthShowcaseSourceMapAuditStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthShowcaseSourceMapAuditStatus.broken:
      return Colors.red.shade700;
  }
}

String registryHealthShowcaseSourceMapAuditIssueLocation(
  RegistryHealthShowcaseSourceMapAuditIssue issue,
) {
  final sample = issue.sampleTitle?.trim();
  final type = issue.chartType?.trim();
  final base = sample == null || sample.isEmpty
      ? issue.familyTitle
      : '${issue.familyTitle} / $sample';
  if (type == null || type.isEmpty) return base;
  return '$base ($type)';
}

class _SourceMapMetricChip extends StatelessWidget {
  const _SourceMapMetricChip({
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
        backgroundColor: effectiveColor.withValues(alpha: 0.12),
        child: Icon(Icons.place_outlined, size: 14, color: effectiveColor),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourceMapAuditIssueRow extends StatelessWidget {
  const _SourceMapAuditIssueRow({required this.issue});

  final RegistryHealthShowcaseSourceMapAuditIssue issue;

  @override
  Widget build(BuildContext context) {
    final isError =
        issue.severity == RegistryHealthShowcaseSourceMapAuditSeverity.error;
    final color = isError ? Colors.red.shade700 : Colors.orange.shade800;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${issue.code} · '
                  '${registryHealthShowcaseSourceMapAuditIssueLocation(issue)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  issue.message,
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
