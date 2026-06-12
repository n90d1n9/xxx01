import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../../order/widgets/order_sidebar.dart';
import '../states/pos_layout_provider.dart';
import 'pos_catalog_panel.dart';

class POSLayoutSlotContent {
  final int itemCount;
  final ValueChanged<Product> onProductSelected;

  const POSLayoutSlotContent({
    required this.itemCount,
    required this.onProductSelected,
  });

  Widget catalog({bool dense = false}) {
    return POSCatalogPanel(dense: dense, onProductSelected: onProductSelected);
  }

  Widget order({bool compact = false, bool edgeToEdge = false}) {
    return OrderSidebar(compact: compact, edgeToEdge: edgeToEdge);
  }

  Tab tabFor(POSLayoutSlot slot) {
    switch (slot) {
      case POSLayoutSlot.catalog:
        return const Tab(icon: Icon(Icons.grid_view), text: 'Products');
      case POSLayoutSlot.order:
      case POSLayoutSlot.checkout:
        return Tab(
          icon: Badge.count(
            count: itemCount,
            isLabelVisible: itemCount > 0,
            child: const Icon(Icons.receipt_long_outlined),
          ),
          text: slot == POSLayoutSlot.checkout ? 'Checkout' : 'Order',
        );
      case POSLayoutSlot.commandBar:
        return const Tab(icon: Icon(Icons.tune_outlined), text: 'Commands');
    }
  }
}
