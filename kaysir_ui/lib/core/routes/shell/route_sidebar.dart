import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/core/features/features_registry.dart';

import 'route_shell_layout.dart';
import 'route_shell_metadata.dart';

/// Sidebar navigation for the route shell, supporting drawer and compact modes.
class AppRouteSidebar extends StatelessWidget {
  const AppRouteSidebar({
    super.key,
    required this.displayMode,
    this.isDrawer = false,
    this.currentPath,
  });

  final RouteSidebarDisplayMode displayMode;
  final bool isDrawer;
  final String? currentPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routes = FeaturesRegistry.getFeatures();
    final isCompact = displayMode == RouteSidebarDisplayMode.compact;

    return Material(
      color: colorScheme.surface,
      child: Container(
        width:
            isDrawer
                ? RouteShellLayout.expandedSidebarWidth
                : (isCompact
                    ? RouteShellLayout.compactSidebarWidth
                    : RouteShellLayout.expandedSidebarWidth),
        decoration: BoxDecoration(
          border:
              isDrawer
                  ? null
                  : Border(
                    right: BorderSide(color: colorScheme.outlineVariant),
                  ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SidebarBrand(isCompact: isCompact),
            Expanded(
              child:
                  isCompact
                      ? _CompactRouteList(
                        routes: routes,
                        currentPath: currentPath,
                      )
                      : _ExpandedRouteList(
                        routes: routes,
                        isDrawer: isDrawer,
                        currentPath: currentPath,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Route sidebar')
Widget appRouteSidebarPreview() {
  return const MaterialApp(
    home: SizedBox(
      width: RouteShellLayout.expandedSidebarWidth,
      child: AppRouteSidebar(displayMode: RouteSidebarDisplayMode.expanded),
    ),
  );
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final mark = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.point_of_sale_rounded,
        color: colorScheme.onPrimaryContainer,
      ),
    );

    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
        child: Tooltip(message: 'Kaysir', child: mark),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          mark,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaysir',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Workspace',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedRouteList extends StatelessWidget {
  const _ExpandedRouteList({
    required this.routes,
    required this.isDrawer,
    this.currentPath,
  });

  final List<FeatureRoutes> routes;
  final bool isDrawer;
  final String? currentPath;

  @override
  Widget build(BuildContext context) {
    final selectedPath = _selectedVisiblePath(routes, context, currentPath);
    final selectedLocation = _selectedLocation(context, currentPath);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        for (final route in routes)
          if (routeShellIsVisible(route) && routeShellHasOpenRoute(route))
            _SidebarRouteNode(
              route: route,
              isDrawer: isDrawer,
              selectedPath: selectedPath,
              selectedLocation: selectedLocation,
            ),
      ],
    );
  }
}

class _CompactRouteList extends StatelessWidget {
  const _CompactRouteList({required this.routes, this.currentPath});

  final List<FeatureRoutes> routes;
  final String? currentPath;

  @override
  Widget build(BuildContext context) {
    final flattened = routeShellVisibleNavigableRoutes(routes);
    final selectedPath = _selectedVisiblePath(routes, context, currentPath);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: flattened.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder:
          (context, index) => _CompactRouteTile(
            route: flattened[index],
            selectedPath: selectedPath,
          ),
    );
  }
}

class _SidebarRouteNode extends StatelessWidget {
  const _SidebarRouteNode({
    required this.route,
    required this.isDrawer,
    required this.selectedPath,
    required this.selectedLocation,
    this.depth = 0,
  });

  final FeatureRoutes route;
  final bool isDrawer;
  final String? selectedPath;
  final String selectedLocation;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final children = routeShellVisibleChildren(
      route,
    ).where(routeShellHasOpenRoute).toList(growable: false);
    final label = routeShellLabel(route);

    if (children.isNotEmpty) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: routeShellIsSelectedBranchForPath(
            route,
            selectedLocation,
          ),
          tilePadding: EdgeInsets.only(left: 8 + (depth * 12), right: 8),
          leading: _RouteIcon(route: route),
          title: Text(label, overflow: TextOverflow.ellipsis),
          children: [
            if (routeShellCanOpen(route))
              _ExpandedRouteTile(
                route: route,
                depth: depth + 1,
                isDrawer: isDrawer,
                label: 'Overview',
                selectedPath: selectedPath,
              ),
            for (final child in children)
              _SidebarRouteNode(
                route: child,
                depth: depth + 1,
                isDrawer: isDrawer,
                selectedPath: selectedPath,
                selectedLocation: selectedLocation,
              ),
          ],
        ),
      );
    }

