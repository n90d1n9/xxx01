import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollPayslipTemplatePanel extends StatelessWidget {
  final PayrollPayslipTemplateSummary summary;

  const PayrollPayslipTemplatePanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.description_outlined,
      title: 'Payslip template center',
      subtitle:
          '${summary.profile.templateId} - ${summary.package.periodLabel}',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        HrisStatusPill(
                          label: summary.status.label,
                          color: statusColor,
                        ),
                        _MetaChip(
                          icon: Icons.palette_outlined,
                          label: summary.profile.brandName,
                        ),
                        _MetaChip(
                          icon: Icons.view_agenda_outlined,
                          label:
                              '${summary.enabledSectionCount}/${summary.sections.length} sections',
                        ),
                        _MetaChip(
                          icon: Icons.badge_outlined,
                          label: summary.profile.preparedBy,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(_statusIcon(summary.status), color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: summary.readinessScore,
                color: statusColor,
                label:
                    '${NumberFormat.percentPattern().format(summary.readinessScore)} readiness',
              ),
              const SizedBox(height: 12),
              _NextActionRow(summary: summary, color: statusColor),
            ],
          ),
        ),
        _PayslipPreview(summary: summary),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statement sections',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...summary.sections.map(
                (section) => _TemplateSectionRow(section: section),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayslipPreview extends StatelessWidget {
  final PayrollPayslipTemplateSummary summary;

  const _PayslipPreview({required this.summary});

  @override
  Widget build(BuildContext context) {
    final line = summary.previewLine;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    summary.profile.logoLabel,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HrisColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.previewEmployeeName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      summary.previewStatementId,
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
                label: 'Gross',
                value: payrollCurrencyFormat.format(line?.grossAmount ?? 0),
              ),
              HrisMetricStripItem(
                label: 'Deductions',
                value: payrollCurrencyFormat.format(line?.deductionAmount ?? 0),
              ),
              HrisMetricStripItem(
                label: 'Net pay',
                value: payrollCurrencyFormat.format(line?.netAmount ?? 0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: Icons.local_shipping_outlined,
                label: summary.deliveryNote,
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                label: line?.paymentReferenceCode ?? 'No reference',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary.profile.employeeMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateSectionRow extends StatelessWidget {
  final PayrollPayslipTemplateSection section;

  const _TemplateSectionRow({required this.section});

  @override
  Widget build(BuildContext context) {
    final color =
        section.isEnabled
            ? const Color(0xFF15803D)
            : section.isRequired
            ? const Color(0xFFB91C1C)
            : HrisColors.muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            section.isEnabled
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  section.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          HrisStatusPill(label: section.statusLabel, color: color),
        ],
      ),
    );
  }
}

class _NextActionRow extends StatelessWidget {
  final PayrollPayslipTemplateSummary summary;
  final Color color;

  const _NextActionRow({required this.summary, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollPayslipTemplateStatus status) {
  return switch (status) {
    PayrollPayslipTemplateStatus.needsSetup => const Color(0xFFB45309),
    PayrollPayslipTemplateStatus.blocked => const Color(0xFFB91C1C),
    PayrollPayslipTemplateStatus.ready => const Color(0xFF2563EB),
    PayrollPayslipTemplateStatus.published => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollPayslipTemplateStatus status) {
  return switch (status) {
    PayrollPayslipTemplateStatus.needsSetup => Icons.tune_outlined,
    PayrollPayslipTemplateStatus.blocked => Icons.lock_outlined,
    PayrollPayslipTemplateStatus.ready => Icons.preview_outlined,
    PayrollPayslipTemplateStatus.published => Icons.verified_outlined,
  };
}
