import 'dart:ui';

enum BuilderBreakpoint {
  mobile(
    key: 'mobile',
    label: 'Mobile',
    maxWidth: 600,
    previewSize: Size(390, 844),
  ),
  tablet(
    key: 'tablet',
    label: 'Tablet',
    maxWidth: 1024,
    previewSize: Size(768, 1024),
  ),
  desktop(
    key: 'desktop',
    label: 'Desktop',
    maxWidth: 1440,
    previewSize: Size(1200, 760),
  ),
  wide(
    key: 'wide',
    label: 'Wide',
    maxWidth: double.infinity,
    previewSize: Size(1440, 900),
  );

  const BuilderBreakpoint({
    required this.key,
    required this.label,
    required this.maxWidth,
    required this.previewSize,
  });

  final String key;
  final String label;
  final double maxWidth;
  final Size previewSize;

  static BuilderBreakpoint fromKey(String? key) {
    return BuilderBreakpoint.values.firstWhere(
      (breakpoint) => breakpoint.key == key || breakpoint.name == key,
      orElse: () => BuilderBreakpoint.desktop,
    );
  }

  static BuilderBreakpoint forWidth(double width) {
    return BuilderBreakpoint.values.firstWhere(
      (breakpoint) => width <= breakpoint.maxWidth,
      orElse: () => BuilderBreakpoint.wide,
    );
  }
}
