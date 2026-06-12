class ResponsiveGridSystem {
  static const breakpoints = {
    'xs': 0,
    'sm': 576,
    'md': 768,
    'lg': 992,
    'xl': 1200,
    'xxl': 1400,
  };

  static String getCurrentBreakpoint(double width) {
    if (width >= breakpoints['xxl']!) return 'xxl';
    if (width >= breakpoints['xl']!) return 'xl';
    if (width >= breakpoints['lg']!) return 'lg';
    if (width >= breakpoints['md']!) return 'md';
    if (width >= breakpoints['sm']!) return 'sm';
    return 'xs';
  }

  static int getColumns(String breakpoint) {
    switch (breakpoint) {
      case 'xxl':
      case 'xl':
        return 12;
      case 'lg':
        return 12;
      case 'md':
        return 8;
      case 'sm':
        return 4;
      case 'xs':
        return 2;
      default:
        return 12;
    }
  }
}

class GridConfig {
  final Map<String, int> columnSpan; // breakpoint -> columns
  final Map<String, int> columnOffset;
  final Map<String, bool> hidden;
  final String alignment; // start, center, end, stretch
  final double gap;

  const GridConfig({
    this.columnSpan = const {'xs': 12},
    this.columnOffset = const {},
    this.hidden = const {},
    this.alignment = 'stretch',
    this.gap = 16,
  });

  GridConfig copyWith({
    Map<String, int>? columnSpan,
    Map<String, int>? columnOffset,
    Map<String, bool>? hidden,
    String? alignment,
    double? gap,
  }) {
    return GridConfig(
      columnSpan: columnSpan ?? this.columnSpan,
      columnOffset: columnOffset ?? this.columnOffset,
      hidden: hidden ?? this.hidden,
      alignment: alignment ?? this.alignment,
      gap: gap ?? this.gap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'columnSpan': columnSpan,
      'columnOffset': columnOffset,
      'hidden': hidden,
      'alignment': alignment,
      'gap': gap,
    };
  }
}
