import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_traceability.dart';

class RegistryHealthApiConsistencyTraceabilityPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyTraceabilityPanel({
    super.key,
    required this.report,
    this.traceLimit = 8,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencyTraceabilityReport report;
  final int traceLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API implementation traces.');
    }

    final visibleItems = report.visibleItems(limit: traceLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Implementation Traceability',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyTraceJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyTargets(context),
                    icon: const Icon(Icons.account_tree_outlined, size: 16),
                    label: const Text('Copy Targets'),
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
            _TraceabilityMetricChip(
              label: 'Traces',
              value: report.traceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _TraceabilityMetricChip(
              label: 'Families',
              value: report.familyTraceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _TraceabilityMetricChip(
              label: 'Primitives',
              value: report.primitiveTraceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _TraceabilityMetricChip(
              label: 'Fields',
              value: report.fieldTraceCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _TraceabilityMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _TraceabilityRow(item: item),
        if (report.traceCount > visibleItems.length)
          Text(
            '+${report.traceCount - visibleItems.length} more traces',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyTraceJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(traceLimit: traceLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API traceability JSON copied')),
    );
  }

  void _copyTargets(BuildContext context) {
    final text = registryHealthApiConsistencyTraceabilityText(
      report,
      traceLimit: traceLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API traceability targets copied')),
    );
  }
}

class _TraceabilityMetricChip extends StatelessWidget {
  const _TraceabilityMetricChip({
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
        child: Icon(Icons.route_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _TraceabilityRow extends StatelessWidget {
  const _TraceabilityRow({required this.item});

  final RegistryHealthApiConsistencyTraceItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _traceabilityStatusColor(item.status);
    final phaseColor = _traceabilityPhaseColor(item.phase);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.route_outlined, size: 18, color: statusColor),
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.title,
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
                    Text(
                      item.phaseLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Impact +${item.scoreImpactLabel}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.recipeTargetLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.primarySourceLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${item.sourceTargets.length} source targets',
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

Color _traceabilityStatusColor(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Colors.red.shade700;
  }
}

Color _traceabilityPhaseColor(RegistryHealthApiConsistencyActionPhase phase) {
  switch (phase) {
    case RegistryHealthApiConsistencyActionPhase.now:
      return Colors.red.shade700;
    case RegistryHealthApiConsistencyActionPhase.next:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyActionPhase.later:
      return Colors.blueGrey.shade600;
  }
}