    if (!routeShellCanOpen(route)) return const SizedBox.shrink();

    return _ExpandedRouteTile(
      route: route,
      depth: depth,
      isDrawer: isDrawer,
      selectedPath: selectedPath,
    );
  }
}

class _ExpandedRouteTile extends StatelessWidget {
  const _ExpandedRouteTile({
    required this.route,
    required this.depth,
    required this.isDrawer,
    required this.selectedPath,
    this.label,
  });

  final FeatureRoutes route;
  final int depth;
  final bool isDrawer;
  final String? selectedPath;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = route.path;
    final canOpen = routeShellCanOpen(route);
    final selected =
        canOpen && path != null && path.trim() == selectedPath?.trim();

    return Padding(
      padding: EdgeInsets.only(left: depth * 12),
      child: ListTile(
        key: ValueKey('route-sidebar-expanded-${path ?? route.id}'),
        dense: true,
        selected: selected,
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: _RouteIcon(route: route),
        title: Text(
          label ?? routeShellLabel(route),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle:
            route.subtitle == null
                ? null
                : Text(route.subtitle!, overflow: TextOverflow.ellipsis),
        onTap:
            !canOpen || path == null || path.trim().isEmpty
                ? null
                : () => _goToRoute(context, path, closeDrawer: isDrawer),
      ),
    );
  }
}

class _CompactRouteTile extends StatelessWidget {
  const _CompactRouteTile({required this.route, required this.selectedPath});

  final FeatureRoutes route;
  final String? selectedPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = route.path;
    final canOpen = routeShellCanOpen(route);
    final selected =
        canOpen && path != null && path.trim() == selectedPath?.trim();

    return Tooltip(
      message: routeShellLabel(route),
      child: IconButton(
        key: ValueKey('route-sidebar-compact-${path ?? route.id}'),
        isSelected: selected,
        selectedIcon: Icon(routeShellIconData(route)),
        icon: Icon(routeShellIconData(route)),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(48),
          minimumSize: const Size.square(48),
          foregroundColor:
              selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
          backgroundColor:
              selected ? colorScheme.primaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            !canOpen || path == null || path.trim().isEmpty
                ? null
                : () => _goToRoute(context, path),
      ),
    );
  }
}

class _RouteIcon extends StatelessWidget {
  const _RouteIcon({required this.route});

  final FeatureRoutes route;

  @override
  Widget build(BuildContext context) {
    return Icon(routeShellIconData(route), size: 20);
  }
}

void _goToRoute(BuildContext context, String path, {bool closeDrawer = false}) {
  if (closeDrawer) Scaffold.maybeOf(context)?.closeDrawer();
  if (routeShellCurrentLocation(context) != path) context.go(path);
}

String? _selectedVisiblePath(
  List<FeatureRoutes> routes,
  BuildContext context,
  String? currentPath,
) {
  final path = currentPath?.trim();
  final selectedRoute =
      path == null || path.isEmpty
          ? routeShellSelectedVisibleRoute(routes, context)
          : routeShellSelectedVisibleRouteForPath(routes, path);
  return selectedRoute?.path;
}

String _selectedLocation(BuildContext context, String? currentPath) {
  final path = currentPath?.trim();
  if (path != null && path.isNotEmpty) return path;
  return routeShellCurrentLocation(context);
}
