import 'package:flutter/material.dart';

import '../../cashier/utils/pos_formatters.dart';
import '../models/order.dart';

class ReceiptDialog extends StatelessWidget {
  final Order order;

  const ReceiptDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change =
        order.paidAmount > order.total ? order.paidAmount - order.total : 0.0;
    final fulfillment = order.fulfillment;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text('Receipt', style: theme.textTheme.headlineSmall),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ReceiptMetaRow(
                label: 'Order',
                value: '#${_shortOrderId(order.id)}',
              ),
              _ReceiptMetaRow(label: 'Terminal', value: order.terminal.name),
              _ReceiptMetaRow(
                label: 'Time',
                value: _timeLabel(order.createdAt),
              ),
              if (order.customer != null)
                _ReceiptMetaRow(label: 'Customer', value: order.customer!.name),
              if (fulfillment != null) ...[
                _ReceiptMetaRow(
                  label: 'Channel',
                  value: fulfillment.commerceChannelLabel,
                ),
                _ReceiptMetaRow(
                  label: 'Fulfillment',
                  value: fulfillment.fulfillmentModeLabel,
                ),
                if (fulfillment.detailLabel.isNotEmpty)
                  _ReceiptMetaRow(
                    label: 'Details',
                    value: fulfillment.detailLabel,
                  ),
              ],
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 42,
                          child: Text(
                            '${item.quantity}x',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatPOSCurrency(item.total),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(color: theme.dividerColor),
              _ReceiptTotalRow(label: 'Subtotal', value: order.subtotal),
              if (order.discountTotal > 0)
                _ReceiptTotalRow(
                  label: 'Discount',
                  value: -order.discountTotal,
                  color: theme.colorScheme.error,
                ),
              _ReceiptTotalRow(
                label: 'Total',
                value: order.total,
                emphasized: true,
              ),
              const SizedBox(height: 8),
              ...order.payments.map(
                (payment) => _ReceiptMetaRow(
                  label: payment.method,
                  value: formatPOSCurrency(payment.amount),
                ),
              ),
              if (change > 0)
                _ReceiptMetaRow(
                  label: 'Change',
                  value: formatPOSCurrency(change),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptMetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptMetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 2,
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptTotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;
  final Color? color;

  const _ReceiptTotalRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        emphasized ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: style?.copyWith(
              fontWeight: emphasized ? FontWeight.w800 : null,
            ),
          ),
          const Spacer(),
          Text(
            formatPOSCurrency(value),
            style: style?.copyWith(
              color: color ?? (emphasized ? theme.colorScheme.primary : null),
              fontWeight: emphasized ? FontWeight.w800 : null,
            ),
          ),
        ],
      ),
    );
  }
}

String _shortOrderId(String id) {
  final normalized = id.startsWith('temp_') ? id.substring(5) : id;
  if (normalized.length <= 6) return normalized;
  return normalized.substring(normalized.length - 6);
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
