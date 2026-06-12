/// Describes the grid cell position and span for a component.
class LayoutRuleGridGeometryMetrics {
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;
  final double pixelWidth;
  final double pixelHeight;

  const LayoutRuleGridGeometryMetrics({
    required this.column,
    required this.row,
    required this.columnSpan,
    required this.rowSpan,
    required this.pixelWidth,
    required this.pixelHeight,
  });
}

/// Describes the tabular column position and span for a component.
class LayoutRuleTabularGeometryMetrics {
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;
  final double pixelWidth;
  final double pixelHeight;

  const LayoutRuleTabularGeometryMetrics({
    required this.column,
    required this.row,
    required this.columnSpan,
    required this.rowSpan,
    required this.pixelWidth,
    required this.pixelHeight,
  });
}

/// Describes the auto-grid cell position and span for a component.
class LayoutRuleAutoGridGeometryMetrics {
  final int column;
  final int row;
  final int columnSpan;
  final int rowSpan;
  final double pixelWidth;
  final double pixelHeight;

  const LayoutRuleAutoGridGeometryMetrics({
    required this.column,
    required this.row,
    required this.columnSpan,
    required this.rowSpan,
    required this.pixelWidth,
    required this.pixelHeight,
  });
}

/// Describes the occupied layout-rule cell range for a component selection.
class LayoutRuleSelectionMetrics {
  final int startColumn;
  final int startRow;
  final int endColumn;
  final int endRow;

  const LayoutRuleSelectionMetrics({
    required this.startColumn,
    required this.startRow,
    required this.endColumn,
    required this.endRow,
  });

  int get columnSpan => endColumn - startColumn + 1;
  int get rowSpan => endRow - startRow + 1;
}

/// Summarizes whether components need position or size snapping.
class LayoutRuleSnapStatus {
  final int positionCount;
  final int sizeCount;

  const LayoutRuleSnapStatus({
    required this.positionCount,
    required this.sizeCount,
  });

  bool get isAligned => positionCount == 0 && sizeCount == 0;
}
