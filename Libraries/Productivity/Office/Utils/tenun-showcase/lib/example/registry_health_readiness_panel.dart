import 'package:flutter/material.dart';

import 'registry_health_readiness.dart';
import 'registry_health_readiness_action_plan.dart';
import 'registry_health_readiness_action_plan_panel.dart';

class RegistryHealthReadinessPanel extends StatelessWidget {
  const RegistryHealthReadinessPanel({
    super.key,
    required this.report,
    this.gateLimit = 8,
    this.actionLimit = 6,
    this.showActionPlan = true,
  });

  final RegistryHealthReadinessReport report;
  final int gateLimit;
  final int actionLimit;
  final bool showActionPlan;

  @override
  Widget build(BuildContext context) {
    final visibleGates = registryHealthReadinessVisibleGates(
      report,
      limit: gateLimit,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          registryHealthReadinessSummary(report),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ReadinessMetricChip(
              label: 'Status',
              value: report.statusLabel,
              color: registryHealthReadinessStatusColor(report.status),
            ),
            _ReadinessMetricChip(
              label: 'Ready',
              value: report.readyCount.toString(),
              color: Colors.green.shade700,
            ),
            _ReadinessMetricChip(
              label: 'Warnings',
              value: report.warningCount.toString(),
              color: report.warningCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ReadinessMetricChip(
              label: 'Blocked',
              value: report.blockedCount.toString(),
              color: report.blockedCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleGates.isEmpty)
          const Text('All readiness gates are passing.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final gate in visibleGates) _ReadinessGateRow(gate: gate),
              if (report.attentionGates.length > visibleGates.length)
                Text(
                  '+${report.attentionGates.length - visibleGates.length} more gates',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        if (showActionPlan) ...[
          const SizedBox(height: 12),
          RegistryHealthReadinessActionPlanPanel(
            plan: registryHealthReadinessActionPlan(report),
            actionLimit: actionLimit,
          ),
        ],
      ],
    );
  }
}

String registryHealthReadinessSummary(RegistryHealthReadinessReport report) {
  final gateLabel = report.gateCount == 1 ? 'gate' : 'gates';
  return '${report.readyCount}/${report.gateCount} readiness $gateLabel ready, '
      '${report.blockedCount} blocked, ${report.warningCount} warnings.';
}

Color registryHealthReadinessStatusColor(RegistryHealthReadinessStatus status) {
  switch (status) {
    case RegistryHealthReadinessStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthReadinessStatus.warning:
      return Colors.orange.shade800;
    case RegistryHealthReadinessStatus.blocked:
      return Colors.red.shade700;
  }
}

class _ReadinessMetricChip extends StatelessWidget {
  const _ReadinessMetricChip({
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
        child: Icon(Icons.rule_outlined, size: 14, color: effectiveColor),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ReadinessGateRow extends StatelessWidget {
  const _ReadinessGateRow({required this.gate});

  final RegistryHealthReadinessGate gate;

  @override
  Widget build(BuildContext context) {
    final color = registryHealthReadinessStatusColor(gate.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            gate.status == RegistryHealthReadinessStatus.blocked
                ? Icons.error_outline
                : Icons.info_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gate.label} · ${gate.statusLabel}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(gate.detail, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  gate.action,
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
