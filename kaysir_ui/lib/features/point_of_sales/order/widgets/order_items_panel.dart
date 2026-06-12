import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/experiences/pos_experience_provider.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../models/order.dart';
import 'order_item_tile.dart';

class OrderItemsPanel extends ConsumerWidget {
  final Order order;

  const OrderItemsPanel({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartBehavior = ref.watch(posCartBehaviorProvider);

    if (order.items.isEmpty) {
      return POSEmptyState(
        icon: Icons.shopping_basket_outlined,
        title: cartBehavior.emptyCartTitle,
        message: cartBehavior.emptyCartMessage,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: order.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: POSUiTokens.gap),
      itemBuilder: (context, index) {
        return OrderItemTile(item: order.items[index]);
      },
    );
  }
}
