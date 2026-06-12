import 'package:flutter/material.dart';

import '../models/billing_invoice_status.dart';

class BillingInvoiceStatusBadge extends StatelessWidget {
  final BillingInvoiceStatus status;

  const BillingInvoiceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = invoiceStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

Color invoiceStatusColor(BillingInvoiceStatus status) {
  switch (status) {
    case BillingInvoiceStatus.paid:
      return const Color(0xFF10B981);
    case BillingInvoiceStatus.overdue:
      return const Color(0xFFEF4444);
    case BillingInvoiceStatus.pending:
      return const Color(0xFFF59E0B);
    case BillingInvoiceStatus.draft:
      return const Color(0xFF6366F1);
    case BillingInvoiceStatus.voided:
      return const Color(0xFF64748B);
  }
}
