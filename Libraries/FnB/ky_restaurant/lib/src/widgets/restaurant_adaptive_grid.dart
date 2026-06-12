import 'package:flutter/material.dart';

class RestaurantAdaptiveGrid extends StatelessWidget {
  const RestaurantAdaptiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemExtent,
    this.wideBreakpoint = 1100,
    this.mediumBreakpoint = 680,
    this.wideColumns = 4,
    this.mediumColumns = 2,
    this.compactColumns = 1,
    this.spacing = 12,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemExtent;
  final double wideBreakpoint;
  final double mediumBreakpoint;
  final int wideColumns;
  final int mediumColumns;
  final int compactColumns;
  final double spacing;

  static int columnsForWidth(
    double width, {
    double wideBreakpoint = 1100,
    double mediumBreakpoint = 680,
    int wideColumns = 4,
    int mediumColumns = 2,
    int compactColumns = 1,
  }) {
    if (width >= wideBreakpoint) return wideColumns;
    if (width >= mediumBreakpoint) return mediumColumns;
    return compactColumns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsForWidth(
          constraints.maxWidth,
          wideBreakpoint: wideBreakpoint,
          mediumBreakpoint: mediumBreakpoint,
          wideColumns: wideColumns,
          mediumColumns: mediumColumns,
          compactColumns: compactColumns,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemExtent,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
