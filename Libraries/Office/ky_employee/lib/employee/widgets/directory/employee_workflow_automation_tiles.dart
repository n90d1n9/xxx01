import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_automation_models.dart';
import 'employee_workflow_automation_styles.dart';

class EmployeeWorkflowAutomationSummaryStrip extends StatelessWidget {
  final EmployeeWorkflowAutomationProfile profile;

  const EmployeeWorkflowAutomationSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Active', value: '${profile.activeCount}'),
        HrisMetricStripItem(label: 'Due', value: '${profile.dueCount}'),
        HrisMetricStripItem(label: 'Failed', value: '${profile.failedCount}'),
        HrisMetricStripItem(
          label: 'Generated',
          value: '${profile.generatedTaskCount}',
        ),
      ],
    );
  }
}

class EmployeeWorkflowAutomationStatusCard extends StatelessWidget {
  final EmployeeWorkflowAutomationProfile profile;

  const EmployeeWorkflowAutomationStatusCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor =
        profile.failedCount > 0
            ? const Color(0xFFB91C1C)
            : profile.attentionCount > 0
            ? const Color(0xFFB45309)
            : const Color(0xFF15803D);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_motion_outlined,
                  color: progressColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generated ${profile.generatedTaskCount} workflow task(s)',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.highRiskCount} high-risk hook(s), ${profile.dueSoonCount} due soon',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label:
                    profile.attentionCount == 0
                        ? 'Healthy'
                        : '${profile.attentionCount} open',
                color: progressColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.activeRatio,
            color: progressColor,
            label: '${(profile.activeRatio * 100).round()}% hooks active',
          ),
        ],
      ),
    );
  }
}

class EmployeeWorkflowAutomationHookTile extends StatelessWidget {
  final EmployeeWorkflowAutomationHook hook;
  final DateTime asOfDate;
  final VoidCallback onRun;
  final VoidCallback onActivate;
  final VoidCallback onPause;
  final VoidCallback onFail;
  final VoidCallback onRemove;

  const EmployeeWorkflowAutomationHookTile({
    super.key,
    required this.hook,
    required this.asOfDate,
    required this.onRun,
    required this.onActivate,
    required this.onPause,
    required this.onFail,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeWorkflowAutomationStatusColor(hook.status);
    final riskColor = employeeWorkflowAutomationRiskColor(hook.risk);
    final due = hook.isDue(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeWorkflowAutomationStatusIcon(hook.status),
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hook.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hook.generatedTaskTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: hook.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeeWorkflowAutomationTriggerIcon(hook.trigger),
                label: hook.trigger.label,
              ),
              _MetaChip(
                icon: employeeWorkflowAutomationDeliveryIcon(hook.delivery),
                label: hook.delivery.label,
              ),
              _MetaChip(
                icon: Icons.person_outline,
                label: hook.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(icon: Icons.hub_outlined, label: hook.sourceLabel),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Next ${_formatDate(hook.nextRunAt)}',
                color: due ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: hook.risk.label,
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hook.isFailed && hook.failureReason.isNotEmpty
                ? hook.failureReason
                : hook.notes,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: hook.isFailed ? const Color(0xFFB91C1C) : HrisColors.muted,
              fontWeight: hook.isFailed ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onRun,
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text('Run now'),
              ),
              if (!hook.isActive)
                TextButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Activate'),
                ),
              if (hook.isActive)
                TextButton.icon(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Pause'),
                ),
              TextButton.icon(
                onPressed: onFail,
                icon: const Icon(Icons.error_outline),
                label: const Text('Mark failed'),
              ),
              IconButton(
                tooltip: 'Remove automation hook',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}
