/// Available sidebar presentations for the responsive route shell.
enum RouteSidebarDisplayMode { expanded, compact }

/// Breakpoint and width rules for the application route shell.
class RouteShellLayout {
  const RouteShellLayout._({
    required this.usesDrawer,
    required this.sidebarDisplayMode,
  });

  static const drawerBreakpoint = 760.0;
  static const compactBreakpoint = 1120.0;
  static const expandedSidebarWidth = 288.0;
  static const compactSidebarWidth = 84.0;

  /// Whether the sidebar should move into a drawer at this width.
  final bool usesDrawer;

  /// The non-drawer sidebar presentation for this width.
  final RouteSidebarDisplayMode sidebarDisplayMode;

  /// Whether the sidebar should render icon-only navigation.
  bool get isCompact => sidebarDisplayMode == RouteSidebarDisplayMode.compact;

  /// Width reserved by the sidebar in the current display mode.
  double get sidebarWidth =>
      isCompact ? compactSidebarWidth : expandedSidebarWidth;

  /// Resolves shell chrome behavior for the provided logical viewport width.
  static RouteShellLayout fromWidth(double width) {
    if (width < drawerBreakpoint) {
      return const RouteShellLayout._(
        usesDrawer: true,
        sidebarDisplayMode: RouteSidebarDisplayMode.expanded,
      );
    }

    if (width < compactBreakpoint) {
      return const RouteShellLayout._(
        usesDrawer: false,
        sidebarDisplayMode: RouteSidebarDisplayMode.compact,
      );
    }

    return const RouteShellLayout._(
      usesDrawer: false,
      sidebarDisplayMode: RouteSidebarDisplayMode.expanded,
    );
  }
}
