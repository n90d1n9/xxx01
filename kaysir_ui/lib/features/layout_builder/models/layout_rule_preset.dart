import 'grid_setting.dart';
import 'layout_config.dart';

class LayoutRulePreset {
  final String id;
  final String label;
  final String description;
  final LayoutMechanism layoutMechanism;
  final double gridSize;
  final bool snapToGrid;
  final bool showGrid;
  final bool showSubgrid;
  final int? tabularColumnCount;
  final double? tabularColumnGap;
  final double? tabularRowHeight;
  final int? autoGridColumnCount;
  final double? autoGridGap;
  final double? autoGridRowHeight;

  const LayoutRulePreset({
    required this.id,
    required this.label,
    required this.description,
    required this.layoutMechanism,
    required this.gridSize,
    required this.snapToGrid,
    required this.showGrid,
    this.showSubgrid = true,
    this.tabularColumnCount,
    this.tabularColumnGap,
    this.tabularRowHeight,
    this.autoGridColumnCount,
    this.autoGridGap,
    this.autoGridRowHeight,
  });

  LayoutConfig applyToConfig(LayoutConfig config) {
    return config.copyWith(
      layoutMechanism: layoutMechanism,
      gridSize: gridSize,
      snapToGrid: snapToGrid,
      showGrid: showGrid,
      tabularColumnCount: tabularColumnCount,
      tabularColumnGap: tabularColumnGap,
      tabularRowHeight: tabularRowHeight,
      autoGridColumnCount: autoGridColumnCount,
      autoGridGap: autoGridGap,
      autoGridRowHeight: autoGridRowHeight,
    );
  }

  GridSettings applyToGridSettings(GridSettings settings) {
    return settings.copyWith(
      gridSize: gridSize,
      snapToGrid: snapToGrid,
      enabled: showGrid,
      showSubgrid: showSubgrid,
    );
  }

  bool matches(LayoutConfig config, GridSettings settings) {
    return config.layoutMechanism == layoutMechanism &&
        _sameDouble(settings.gridSize, gridSize) &&
        settings.snapToGrid == snapToGrid &&
        settings.enabled == showGrid &&
        settings.showSubgrid == showSubgrid &&
        (tabularColumnCount == null ||
            config.tabularColumnCount == tabularColumnCount) &&
        (tabularColumnGap == null ||
            _sameDouble(config.tabularColumnGap, tabularColumnGap!)) &&
        (tabularRowHeight == null ||
            _sameDouble(config.tabularRowHeight, tabularRowHeight!)) &&
        (autoGridColumnCount == null ||
            config.autoGridColumnCount == autoGridColumnCount) &&
        (autoGridGap == null ||
            _sameDouble(config.autoGridGap, autoGridGap!)) &&
        (autoGridRowHeight == null ||
            _sameDouble(config.autoGridRowHeight, autoGridRowHeight!));
  }
}

String? selectedLayoutRulePresetId(LayoutConfig config, GridSettings settings) {
  for (final preset in layoutRulePresets) {
    if (preset.matches(config, settings)) return preset.id;
  }

  return null;
}

const layoutRulePresets = <LayoutRulePreset>[
  LayoutRulePreset(
    id: 'free-placement',
    label: 'Free',
    description: 'Free placement with the grid visible for reference.',
    layoutMechanism: LayoutMechanism.freeform,
    gridSize: 8,
    snapToGrid: false,
    showGrid: true,
    showSubgrid: false,
  ),
  LayoutRulePreset(
    id: 'precision-grid',
    label: 'Precision Grid',
    description: '20px snapping grid for pixel-aligned layouts.',
    layoutMechanism: LayoutMechanism.grid,
    gridSize: 20,
    snapToGrid: true,
    showGrid: true,
  ),
  LayoutRulePreset(
    id: 'dense-grid',
    label: 'Dense Grid',
    description: '12px snapping grid for compact tools and dashboards.',
    layoutMechanism: LayoutMechanism.grid,
    gridSize: 12,
    snapToGrid: true,
    showGrid: true,
  ),
  LayoutRulePreset(
    id: 'responsive-columns',
    label: 'Responsive Columns',
    description: '12-column tabular layout for responsive pages.',
    layoutMechanism: LayoutMechanism.tabularColumns,
    gridSize: 24,
    snapToGrid: true,
    showGrid: true,
    tabularColumnCount: 12,
    tabularColumnGap: 24,
    tabularRowHeight: 72,
  ),
  LayoutRulePreset(
    id: 'form-columns',
    label: 'Form Columns',
    description: '8-column tabular layout for forms and admin pages.',
    layoutMechanism: LayoutMechanism.tabularColumns,
    gridSize: 16,
    snapToGrid: true,
    showGrid: true,
    tabularColumnCount: 8,
    tabularColumnGap: 16,
    tabularRowHeight: 64,
  ),
  LayoutRulePreset(
    id: 'auto-cards',
    label: 'Auto Cards',
    description: 'Auto Grid tuned for card-based dashboard blocks.',
    layoutMechanism: LayoutMechanism.autoGrid,
    gridSize: 16,
    snapToGrid: true,
    showGrid: true,
    autoGridColumnCount: 4,
    autoGridGap: 16,
    autoGridRowHeight: 140,
  ),
  LayoutRulePreset(
    id: 'auto-dense',
    label: 'Auto Dense',
    description: 'Compact Auto Grid for dense operational surfaces.',
    layoutMechanism: LayoutMechanism.autoGrid,
    gridSize: 12,
    snapToGrid: true,
    showGrid: true,
    autoGridColumnCount: 6,
    autoGridGap: 12,
    autoGridRowHeight: 96,
  ),
];

bool _sameDouble(double left, double right) {
  return (left - right).abs() < 0.01;
}
