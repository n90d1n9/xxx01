enum POSShellActionDensity { compact, balanced, expanded }

class POSShellActionLayout {
  static const double compactBreakpoint = 760;
  static const double expandedBreakpoint = 1180;

  final POSShellActionDensity density;
  final bool showTerminalInline;
  final bool showSecondaryActionsInline;

  const POSShellActionLayout({
    required this.density,
    required this.showTerminalInline,
    required this.showSecondaryActionsInline,
  });

  factory POSShellActionLayout.resolve(double width) {
    if (width < compactBreakpoint) {
      return const POSShellActionLayout(
        density: POSShellActionDensity.compact,
        showTerminalInline: false,
        showSecondaryActionsInline: false,
      );
    }

    if (width < expandedBreakpoint) {
      return const POSShellActionLayout(
        density: POSShellActionDensity.balanced,
        showTerminalInline: true,
        showSecondaryActionsInline: false,
      );
    }

    return const POSShellActionLayout(
      density: POSShellActionDensity.expanded,
      showTerminalInline: true,
      showSecondaryActionsInline: true,
    );
  }
}
