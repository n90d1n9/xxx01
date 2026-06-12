/// Layout mode used by the product editor form content.
enum ProductEditorFormLayoutMode { stacked, split }

/// Responsive layout metrics for the product editor form content.
class ProductEditorFormLayout {
  const ProductEditorFormLayout({
    required this.mode,
    required this.sideRailWidth,
    required this.gap,
  });

  /// Resolves editor layout metrics from the available content width.
  factory ProductEditorFormLayout.forWidth(double width) {
    if (width >= 1100) {
      return const ProductEditorFormLayout(
        mode: ProductEditorFormLayoutMode.split,
        sideRailWidth: 360,
        gap: 20,
      );
    }

    return const ProductEditorFormLayout(
      mode: ProductEditorFormLayoutMode.stacked,
      sideRailWidth: 0,
      gap: 16,
    );
  }

  final ProductEditorFormLayoutMode mode;
  final double sideRailWidth;
  final double gap;

  bool get isSplit => mode == ProductEditorFormLayoutMode.split;
}
