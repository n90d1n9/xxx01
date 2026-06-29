import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_release_approval_models.dart';

class HolidayReleaseApprovalPanel extends StatelessWidget {
  final HolidayReleaseApprovalPlan plan;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onRevoke;

  const HolidayReleaseApprovalPanel({
    super.key,
    required this.plan,
    required this.onApprove,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Release approvals',
      subtitle: '${plan.approvedCount}/${plan.totalStepCount} approved',
      children: [
        _ApprovalSummarySurface(plan: plan),
        for (final step in plan.steps)
          _ApprovalStepTile(
            step: step,
            onApprove: onApprove,
            onRevoke: onRevoke,
          ),
      ],
    );
  }
}

class _ApprovalSummarySurface extends StatelessWidget {
  final HolidayReleaseApprovalPlan plan;

  const _ApprovalSummarySurface({required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headline = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _scoreColor(plan).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${plan.approvalScore}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _scoreColor(plan),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.isFullyApproved ? 'Fully approved' : 'Approval gate',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${plan.approvableCount} ready for sign-off',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                  ),
                ],
              ),
            ],
          );

          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ApprovalStat(
                icon: Icons.verified_outlined,
                label: 'Approved',
                value: '${plan.approvedCount}',
              ),
              _ApprovalStat(
                icon: Icons.pending_actions_outlined,
                label: 'Pending',
                value: '${plan.pendingCount}',
              ),
              _ApprovalStat(
                icon: Icons.rate_review_outlined,
                label: 'Waiting',
                value: '${plan.waitingCount}',
              ),
              _ApprovalStat(
                icon: Icons.block_outlined,
                label: 'Blocked',
                value: '${plan.blockedCount}',
              ),
            ],
          );

          final nextAction = _NextApprovalAction(plan: plan);

          if (constraints.maxWidth < 820) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headline,
                const SizedBox(height: 14),
                stats,
                const SizedBox(height: 12),
                nextAction,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headline,
              const SizedBox(width: 20),
              Expanded(child: stats),
              const SizedBox(width: 20),
              Expanded(child: nextAction),
            ],
          );
        },
      ),
    );
  }
}

class _NextApprovalAction extends StatelessWidget {
  final HolidayReleaseApprovalPlan plan;

  const _NextApprovalAction({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.flag_circle_outlined,
          color: HrisColors.primary,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next approval',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HrisColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                plan.nextAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApprovalStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ApprovalStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: HrisColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalStepTile extends StatelessWidget {
  final HolidayReleaseApprovalStep step;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onRevoke;

  const _ApprovalStepTile({
    required this.step,
    required this.onApprove,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(step.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _statusIcon(step.status),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          step.owner,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: step.status.label, color: statusColor),
                  if (step.canApprove)
                    FilledButton.icon(
                      onPressed: () => onApprove(step.id),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Approve'),
                    )
                  else if (step.canRevoke)
                    OutlinedButton.icon(
                      onPressed: () => onRevoke(step.id),
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: const Text('Revoke'),
                    ),
                ],
              );

              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 12), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  Flexible(child: actions),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            step.requirement,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.action,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _scoreColor(HolidayReleaseApprovalPlan plan) {
  if (plan.blockedCount > 0) return Colors.red.shade700;
  if (!plan.isFullyApproved) return Colors.orange.shade700;
  return Colors.green.shade700;
}

Color _statusColor(HolidayReleaseApprovalStatus status) {
  return switch (status) {
    HolidayReleaseApprovalStatus.blocked => Colors.red.shade700,
    HolidayReleaseApprovalStatus.waiting => Colors.orange.shade700,
    HolidayReleaseApprovalStatus.pending => HrisColors.primary,
    HolidayReleaseApprovalStatus.approved => Colors.green.shade700,
  };
}

IconData _statusIcon(HolidayReleaseApprovalStatus status) {
  return switch (status) {
    HolidayReleaseApprovalStatus.blocked => Icons.block_outlined,
    HolidayReleaseApprovalStatus.waiting => Icons.rate_review_outlined,
    HolidayReleaseApprovalStatus.pending => Icons.pending_actions_outlined,
    HolidayReleaseApprovalStatus.approved => Icons.verified_outlined,
  };
}
