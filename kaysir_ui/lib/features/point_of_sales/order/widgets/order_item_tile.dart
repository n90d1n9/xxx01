import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/experiences/pos_experience_provider.dart';
import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../models/order_item.dart';
import '../states/current_order_provider.dart';

class OrderItemTile extends ConsumerWidget {
  final OrderItem item;

  const OrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartBehavior = ref.watch(posCartBehaviorProvider);
    final quantityStep = cartBehavior.quantityStep;
    final nextQuantity = cartBehavior.resolveQuantityChange(
      product: item.product,
      requestedQuantity: item.quantity + quantityStep,
    );
    final canIncrement = nextQuantity.quantity > item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: POSSurface(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.34,
        ),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.72)),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductThumb(image: item.product.image),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(child: _ItemDetails(item: item)),
            const SizedBox(width: POSUiTokens.gap),
            _QuantityStepper(
              quantity: item.quantity,
              onDecrement: () {
                final requestedQuantity = item.quantity - quantityStep;
                if (requestedQuantity > 0) {
                  ref
                      .read(currentOrderProvider.notifier)
                      .updateItemQuantity(
                        item.id,
                        requestedQuantity,
                        cartBehavior: cartBehavior,
                      );
                } else {
                  ref.read(currentOrderProvider.notifier).removeItem(item.id);
                }
              },
              onIncrement:
                  canIncrement
                      ? () {
                        ref
                            .read(currentOrderProvider.notifier)
                            .updateItemQuantity(
                              item.id,
                              item.quantity + quantityStep,
                              cartBehavior: cartBehavior,
                            );
                      }
                      : null,
              incrementTooltip:
                  canIncrement
                      ? 'Increase quantity'
                      : nextQuantity.message ??
                          cartBehavior.quantityLimitMessage,
            ),
            const SizedBox(width: POSUiTokens.gap),
            _ItemTotal(
              item: item,
              onRemove: () {
                ref.read(currentOrderProvider.notifier).removeItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? image;

  const _ProductThumb({required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productImage = image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(POSUiTokens.radius),
      child: Container(
        width: 48,
        height: 48,
        color: theme.colorScheme.surface,
        child:
            productImage == null || productImage.isEmpty
                ? Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                )
                : productImage.startsWith('http')
                ? Image.network(productImage, fit: BoxFit.cover)
                : Image.asset(productImage, fit: BoxFit.cover),
      ),
    );
  }
}

class _ItemDetails extends StatelessWidget {
  final OrderItem item;

  const _ItemDetails({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${formatPOSCurrency(item.unitPrice)} each',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (item.discount > 0) ...[
          const SizedBox(height: 3),
          Text(
            'Discount -${formatPOSCurrency(item.discount)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback? onIncrement;
  final String incrementTooltip;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.incrementTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      color: theme.colorScheme.surface,
      border: Border.all(color: theme.dividerColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            tooltip: 'Decrease quantity',
            onPressed: onDecrement,
          ),
          SizedBox(
            width: 32,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            tooltip: incrementTooltip,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 17),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
      ),
    );
  }
}

class _ItemTotal extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onRemove;

  const _ItemTotal({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              formatPOSCurrency(item.total),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          IconButton(
            tooltip: 'Remove item',
            icon: const Icon(Icons.delete_outline, size: 20),
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
