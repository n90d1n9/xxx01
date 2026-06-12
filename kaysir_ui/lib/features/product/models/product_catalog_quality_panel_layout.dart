/// Responsive layout metrics for the catalog quality panel issue grid.
class ProductCatalogQualityPanelLayout {
  const ProductCatalogQualityPanelLayout._({
    required this.maxWidth,
    required this.columnCount,
    required this.gap,
    required this.tileWidth,
  });

  factory ProductCatalogQualityPanelLayout.forWidth(
    double maxWidth, {
    double gap = 10,
  }) {
    final safeWidth = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 0.0;
    final safeGap = gap.isFinite && gap > 0 ? gap : 0.0;
    final columnCount = _columnCountForWidth(safeWidth);
    final totalGapWidth = safeGap * (columnCount - 1);
    final availableTileWidth =
        safeWidth > totalGapWidth ? safeWidth - totalGapWidth : 0.0;

    return ProductCatalogQualityPanelLayout._(
      maxWidth: safeWidth,
      columnCount: columnCount,
      gap: safeGap,
      tileWidth: availableTileWidth / columnCount,
    );
  }

  final double maxWidth;
  final int columnCount;
  final double gap;
  final double tileWidth;

  static int _columnCountForWidth(double width) {
    if (width >= 1000) return 5;
    if (width >= 720) return 3;
    if (width >= 480) return 2;

    return 1;
  }
}
