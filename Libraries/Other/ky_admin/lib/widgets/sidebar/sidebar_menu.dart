import 'package:flutter/material.dart';

import '../../../../core/features/feature_routes.dart';
import '../../states/sidebar_provider.dart';
import 'sidebar_menu_tile.dart';

class SidebarMenuWidget extends StatefulWidget {
  final List<FeatureRoutes> menuItems;
  final Function(FeatureRoutes)? onMenuSelected;
  final Color? backgroundColor;
  final Color? accentColor;
  final FeatureRoutes? selectedMenu;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final SidebarMode displayMode;
  final bool enableTooltips;
  final Function()? onToggleDisplayMode;

  const SidebarMenuWidget({
    super.key,
    required this.menuItems,
    this.onMenuSelected,
    this.backgroundColor,
    this.accentColor,
    this.selectedMenu,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.displayMode = SidebarMode.expanded,
    this.enableTooltips = true,
    this.onToggleDisplayMode,
  });

  @override
  State<SidebarMenuWidget> createState() => _SidebarMenuWidgetState();
}

class _SidebarMenuWidgetState extends State<SidebarMenuWidget>
    with TickerProviderStateMixin {
  FeatureRoutes? _selectedMenu;
  final Map<int, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _selectedMenu = widget.selectedMenu;
  }

  @override
  void didUpdateWidget(SidebarMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMenu != oldWidget.selectedMenu) {
      _selectedMenu = widget.selectedMenu;
    }
  }

  bool _isExpanded(FeatureRoutes item) {
    final itemId = item.id;
    return _expandedItems[itemId] ?? _containsSelectedChild(item);
  }

  bool _containsSelectedChild(FeatureRoutes item) {
    return item.items.any(
      (child) =>
          _selectedMenu?.id == child.id ||
          _selectedMenu?.path == child.path ||
          _containsSelectedChild(child),
    );
  }

  void _toggleExpanded(FeatureRoutes item) {
    final itemId = item.id;

    setState(() {
      _expandedItems[itemId] = !(_expandedItems[itemId] ?? false);
    });
  }

  void _selectMenu(FeatureRoutes menu) {
    setState(() {
      _selectedMenu = menu;
    });
    widget.onMenuSelected?.call(menu);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final accentColor = widget.accentColor ?? theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onToggleDisplayMode != null)
              _buildDisplayModeToggle(context, accentColor),
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: _buildMenuItems(widget.menuItems, accentColor, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayModeToggle(BuildContext context, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: widget.onToggleDisplayMode,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.displayMode == SidebarMode.expanded
                    ? Icons.menu_open
                    : Icons.menu,
                size: 20,
                color: accentColor,
              ),
              if (widget.displayMode == SidebarMode.expanded) ...[
                const SizedBox(width: 8),
                Text(
                  "Collapse Menu",
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(FeatureRoutes item, Color accentColor, int depth) {
    final bool isSelected =
        _selectedMenu?.id == item.id || _selectedMenu?.path == item.path;
    final bool hasChildren = item.items.isNotEmpty;
    final bool isExpanded = _isExpanded(item);

    return SidebarMenuTile(
      item: item,
      displayMode: widget.displayMode,
      isSelected: isSelected,
      isExpanded: isExpanded,
      depth: depth,
      expandedPadding: widget.padding,
      accentColor: accentColor,
      enableTooltip: widget.enableTooltips,
      onTap: () {
        if (hasChildren) {
          _toggleExpanded(item);
        }
        if (item.path != null) {
          _selectMenu(item);
        }
      },
    );
  }

  List<Widget> _buildMenuItems(
    List<FeatureRoutes> items,
    Color accentColor,
    int depth,
  ) {
    final List<Widget> widgets = [];
    for (final item in items) {
      if (item.enabled != false &&
          item.position.contains(MenuPosition.sidebar)) {
        widgets.add(_buildMenuItem(item, accentColor, depth));

        // Allow children to be shown in both modes if the parent is expanded
        if (_isExpanded(item) && item.items.isNotEmpty) {
          widgets.addAll(_buildMenuItems(item.items, accentColor, depth + 1));
        }
      }
    }

    return widgets;
  }
}
