import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollEmployeeProfilePanel extends StatelessWidget {
  final PayrollEmployeeProfileSummary summary;

  const PayrollEmployeeProfilePanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final profile = summary.selectedProfile;

    return HrisSectionPanel(
      icon: Icons.badge_outlined,
      title: 'Employee payroll profile',
      subtitle:
          profile == null
              ? '${summary.profiles.length} profiles'
              : profile.employeeName,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${summary.readyCount}'),
            HrisMetricStripItem(
              label: 'Incomplete',
              value: '${summary.incompleteCount}',
            ),
            HrisMetricStripItem(
              label: 'Suspended',
              value: '${summary.suspendedCount}',
            ),
            HrisMetricStripItem(
              label: 'Readiness',
              value: '${(summary.readinessRate * 100).round()}%',
            ),
          ],
        ),
        if (profile == null)
          const HrisEmptyState(
            message: 'Select an employee to review payroll profile setup',
          )
        else
          _SelectedProfileCard(profile: profile),
      ],
    );
  }
}

class _SelectedProfileCard extends StatelessWidget {
  final PayrollEmployeeProfile profile;

  const _SelectedProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(profile.status);

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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_statusIcon(profile.status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          profile.employeeName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        HrisStatusPill(
                          label: profile.status.label,
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.position,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Salary',
                value: payrollCurrencyFormat.format(profile.salary),
              ),
              HrisMetricStripItem(
                label: 'Recurring earn',
                value: payrollCurrencyFormat.format(
                  profile.recurringEarningTotal,
                ),
              ),
              HrisMetricStripItem(
                label: 'Recurring deduct',
                value: payrollCurrencyFormat.format(
                  profile.recurringDeductionTotal,
                ),
              ),
              HrisMetricStripItem(
                label: 'Employer benefit',
                value: payrollCurrencyFormat.format(
                  profile.employerBenefitContribution,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SetupChecklist(profile: profile),
          if (profile.activeRecurringRules.isNotEmpty) ...[
            const SizedBox(height: 12),
            _RecurringRulesList(rules: profile.activeRecurringRules),
          ],
        ],
      ),
    );
  }
}

class _SetupChecklist extends StatelessWidget {
  final PayrollEmployeeProfile profile;

  const _SetupChecklist({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SetupRow(
          label: 'Payment',
          detail:
              profile.paymentProfile == null
                  ? 'Not configured'
                  : '${profile.paymentProfile!.method.label} - ${profile.paymentProfile!.destinationLabel}',
          isComplete: profile.paymentProfile?.hasDestination ?? false,
        ),
        _SetupRow(
          label: 'Tax',
          detail:
              profile.taxProfile == null
                  ? 'Not configured'
                  : '${profile.taxProfile!.filingStatus.label}, ${profile.taxProfile!.allowanceCount} allowances',
          isComplete: profile.taxProfile?.isComplete ?? false,
        ),
        _SetupRow(
          label: 'Payslip',
          detail:
              profile.payslipDeliveryProfile == null
                  ? 'Not configured'
                  : profile.payslipDeliveryProfile!.destinationLabel,
          isComplete: profile.payslipDeliveryProfile != null,
        ),
        _SetupRow(
          label: 'Benefits',
          detail: '${profile.activeBenefits.length} active elections',
          isComplete: profile.activeBenefits.isNotEmpty,
        ),
      ],
    );
  }
}

class _SetupRow extends StatelessWidget {
  final String label;
  final String detail;
  final bool isComplete;

  const _SetupRow({
    required this.label,
    required this.detail,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isComplete ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isComplete ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              detail,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringRulesList extends StatelessWidget {
  final List<PayrollRecurringRule> rules;

  const _RecurringRulesList({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < rules.length; index++) ...[
          _RecurringRuleRow(rule: rules[index]),
          if (index < rules.length - 1)
            const Divider(height: 18, color: HrisColors.border),
        ],
      ],
    );
  }
}

class _RecurringRuleRow extends StatelessWidget {
  final PayrollRecurringRule rule;

  const _RecurringRuleRow({required this.rule});

  @override
  Widget build(BuildContext context) {
    final color = _ruleColor(rule.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_ruleIcon(rule.type), color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rule.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                rule.type.label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          payrollCurrencyFormat.format(rule.amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollEmployeeProfileStatus status) {
  return switch (status) {
    PayrollEmployeeProfileStatus.incomplete => const Color(0xFFB45309),
    PayrollEmployeeProfileStatus.ready => const Color(0xFF15803D),
    PayrollEmployeeProfileStatus.suspended => const Color(0xFFB91C1C),
  };
}

IconData _statusIcon(PayrollEmployeeProfileStatus status) {
  return switch (status) {
    PayrollEmployeeProfileStatus.incomplete => Icons.pending_actions_outlined,
    PayrollEmployeeProfileStatus.ready => Icons.verified_outlined,
    PayrollEmployeeProfileStatus.suspended => Icons.block_outlined,
  };
}

Color _ruleColor(PayrollRecurringRuleType type) {
  return switch (type) {
    PayrollRecurringRuleType.earning => const Color(0xFF15803D),
    PayrollRecurringRuleType.deduction => const Color(0xFFB45309),
    PayrollRecurringRuleType.benefit => HrisColors.primary,
  };
}

IconData _ruleIcon(PayrollRecurringRuleType type) {
  return switch (type) {
    PayrollRecurringRuleType.earning => Icons.add_circle_outline,
    PayrollRecurringRuleType.deduction => Icons.remove_circle_outline,
    PayrollRecurringRuleType.benefit => Icons.health_and_safety_outlined,
  };
}
