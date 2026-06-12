import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_close_models.dart';
import 'employee_payroll_close_styles.dart';

class EmployeePayrollCloseSummaryStrip extends StatelessWidget {
  final EmployeePayrollCloseProfile profile;

  const EmployeePayrollCloseSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Debits',
          value: _formatMoney(profile.totalDebits, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Credits',
          value: _formatMoney(profile.totalCredits, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Variance',
          value: _formatMoney(profile.variance, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Blockers',
          value: '${profile.attentionCount}',
        ),
      ],
    );
  }
}

class EmployeePayrollCloseStatusCard extends StatelessWidget {
  final EmployeePayrollCloseProfile profile;

  const EmployeePayrollCloseStatusCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollCloseStatusColor(profile.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Close readiness',
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
              if (profile.paymentReference.isNotEmpty)
                _MetaChip(
                  icon: Icons.tag_outlined,
                  label: profile.paymentReference,
                  color: const Color(0xFF15803D),
                ),
              if (profile.journalBatchId.isNotEmpty)
                _MetaChip(
                  icon: Icons.book_outlined,
                  label: profile.journalBatchId,
                  color: const Color(0xFF15803D),
                ),
              if (profile.closeOwner.isNotEmpty)
                _MetaChip(
                  icon: Icons.verified_user_outlined,
                  label: profile.closeOwner,
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _progressValue(EmployeePayrollCloseProfile profile) {
    return switch (profile.status) {
      EmployeePayrollCloseStatus.blocked => 0.25,
      EmployeePayrollCloseStatus.ready => 0.65,
      EmployeePayrollCloseStatus.posted => 0.85,
      EmployeePayrollCloseStatus.closed => 1,
    };
  }
}

class EmployeePayrollJournalLineTile extends StatelessWidget {
  final EmployeePayrollJournalLine line;

  const EmployeePayrollJournalLineTile({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollJournalLineStatusColor(line.status);

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
              employeePayrollJournalLineTypeIcon(line.type),
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
                        line.accountName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(label: line.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  line.detail,
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
                      icon: Icons.numbers_outlined,
                      label: line.accountCode,
                    ),
                    _MetaChip(
                      icon:
                          line.isDebit
                              ? Icons.arrow_downward_outlined
                              : Icons.arrow_upward_outlined,
                      label:
                          '${line.isDebit ? 'Debit' : 'Credit'} ${_formatMoney(line.amount, line.currencyCode)}',
                      color:
                          line.isDebit
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF7C3AED),
                    ),
                    _MetaChip(
                      icon: Icons.category_outlined,
                      label: line.type.label,
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
