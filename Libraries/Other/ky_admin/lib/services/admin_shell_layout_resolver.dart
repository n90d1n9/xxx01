import '../models/admin_shell_layout.dart';
import '../states/sidebar_provider.dart';

abstract final class AdminShellBreakpoints {
  static const footerLinks = 620.0;
  static const accountCopy = 720.0;
  static const footerStatus = 760.0;
  static const drawerNavigation = 900.0;
  static const expandedSearch = 900.0;
}

abstract final class AdminShellDimensions {
  static const compactHeaderHeight = 64.0;
  static const comfortableHeaderHeight = 72.0;
  static const compactFooterHeight = 44.0;
  static const comfortableFooterHeight = 48.0;
  static const compactPadding = 12.0;
  static const comfortablePadding = 16.0;
  static const spaciousPadding = 20.0;
  static const sidebarCompactWidth = 76.0;
  static const sidebarExpandedWidth = 280.0;
}

AdminShellLayout resolveAdminShellLayout(double width) {
  final density =
      width < AdminShellBreakpoints.footerLinks
          ? AdminShellDensity.compact
          : width < AdminShellBreakpoints.drawerNavigation
          ? AdminShellDensity.comfortable
          : AdminShellDensity.spacious;

  return AdminShellLayout(
    density: density,
    useDrawerNavigation: width < AdminShellBreakpoints.drawerNavigation,
    showExpandedSearch: width >= AdminShellBreakpoints.expandedSearch,
    showAccountCopy: width > AdminShellBreakpoints.accountCopy,
    showFooterStatus: width >= AdminShellBreakpoints.footerStatus,
    showFooterLinks: width >= AdminShellBreakpoints.footerLinks,
    headerHeight:
        density == AdminShellDensity.compact
            ? AdminShellDimensions.compactHeaderHeight
            : AdminShellDimensions.comfortableHeaderHeight,
    footerHeight:
        density == AdminShellDensity.compact
            ? AdminShellDimensions.compactFooterHeight
            : AdminShellDimensions.comfortableFooterHeight,
    horizontalPadding:
        density == AdminShellDensity.compact
            ? AdminShellDimensions.compactPadding
            : density == AdminShellDensity.comfortable
            ? AdminShellDimensions.comfortablePadding
            : AdminShellDimensions.spaciousPadding,
  );
}

double resolveAdminSidebarWidth({
  required SidebarMode mode,
  required bool isDrawer,
}) {
  if (isDrawer || mode == SidebarMode.expanded) {
    return AdminShellDimensions.sidebarExpandedWidth;
  }

  return AdminShellDimensions.sidebarCompactWidth;
}
