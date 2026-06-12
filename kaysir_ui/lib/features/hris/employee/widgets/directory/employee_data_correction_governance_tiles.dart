import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_correction_governance_models.dart';
import 'employee_data_correction_governance_styles.dart';

class EmployeeDataCorrectionGovernanceSummaryStrip extends StatelessWidget {
  final EmployeeDataCorrectionGovernanceProfile profile;

  const EmployeeDataCorrectionGovernanceSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Blocked', value: '${profile.blockedCount}'),
        HrisMetricStripItem(label: 'Warning', value: '${profile.warningCount}'),
        HrisMetricStripItem(label: 'Passed', value: '${profile.passedCount}'),
        HrisMetricStripItem(
          label: 'Evidence',
          value: '${profile.evidenceCount}',
        ),
      ],
    );
  }
}

class EmployeeDataCorrectionGovernanceRuleTile extends StatelessWidget {
  final EmployeeDataCorrectionGovernanceRule rule;
  final VoidCallback onWaive;
  final VoidCallback onReinstate;

  const EmployeeDataCorrectionGovernanceRuleTile({
    super.key,
    required this.rule,
    required this.onWaive,
    required this.onReinstate,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeDataCorrectionGovernanceStatusColor(rule.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeDataCorrectionGovernanceRuleIcon(rule.type),
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rule.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: rule.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${rule.requestField} - ${rule.type.label}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Text(
                  rule.detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(icon: Icons.person_outline, label: rule.owner),
                    if (rule.status ==
                        EmployeeDataCorrectionGovernanceStatus.waived)
                      OutlinedButton.icon(
                        onPressed: onReinstate,
                        icon: const Icon(Icons.replay_outlined),
                        label: const Text('Reinstate'),
                      )
                    else if (rule.needsAttention)
                      OutlinedButton.icon(
                        onPressed: onWaive,
                        icon: const Icon(Icons.do_not_disturb_on_outlined),
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

class EmployeeDataCorrectionEvidenceTile extends StatelessWidget {
  final EmployeeDataCorrectionEvidence evidence;
  final String requestField;

  const EmployeeDataCorrectionEvidenceTile({
    super.key,
    required this.evidence,
    required this.requestField,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF15803D);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requestField,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  evidence.summary,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: evidence.author,
                    ),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(evidence.createdAt),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: HrisColors.muted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
