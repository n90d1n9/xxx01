import '../models/billing_invoice.dart';
import '../models/billing_invoice_attention.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_formatters.dart';
import 'billing_invoice_aging.dart';
import 'billing_invoice_terms.dart';

BillingInvoiceAttentionSummary summarizeBillingInvoiceAttention(
  Iterable<BillingInvoice> invoices, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();
  var overdueCount = 0;
  var dueSoonCount = 0;
  var openCount = 0;
  var overdueAmount = 0.0;
  var dueSoonAmount = 0.0;
  var openAmount = 0.0;
  DateTime? nextDueDate;

  for (final invoice in invoices) {
    final dueDate = billingInvoiceDueDate(invoice, preferences: preferences);
    final aging = BillingInvoiceAging(
      status: invoice.status,
      dueDate: dueDate,
      now: currentTime,
    );

    if (invoice.status.isCollectable) {
      openCount += 1;
      openAmount += invoice.amount;
      if (nextDueDate == null || dueDate.isBefore(nextDueDate)) {
        nextDueDate = dueDate;
      }
    }

    switch (aging.health) {
      case BillingInvoiceHealth.overdue:
        overdueCount += 1;
        overdueAmount += invoice.amount;
        break;
      case BillingInvoiceHealth.dueSoon:
        dueSoonCount += 1;
        dueSoonAmount += invoice.amount;
        break;
      case BillingInvoiceHealth.draft:
      case BillingInvoiceHealth.paid:
      case BillingInvoiceHealth.pending:
      case BillingInvoiceHealth.voided:
        break;
    }
  }

  final level = _attentionLevel(
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
    openCount: openCount,
  );
  final openAmountText = formatBillingCurrency(
    openAmount,
    preferences: preferences,
  );
  final overdueAmountText = formatBillingCurrency(
    overdueAmount,
    preferences: preferences,
  );
  final dueSoonAmountText = formatBillingCurrency(
    dueSoonAmount,
    preferences: preferences,
  );

  return BillingInvoiceAttentionSummary(
    level: level,
    headline: _headline(
      level,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      openCount: openCount,
    ),
    supportingText: _supportingText(
      level,
      openAmountText: openAmountText,
      overdueAmountText: overdueAmountText,
      dueSoonAmountText: dueSoonAmountText,
      nextDueDate: nextDueDate,
      preferences: preferences,
    ),
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
    openCount: openCount,
    overdueAmount: overdueAmount,
    dueSoonAmount: dueSoonAmount,
    openAmount: openAmount,
    nextDueDate: nextDueDate,
    items: [
      BillingInvoiceAttentionItem(
        kind: BillingInvoiceAttentionKind.overdue,
        title: 'Overdue',
        value: overdueAmountText,
        description: _invoiceCountLabel(overdueCount),
        count: overdueCount,
        amount: overdueAmount,
        level:
            overdueCount > 0
                ? BillingInvoiceAttentionLevel.urgent
                : BillingInvoiceAttentionLevel.settled,
      ),
      BillingInvoiceAttentionItem(
        kind: BillingInvoiceAttentionKind.dueSoon,
        title: 'Due soon',
        value: dueSoonAmountText,
        description: _invoiceCountLabel(dueSoonCount),
        count: dueSoonCount,
        amount: dueSoonAmount,
        level:
            dueSoonCount > 0
                ? BillingInvoiceAttentionLevel.watch
                : BillingInvoiceAttentionLevel.settled,
      ),
      BillingInvoiceAttentionItem(
        kind: BillingInvoiceAttentionKind.openBalance,
        title: 'Open balance',
        value: openAmountText,
        description: _invoiceCountLabel(openCount),
        count: openCount,
        amount: openAmount,
        level:
            openCount > 0
                ? BillingInvoiceAttentionLevel.calm
                : BillingInvoiceAttentionLevel.settled,
      ),
    ],
  );
}

BillingInvoiceAttentionLevel _attentionLevel({
  required int overdueCount,
  required int dueSoonCount,
  required int openCount,
}) {
  if (overdueCount > 0) return BillingInvoiceAttentionLevel.urgent;
  if (dueSoonCount > 0) return BillingInvoiceAttentionLevel.watch;
  if (openCount > 0) return BillingInvoiceAttentionLevel.calm;
  return BillingInvoiceAttentionLevel.settled;
}

String _headline(
  BillingInvoiceAttentionLevel level, {
  required int overdueCount,
  required int dueSoonCount,
  required int openCount,
}) {
  switch (level) {
    case BillingInvoiceAttentionLevel.urgent:
      final verb = overdueCount == 1 ? 'needs' : 'need';
      return '$overdueCount overdue ${_invoiceNoun(overdueCount)} $verb follow-up';
    case BillingInvoiceAttentionLevel.watch:
      return '$dueSoonCount ${_invoiceNoun(dueSoonCount)} due soon';
    case BillingInvoiceAttentionLevel.calm:
      return '$openCount open ${_invoiceNoun(openCount)} in collection';
    case BillingInvoiceAttentionLevel.settled:
      return 'Receivables are settled';
  }
}

String _supportingText(
  BillingInvoiceAttentionLevel level, {
  required String openAmountText,
  required String overdueAmountText,
  required String dueSoonAmountText,
  required DateTime? nextDueDate,
  required BillingTenantPreferences preferences,
}) {
  switch (level) {
    case BillingInvoiceAttentionLevel.urgent:
      return '$overdueAmountText is past due. Start collection follow-up first.';
    case BillingInvoiceAttentionLevel.watch:
      return '$dueSoonAmountText is approaching due date. Send reminders early.';
    case BillingInvoiceAttentionLevel.calm:
      final dueText =
          nextDueDate == null
              ? 'No due date available'
              : 'Next due ${formatBillingDate(nextDueDate, preferences: preferences)}';
      return '$openAmountText is open. $dueText.';
    case BillingInvoiceAttentionLevel.settled:
      return 'No overdue or open invoices need operator attention right now.';
  }
}

String _invoiceCountLabel(int count) {
  return '$count ${_invoiceNoun(count)}';
}

String _invoiceNoun(int count) {
  return count == 1 ? 'invoice' : 'invoices';
}
