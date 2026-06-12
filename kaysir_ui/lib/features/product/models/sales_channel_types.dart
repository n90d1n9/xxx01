/// Selling channels that product readiness can be evaluated against.
enum ProductSalesChannel { posCheckout, onlineStore, marketplace, kiosk }

/// Common blocker categories that prevent channel launch readiness.
enum ProductSalesChannelBlocker {
  missingPrice,
  stockNotSellable,
  missingSku,
  missingCopy,
  missingCategory,
  missingScanCode,
}
