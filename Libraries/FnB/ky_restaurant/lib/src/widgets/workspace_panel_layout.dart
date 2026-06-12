import 'package:flutter/material.dart';

import 'restaurant_spaced_list.dart';

/// Arranges workspace panels as a single stack or balanced two-column layout.
class RestaurantWorkspacePanelLayout extends StatelessWidget {
  const RestaurantWorkspacePanelLayout({
    super.key,
    required this.panels,
    this.wideBreakpoint = 980,
    this.columnSpacing = 16,
    this.panelSpacing = 16,
  });

  final List<Widget> panels;
  final double wideBreakpoint;
  final double columnSpacing;
  final double panelSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < wideBreakpoint) {
          return RestaurantWorkspacePanelColumn(
            panels: panels,
            spacing: panelSpacing,
          );
        }

        final left = panels.take((panels.length / 2).ceil()).toList();
        final right = panels.skip(left.length).toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RestaurantWorkspacePanelColumn(
                panels: left,
                spacing: panelSpacing,
              ),
            ),
            SizedBox(width: columnSpacing),
            Expanded(
              child: RestaurantWorkspacePanelColumn(
                panels: right,
                spacing: panelSpacing,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Displays a vertical stack of workspace panels with consistent spacing.
class RestaurantWorkspacePanelColumn extends StatelessWidget {
  const RestaurantWorkspacePanelColumn({
    super.key,
    required this.panels,
    this.spacing = 16,
  });

  final List<Widget> panels;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<Widget>(
      items: panels,
      spacing: spacing,
      itemBuilder: (context, panel, index) => panel,
    );
  }
}
