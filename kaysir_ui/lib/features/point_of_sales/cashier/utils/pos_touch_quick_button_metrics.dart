import '../models/pos_touch_layout_profile.dart';

/// Sizing contract for POS touch quick-button boards.
///
/// The metrics are intentionally separate from widgets so product profiles and
/// operator preferences can be tested without building the Flutter tree.
class POSTouchQuickButtonMetrics {
  final POSTouchLayoutDensity density;
  final double targetExtent;
  final double mainAxisExtent;
  final double spacing;
  final double sectionPadding;

  const POSTouchQuickButtonMetrics({
    required this.density,
    required this.targetExtent,
    required this.mainAxisExtent,
    required this.spacing,
    required this.sectionPadding,
  });

  int columnsFor({required double width, required int maxColumns}) {
    final safeMaxColumns = maxColumns <= 0 ? 1 : maxColumns;
    final columns = (width / targetExtent).floor();

    return columns.clamp(1, safeMaxColumns);
  }
}

/// Resolves board sizing from a profile density and compact parent chrome.
POSTouchQuickButtonMetrics resolvePOSTouchQuickButtonMetrics({
  required POSTouchLayoutDensity density,
  required bool compactChrome,
  required double minTileExtent,
}) {
  final base = _baseMetricsFor(density);
  final compactOffset = compactChrome ? _compactOffsetFor(density) : 0.0;

  return POSTouchQuickButtonMetrics(
    density: density,
    targetExtent: _maxDouble(base.targetExtent + compactOffset, minTileExtent),
    mainAxisExtent: _maxDouble(base.mainAxisExtent + compactOffset, 88),
    spacing: _maxDouble(base.spacing + (compactChrome ? -2 : 0), 6),
    sectionPadding: _maxDouble(
      base.sectionPadding + (compactChrome ? -2 : 0),
      8,
    ),
  );
}

POSTouchQuickButtonMetrics _baseMetricsFor(POSTouchLayoutDensity density) {
  switch (density) {
    case POSTouchLayoutDensity.compact:
      return const POSTouchQuickButtonMetrics(
        density: POSTouchLayoutDensity.compact,
        targetExtent: 132,
        mainAxisExtent: 128,
        spacing: 8,
        sectionPadding: 10,
      );
    case POSTouchLayoutDensity.comfortable:
      return const POSTouchQuickButtonMetrics(
        density: POSTouchLayoutDensity.comfortable,
        targetExtent: 152,
        mainAxisExtent: 136,
        spacing: 10,
        sectionPadding: 12,
      );
    case POSTouchLayoutDensity.spacious:
      return const POSTouchQuickButtonMetrics(
        density: POSTouchLayoutDensity.spacious,
        targetExtent: 176,
        mainAxisExtent: 156,
        spacing: 12,
        sectionPadding: 14,
      );
    case POSTouchLayoutDensity.kiosk:
      return const POSTouchQuickButtonMetrics(
        density: POSTouchLayoutDensity.kiosk,
        targetExtent: 204,
        mainAxisExtent: 180,
        spacing: 14,
        sectionPadding: 16,
      );
  }
}

double _compactOffsetFor(POSTouchLayoutDensity density) {
  switch (density) {
    case POSTouchLayoutDensity.compact:
      return -4;
    case POSTouchLayoutDensity.comfortable:
      return -12;
    case POSTouchLayoutDensity.spacious:
      return -6;
    case POSTouchLayoutDensity.kiosk:
      return 0;
  }
}

double _maxDouble(double left, double right) {
  return left > right ? left : right;
}
