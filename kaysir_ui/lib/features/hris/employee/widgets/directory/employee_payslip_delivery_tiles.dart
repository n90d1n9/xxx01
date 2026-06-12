import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payslip_delivery_models.dart';
import 'employee_payslip_delivery_styles.dart';

class EmployeePayslipDeliverySummaryStrip extends StatelessWidget {
  final EmployeePayslipDeliveryProfile profile;

  const EmployeePayslipDeliverySummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Net pay',
          value: _formatMoney(profile.netPay, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Gross',
          value: _formatMoney(profile.grossEarnings, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Channels',
          value: '${profile.deliveredChannelCount}/${profile.channels.length}',
        ),
        HrisMetricStripItem(
          label: 'Blockers',
          value: '${profile.attentionCount}',
        ),
      ],
    );
  }
}

class EmployeePayslipDeliveryStatusCard extends StatelessWidget {
  final EmployeePayslipDeliveryProfile profile;

  const EmployeePayslipDeliveryStatusCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = employeePayslipDeliveryStatusColor(profile.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Delivery readiness',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: profile.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: _progressValue(profile),
            color: color,
            label: profile.nextAction,
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
                icon: Icons.payments_outlined,
                label: 'Pay ${_formatDate(profile.payDate)}',
                color: color,
              ),
              if (profile.exportBatchId.isNotEmpty)
                _MetaChip(
                  icon: Icons.ios_share_outlined,
                  label: profile.exportBatchId,
                  color: const Color(0xFF15803D),
                ),
              if (profile.releaseOwner.isNotEmpty)
                _MetaChip(
                  icon: Icons.verified_user_outlined,
                  label: profile.releaseOwner,
                  color: const Color(0xFF15803D),
                ),
              if (profile.releasedAt != null)
                _MetaChip(
                  icon: Icons.event_available_outlined,
                  label: 'Released ${_formatDate(profile.releasedAt!)}',
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _progressValue(EmployeePayslipDeliveryProfile profile) {
    return switch (profile.status) {
      EmployeePayslipDeliveryStatus.blocked => 0.25,
      EmployeePayslipDeliveryStatus.suppressed => 0.4,
      EmployeePayslipDeliveryStatus.ready => 0.75,
      EmployeePayslipDeliveryStatus.published => 1,
    };
  }
}

class EmployeePayslipPreviewCard extends StatelessWidget {
  final EmployeePayslipDeliveryProfile profile;

  const EmployeePayslipPreviewCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employee payslip preview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AmountChip(
                label: 'Gross earnings',
                value: _formatMoney(
                  profile.grossEarnings,
                  profile.currencyCode,
                ),
              ),
              _AmountChip(
                label: 'Reimbursements',
                value: _formatMoney(
                  profile.reimbursements,
                  profile.currencyCode,
                ),
              ),
              _AmountChip(
                label: 'Deductions',
                value: _formatMoney(profile.deductions, profile.currencyCode),
                color: const Color(0xFFB91C1C),
              ),
              _AmountChip(
                label: 'Taxable gross',
                value: _formatMoney(profile.taxableGross, profile.currencyCode),
              ),
              _AmountChip(
                label: 'Employer cost',
                value: _formatMoney(profile.employerCost, profile.currencyCode),
              ),
              _AmountChip(
                label: 'Net pay',
                value: _formatMoney(profile.netPay, profile.currencyCode),
                color: const Color(0xFF15803D),
              ),
            ],
          ),
          if (profile.releaseNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              profile.releaseNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class EmployeePayslipDeliveryChannelTile extends StatelessWidget {
  final EmployeePayslipDeliveryChannelItem channel;

  const EmployeePayslipDeliveryChannelTile({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final color = employeePayslipChannelStatusColor(channel.status);

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
              employeePayslipChannelIcon(channel.channel),
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
                        channel.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(label: channel.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  channel.detail,
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
                      icon: Icons.category_outlined,
                      label: channel.channel.label,
                    ),
                    if (channel.required)
                      const _MetaChip(
                        icon: Icons.lock_outline,
                        label: 'Required',
                        color: Color(0xFF2563EB),
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

class _AmountChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _AmountChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.ink;

    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: resolvedColor,
              fontWeight: FontWeight.w800,
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

String _formatMoney(double value, String currencyCode) {
  return NumberFormat.compactCurrency(
    symbol: '$currencyCode ',
    decimalDigits: 1,
  ).format(value);
}

String _formatDate(DateTime value) {
  return DateFormat('d MMM y').format(value);
}

String _formatShortDate(DateTime value) {
  return DateFormat('d MMM').format(value);
}
