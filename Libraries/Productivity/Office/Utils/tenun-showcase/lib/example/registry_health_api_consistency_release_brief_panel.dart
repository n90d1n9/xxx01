import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_consistency_release_brief.dart';
import 'registry_health_api_consistency_release_brief_text.dart';

class RegistryHealthApiConsistencyReleaseBriefPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyReleaseBriefPanel({
    super.key,
    required this.report,
    this.itemLimit = 5,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencyReleaseBriefReport report;
  final int itemLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API release brief.');
    }

    final visibleItems = report.visibleItems(limit: itemLimit);
    final statusColor = _releaseBriefStatusColor(report.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Release Brief',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyBriefJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyBrief(context),
                    icon: const Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 16,
                    ),
                    label: const Text('Copy Brief'),
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
            _ReleaseBriefMetricChip(
              label: 'Status',
              value: report.statusLabel,
              color: statusColor,
            ),
            _ReleaseBriefMetricChip(
              label: 'Current',
              value: '${report.currentScorePercent}%',
              color: Theme.of(context).colorScheme.primary,
            ),
            _ReleaseBriefMetricChip(
              label: 'Projected',
              value: '${report.projectedScorePercent}%',
              color: statusColor,
            ),
            _ReleaseBriefMetricChip(
              label: 'Review',
              value: report.reviewItemCount.toString(),
              color: report.reviewItemCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ReleaseBriefMetricChip(
              label: 'Blocked',
              value: report.blockedItemCount.toString(),
              color: report.blockedItemCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          report.releaseLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in visibleItems) _ReleaseBriefRow(item: item),
        if (report.itemCount > visibleItems.length)
          Text(
            '+${report.itemCount - visibleItems.length} more release brief items',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyBriefJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(itemLimit: itemLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API release brief JSON copied')),
    );
  }

  void _copyBrief(BuildContext context) {
    final text = registryHealthApiConsistencyReleaseBriefText(
      report,
      itemLimit: itemLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API release brief copied')));
  }
}

class _ReleaseBriefMetricChip extends StatelessWidget {
  const _ReleaseBriefMetricChip({
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
        child: Icon(
          Icons.assignment_turned_in_outlined,
          size: 14,
          color: color,
        ),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ReleaseBriefRow extends StatelessWidget {
  const _ReleaseBriefRow({required this.item});

  final RegistryHealthApiConsistencyReleaseBriefItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _releaseBriefStatusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 18,
            color: statusColor,
          ),
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
                      item.kindLabel,
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
                    for (final metric in item.metrics.take(2))
                      Text(
                        metric,
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
                  item.detailLabel,
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

Color _releaseBriefStatusColor(RegistryHealthApiConformanceGateStatus status) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConformanceGateStatus.review:
      return Colors.orange.shade800;
    case RegistryHealthApiConformanceGateStatus.blocked:
      return Colors.red.shade700;
  }
}
