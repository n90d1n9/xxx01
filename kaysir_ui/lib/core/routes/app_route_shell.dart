import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../features/features_registry.dart';
import 'shell/route_search_dialog.dart';
import 'shell/route_shell_header.dart';
import 'shell/route_shell_layout.dart';
import 'shell/route_shell_shortcuts.dart';
import 'shell/route_sidebar.dart';

/// Responsive application shell that keeps navigation visible around feature routes.
class AppRouteShell extends StatelessWidget {
  const AppRouteShell({super.key, required this.child, this.currentLocation});

  final Widget child;
  final String? currentLocation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentRouteLocation = _locationFromInput(currentLocation);

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = RouteShellLayout.fromWidth(constraints.maxWidth);

        return RouteShellShortcuts(
          onSearchPressed:
              () => showRouteSearchDialog(
                context,
                features: FeaturesRegistry.getFeatures(),
              ),
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            drawer:
                layout.usesDrawer
                    ? Drawer(
                      width: RouteShellLayout.expandedSidebarWidth,
                      child: AppRouteSidebar(
                        displayMode: RouteSidebarDisplayMode.expanded,
                        isDrawer: true,
                        currentPath: currentRouteLocation,
                      ),
                    )
                    : null,
            body: SafeArea(
              child: Row(
                children: [
                  if (!layout.usesDrawer)
                    AppRouteSidebar(
                      displayMode: layout.sidebarDisplayMode,
                      currentPath: currentRouteLocation,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        RouteShellHeader(
                          layout: layout,
                          currentPath: currentRouteLocation,
                        ),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

@Preview(name: 'Route shell')
Widget appRouteShellPreview() {
  return const MaterialApp(
    home: AppRouteShell(child: Center(child: Text('Route content'))),
  );
}

String? _locationFromInput(String? location) {
  final value = location?.trim();
  if (value == null || value.isEmpty) return null;
  return Uri.tryParse(value)?.toString() ?? value;
}
