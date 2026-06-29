enum ResponsiveBreakpoint {
  mobile(maxWidth: 600),
  tablet(maxWidth: 1024),
  desktop(maxWidth: 1440),
  wide(maxWidth: double.infinity);

  final double maxWidth;
  const ResponsiveBreakpoint({required this.maxWidth});
}

enum ProjectStatus { idle, saving, loading, error }

enum CollaborationStatus { disconnected, connecting, connected }

enum LayoutMode { freeform, grid, flex, absolute }

enum AlignType {
  left,
  center,
  right,
  top,
  bottom,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}
