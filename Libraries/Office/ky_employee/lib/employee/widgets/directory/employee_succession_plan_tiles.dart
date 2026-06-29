import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_succession_plan_models.dart';
import 'employee_succession_plan_styles.dart';

class EmployeeSuccessionSummaryStrip extends StatelessWidget {
  final EmployeeSuccessionProfile profile;

  const EmployeeSuccessionSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Coverage',
          value: profile.coverageStatus.label,
        ),
        HrisMetricStripItem(
          label: 'Ready now',
          value: '${profile.readyNowCount}',
        ),
        HrisMetricStripItem(
          label: 'Ready soon',
          value: '${profile.readySoonCount}',
        ),
        HrisMetricStripItem(
          label: 'Attention',
          value: '${profile.attentionCount}',
        ),
      ],
    );
  }
}

class EmployeeSuccessionCoverageCard extends StatelessWidget {
  final EmployeeSuccessionProfile profile;
  final TextEditingController ownerController;
  final ValueChanged<EmployeeSuccessionCriticality> onCriticalityChanged;
  final ValueChanged<String> onOwnerChanged;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onMarkReviewed;
  final VoidCallback onReset;

  const EmployeeSuccessionCoverageCard({
    super.key,
    required this.profile,
    required this.ownerController,
    required this.onCriticalityChanged,
    required this.onOwnerChanged,
    required this.onSelectReviewDate,
    required this.onMarkReviewed,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeSuccessionCoverageStatusColor(
      profile.coverageStatus,
    );
    final criticalityColor = employeeSuccessionCriticalityColor(
      profile.criticality,
    );

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
                  employeeSuccessionCoverageStatusIcon(profile.coverageStatus),
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
                      profile.incumbentRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.department} - manager ${profile.manager}',
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
                label: profile.coverageStatus.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: profile.criticality.label,
                color: criticalityColor,
              ),
              _MetaChip(
                icon: Icons.person_outline,
                label: profile.coverageOwner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.event_note_outlined,
                label:
                    'Review ${DateFormat('MMM d').format(profile.reviewDate)}',
                color:
                    profile.isReviewDue
                        ? const Color(0xFFB91C1C)
                        : HrisColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.benchStrength,
            color: statusColor,
            label: '${(profile.benchStrength * 100).round()}% bench strength',
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeeSuccessionCriticality>(
              showSelectedIcon: false,
              segments:
                  EmployeeSuccessionCriticality.values
                      .map(
                        (criticality) => ButtonSegment(
                          value: criticality,
                          label: Text(criticality.label),
                        ),
                      )
                      .toList(),
              selected: {profile.criticality},
              onSelectionChanged:
                  (selection) => onCriticalityChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Coverage owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.supervisor_account_outlined),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _ReviewDateField(
            label: 'Succession review',
            date: profile.reviewDate,
            onTap: onSelectReviewDate,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (profile.isReviewDue)
                FilledButton.tonalIcon(
                  onPressed: onMarkReviewed,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Mark reviewed'),
                ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeSuccessionCandidateTile extends StatelessWidget {
  final EmployeeSuccessionCandidate candidate;
  final DateTime asOfDate;
  final ValueChanged<EmployeeSuccessionReadiness> onReadinessChanged;
  final ValueChanged<EmployeeSuccessionRisk> onRiskChanged;
  final ValueChanged<EmployeeSuccessionActionType> onActionChanged;
  final VoidCallback onScheduleReview;
  final VoidCallback onRemove;

  const EmployeeSuccessionCandidateTile({
    super.key,
    required this.candidate,
    required this.asOfDate,
    required this.onReadinessChanged,
    required this.onRiskChanged,
    required this.onActionChanged,
    required this.onScheduleReview,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final readinessColor = employeeSuccessionReadinessColor(
      candidate.readiness,
    );
    final riskColor = employeeSuccessionRiskColor(candidate.risk);
    final overdue = candidate.isOverdue(asOfDate);

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
                  color: readinessColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeSuccessionReadinessIcon(candidate.readiness),
                  color: readinessColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${candidate.currentRole} -> ${candidate.targetRole}',
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
                label: candidate.readiness.label,
                color: readinessColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            candidate.notes,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeeSuccessionActionTypeIcon(candidate.actionType),
                label: candidate.actionType.label,
              ),
              _MetaChip(
                icon: Icons.person_outline,
                label: candidate.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label:
                    'Review ${DateFormat('MMM d').format(candidate.reviewDate)}',
                color: overdue ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: candidate.risk.label,
                color: riskColor,
              ),
              _MetaChip(
                icon: Icons.speed_outlined,
                label: '${candidate.benchScore}% bench',
                color:
                    candidate.benchScore >= 75
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PopupMenuButton<EmployeeSuccessionReadiness>(
                tooltip: 'Update readiness',
                onSelected: onReadinessChanged,
                itemBuilder:
                    (context) =>
                        EmployeeSuccessionReadiness.values
                            .map(
                              (readiness) => PopupMenuItem(
                                value: readiness,
                                child: Text(readiness.label),
                              ),
                            )
                            .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.timeline_outlined),
                  label: const Text('Readiness'),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<EmployeeSuccessionRisk>(
                tooltip: 'Update risk',
                onSelected: onRiskChanged,
                itemBuilder:
                    (context) =>
                        EmployeeSuccessionRisk.values
                            .map(
                              (risk) => PopupMenuItem(
                                value: risk,
                                child: Text(risk.label),
                              ),
                            )
                            .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Risk'),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<EmployeeSuccessionActionType>(
                tooltip: 'Update action',
                onSelected: onActionChanged,
                itemBuilder:
                    (context) =>
                        EmployeeSuccessionActionType.values
                            .map(
                              (action) => PopupMenuItem(
                                value: action,
                                child: Text(action.label),
                              ),
                            )
                            .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Action'),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Schedule review',
                onPressed: onScheduleReview,
                icon: const Icon(Icons.event_repeat_outlined),
              ),
              IconButton(
                tooltip: 'Remove candidate',
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

class _ReviewDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _ReviewDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_note_outlined),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(date)),
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
