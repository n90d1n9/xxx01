import 'package:flutter/material.dart';

import 'registry_health_chart_example_matrix_model.dart';

class RegistryHealthChartExampleMatrixWorkSections extends StatelessWidget {
  const RegistryHealthChartExampleMatrixWorkSections({
    super.key,
    required this.report,
    this.prioritySummaryLimit = 6,
    this.actionSummaryLimit = 6,
    this.nextWorkLimit = 6,
    this.attentionLimit = 8,
  });

  final RegistryHealthChartExampleMatrixReport report;
  final int prioritySummaryLimit;
  final int actionSummaryLimit;
  final int nextWorkLimit;
  final int attentionLimit;

  @override
  Widget build(BuildContext context) {
    final visiblePrioritySummaries =
        registryHealthChartExampleMatrixVisiblePrioritySummaries(
          report,
          limit: prioritySummaryLimit,
        );
    final visibleActionSummaries =
        registryHealthChartExampleMatrixVisibleActionSummaries(
          report,
          limit: actionSummaryLimit,
        );
    final visibleNextWorkItems = registryHealthChartExampleMatrixNextWorkItems(
      report,
      limit: nextWorkLimit,
    );
    final visibleAttentionRows =
        registryHealthChartExampleMatrixVisibleAttentionRows(
          report,
          limit: attentionLimit,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (visiblePrioritySummaries.isNotEmpty) ...[
          _ChartExampleMatrixWorkSection(
            title: 'Priority Summary',
            children: [
              for (final summary in visiblePrioritySummaries)
                _MatrixPrioritySummaryChip(summary: summary),
              if (report.attentionPrioritySummaryCount >
                  visiblePrioritySummaries.length)
                _MatrixMoreChip(
                  hiddenCount:
                      report.attentionPrioritySummaryCount -
                      visiblePrioritySummaries.length,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (visibleActionSummaries.isNotEmpty) ...[
          _ChartExampleMatrixWorkSection(
            title: 'Action Summary',
            children: [
              for (final summary in visibleActionSummaries)
                _MatrixActionSummaryChip(summary: summary),
              if (report.actionSummaryCount > visibleActionSummaries.length)
                _MatrixMoreChip(
                  hiddenCount:
                      report.actionSummaryCount - visibleActionSummaries.length,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (visibleNextWorkItems.isNotEmpty) ...[
          _ChartExampleMatrixWorkSection(
            title: 'Next Work',
            children: [
              for (final item in visibleNextWorkItems)
                _MatrixNextWorkItemChip(item: item),
              if (report.nextWorkItemCount > visibleNextWorkItems.length)
                _MatrixMoreChip(
                  hiddenCount:
                      report.nextWorkItemCount - visibleNextWorkItems.length,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (visibleAttentionRows.isNotEmpty) ...[
          _ChartExampleMatrixWorkSection(
            title: 'Attention Queue',
            children: [
              for (final row in visibleAttentionRows)
                _MatrixAttentionChip(row: row),
              if (report.attentionCount > visibleAttentionRows.length)
                _MatrixMoreChip(
                  hiddenCount:
                      report.attentionCount - visibleAttentionRows.length,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ChartExampleMatrixWorkSection extends StatelessWidget {
  const _ChartExampleMatrixWorkSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _MatrixMoreChip extends StatelessWidget {
  const _MatrixMoreChip({required this.hiddenCount});

  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('+$hiddenCount more'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MatrixActionSummaryChip extends StatelessWidget {
  const _MatrixActionSummaryChip({required this.summary});

  final RegistryHealthChartExampleMatrixActionSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = _rowStatusColor(summary.status);
    final chartTypeLabel = summary.rowCount == 1 ? 'type' : 'types';
    final issueText = summary.issueCount == 0
        ? ''
        : ', ${summary.issueCount} issues';
    return Chip(
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Text(
          summary.rowCount.toString(),
          style: const TextStyle(fontSize: 10),
        ),
      ),
      label: Text(
        '${summary.action} - ${summary.rowCount} $chartTypeLabel$issueText',
      ),
      side: BorderSide(color: color.withValues(alpha: 0.38)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MatrixPrioritySummaryChip extends StatelessWidget {
  const _MatrixPrioritySummaryChip({required this.summary});

  final RegistryHealthChartExampleMatrixPrioritySummary summary;

  @override
  Widget build(BuildContext context) {
    final color = _prioritySummaryColor(summary);
    final issueText = summary.issueCount == 0
        ? ''
        : ', ${summary.issueCount} issues';
    return Chip(
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Text(
          summary.attentionCount.toString(),
          style: const TextStyle(fontSize: 10),
        ),
      ),
      label: Text(
        '${summary.priorityLabel} - ${summary.attentionCount}/${summary.rowCount} need work$issueText',
      ),
      side: BorderSide(color: color.withValues(alpha: 0.38)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MatrixNextWorkItemChip extends StatelessWidget {
  const _MatrixNextWorkItemChip({required this.item});

  final RegistryHealthChartExampleMatrixWorkItem item;

  @override
  Widget build(BuildContext context) {
    final color = _rowStatusColor(item.status);
    final issueText = item.issueCount == 0 ? '' : ', ${item.issueCount} issues';
    return Chip(
      avatar: CircleAvatar(
        radius: 11,
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Text('#${item.rank}', style: const TextStyle(fontSize: 9)),
      ),
      label: Text(
        '${item.typeString}: ${item.priorityLabel} ${item.statusLabel}$issueText - ${item.action}',
      ),
      side: BorderSide(color: color.withValues(alpha: 0.38)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MatrixAttentionChip extends StatelessWidget {
  const _MatrixAttentionChip({required this.row});

  final RegistryHealthChartExampleMatrixRow row;

  @override
  Widget build(BuildContext context) {
    final color = _rowStatusColor(row.status);
    final issueText = row.issueCount == 0 ? '' : ', ${row.issueCount} issues';
    return Chip(
      label: Text(
        '${row.typeString}: ${row.priorityLabel} ${row.statusLabel}$issueText - ${row.nextAction}',
      ),
      side: BorderSide(color: color.withValues(alpha: 0.38)),
      backgroundColor: color.withValues(alpha: 0.08),
      visualDensity: VisualDensity.compact,
    );
  }
}

Color _rowStatusColor(RegistryHealthChartExampleMatrixStatus status) {
  return switch (status) {
    RegistryHealthChartExampleMatrixStatus.ready => Colors.green.shade700,
    RegistryHealthChartExampleMatrixStatus.missingSample =>
      Colors.orange.shade800,
    RegistryHealthChartExampleMatrixStatus.issue => Colors.red.shade700,
    RegistryHealthChartExampleMatrixStatus.unknown => Colors.red.shade700,
  };
}

Color _prioritySummaryColor(
  RegistryHealthChartExampleMatrixPrioritySummary summary,
) {
  if (summary.unknownRowCount > 0 || summary.issueRowCount > 0) {
    return Colors.red.shade700;
  }
  if (summary.missingSampleCount > 0) return Colors.orange.shade800;
  return Colors.green.shade700;
}
