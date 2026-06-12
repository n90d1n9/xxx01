import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

typedef GridColumnResolver = int Function(double width);

typedef GridItemBuilder =
    Widget Function(BuildContext context, int index, double itemWidth);

class ResponsiveWrapGrid extends StatelessWidget {
  const ResponsiveWrapGrid({
    required this.itemCount,
    required this.columnsForWidth,
    required this.itemBuilder,
    this.spacing = POSUiTokens.gapLarge,
    this.runSpacing = POSUiTokens.gapLarge,
    super.key,
  }) : assert(itemCount >= 0);

  final int itemCount;
  final GridColumnResolver columnsForWidth;
  final GridItemBuilder itemBuilder;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final requestedColumns = columnsForWidth(constraints.maxWidth);
        final columns = requestedColumns < 1 ? 1 : requestedColumns;
        final effectiveSpacing = columns == 1 ? 0.0 : spacing;
        final itemWidth =
            (constraints.maxWidth - effectiveSpacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: List.generate(
            itemCount,
            (index) => itemBuilder(context, index, itemWidth),
          ),
        );
      },
    );
  }
}
