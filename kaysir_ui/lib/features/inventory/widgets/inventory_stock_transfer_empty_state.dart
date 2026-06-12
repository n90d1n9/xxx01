import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';

class InventoryStockTransferEmptyState extends StatelessWidget {
  const InventoryStockTransferEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'No transfer destination',
      message:
          'Create another warehouse before moving stock out of this location.',
      icon: Icons.swap_horiz_rounded,
    );
  }
}
