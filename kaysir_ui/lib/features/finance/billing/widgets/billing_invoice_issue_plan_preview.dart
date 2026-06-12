import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_plan.dart';
import '../models/billing_invoice_tax_mode.dart';
import '../models/billing_payment_schedule.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';

class BillingInvoiceIssuePlanPreview extends StatelessWidget {
  final BillingInvoiceIssuePlan issuePlan;
  final BillingTenantPreferences preferences;
  final bool showTotalPlaceholder;

  const BillingInvoiceIssuePlanPreview({
    super.key,
    required this.issuePlan,
    required this.preferences,
    this.showTotalPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalText =
        showTotalPlaceholder
            ? '-'
            : formatBillingCurrency(issuePlan.total, preferences: preferences);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_outlined, color: Color(0xFF475569)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Draft total',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalText,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (issuePlan.isLineItemBased) ...[
            _IssuePlanFactRow(
              label: 'Subtotal',
              value: formatBillingCurrency(
                issuePlan.subtotal,
                preferences: preferences,
              ),
            ),
            _IssuePlanFactRow(
              label: 'Tax',
              value: formatBillingCurrency(
                issuePlan.tax,
                preferences: preferences,
              ),
            ),
          ],
          _IssuePlanFactRow(
            label: 'Issued',
            value: formatBillingDate(
              issuePlan.draft.issueDate,
              preferences: preferences,
            ),
          ),
          _IssuePlanFactRow(
            label: 'Due',
            value: formatBillingDate(
              issuePlan.dueDate,
              preferences: preferences,
            ),
          ),
          if (issuePlan.hasScheduledPayments) ...[
            _IssuePlanFactRow(
              label: 'Schedule',
              value:
                  '${issuePlan.paymentSchedule.paymentCount} payments'
                  ' - ${issuePlan.paymentSchedule.strategy.label}',
            ),
            _IssuePlanFactRow(
              label: 'Final due',
              value: formatBillingDate(
                issuePlan.paymentSchedule.finalDueDate ?? issuePlan.dueDate,
                preferences: preferences,
              ),
            ),
          ],
          _IssuePlanFactRow(
            label: 'Terms',
            value: '${issuePlan.paymentTermsDays} days',
          ),
          _IssuePlanFactRow(label: 'Tax mode', value: issuePlan.taxMode.label),
        ],
      ),
    );
  }
}

class _IssuePlanFactRow extends StatelessWidget {
  final String label;
  final String value;

  const _IssuePlanFactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _BillingInvoiceTaxModeLabel on BillingInvoiceTaxMode {
  String get label {
    return switch (this) {
      BillingInvoiceTaxMode.exclusive => 'Exclusive',
      BillingInvoiceTaxMode.inclusive => 'Inclusive',
      BillingInvoiceTaxMode.exempt => 'Exempt',
    };
  }
}

extension _BillingPaymentScheduleStrategyLabel
    on BillingPaymentScheduleStrategy {
  String get label {
    return switch (this) {
      BillingPaymentScheduleStrategy.singleDueDate => 'Single',
      BillingPaymentScheduleStrategy.splitEqual => 'Split',
      BillingPaymentScheduleStrategy.upfrontAndBalance => 'Deposit',
      BillingPaymentScheduleStrategy.milestones => 'Milestones',
    };
  }
}
