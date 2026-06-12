import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

typedef PaneWidthBuilder = double Function(double availableWidth);

double defaultLeadingPaneWidth(double availableWidth) {
  return availableWidth >= 1100 ? 410 : 360;
}

class AdaptiveTwoPane extends StatelessWidget {
  final Widget leadingPane;
  final Widget mainPane;
  final double wideBreakpoint;
  final double maxContentWidth;
  final double gap;
  final double compactLeadingMaxHeightFactor;
  final bool scrollLeadingPane;
  final PaneWidthBuilder leadingPaneWidthBuilder;

  const AdaptiveTwoPane({
    super.key,
    required this.leadingPane,
    required this.mainPane,
    this.wideBreakpoint = 900,
    this.maxContentWidth = 1180,
    this.gap = POSUiTokens.gapLarge,
    this.compactLeadingMaxHeightFactor = 0.56,
    this.scrollLeadingPane = true,
    this.leadingPaneWidthBuilder = defaultLeadingPaneWidth,
  }) : assert(wideBreakpoint > 0),
       assert(maxContentWidth > 0),
       assert(gap >= 0),
       assert(compactLeadingMaxHeightFactor > 0),
       assert(compactLeadingMaxHeightFactor <= 1);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= wideBreakpoint) {
              return _WideTwoPaneLayout(
                leadingPane: leadingPane,
                mainPane: mainPane,
                gap: gap,
                leadingPaneWidth: _resolvedLeadingPaneWidth(
                  constraints.maxWidth,
                ),
                scrollLeadingPane: scrollLeadingPane,
              );
            }

            return _CompactTwoPaneLayout(
              leadingPane: leadingPane,
              mainPane: mainPane,
              gap: gap,
              leadingMaxHeight:
                  constraints.hasBoundedHeight
                      ? constraints.maxHeight * compactLeadingMaxHeightFactor
                      : double.infinity,
              mainHasBoundedHeight: constraints.hasBoundedHeight,
              scrollLeadingPane: scrollLeadingPane,
            );
          },
        ),
      ),
    );
  }

  double _resolvedLeadingPaneWidth(double availableWidth) {
    final maxLeadingWidth =
        availableWidth > gap ? availableWidth - gap : availableWidth;

    return leadingPaneWidthBuilder(
      availableWidth,
    ).clamp(0.0, maxLeadingWidth).toDouble();
  }
}

class _WideTwoPaneLayout extends StatelessWidget {
  final Widget leadingPane;
  final Widget mainPane;
  final double gap;
  final double leadingPaneWidth;
  final bool scrollLeadingPane;

  const _WideTwoPaneLayout({
    required this.leadingPane,
    required this.mainPane,
    required this.gap,
    required this.leadingPaneWidth,
    required this.scrollLeadingPane,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: leadingPaneWidth,
          child: _MaybeScrollablePane(
            enabled: scrollLeadingPane,
            child: leadingPane,
          ),
        ),
        SizedBox(width: gap),
        Expanded(child: mainPane),
      ],
    );
  }
}

class _CompactTwoPaneLayout extends StatelessWidget {
  final Widget leadingPane;
  final Widget mainPane;
  final double gap;
  final double leadingMaxHeight;
  final bool mainHasBoundedHeight;
  final bool scrollLeadingPane;

  const _CompactTwoPaneLayout({
    required this.leadingPane,
    required this.mainPane,
    required this.gap,
    required this.leadingMaxHeight,
    required this.mainHasBoundedHeight,
    required this.scrollLeadingPane,
  });

  @override
  Widget build(BuildContext context) {
    final boundedMainPane =
        mainHasBoundedHeight ? Expanded(child: mainPane) : mainPane;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: leadingMaxHeight),
          child: _MaybeScrollablePane(
            enabled: scrollLeadingPane,
            child: leadingPane,
          ),
        ),
        SizedBox(height: gap),
        boundedMainPane,
      ],
    );
  }
}

class _MaybeScrollablePane extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const _MaybeScrollablePane({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return SingleChildScrollView(child: child);
  }
}
