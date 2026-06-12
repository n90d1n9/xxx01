import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../states/pos_layout_provider.dart';
import 'pos_layout_slots.dart';

class POSCounterLayout extends StatelessWidget {
  final ValueChanged<Product> onProductSelected;
  final POSLayoutSlotContent? slots;

  const POSCounterLayout({
    super.key,
    required this.onProductSelected,
    this.slots,
  });

  @override
  Widget build(BuildContext context) {
    final slotContent =
        slots ??
        POSLayoutSlotContent(
          itemCount: 0,
          onProductSelected: onProductSelected,
        );

    return Row(
      children: [
        Expanded(flex: 5, child: slotContent.catalog()),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: slotContent.order()),
      ],
    );
  }
}

class POSCheckoutLayout extends StatelessWidget {
  final ValueChanged<Product> onProductSelected;
  final POSLayoutSlotContent? slots;

  const POSCheckoutLayout({
    super.key,
    required this.onProductSelected,
    this.slots,
  });

  @override
  Widget build(BuildContext context) {
    final slotContent =
        slots ??
        POSLayoutSlotContent(
          itemCount: 0,
          onProductSelected: onProductSelected,
        );

    return Row(
      children: [
        Expanded(flex: 4, child: slotContent.order()),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: slotContent.catalog(dense: true)),
      ],
    );
  }
}

class POSCompactLayout extends StatelessWidget {
  final int itemCount;
  final ValueChanged<Product> onProductSelected;
  final POSLayoutSlotContent? slots;

  const POSCompactLayout({
    super.key,
    required this.itemCount,
    required this.onProductSelected,
    this.slots,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slotContent =
        slots ??
        POSLayoutSlotContent(
          itemCount: itemCount,
          onProductSelected: onProductSelected,
        );

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: theme.colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  slotContent.tabFor(POSLayoutSlot.catalog),
                  slotContent.tabFor(POSLayoutSlot.order),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                slotContent.catalog(dense: true),
                slotContent.order(compact: true, edgeToEdge: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
