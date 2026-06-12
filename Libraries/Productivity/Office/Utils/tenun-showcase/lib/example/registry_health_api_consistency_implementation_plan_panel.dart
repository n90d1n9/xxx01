import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_implementation_plan.dart';

class RegistryHealthApiConsistencyImplementationPlanPanel
    extends StatelessWidget {
  const RegistryHealthApiConsistencyImplementationPlanPanel({
    super.key,
    required this.plan,
    this.actionLimit = 8,
    this.familyLimit = 4,
    this.primitiveLimit = 5,
    this.fieldLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencyImplementationPlan plan;
  final int actionLimit;
  final int familyLimit;
  final int primitiveLimit;
  final int fieldLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (plan.isClear) {
      return const Text('No API implementation work is queued.');
    }

    final statusColor = _implementationPlanStatusColor(plan.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Implementation Bundle',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyPlanJson(context),
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
            _ImplementationPlanMetricChip(
              label: 'Status',
              value: plan.statusLabel,
              color: statusColor,
            ),
            _ImplementationPlanMetricChip(
              label: 'Actions',
              value: plan.actionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ImplementationPlanMetricChip(
              label: 'Families',
              value: plan.familyCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ImplementationPlanMetricChip(
              label: 'Primitives',
              value: plan.primitiveCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ImplementationPlanMetricChip(
              label: 'Fields',
              value: plan.fieldOptionCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ImplementationPlanMetricChip(
              label: 'Impact',
              value: '+${plan.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          plan.recommendedStartLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (plan.topFamily != null)
          _ImplementationPlanRow(
            icon: Icons.account_tree_outlined,
            label: 'Top Family',
            title: plan.topFamily!.familyName,
            detail: plan.topFamily!.recipe.targetLabel,
            note: plan.topFamily!.focusLabel,
            color: statusColor,
          ),
        if (plan.topPrimitive != null)
          _ImplementationPlanRow(
            icon: Icons.construction_outlined,
            label: 'Top Primitive',
            title: plan.topPrimitive!.primitiveLabel,
            detail: plan.topPrimitive!.recipe.targetLabel,
            note: plan.topPrimitive!.fieldLabel,
            color: statusColor,
          ),
        if (plan.topField != null)
          _ImplementationPlanRow(
            icon: Icons.tune_outlined,
            label: 'Top Field',
            title: plan.topField!.fieldName,
            detail: plan.topField!.recipe.targetLabel,
            note:
                '${plan.topField!.recipe.adapterLabel}, '
                '${plan.topField!.recipe.valueKindLabel}',
            color: statusColor,
          ),
      ],
    );
  }

  void _copyPlanJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(
      plan.toJson(
        actionLimit: actionLimit,
        familyLimit: familyLimit,
        primitiveLimit: primitiveLimit,
        fieldLimit: fieldLimit,
      ),
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API implementation bundle JSON copied')),
    );
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthApiConsistencyImplementationChecklistText(
      plan,
      actionLimit: actionLimit,
      familyLimit: familyLimit,
      primitiveLimit: primitiveLimit,
      fieldLimit: fieldLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API implementation checklist copied')),
    );
  }
}

class _ImplementationPlanMetricChip extends StatelessWidget {
  const _ImplementationPlanMetricChip({
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
        child: Icon(Icons.integration_instructions, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ImplementationPlanRow extends StatelessWidget {
  const _ImplementationPlanRow({
    required this.icon,
    required this.label,
    required this.title,
    required this.detail,
    required this.note,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String title;
  final String detail;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
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
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  note,
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

Color _implementationPlanStatusColor(
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
