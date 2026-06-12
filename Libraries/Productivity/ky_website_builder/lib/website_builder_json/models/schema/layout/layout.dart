import '../styles/spacing.dart';

/// Layout configuration for sections and components
class Layout {
  final String type; // flex, grid, stack, absolute, flow
  final String? direction; // row, column, row-reverse, column-reverse
  final String? alignment; // start, center, end, stretch, space-between, etc.
  final String? justifyContent;
  final String? alignItems;
  final Spacing? spacing;
  final Spacing? padding;
  final int? columns; // For grid layout
  final int? rows; // For grid layout
  final String? gap;
  final Map<String, dynamic>? gridTemplate; // Advanced grid configurations
  final Map<String, dynamic>? customProps;

  Layout({
    required this.type,
    this.direction,
    this.alignment,
    this.justifyContent,
    this.alignItems,
    this.spacing,
    this.padding,
    this.columns,
    this.rows,
    this.gap,
    this.gridTemplate,
    this.customProps,
  });

  factory Layout.fromJson(Map<String, dynamic> json) {
    return Layout(
      type: json['type'] as String,
      direction: json['direction'] as String?,
      alignment: json['alignment'] as String?,
      justifyContent: json['justifyContent'] as String?,
      alignItems: json['alignItems'] as String?,
      spacing:
          json['spacing'] != null
              ? Spacing.fromJson(json['spacing'] as Map<String, dynamic>)
              : null,
      padding:
          json['padding'] != null
              ? Spacing.fromJson(json['padding'] as Map<String, dynamic>)
              : null,
      columns: json['columns'] as int?,
      rows: json['rows'] as int?,
      gap: json['gap'] as String?,
      gridTemplate: json['gridTemplate'] as Map<String, dynamic>?,
      customProps: json['customProps'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (direction != null) 'direction': direction,
    if (alignment != null) 'alignment': alignment,
    if (justifyContent != null) 'justifyContent': justifyContent,
    if (alignItems != null) 'alignItems': alignItems,
    if (spacing != null) 'spacing': spacing!.toJson(),
    if (padding != null) 'padding': padding!.toJson(),
    if (columns != null) 'columns': columns,
    if (rows != null) 'rows': rows,
    if (gap != null) 'gap': gap,
    if (gridTemplate != null) 'gridTemplate': gridTemplate,
    if (customProps != null) 'customProps': customProps,
  };
}
