import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_cutoff_models.dart';
import 'employee_payroll_cutoff_styles.dart';

class EmployeePayrollCutoffSummaryStrip extends StatelessWidget {
  final EmployeePayrollCutoffReconciliationProfile profile;

  const EmployeePayrollCutoffSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Stage', value: profile.stage.label),
        HrisMetricStripItem(
          label: 'Blockers',
          value: '${profile.blockingCount}',
        ),
        HrisMetricStripItem(
          label: 'Warnings',
          value: '${profile.openWarningCount}',
        ),
        HrisMetricStripItem(
          label: 'Progress',
          value: '${(profile.completionRatio * 100).round()}%',
        ),
      ],
    );
  }
}

class EmployeePayrollCutoffPeriodCard extends StatelessWidget {
  final EmployeePayrollCutoffReconciliationProfile profile;

  const EmployeePayrollCutoffPeriodCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final stageColor = employeePayrollCutoffStageColor(profile.stage);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payroll period readiness',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: profile.stage.label, color: stageColor),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: profile.completionRatio,
            color: stageColor,
            label:
                '${profile.resolvedCount + profile.waivedCount} of ${profile.items.length} reconciliation items closed',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.date_range_outlined,
                label:
                    '${_formatShortDate(profile.periodStart)} - ${_formatShortDate(profile.periodEnd)}',
              ),
              _MetaChip(
                icon: Icons.event_busy_outlined,
                label: 'Cutoff ${_formatDate(profile.cutoffDate)}',
                color: stageColor,
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                label:
                    '${profile.currencyCode} pay ${_formatDate(profile.nextPayDate)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeePayrollCutoffItemTile extends StatelessWidget {
  final EmployeePayrollCutoffItem item;
  final VoidCallback onReview;
  final VoidCallback onResolve;
  final VoidCallback onWaive;
  final VoidCallback onReopen;

  const EmployeePayrollCutoffItemTile({
    super.key,
    required this.item,
    required this.onReview,
    required this.onResolve,
    required this.onWaive,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = employeePayrollCutoffSeverityColor(item.severity);
    final statusColor = employeePayrollCutoffStatusColor(item.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeePayrollCutoffSourceIcon(item.source),
              color: severityColor,
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
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: item.status.label,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  maxLines: 3,
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
                      icon: Icons.source_outlined,
                      label: item.source.label,
                    ),
                    _MetaChip(
                      icon: Icons.priority_high_outlined,
                      label: item.severity.label,
                      color: severityColor,
                    ),
                    _MetaChip(icon: Icons.person_outline, label: item.owner),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: 'Due ${_formatShortDate(item.dueDate)}',
                    ),
                    if (item.payrollImpact)
                      const _MetaChip(
                        icon: Icons.block_outlined,
                        label: 'Payroll impact',
                        color: Color(0xFFB91C1C),
                      ),
                    if (!item.isClosed)
                      OutlinedButton.icon(
                        onPressed:
                            item.status == EmployeePayrollCutoffItemStatus.open
                                ? onReview
                                : null,
                        icon: const Icon(Icons.manage_search_outlined),
                        label: const Text('Review'),
                      ),
                    if (!item.isClosed)
                      FilledButton.tonalIcon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Resolve'),
                      ),
                    if (!item.isClosed)
                      TextButton.icon(
                        onPressed: onWaive,
                        icon: const Icon(Icons.do_disturb_on_outlined),
                        label: const Text('Waive'),
                      ),
                    if (item.isClosed)
                      TextButton.icon(
                        onPressed: onReopen,
                        icon: const Icon(Icons.restart_alt_outlined),
                        label: const Text('Reopen'),
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

class EmployeePayrollCutoffSignoffCard extends StatelessWidget {
  final EmployeePayrollCutoffSignoff signoff;

  const EmployeePayrollCutoffSignoffCard({super.key, required this.signoff});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF15803D),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cutoff signed off',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: 'Signed off',
                color: const Color(0xFF15803D),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            signoff.note,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.person_outline, label: signoff.reviewer),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: _formatDate(signoff.reviewedAt),
              ),
              if (signoff.acceptedWarningCount > 0)
                _MetaChip(
                  icon: Icons.info_outline,
                  label: '${signoff.acceptedWarningCount} warning accepted',
                  color: const Color(0xFFB45309),
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

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String _formatShortDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}
