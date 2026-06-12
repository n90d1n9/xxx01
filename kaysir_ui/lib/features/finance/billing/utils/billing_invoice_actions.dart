import '../models/billing_invoice_action.dart';
import '../models/billing_invoice_status.dart';

List<BillingInvoiceAction> billingInvoiceActions(BillingInvoiceStatus status) {
  final actions = <BillingInvoiceAction>[
    BillingInvoiceAction(
      type: BillingInvoiceActionType.collectPayment,
      label: status.isCollectable ? 'Collect Payment' : 'Payment Closed',
      style: BillingInvoiceActionStyle.primary,
      enabled: status.isCollectable,
      disabledReason:
          status.isCollectable ? null : 'This invoice is not collectable.',
    ),
  ];

  if (status.isCollectable) {
    actions.add(
      const BillingInvoiceAction(
        type: BillingInvoiceActionType.sendReminder,
        label: 'Send Reminder',
        style: BillingInvoiceActionStyle.secondary,
      ),
    );
  }

  actions.add(
    const BillingInvoiceAction(
      type: BillingInvoiceActionType.download,
      label: 'Download',
      style: BillingInvoiceActionStyle.secondary,
    ),
  );

  return List.unmodifiable(actions);
}
