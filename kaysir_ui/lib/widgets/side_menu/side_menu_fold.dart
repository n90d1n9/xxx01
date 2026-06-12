import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/features/feature_routes.dart';
import '../../utils/helper.dart';

class SideMenuFold extends StatelessWidget {
  const SideMenuFold({
    super.key,
    this.floatingActionButton,
    required this.menuItems,
    this.onMenuClick,
    this.currentIndex,
    this.currentPath,
  });
  final Widget? floatingActionButton;
  final List<FeatureRoutes>? menuItems;
  final void Function(FeatureRoutes)? onMenuClick;
  final int? currentIndex;
  final String? currentPath;

  @override
  Widget build(BuildContext context) {
    final items = _leafMenuItems(menuItems ?? const <FeatureRoutes>[]);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndexFromPath = _selectedIndexForPath(items, currentPath);
    final selectedIndex =
        selectedIndexFromPath ??
        (currentIndex != null &&
                currentIndex! >= 0 &&
                currentIndex! < items.length
            ? currentIndex
            : null);

    if (items.length == 1) {
      final item = items.single;
      final title = item.title ?? item.name ?? 'Untitled';
      final selected = selectedIndex == 0;

      return SafeArea(
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              if (floatingActionButton != null) floatingActionButton!,
              Tooltip(
                message: title,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withValues(alpha: .6)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: item.iconWidget ?? getIcon(item.icon ?? 'home'),
                    onPressed:
                        onMenuClick == null ? null : () => onMenuClick!(item),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SizedBox(
        width: 72,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportHeight =
                constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : MediaQuery.sizeOf(context).height;
            final estimatedRailHeight =
                (items.length * 72.0) + (floatingActionButton == null ? 0 : 72);

            return SingleChildScrollView(
              child: SizedBox(
                height: math.max(viewportHeight, estimatedRailHeight),
                child: NavigationRail(
                  minWidth: 50,
                  minExtendedWidth: 70,
                  leading: floatingActionButton,
                  destinations: [
                    ...items.map((d) {
                      final title = d.title ?? d.name ?? 'Untitled';

                      return NavigationRailDestination(
                        icon: Tooltip(
                          message: title,
                          child: d.iconWidget ?? getIcon(d.icon ?? 'home'),
                        ),
                        label: Text(title),
                      );
                    }),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected:
                      onMenuClick == null
                          ? null
                          : (index) => onMenuClick!(items[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<FeatureRoutes> _leafMenuItems(List<FeatureRoutes> items) {
    final flattened = <FeatureRoutes>[];
    for (final item in items) {
      if (item.items.isEmpty) {
        flattened.add(item);
        continue;
      }
      final path = item.path?.trim();
      if (path != null && path.isNotEmpty) {
        flattened.add(item);
      }
      flattened.addAll(_leafMenuItems(item.items));
    }
    return flattened;
  }

  int? _selectedIndexForPath(List<FeatureRoutes> items, String? currentPath) {
    final normalizedCurrentPath = _normalizedPath(currentPath);
    if (normalizedCurrentPath == null) return null;

    final exactIndex = items.indexWhere(
      (item) => _normalizedPath(item.path) == normalizedCurrentPath,
    );
    if (exactIndex >= 0) return exactIndex;

    final parentIndex = items.indexWhere(
      (item) => _matchesPath(item.path, normalizedCurrentPath),
    );
    return parentIndex >= 0 ? parentIndex : null;
  }
}

String? _normalizedPath(String? path) {
  final trimmed = path?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  final normalized = uri?.path.trim() ?? trimmed;
  return normalized.isEmpty ? null : normalized;
}

bool _matchesPath(String? routePath, String currentPath) {
  final path = _normalizedPath(routePath);
  if (path == null) return false;
  if (path == currentPath) return true;
  if (path == '/') return currentPath == '/';
  return currentPath.startsWith('$path/');
}
