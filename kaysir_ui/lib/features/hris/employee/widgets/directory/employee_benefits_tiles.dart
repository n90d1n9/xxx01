import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_benefits_models.dart';
import 'employee_benefits_styles.dart';

class EmployeeBenefitsSummaryStrip extends StatelessWidget {
  final EmployeeBenefitsProfile profile;

  const EmployeeBenefitsSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'USD');

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Active',
          value: '${profile.activeEnrollmentCount}',
        ),
        HrisMetricStripItem(
          label: 'Actions',
          value: '${profile.actionRequiredCount}',
        ),
        HrisMetricStripItem(
          label: 'Dependents',
          value: '${profile.coveredDependentCount}',
        ),
        HrisMetricStripItem(
          label: 'Employee',
          value: currency.format(profile.monthlyEmployeeContribution),
        ),
      ],
    );
  }
}

class EmployeeBenefitEnrollmentTile extends StatelessWidget {
  final EmployeeBenefitEnrollment enrollment;
  final DateTime asOfDate;
  final ValueChanged<EmployeeBenefitCoverageTier> onCoverageTierChanged;
  final VoidCallback onActivate;
  final VoidCallback onWaive;

  const EmployeeBenefitEnrollmentTile({
    super.key,
    required this.enrollment,
    required this.asOfDate,
    required this.onCoverageTierChanged,
    required this.onActivate,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(name: 'USD');
    final attention = enrollment.needsAttention(asOfDate);
    final color =
        attention
            ? const Color(0xFFB91C1C)
            : employeeBenefitEnrollmentStatusColor(enrollment.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  employeeBenefitPlanTypeIcon(enrollment.type),
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
                      enrollment.planName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${enrollment.provider} - ${enrollment.type.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: enrollment.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeBenefitCoverageTier>(
            initialValue: enrollment.coverageTier,
            decoration: const InputDecoration(
              labelText: 'Coverage',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.family_restroom_outlined),
            ),
            items:
                EmployeeBenefitCoverageTier.values
                    .map(
                      (tier) => DropdownMenuItem(
                        value: tier,
                        child: Text(tier.label),
                      ),
                    )
                    .toList(),
            onChanged: (tier) {
              if (tier != null) onCoverageTierChanged(tier);
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.payments_outlined,
                label:
                    'Employee ${currency.format(enrollment.monthlyEmployeeContribution)}',
              ),
              _MetaChip(
                icon: Icons.business_center_outlined,
                label:
                    'Employer ${currency.format(enrollment.monthlyEmployerContribution)}',
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label:
                    'Renews ${DateFormat('MMM d').format(enrollment.renewalDate)}',
                color: attention ? const Color(0xFFB91C1C) : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed:
                    enrollment.status == EmployeeBenefitEnrollmentStatus.waived
                        ? null
                        : onWaive,
                icon: const Icon(Icons.block_outlined),
                label: const Text('Waive'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed:
                    enrollment.status == EmployeeBenefitEnrollmentStatus.active
                        ? null
                        : onActivate,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Enroll'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeDependentRecordTile extends StatelessWidget {
  final EmployeeDependentRecord dependent;
  final DateTime asOfDate;
  final VoidCallback onVerify;

  const EmployeeDependentRecordTile({
    super.key,
    required this.dependent,
    required this.asOfDate,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeDependentVerificationStatusColor(
      dependent.verificationStatus,
    );

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
            child: Icon(Icons.badge_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dependent.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dependent.relationship.label} - age ${dependent.age(asOfDate)}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (dependent.isVerified)
            HrisStatusPill(
              label: dependent.verificationStatus.label,
              color: color,
            )
          else
            FilledButton.tonalIcon(
              onPressed: onVerify,
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Verify'),
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
