import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_primitive_remediation.dart';

class RegistryHealthApiConsistencyPrimitiveRemediationPanel
    extends StatelessWidget {
  const RegistryHealthApiConsistencyPrimitiveRemediationPanel({
    super.key,
    required this.report,
    this.primitiveLimit = 5,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencyPrimitiveRemediationReport report;
  final int primitiveLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No primitive remediation targets.');
    }

    final visibleItems = report.visibleItems(limit: primitiveLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Primitive Plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyPrimitivePlanJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyChecklist(context),
                    icon: const Icon(Icons.checklist_outlined, size: 16),
                    label: const Text('Copy Checklist'),
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
            _PrimitiveRemediationMetricChip(
              label: 'Primitives',
              value: report.primitiveCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _PrimitiveRemediationMetricChip(
              label: 'Actions',
              value: report.actionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _PrimitiveRemediationMetricChip(
              label: 'Required',
              value: report.requiredGapCount.toString(),
              color: report.requiredGapCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _PrimitiveRemediationMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _PrimitiveRemediationRow(item: item),
        if (report.primitiveCount > visibleItems.length)
          Text(
            '+${report.primitiveCount - visibleItems.length} more primitives',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyPrimitivePlanJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(primitiveLimit: primitiveLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API primitive plan JSON copied')),
    );
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthApiConsistencyPrimitiveChecklistText(
      report,
      primitiveLimit: primitiveLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API primitive checklist copied')),
    );
  }
}

class _PrimitiveRemediationMetricChip extends StatelessWidget {
  const _PrimitiveRemediationMetricChip({
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
        child: Icon(Icons.construction_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PrimitiveRemediationRow extends StatelessWidget {
  const _PrimitiveRemediationRow({required this.item});

  final RegistryHealthApiConsistencyPrimitiveRemediationItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _primitiveRemediationStatusColor(item.status);
    final phaseColor = _primitiveRemediationPhaseColor(item.leadingPhase);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.construction_outlined, size: 18, color: statusColor),
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
                      item.primitiveLabel,
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
                      item.leadingPhaseLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${item.actionCount} actions',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  item.fieldLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.coverageLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.topAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.recipe.targetLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.recipe.acceptanceLabel,
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

Color _primitiveRemediationStatusColor(
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

Color _primitiveRemediationPhaseColor(
  RegistryHealthApiConsistencyActionPhase phase,
) {
  switch (phase) {
    case RegistryHealthApiConsistencyActionPhase.now:
      return Colors.red.shade700;
    case RegistryHealthApiConsistencyActionPhase.next:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyActionPhase.later:
      return Colors.blueGrey.shade600;
  }
}
