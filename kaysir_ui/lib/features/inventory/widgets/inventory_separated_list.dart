import 'package:flutter/material.dart';

typedef InventorySeparatedListItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

class InventorySeparatedList<T> extends StatelessWidget {
  const InventorySeparatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 10,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<T> items;
  final InventorySeparatedListItemBuilder<T> itemBuilder;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (var index = 0; index < items.length; index += 1) ...[
          itemBuilder(context, items[index], index),
          if (index != items.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
