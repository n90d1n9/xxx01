enum POSCommandBarDensity { compact, balanced, expanded }

class POSCommandBarLayout {
  static const double stackedBreakpoint = 1320;
  static const double expandedBreakpoint = 1440;

  final POSCommandBarDensity density;
  final bool stacksActions;
  final bool usesCompactControls;

  const POSCommandBarLayout._({
    required this.density,
    required this.stacksActions,
    required this.usesCompactControls,
  });

  factory POSCommandBarLayout.resolve(double width) {
    final effectiveWidth = width.isFinite ? width : expandedBreakpoint;

    if (effectiveWidth < stackedBreakpoint) {
      return const POSCommandBarLayout._(
        density: POSCommandBarDensity.compact,
        stacksActions: true,
        usesCompactControls: true,
      );
    }

    if (effectiveWidth < expandedBreakpoint) {
      return const POSCommandBarLayout._(
        density: POSCommandBarDensity.balanced,
        stacksActions: false,
        usesCompactControls: true,
      );
    }

    return const POSCommandBarLayout._(
      density: POSCommandBarDensity.expanded,
      stacksActions: false,
      usesCompactControls: false,
    );
  }
}
