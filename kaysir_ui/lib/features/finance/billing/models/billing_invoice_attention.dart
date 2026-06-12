enum BillingInvoiceAttentionKind { overdue, dueSoon, openBalance }

enum BillingInvoiceAttentionLevel { settled, calm, watch, urgent }

class BillingInvoiceAttentionItem {
  final BillingInvoiceAttentionKind kind;
  final String title;
  final String value;
  final String description;
  final int count;
  final double amount;
  final BillingInvoiceAttentionLevel level;

  const BillingInvoiceAttentionItem({
    required this.kind,
    required this.title,
    required this.value,
    required this.description,
    required this.count,
    required this.amount,
    required this.level,
  });
}

class BillingInvoiceAttentionSummary {
  final BillingInvoiceAttentionLevel level;
  final String headline;
  final String supportingText;
  final int overdueCount;
  final int dueSoonCount;
  final int openCount;
  final double overdueAmount;
  final double dueSoonAmount;
  final double openAmount;
  final DateTime? nextDueDate;
  final List<BillingInvoiceAttentionItem> items;

  const BillingInvoiceAttentionSummary({
    required this.level,
    required this.headline,
    required this.supportingText,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.openCount,
    required this.overdueAmount,
    required this.dueSoonAmount,
    required this.openAmount,
    required this.items,
    this.nextDueDate,
  });

  bool get hasOpenReceivables => openCount > 0;
}
