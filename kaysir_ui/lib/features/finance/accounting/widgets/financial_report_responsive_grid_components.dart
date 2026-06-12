import 'package:flutter/material.dart';

typedef FinancialReportResponsiveGridItemBuilder<T> =
    Widget Function(BuildContext context, T item);

class FinancialReportResponsiveGridBreakpoint {
  const FinancialReportResponsiveGridBreakpoint({
    required this.minWidth,
    required this.columns,
  });

  final double minWidth;
  final int columns;
}

class FinancialReportResponsiveWrapGrid<T> extends StatelessWidget {
  const FinancialReportResponsiveWrapGrid({
    required this.items,
    required this.itemBuilder,
    this.breakpoints = const [],
    this.spacing = 10,
    this.runSpacing,
    this.fallbackWidth = 960,
    super.key,
  });

  final List<T> items;
  final FinancialReportResponsiveGridItemBuilder<T> itemBuilder;
  final List<FinancialReportResponsiveGridBreakpoint> breakpoints;
  final double spacing;
  final double? runSpacing;
  final double fallbackWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : fallbackWidth;
        final columnCount = _columnCountFor(availableWidth);
        final itemWidth =
            columnCount == 1
                ? availableWidth
                : (availableWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing ?? spacing,
          children:
              items
                  .map(
                    (item) => SizedBox(
                      width: itemWidth.clamp(0.0, availableWidth).toDouble(),
                      child: itemBuilder(context, item),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  int _columnCountFor(double width) {
    var columns = 1;
    var selectedMinWidth = double.negativeInfinity;
    for (final breakpoint in breakpoints) {
      if (width >= breakpoint.minWidth &&
          breakpoint.minWidth >= selectedMinWidth) {
        columns = breakpoint.columns;
        selectedMinWidth = breakpoint.minWidth;
      }
    }
    return columns < 1 ? 1 : columns;
  }
}
