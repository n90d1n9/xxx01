// Grid settings
class GridSettings {
  final bool enabled;
  final double spacing;
  final bool snapToGrid;

  GridSettings({
    this.enabled = true,
    this.spacing = 20.0,
    this.snapToGrid = true,
  });

  GridSettings copyWith({bool? enabled, double? spacing, bool? snapToGrid}) {
    return GridSettings(
      enabled: enabled ?? this.enabled,
      spacing: spacing ?? this.spacing,
      snapToGrid: snapToGrid ?? this.snapToGrid,
    );
  }
}
