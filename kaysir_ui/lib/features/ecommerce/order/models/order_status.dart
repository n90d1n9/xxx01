enum OrderStatusTone { neutral, warning, progress, ready, success, danger }

class OrderStatusOption {
  final String value;
  final String label;
  final OrderStatusTone tone;

  const OrderStatusOption({
    required this.value,
    required this.label,
    required this.tone,
  });
}

const ecommerceOrderStatusOptions = <OrderStatusOption>[
  OrderStatusOption(
    value: 'pending',
    label: 'Pending',
    tone: OrderStatusTone.warning,
  ),
  OrderStatusOption(
    value: 'processing',
    label: 'Processing',
    tone: OrderStatusTone.progress,
  ),
  OrderStatusOption(
    value: 'ready',
    label: 'Ready',
    tone: OrderStatusTone.ready,
  ),
  OrderStatusOption(
    value: 'completed',
    label: 'Completed',
    tone: OrderStatusTone.success,
  ),
  OrderStatusOption(
    value: 'cancelled',
    label: 'Cancelled',
    tone: OrderStatusTone.danger,
  ),
];

OrderStatusOption ecommerceOrderStatusFor(String status) {
  final normalized = normalizeOrderStatus(status);
  for (final option in ecommerceOrderStatusOptions) {
    if (option.value == normalized) return option;
  }

  return OrderStatusOption(
    value: normalized.isEmpty ? 'unknown' : normalized,
    label: _humanizeStatus(status),
    tone: OrderStatusTone.neutral,
  );
}

List<OrderStatusOption> ecommerceOrderLifecycleActions() {
  return ecommerceOrderStatusOptions;
}

String normalizeOrderStatus(String status) {
  return status.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
}

String _humanizeStatus(String status) {
  final normalized = normalizeOrderStatus(status);
  if (normalized.isEmpty) return 'Unknown';

  return normalized
      .split(RegExp(r'[_-]+'))
      .where((part) => part.isNotEmpty)
      .map(_titleCase)
      .join(' ');
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
