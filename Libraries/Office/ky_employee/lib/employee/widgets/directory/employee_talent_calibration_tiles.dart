import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_talent_calibration_models.dart';
import 'employee_talent_calibration_styles.dart';

class EmployeeTalentCalibrationSummaryStrip extends StatelessWidget {
  final EmployeeTalentCalibrationProfile profile;

  const EmployeeTalentCalibrationSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Score', value: '${profile.talentScore}'),
        HrisMetricStripItem(label: 'Risk', value: profile.riskLevel.label),
        HrisMetricStripItem(
          label: 'Open',
          value: '${profile.openFollowUpCount}',
        ),
        HrisMetricStripItem(
          label: 'Overdue',
          value: '${profile.overdueFollowUpCount}',
        ),
      ],
    );
  }
}

class EmployeeTalentCalibrationCard extends StatelessWidget {
  final EmployeeTalentCalibrationProfile profile;
  final ValueChanged<EmployeeTalentPerformanceBand> onPerformanceChanged;
  final ValueChanged<EmployeeTalentPotentialBand> onPotentialChanged;
  final ValueChanged<EmployeeTalentRiskLevel> onRiskChanged;
  final ValueChanged<EmployeeTalentCalibrationDecision> onDecisionChanged;
  final VoidCallback onMarkCalibrated;
  final VoidCallback onMarkDisputed;

  const EmployeeTalentCalibrationCard({
    super.key,
    required this.profile,
    required this.onPerformanceChanged,
    required this.onPotentialChanged,
    required this.onRiskChanged,
    required this.onDecisionChanged,
    required this.onMarkCalibrated,
    required this.onMarkDisputed,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = employeeTalentRiskColor(profile.riskLevel);
    final statusColor = employeeTalentStatusColor(profile.status);
    final decisionColor = employeeTalentDecisionColor(profile.decision);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.gridPlacement,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${profile.cycle} - ${profile.calibrator}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: profile.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: profile.talentScore / 100,
            color: profile.isHighRisk ? riskColor : decisionColor,
            label: '${profile.decision.label} decision - ${profile.role}',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EnumDropdown<EmployeeTalentPerformanceBand>(
                  label: 'Performance',
                  icon: Icons.query_stats_outlined,
                  value: profile.performanceBand,
                  values: EmployeeTalentPerformanceBand.values,
                  labelFor: (value) => value.label,
                  onChanged: onPerformanceChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnumDropdown<EmployeeTalentPotentialBand>(
                  label: 'Potential',
                  icon: Icons.auto_graph_outlined,
                  value: profile.potentialBand,
                  values: EmployeeTalentPotentialBand.values,
                  labelFor: (value) => value.label,
                  onChanged: onPotentialChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _EnumDropdown<EmployeeTalentRiskLevel>(
                  label: 'Risk',
                  icon: Icons.warning_amber_outlined,
                  value: profile.riskLevel,
                  values: EmployeeTalentRiskLevel.values,
                  labelFor: (value) => value.label,
                  onChanged: onRiskChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnumDropdown<EmployeeTalentCalibrationDecision>(
                  label: 'Decision',
                  icon: Icons.rule_outlined,
                  value: profile.decision,
                  values: EmployeeTalentCalibrationDecision.values,
                  labelFor: (value) => value.label,
                  onChanged: onDecisionChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.event_repeat_outlined,
                label:
                    'Next ${DateFormat('MMM d').format(profile.nextReviewDate)}',
                color: profile.isReviewDue ? const Color(0xFFB91C1C) : null,
              ),
              _MetaChip(
                icon: Icons.trending_up_outlined,
                label: profile.decision.label,
                color: decisionColor,
              ),
              _MetaChip(
                icon: Icons.warning_amber_outlined,
                label: profile.riskLevel.label,
                color: riskColor,
              ),
              FilledButton.tonalIcon(
                onPressed:
                    profile.status == EmployeeTalentCalibrationStatus.calibrated
                        ? null
                        : onMarkCalibrated,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Calibrate'),
              ),
              OutlinedButton.icon(
                onPressed:
                    profile.status == EmployeeTalentCalibrationStatus.disputed
                        ? null
                        : onMarkDisputed,
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Dispute'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeTalentFollowUpTile extends StatelessWidget {
  final EmployeeTalentFollowUp followUp;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onWaive;

  const EmployeeTalentFollowUpTile({
    super.key,
    required this.followUp,
    required this.asOfDate,
    required this.onStart,
    required this.onComplete,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = followUp.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeTalentFollowUpStatusColor(followUp.status);

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
              employeeTalentFollowUpTypeIcon(followUp.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        followUp.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: overdue ? 'Overdue' : followUp.status.label,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  followUp.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: followUp.owner,
                    ),
                    _MetaChip(
                      icon: Icons.route_outlined,
                      label: followUp.type.label,
                    ),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(followUp.dueDate),
                      color: overdue ? const Color(0xFFB91C1C) : null,
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          followUp.status == EmployeeTalentFollowUpStatus.open
                              ? onStart
                              : null,
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Start'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: followUp.isComplete ? null : onComplete,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete'),
                    ),
                    TextButton.icon(
                      onPressed: followUp.isComplete ? null : onWaive,
                      icon: const Icon(Icons.do_disturb_on_outlined),
                      label: const Text('Waive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items:
          values
              .map(
                (entry) => DropdownMenuItem<T>(
                  value: entry,
                  child: Text(labelFor(entry), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
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
