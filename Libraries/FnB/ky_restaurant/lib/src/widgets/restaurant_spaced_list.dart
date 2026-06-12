import 'package:flutter/widgets.dart';

typedef RestaurantSpacedItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// Displays a vertical item list with consistent spacing and no trailing gap.
class RestaurantSpacedList<T> extends StatelessWidget {
  const RestaurantSpacedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 12,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<T> items;
  final RestaurantSpacedItemBuilder<T> itemBuilder;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          itemBuilder(context, items[index], index),
          if (index < items.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
