import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_field_remediation.dart';

class RegistryHealthApiConsistencyFieldRemediationPanel
    extends StatelessWidget {
  const RegistryHealthApiConsistencyFieldRemediationPanel({
    super.key,
    required this.report,
    this.fieldLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencyFieldRemediationReport report;
  final int fieldLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No field remediation targets.');
    }

    final visibleItems = report.visibleItems(limit: fieldLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Field Remediation',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyFieldPlanJson(context),
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
            _FieldRemediationMetricChip(
              label: 'Fields',
              value: report.fieldOptionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _FieldRemediationMetricChip(
              label: 'Actions',
              value: report.actionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _FieldRemediationMetricChip(
              label: 'Required',
              value: report.requiredGapCount.toString(),
              color: report.requiredGapCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _FieldRemediationMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _FieldRemediationRow(item: item),
        if (report.fieldOptionCount > visibleItems.length)
          Text(
            '+${report.fieldOptionCount - visibleItems.length} more fields',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyFieldPlanJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(report.toJson(fieldLimit: fieldLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API field plan JSON copied')));
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthApiConsistencyFieldChecklistText(
      report,
      fieldLimit: fieldLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API field checklist copied')));
  }
}

class _FieldRemediationMetricChip extends StatelessWidget {
  const _FieldRemediationMetricChip({
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
        child: Icon(Icons.tune_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _FieldRemediationRow extends StatelessWidget {
  const _FieldRemediationRow({required this.item});

  final RegistryHealthApiConsistencyFieldRemediationItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _fieldRemediationStatusColor(item.status);
    final phaseColor = _fieldRemediationPhaseColor(item.leadingPhase);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tune_outlined, size: 18, color: statusColor),
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
                      item.fieldName,
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
                  item.coverageLabel,
                  style: Theme.of(context).textTheme.bodySmall,
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
                Text(
                  'Families: ${item.familyNames.join(', ')}',
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

Color _fieldRemediationStatusColor(RegistryHealthApiConsistencyStatus status) {
  switch (status) {
    case RegistryHealthApiConsistencyStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyStatus.blocked:
      return Colors.red.shade700;
  }
}

Color _fieldRemediationPhaseColor(
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
