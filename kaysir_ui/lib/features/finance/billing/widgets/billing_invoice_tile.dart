import 'package:flutter/material.dart';

import '../models/billing_invoice.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_invoice_sync_state.dart';
import '../models/billing_tenant_preferences.dart';
import '../utils/billing_formatters.dart';
import 'billing_invoice_status_badge.dart';
import 'billing_invoice_sync_badge.dart';

class BillingInvoiceTile extends StatelessWidget {
  final BillingInvoice invoice;
  final BillingTenantPreferences preferences;
  final BillingInvoiceSyncState syncState;
  final VoidCallback? onTap;

  const BillingInvoiceTile({
    super.key,
    required this.invoice,
    this.preferences = const BillingTenantPreferences(),
    this.syncState = BillingInvoiceSyncState.confirmed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatted = formatBillingCurrency(
      invoice.amount,
      preferences: preferences,
    );
    final dateFormatted = formatBillingDate(
      invoice.date,
      preferences: preferences,
    );
    final statusColor = invoiceStatusColor(invoice.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 460;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ColoredBox(
                        color: statusColor,
                        child: const SizedBox(width: 4),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child:
                              isCompact
                                  ? _CompactInvoiceTileContent(
                                    invoiceId: invoice.id,
                                    amount: amountFormatted,
                                    date: dateFormatted,
                                    status: invoice.status,
                                    syncState: syncState,
                                    showChevron: onTap != null,
                                  )
                                  : _WideInvoiceTileContent(
                                    invoiceId: invoice.id,
                                    amount: amountFormatted,
                                    date: dateFormatted,
                                    status: invoice.status,
                                    syncState: syncState,
                                    showChevron: onTap != null,
                                  ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WideInvoiceTileContent extends StatelessWidget {
  final String invoiceId;
  final String amount;
  final String date;
  final BillingInvoiceStatus status;
  final BillingInvoiceSyncState syncState;
  final bool showChevron;

  const _WideInvoiceTileContent({
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.status,
    required this.syncState,
    required this.showChevron,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _InvoiceIdentity(invoiceId: invoiceId, date: date)),
        const SizedBox(width: 12),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 14),
        BillingInvoiceStatusBadge(status: status),
        if (syncState != BillingInvoiceSyncState.confirmed) ...[
          const SizedBox(width: 8),
          BillingInvoiceSyncBadge(state: syncState),
        ],
        if (showChevron) ...[
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ],
    );
  }
}

class _CompactInvoiceTileContent extends StatelessWidget {
  final String invoiceId;
  final String amount;
  final String date;
  final BillingInvoiceStatus status;
  final BillingInvoiceSyncState syncState;
  final bool showChevron;

  const _CompactInvoiceTileContent({
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.status,
    required this.syncState,
    required this.showChevron,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _InvoiceIdentity(invoiceId: invoiceId, date: date)),
            const SizedBox(width: 8),
            BillingInvoiceStatusBadge(status: status),
          ],
        ),
        if (syncState != BillingInvoiceSyncState.confirmed) ...[
          const SizedBox(height: 8),
          BillingInvoiceSyncBadge(state: syncState),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ],
    );
  }
}

class _InvoiceIdentity extends StatelessWidget {
  final String invoiceId;
  final String date;

  const _InvoiceIdentity({required this.invoiceId, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Invoice #$invoiceId',
          style: const TextStyle(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
