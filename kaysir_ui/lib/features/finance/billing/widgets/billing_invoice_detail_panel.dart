import 'package:flutter/material.dart';

import '../models/billing_invoice_action.dart';
import '../models/billing_invoice.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';
import '../utils/billing_invoice_actions.dart';
import '../utils/billing_invoice_activity.dart';
import '../utils/billing_invoice_terms.dart';
import 'billing_invoice_action_bar.dart';
import 'billing_invoice_activity_timeline.dart';
import 'billing_invoice_status_badge.dart';

class BillingInvoiceDetailPanel extends StatelessWidget {
  final BillingInvoice invoice;
  final BillingTenantPreferences preferences;
  final String? tenantName;
  final VoidCallback? onClose;
  final ValueChanged<BillingInvoiceAction>? onActionSelected;
  final DateTime? activityNow;

  const BillingInvoiceDetailPanel({
    super.key,
    required this.invoice,
    this.preferences = const BillingTenantPreferences(),
    this.tenantName,
    this.onClose,
    this.onActionSelected,
    this.activityNow,
  });

  @override
  Widget build(BuildContext context) {
    final amount = formatBillingCurrency(
      invoice.amount,
      preferences: preferences,
    );
    final issuedDate = formatBillingDate(
      invoice.date,
      preferences: preferences,
    );
    final dueDate = formatBillingDate(
      billingInvoiceDueDate(invoice, preferences: preferences),
      preferences: preferences,
    );
    final activityEntries = buildBillingInvoiceActivityTimeline(
      invoice,
      preferences: preferences,
      now: activityNow,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${invoice.id}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tenantName ?? invoice.tenantId,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                BillingInvoiceStatusBadge(status: invoice.status),
                if (onClose != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount due',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InvoiceFactGrid(
              facts: [
                _InvoiceFact(
                  label: 'Issued',
                  value: issuedDate,
                  icon: Icons.event_note_outlined,
                ),
                _InvoiceFact(
                  label: 'Due',
                  value: dueDate,
                  icon: Icons.event_available_outlined,
                ),
                _InvoiceFact(
                  label: 'Terms',
                  value: '${preferences.paymentTermsDays} days',
                  icon: Icons.schedule_outlined,
                ),
                _InvoiceFact(
                  label: 'Tax',
                  value: preferences.taxMode.label,
                  icon: Icons.receipt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            BillingInvoiceActivityTimeline(
              entries: activityEntries,
              preferences: preferences,
            ),
            const SizedBox(height: 18),
            BillingInvoiceActionBar(
              actions: billingInvoiceActions(invoice.status),
              onActionSelected: onActionSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceFact {
  final String label;
  final String value;
  final IconData icon;

  const _InvoiceFact({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _InvoiceFactGrid extends StatelessWidget {
  final List<_InvoiceFact> facts;

  const _InvoiceFactGrid({required this.facts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              facts.map((fact) {
                final width =
                    isCompact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 10) / 2;

                return SizedBox(
                  width: width,
                  child: _InvoiceFactTile(fact: fact),
                );
              }).toList(),
        );
      },
    );
  }
}

class _InvoiceFactTile extends StatelessWidget {
  final _InvoiceFact fact;

  const _InvoiceFactTile({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(fact.icon, color: const Color(0xFF475569), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fact.value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _BillingTaxModeLabel on BillingTaxMode {
  String get label {
    switch (this) {
      case BillingTaxMode.exclusive:
        return 'Exclusive';
      case BillingTaxMode.inclusive:
        return 'Inclusive';
      case BillingTaxMode.exempt:
        return 'Exempt';
    }
  }
}
