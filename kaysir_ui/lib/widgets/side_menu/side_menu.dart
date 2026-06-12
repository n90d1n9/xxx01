import 'package:flutter/material.dart';

import '../../core/features/feature_routes.dart';
import '../../utils/helper.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
    this.floatingActionButton,
    required this.menuItems,
    required this.onMenuClick,
    this.currentIndex,
    this.currentPath,
    this.title = const Text(''),
    this.width,
    this.image,
  });
  final Widget? floatingActionButton;
  final List<FeatureRoutes>? menuItems;
  final void Function(FeatureRoutes)? onMenuClick;
  final int? currentIndex;
  final String? currentPath;
  final Widget title;
  final double? width;
  final String? image;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final menuItems = widget.menuItems ?? const <FeatureRoutes>[];

    return Drawer(
      width: widget.width,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Side menu header
              DrawerHeader(
                child: Center(
                  child: Column(
                    children: [
                      if (widget.image == null)
                        const Icon(Icons.apps, size: 60)
                      else
                        Image.asset(widget.image!, width: 60, height: 60),
                      widget.title,
                    ],
                  ),
                ),
              ),

              // Menu list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildList(menuItems[index], topLevelIndex: index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(FeatureRoutes menu, {int? topLevelIndex}) {
    final title = menu.title ?? menu.name ?? 'Untitled';
    final selected = _isSelected(menu, topLevelIndex: topLevelIndex);
    final containsSelected = _containsSelectedRoute(menu);
    final theme = Theme.of(context);

    return menu.items.isEmpty
        ? Builder(
          builder: (context) {
            return ListTile(
              selected: selected,
              selectedTileColor: theme.colorScheme.primaryContainer.withValues(
                alpha: .5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap:
                  widget.onMenuClick == null
                      ? null
                      : () => widget.onMenuClick!(menu),
              leading:
                  menu.iconWidget ??
                  getIcon(
                    menu.icon ?? 'home',
                    color:
                        selected
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color ?? Colors.black,
                  ),
              title: Text(title),
            );
          },
        )
        : ExpansionTile(
          initiallyExpanded: containsSelected,
          leading:
              menu.iconWidget ??
              getIcon(
                menu.icon ?? 'home',
                color:
                    containsSelected
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color ?? Colors.black,
              ),
          title: Text(title),
          textColor: theme.colorScheme.primary,
          iconColor: theme.colorScheme.primary,
          onExpansionChanged: (expanded) {
            if (expanded && menu.path != null) {
              widget.onMenuClick?.call(menu);
            }
          },
          children: menu.items.map((item) => _buildList(item)).toList(),
        );
  }

  bool _isSelected(FeatureRoutes menu, {int? topLevelIndex}) {
    final currentPath = _normalizedPath(widget.currentPath);
    if (currentPath != null) {
      return _matchesPath(menu.path, currentPath);
    }

    return topLevelIndex != null && widget.currentIndex == topLevelIndex;
  }

  bool _containsSelectedRoute(FeatureRoutes menu) {
    final currentPath = _normalizedPath(widget.currentPath);
    if (currentPath == null) return false;

    if (_matchesPath(menu.path, currentPath)) return true;
    return menu.items.any(_containsSelectedRoute);
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
