import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency_action_plan.dart';

class RegistryHealthApiConsistencyActionPlanPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyActionPlanPanel({
    super.key,
    required this.plan,
    this.actionLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencyActionPlan plan;
  final int actionLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (plan.isClear) {
      return const Text('No API consistency actions.');
    }

    final visibleItems = plan.visibleItems(limit: actionLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Action Plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyActionPlanJson(context),
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
        _ApiConsistencyActionMetricStrip(plan: plan),
        const SizedBox(height: 10),
        for (final item in visibleItems) _ApiConsistencyActionRow(item: item),
        if (plan.actionCount > visibleItems.length)
          Text(
            '+${plan.actionCount - visibleItems.length} more actions',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyActionPlanJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(plan.toJson(itemLimit: actionLimit));
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API consistency JSON copied')),
    );
  }

  void _copyChecklist(BuildContext context) {
    final text = registryHealthApiConsistencyActionChecklistText(
      plan,
      itemLimit: actionLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API consistency checklist copied')),
    );
  }
}

Color registryHealthApiConsistencyActionPriorityColor(
  RegistryHealthApiConsistencyActionPriority priority,
) {
  switch (priority) {
    case RegistryHealthApiConsistencyActionPriority.critical:
      return Colors.red.shade700;
    case RegistryHealthApiConsistencyActionPriority.high:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyActionPriority.medium:
      return Colors.blueGrey.shade600;
  }
}

Color registryHealthApiConsistencyActionPhaseColor(
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

class _ApiConsistencyActionMetricStrip extends StatelessWidget {
  const _ApiConsistencyActionMetricStrip({required this.plan});

  final RegistryHealthApiConsistencyActionPlan plan;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ApiConsistencyActionMetricChip(
          label: 'Actions',
          value: plan.actionCount.toString(),
          color: Theme.of(context).colorScheme.primary,
        ),
        _ApiConsistencyActionMetricChip(
          label: 'Impact',
          value: '+${plan.scoreImpactLabel}',
          color: Theme.of(context).colorScheme.primary,
        ),
        _ApiConsistencyActionMetricChip(
          label: 'Critical',
          value: plan.criticalCount.toString(),
          color: plan.criticalCount == 0
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
        _ApiConsistencyActionMetricChip(
          label: 'High',
          value: plan.highCount.toString(),
          color: plan.highCount == 0
              ? Colors.green.shade700
              : Colors.orange.shade800,
        ),
        for (final phase in RegistryHealthApiConsistencyActionPhase.values)
          _ApiConsistencyActionMetricChip(
            label: registryHealthApiConsistencyActionPhaseLabel(phase),
            value: plan.phaseCount(phase).toString(),
            color: registryHealthApiConsistencyActionPhaseColor(phase),
          ),
      ],
    );
  }
}

class _ApiConsistencyActionMetricChip extends StatelessWidget {
  const _ApiConsistencyActionMetricChip({
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
        child: Icon(Icons.playlist_add_check, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ApiConsistencyActionRow extends StatelessWidget {
  const _ApiConsistencyActionRow({required this.item});

  final RegistryHealthApiConsistencyActionItem item;

  @override
  Widget build(BuildContext context) {
    final color = registryHealthApiConsistencyActionPriorityColor(
      item.priority,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.priority_high_outlined, size: 18, color: color),
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
                      '${item.contractName}: ${item.concernLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.priorityLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.phaseLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: registryHealthApiConsistencyActionPhaseColor(
                          item.phase,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.levelLabel,
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
                Text(item.action, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Fields: ${item.fieldOptions.join(', ')}',
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
