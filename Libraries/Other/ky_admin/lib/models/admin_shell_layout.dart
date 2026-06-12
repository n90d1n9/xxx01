enum AdminShellDensity { compact, comfortable, spacious }

class AdminShellLayout {
  const AdminShellLayout({
    required this.density,
    required this.useDrawerNavigation,
    required this.showExpandedSearch,
    required this.showAccountCopy,
    required this.showFooterStatus,
    required this.showFooterLinks,
    required this.headerHeight,
    required this.footerHeight,
    required this.horizontalPadding,
  });

  final AdminShellDensity density;
  final bool useDrawerNavigation;
  final bool showExpandedSearch;
  final bool showAccountCopy;
  final bool showFooterStatus;
  final bool showFooterLinks;
  final double headerHeight;
  final double footerHeight;
  final double horizontalPadding;

  bool get isCompact => density == AdminShellDensity.compact;
}
