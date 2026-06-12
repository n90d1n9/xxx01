import '../models/billing_invoice.dart';
import '../models/billing_invoice_activity.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_formatters.dart';
import 'billing_invoice_aging.dart';
import 'billing_invoice_terms.dart';

List<BillingInvoiceActivityEntry> buildBillingInvoiceActivityTimeline(
  BillingInvoice invoice, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  DateTime? now,
}) {
  final dueDate = billingInvoiceDueDate(invoice, preferences: preferences);
  final aging = BillingInvoiceAging(
    status: invoice.status,
    dueDate: dueDate,
    now: now ?? DateTime.now(),
  );
  final amount = formatBillingCurrency(
    invoice.amount,
    preferences: preferences,
  );
  final entries = <BillingInvoiceActivityEntry>[
    BillingInvoiceActivityEntry(
      type:
          invoice.status == BillingInvoiceStatus.draft
              ? BillingInvoiceActivityType.draftReview
              : BillingInvoiceActivityType.issued,
      state: BillingInvoiceActivityState.completed,
      title:
          invoice.status == BillingInvoiceStatus.draft
              ? 'Draft created'
              : 'Invoice issued',
      description:
          invoice.status == BillingInvoiceStatus.draft
              ? 'Invoice is being prepared before release.'
              : 'Created for $amount.',
      date: invoice.date,
    ),
  ];

  switch (aging.health) {
    case BillingInvoiceHealth.draft:
      entries.add(
        const BillingInvoiceActivityEntry(
          type: BillingInvoiceActivityType.draftReview,
          state: BillingInvoiceActivityState.current,
          title: 'Ready for review',
          description: 'Confirm amount, tax mode, and terms before sending.',
        ),
      );
      break;
    case BillingInvoiceHealth.paid:
      entries.add(
        const BillingInvoiceActivityEntry(
          type: BillingInvoiceActivityType.paymentReceived,
          state: BillingInvoiceActivityState.completed,
          title: 'Payment received',
          description: 'Invoice is settled and collection is closed.',
        ),
      );
      break;
    case BillingInvoiceHealth.voided:
      entries.add(
        const BillingInvoiceActivityEntry(
          type: BillingInvoiceActivityType.voided,
          state: BillingInvoiceActivityState.blocked,
          title: 'Invoice voided',
          description: 'Collection is closed for this invoice.',
        ),
      );
      break;
    case BillingInvoiceHealth.overdue:
      entries
        ..add(
          BillingInvoiceActivityEntry(
            type: BillingInvoiceActivityType.overdueNotice,
            state: BillingInvoiceActivityState.current,
            title: 'Payment overdue',
            description: aging.operatorMessage,
            date: dueDate,
          ),
        )
        ..add(
          const BillingInvoiceActivityEntry(
            type: BillingInvoiceActivityType.reminder,
            state: BillingInvoiceActivityState.upcoming,
            title: 'Send reminder',
            description: 'Queue a reminder or start collection follow-up.',
          ),
        );
      break;
    case BillingInvoiceHealth.dueSoon:
      entries
        ..add(
          BillingInvoiceActivityEntry(
            type: BillingInvoiceActivityType.paymentDue,
            state: BillingInvoiceActivityState.current,
            title: 'Payment due soon',
            description: aging.operatorMessage,
            date: dueDate,
          ),
        )
        ..add(
          const BillingInvoiceActivityEntry(
            type: BillingInvoiceActivityType.collectPayment,
            state: BillingInvoiceActivityState.upcoming,
            title: 'Prioritize collection',
            description: 'Record payment or send a customer payment link.',
          ),
        );
      break;
    case BillingInvoiceHealth.pending:
      entries.add(
        BillingInvoiceActivityEntry(
          type: BillingInvoiceActivityType.paymentDue,
          state: BillingInvoiceActivityState.current,
          title: 'Awaiting payment',
          description: aging.operatorMessage,
          date: dueDate,
        ),
      );
      break;
  }

  return List.unmodifiable(entries);
}
