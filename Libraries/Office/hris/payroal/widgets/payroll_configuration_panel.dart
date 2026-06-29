import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollConfigurationPanel extends StatelessWidget {
  final PayrollConfigurationSummary summary;

  const PayrollConfigurationPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.settings_suggest_outlined,
      title: 'Payroll configuration',
      subtitle: summary.period.label,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.status.label, color: color),
                  _MetricChip(
                    icon: Icons.task_alt_outlined,
                    label: '${summary.readyControlCount}/5 controls ready',
                  ),
                  _MetricChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${summary.blockedControlCount} blocked',
                  ),
                  _MetricChip(
                    icon: Icons.speed_outlined,
                    label:
                        '${(summary.readinessRate * 100).round()}% readiness',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_statusIcon(summary.status), color: color, size: 19),
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
              ),
            ],
          ),
        ),
        HrisListSurface(
          child: Column(
            children: [
              _ConfigurationControlRow(
                title: 'Pay schedule',
                owner: 'Payroll Ops',
                detail:
                    '${summary.schedulePolicy.frequency.label}, cut-off day ${summary.schedulePolicy.cutoffDay}, pay day ${summary.schedulePolicy.payDay}',
                value:
                    '${summary.schedulePolicy.approvalLeadDays}d approval lead',
                blockers: summary.schedulePolicy.blockers,
                icon: Icons.calendar_month_outlined,
              ),
              const Divider(height: 20, color: HrisColors.border),
              _ConfigurationControlRow(
                title: 'Tax policy',
                owner: 'Payroll Tax',
                detail:
                    '${summary.taxPolicy.authorityLabel} - ${summary.taxPolicy.employerTaxId}',
                value: '${summary.taxPolicy.filingLeadDays}d filing lead',
                blockers: summary.taxPolicy.blockers,
                icon: Icons.account_balance_outlined,
              ),
              const Divider(height: 20, color: HrisColors.border),
              _ConfigurationControlRow(
                title: 'Benefit policy',
                owner: 'People Ops',
                detail: summary.benefitPolicy.providerLabel,
                value:
                    '${summary.benefitPolicy.enrollmentCutoffDays}d enrollment cut-off',
                blockers: summary.benefitPolicy.blockers,
                icon: Icons.health_and_safety_outlined,
              ),
              const Divider(height: 20, color: HrisColors.border),
              _ConfigurationControlRow(
                title: 'Funding policy',
                owner: 'Finance Ops',
                detail: summary.fundingPolicy.defaultFundingAccount,
                value:
                    '${(summary.fundingPolicy.reserveRatio * 100).toStringAsFixed(1)}% reserve, ${payrollCurrencyFormat.format(summary.fundingPolicy.authorizationLimit)} limit',
                blockers: summary.fundingPolicy.blockers,
                icon: Icons.account_balance_wallet_outlined,
              ),
              const Divider(height: 20, color: HrisColors.border),
              _ConfigurationControlRow(
                title: 'Employee setup',
                owner: 'HR Ops',
                detail:
                    '${summary.employeeProfiles.readyCount}/${summary.employeeProfiles.profiles.length} employee profiles ready',
                value:
                    '${summary.employeeProfiles.incompleteCount} incomplete, ${summary.employeeProfiles.suspendedCount} suspended',
                blockers: [
                  if (summary.employeeProfiles.incompleteCount > 0)
                    '${summary.employeeProfiles.incompleteCount} employee payroll profiles are incomplete',
                  if (summary.employeeProfiles.suspendedCount > 0)
                    '${summary.employeeProfiles.suspendedCount} employee payroll profiles are suspended',
                ],
                icon: Icons.badge_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfigurationControlRow extends StatelessWidget {
  final String title;
  final String owner;
  final String detail;
  final String value;
  final List<String> blockers;
  final IconData icon;

  const _ConfigurationControlRow({
    required this.title,
    required this.owner,
    required this.detail,
    required this.value,
    required this.blockers,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = blockers.isEmpty;
    final color = isReady ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(
                    label: isReady ? 'Ready' : 'Blocked',
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                owner,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(icon: Icons.info_outline, label: detail),
                  _MetricChip(icon: Icons.tune_outlined, label: value),
                  if (!isReady)
                    _MetricChip(
                      icon: Icons.report_problem_outlined,
                      label: blockers.first,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollConfigurationStatus status) {
  return switch (status) {
    PayrollConfigurationStatus.blocked => const Color(0xFFB91C1C),
    PayrollConfigurationStatus.watch => const Color(0xFFB45309),
    PayrollConfigurationStatus.ready => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollConfigurationStatus status) {
  return switch (status) {
    PayrollConfigurationStatus.blocked => Icons.lock_outlined,
    PayrollConfigurationStatus.watch => Icons.visibility_outlined,
    PayrollConfigurationStatus.ready => Icons.verified_outlined,
  };
}
