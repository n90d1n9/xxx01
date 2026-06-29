import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_communication_models.dart';

class HolidayCommunicationPanel extends StatelessWidget {
  final HolidayCommunicationPlan plan;

  const HolidayCommunicationPanel({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.campaign_outlined,
      title: 'Communication briefs',
      subtitle: '${plan.horizonDays}-day announcement readiness',
      emptyMessage: 'No holiday announcements need attention',
      children: [
        _CommunicationReadinessSurface(plan: plan),
        for (final brief in plan.briefs) _CommunicationBriefTile(brief: brief),
      ],
    );
  }
}

class _CommunicationReadinessSurface extends StatelessWidget {
  final HolidayCommunicationPlan plan;

  const _CommunicationReadinessSurface({required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final score = _CommunicationScore(plan: plan);
          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CommunicationStat(
                icon: Icons.priority_high_outlined,
                label: 'Urgent',
                value: '${plan.urgentCount}',
              ),
              _CommunicationStat(
                icon: Icons.rate_review_outlined,
                label: 'Review',
                value: '${plan.reviewCount}',
              ),
              _CommunicationStat(
                icon: Icons.schedule_outlined,
                label: 'Scheduled',
                value: '${plan.scheduledCount}',
              ),
              _CommunicationStat(
                icon: Icons.groups_outlined,
                label: 'Audiences',
                value: '${plan.audienceCount}',
              ),
            ],
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [score, const SizedBox(height: 14), stats],
            );
          }

          return Row(
            children: [
              score,
              const SizedBox(width: 20),
              Expanded(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _CommunicationScore extends StatelessWidget {
  final HolidayCommunicationPlan plan;

  const _CommunicationScore({required this.plan});

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(plan);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${plan.readinessScore}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
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
              plan.readinessLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Comms readiness',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommunicationStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CommunicationStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
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

class _CommunicationBriefTile extends StatelessWidget {
  final HolidayCommunicationBrief brief;

  const _CommunicationBriefTile({required this.brief});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                brief.subject,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              HrisStatusPill(
                label: brief.priority.label,
                color: _priorityColor(brief.priority),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final audience in brief.audiences)
                HrisStatusPill(label: audience, color: HrisColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          _BriefCopyBlock(
            icon: Icons.record_voice_over_outlined,
            label: 'Employee message',
            body: brief.employeeMessage,
          ),
          const SizedBox(height: 10),
          _BriefCopyBlock(
            icon: Icons.supervisor_account_outlined,
            label: 'Manager action',
            body: brief.managerAction,
          ),
          const SizedBox(height: 10),
          _BriefCopyBlock(
            icon: Icons.payments_outlined,
            label: 'Payroll note',
            body: brief.payrollAction,
          ),
        ],
      ),
    );
  }
}

class _BriefCopyBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String body;

  const _BriefCopyBlock({
    required this.icon,
    required this.label,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: HrisColors.muted, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HrisColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _scoreColor(HolidayCommunicationPlan plan) {
  if (plan.urgentCount > 0 || plan.readinessScore < 70) {
    return Colors.red.shade700;
  }
  if (plan.reviewCount > 0 || plan.readinessScore < 92) {
    return Colors.orange.shade700;
  }
  return Colors.green.shade700;
}

Color _priorityColor(HolidayCommunicationPriority priority) {
  return switch (priority) {
    HolidayCommunicationPriority.urgent => Colors.red.shade700,
    HolidayCommunicationPriority.review => Colors.orange.shade700,
    HolidayCommunicationPriority.scheduled => Colors.green.shade700,
  };
}
