import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollActiveRunPlanPanel extends StatelessWidget {
  final PayrollActiveRunPlanSummary summary;

  const PayrollActiveRunPlanPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final request = summary.request;
    final statusColor =
        summary.hasActivePlan
            ? const Color(0xFF059669)
            : const Color(0xFFB45309);

    return HrisSectionPanel(
      icon: Icons.rocket_launch_outlined,
      title: 'Active payroll plan',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final status = _ActivePlanStatus(
                summary: summary,
                color: statusColor,
              );
              final detail = _ActivePlanDetail(request: request);
              final action = _ActivePlanAction(summary: summary);

              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    status,
                    const SizedBox(height: 12),
                    detail,
                    const SizedBox(height: 12),
                    action,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  status,
                  const SizedBox(width: 16),
                  Expanded(child: detail),
                  const SizedBox(width: 16),
                  Expanded(child: action),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActivePlanStatus extends StatelessWidget {
  final PayrollActiveRunPlanSummary summary;
  final Color color;

  const _ActivePlanStatus({required this.summary, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            summary.hasActivePlan
                ? Icons.verified_user_outlined
                : Icons.pending_actions_outlined,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HrisStatusPill(
              label: summary.hasActivePlan ? 'Activated' : 'Not active',
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              '${summary.readyArtifactCount}/${summary.artifactCount} artifacts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivePlanDetail extends StatelessWidget {
  final PayrollRunBuildRequest? request;

  const _ActivePlanDetail({required this.request});

  @override
  Widget build(BuildContext context) {
    if (request == null) {
      return Text(
        'No run plan has been activated for this payroll period yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: HrisColors.ink,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MetaChip(icon: Icons.label_outlined, label: request!.label),
        _MetaChip(icon: Icons.groups_outlined, label: request!.scope.label),
        _MetaChip(
          icon: Icons.event_available_outlined,
          label: DateFormat('MMM d, yyyy').format(request!.payDate),
        ),
      ],
    );
  }
}

class _ActivePlanAction extends StatelessWidget {
  final PayrollActiveRunPlanSummary summary;

  const _ActivePlanAction({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          summary.hasActivePlan
              ? Icons.task_alt_outlined
              : Icons.flag_circle_outlined,
          color: HrisColors.primary,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            summary.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
