enum BillingInvoiceSyncState { confirmed, localOnly }

extension BillingInvoiceSyncStateX on BillingInvoiceSyncState {
  String get label {
    switch (this) {
      case BillingInvoiceSyncState.confirmed:
        return 'Synced';
      case BillingInvoiceSyncState.localOnly:
        return 'Syncing';
    }
  }

  String get description {
    switch (this) {
      case BillingInvoiceSyncState.confirmed:
        return 'Invoice is confirmed by the billing source.';
      case BillingInvoiceSyncState.localOnly:
        return 'Invoice is saved locally until the billing source confirms it.';
    }
  }
}
