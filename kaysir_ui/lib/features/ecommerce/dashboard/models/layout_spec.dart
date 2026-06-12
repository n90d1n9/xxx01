enum LayoutMode { compact, standard, sidePanel }

typedef LayoutSpecBuilder = LayoutSpec Function(double maxWidth);

class LayoutSpec {
  static const double standardBreakpoint = 640;
  static const double sidePanelBreakpoint = 980;
  static const double compactPadding = 12;
  static const double standardPadding = 16;
  static const double compactActionPanelWidth = 320;
  static const double sideActionPanelWidth = 360;

  final LayoutMode mode;
  final double contentPadding;
  final double actionPanelWidth;

  const LayoutSpec({
    required this.mode,
    required this.contentPadding,
    required this.actionPanelWidth,
  });

  factory LayoutSpec.fromWidth(double maxWidth) {
    if (maxWidth >= sidePanelBreakpoint) {
      return const LayoutSpec(
        mode: LayoutMode.sidePanel,
        contentPadding: standardPadding,
        actionPanelWidth: sideActionPanelWidth,
      );
    }

    if (maxWidth >= standardBreakpoint) {
      return const LayoutSpec(
        mode: LayoutMode.standard,
        contentPadding: standardPadding,
        actionPanelWidth: compactActionPanelWidth,
      );
    }

    return const LayoutSpec(
      mode: LayoutMode.compact,
      contentPadding: compactPadding,
      actionPanelWidth: compactActionPanelWidth,
    );
  }

  bool get usesSidePanel => mode == LayoutMode.sidePanel;
}
