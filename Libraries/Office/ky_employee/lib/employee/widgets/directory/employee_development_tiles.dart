import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_development_models.dart';
import 'employee_development_styles.dart';

class EmployeeDevelopmentSummaryStrip extends StatelessWidget {
  final EmployeeDevelopmentPlan plan;

  const EmployeeDevelopmentSummaryStrip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Skill gaps',
          value: '${plan.skillGapCount}',
        ),
        HrisMetricStripItem(
          label: 'Learning',
          value: '${plan.activeLearningCount}',
        ),
        HrisMetricStripItem(
          label: 'Cert risk',
          value: '${plan.certificationRiskCount}',
        ),
        HrisMetricStripItem(
          label: 'Avg done',
          value: '${(plan.averageLearningCompletion * 100).round()}%',
        ),
      ],
    );
  }
}

class EmployeeSkillTargetTile extends StatelessWidget {
  final EmployeeSkillTarget skill;
  final VoidCallback onLevelUp;

  const EmployeeSkillTargetTile({
    super.key,
    required this.skill,
    required this.onLevelUp,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeSkillStatusColor(skill.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.skill,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: skill.status.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: skill.progress,
            color: color,
            label:
                'Level ${skill.currentLevel}/${skill.targetLevel} - gap ${skill.levelGap}',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mentor: ${skill.mentor}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    skill.currentLevel >= skill.targetLevel ? null : onLevelUp,
                icon: const Icon(Icons.trending_up_outlined),
                label: const Text('Level up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeLearningAssignmentTile extends StatelessWidget {
  final EmployeeLearningAssignment item;
  final DateTime asOfDate;
  final VoidCallback onAdvance;
  final VoidCallback onComplete;

  const EmployeeLearningAssignmentTile({
    super.key,
    required this.item,
    required this.asOfDate,
    required this.onAdvance,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = item.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeLearningStatusColor(item.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: overdue ? 'Overdue' : item.status.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: item.progress,
            color: color,
            label: '${(item.progress * 100).round()}% complete',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.school_outlined, label: item.provider),
              _MetaChip(
                icon: Icons.psychology_outlined,
                label: item.skillFocus,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
              OutlinedButton.icon(
                onPressed: item.isComplete ? null : onAdvance,
                icon: const Icon(Icons.add_outlined),
                label: const Text('15%'),
              ),
              FilledButton.tonalIcon(
                onPressed: item.isComplete ? null : onComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Complete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeCertificationTargetTile extends StatelessWidget {
  final EmployeeCertificationTarget certification;
  final DateTime asOfDate;
  final VoidCallback onRenew;

  const EmployeeCertificationTargetTile({
    super.key,
    required this.certification,
    required this.asOfDate,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final expired = certification.isExpired(asOfDate);
    final expiring = certification.isExpiringSoon(asOfDate);
    final color =
        expired
            ? const Color(0xFFB91C1C)
            : expiring
            ? const Color(0xFFB45309)
            : employeeCertificationStatusColor(certification.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeCertificationStatusIcon(certification.status),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${certification.authority} - expires ${DateFormat('MMM d').format(certification.expiryDate)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (expired || expiring || certification.needsAttention(asOfDate))
            FilledButton.tonalIcon(
              onPressed: onRenew,
              icon: const Icon(Icons.autorenew_outlined),
              label: const Text('Renew'),
            )
          else
            HrisStatusPill(label: certification.status.label, color: color),
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
    final resolvedColor = color ?? HrisColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
