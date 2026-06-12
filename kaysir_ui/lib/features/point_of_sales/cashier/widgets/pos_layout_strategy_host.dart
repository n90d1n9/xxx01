import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../states/pos_layout_provider.dart';
import 'pos_layout_strategy_pack.dart';
import 'pos_layout_strategy_renderer.dart';

export 'pos_layout_strategy_renderer.dart';

class POSLayoutStrategyHost extends StatelessWidget {
  final POSLayoutStrategy strategy;
  final int itemCount;
  final ValueChanged<Product> onProductSelected;
  final POSLayoutStrategyRendererRegistry? registry;
  final POSLayoutStrategyPack? pack;

  const POSLayoutStrategyHost({
    super.key,
    required this.strategy,
    required this.itemCount,
    required this.onProductSelected,
    this.registry,
    this.pack,
  }) : assert(
         registry == null || pack == null,
         'Use either a POS layout registry or a POS layout pack, not both.',
       );

  @override
  Widget build(BuildContext context) {
    final resolvedPack =
        pack ??
        (registry == null
            ? defaultPOSLayoutStrategyPack
            : POSLayoutStrategyPack(
              strategyRegistry: registry!.strategyRegistry,
              rendererRegistry: registry!,
            ));

    return resolvedPack.build(
      strategy: strategy,
      itemCount: itemCount,
      onProductSelected: onProductSelected,
    );
  }
}
