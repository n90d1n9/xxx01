enum BillingInvoiceActivityType {
  draftReview,
  issued,
  paymentDue,
  paymentReceived,
  overdueNotice,
  reminder,
  collectPayment,
  voided,
}

enum BillingInvoiceActivityState { completed, current, upcoming, blocked }

class BillingInvoiceActivityEntry {
  final BillingInvoiceActivityType type;
  final BillingInvoiceActivityState state;
  final String title;
  final String description;
  final DateTime? date;

  const BillingInvoiceActivityEntry({
    required this.type,
    required this.state,
    required this.title,
    required this.description,
    this.date,
  });
}
