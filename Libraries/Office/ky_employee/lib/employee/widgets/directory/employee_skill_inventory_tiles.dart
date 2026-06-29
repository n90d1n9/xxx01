import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_skill_inventory_models.dart';
import 'employee_skill_inventory_styles.dart';

class EmployeeSkillInventorySummaryStrip extends StatelessWidget {
  final EmployeeSkillInventoryProfile profile;

  const EmployeeSkillInventorySummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Verified',
          value: '${profile.verifiedCount}',
        ),
        HrisMetricStripItem(
          label: 'Critical gaps',
          value: '${profile.criticalGapCount}',
        ),
        HrisMetricStripItem(
          label: 'Review due',
          value: '${profile.reviewDueCount}',
        ),
        HrisMetricStripItem(
          label: 'Coverage',
          value: '${(profile.coverageRatio * 100).round()}%',
        ),
      ],
    );
  }
}

class EmployeeSkillRecordTile extends StatelessWidget {
  final EmployeeSkillRecord record;
  final DateTime asOfDate;
  final VoidCallback onVerify;
  final VoidCallback onRequestEvidence;
  final VoidCallback onWaive;
  final VoidCallback onLevelUp;

  const EmployeeSkillRecordTile({
    super.key,
    required this.record,
    required this.asOfDate,
    required this.onVerify,
    required this.onRequestEvidence,
    required this.onWaive,
    required this.onLevelUp,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = record.isReviewOverdue(asOfDate);
    final statusColor =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeSkillVerificationStatusColor(record.status);
    final criticalityColor = employeeSkillCriticalityColor(record.criticality);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: criticalityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeSkillCategoryIcon(record.category),
                  color: criticalityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.skillName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      record.evidenceSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: overdue ? 'Review due' : record.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: record.coverageRatio,
            color: record.hasCriticalGap ? criticalityColor : statusColor,
            label:
                'Level ${record.currentLevel}/${record.requiredLevel} - gap ${record.levelGap}',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.category_outlined,
                label: record.category.label,
              ),
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: record.criticality.label,
                color: criticalityColor,
              ),
              _MetaChip(icon: Icons.person_outline, label: record.owner),
              _MetaChip(
                icon: Icons.fact_check_outlined,
                label: '${record.evidenceCount} evidence',
              ),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(record.nextReviewDate),
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
              OutlinedButton.icon(
                onPressed: record.currentLevel >= 5 ? null : onLevelUp,
                icon: const Icon(Icons.trending_up_outlined),
                label: const Text('Level +'),
              ),
              OutlinedButton.icon(
                onPressed:
                    record.status == EmployeeSkillVerificationStatus.evidenceDue
                        ? null
                        : onRequestEvidence,
                icon: const Icon(Icons.assignment_late_outlined),
                label: const Text('Evidence'),
              ),
              FilledButton.tonalIcon(
                onPressed: record.isVerified ? null : onVerify,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Verify'),
              ),
              TextButton.icon(
                onPressed: record.isWaived ? null : onWaive,
                icon: const Icon(Icons.do_disturb_on_outlined),
                label: const Text('Waive'),
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
    final resolvedColor = color ?? HrisColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: resolvedColor),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: resolvedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
