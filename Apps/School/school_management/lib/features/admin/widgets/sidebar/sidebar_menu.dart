import 'package:flutter/material.dart';

import '../../../../core/features/feature_routes.dart';
import '../../states/sidebar_provider.dart';

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
    this.backgroundColor = Colors.white,
    this.accentColor,
    this.selectedMenu,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.displayMode = SidebarMode.expanded,
    this.enableTooltips = true,
    this.onToggleDisplayMode,
  });

  @override
  _SidebarMenuWidgetState createState() => _SidebarMenuWidgetState();
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
    // Use a unique identifier for each menu item
    final itemId = item.id ?? item.title.hashCode;
    return _expandedItems[itemId] ?? false;
  }

  void _toggleExpanded(FeatureRoutes item) {
    final itemId = item.id ?? item.title.hashCode;

    print('>>>>>  $itemId  \n $item');
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
    final backgroundColor = widget.backgroundColor ?? theme.cardColor;
    final accentColor = widget.accentColor ?? theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Column(
          // Fix: Set mainAxisSize to min to prevent the Column from trying to expand to infinity
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onToggleDisplayMode != null)
              _buildDisplayModeToggle(context, accentColor),
            // Fix: Use Flexible instead of Expanded with a fit of FlexFit.loose
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true, // Make ListView wrap its content
                physics: const BouncingScrollPhysics(),
                children: _buildMenuItems(
                  widget.menuItems,
                  accentColor,
                  backgroundColor,
                  0,
                  true,
                ),
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

  Widget _buildMenuItem(
    FeatureRoutes item,
    Color accentColor,
    Color backgroundColor,
    int depth,
  ) {
    final bool isSelected =
        _selectedMenu?.id == item.id || _selectedMenu?.path == item.path;
    final bool hasChildren = item.items.isNotEmpty;
    final bool isExpanded = _isExpanded(item);

    // Compact mode only shows top-level items or direct children of expanded items
    if (widget.displayMode == SidebarMode.compact && depth > 0) {
      // Only show children of expanded parents in compact mode
      bool isChildOfExpanded = false;
      if (depth == 1) {
        // Find this item's parent
        for (var parentItem in widget.menuItems) {
          if (parentItem.items.any((childItem) => childItem.id == item.id)) {
            isChildOfExpanded = _isExpanded(parentItem);
            break;
          }
        }
      }

      if (!isChildOfExpanded) {
        return const SizedBox.shrink();
      }
    }

    // Different padding for expanded vs compact mode
    final EdgeInsetsGeometry itemPadding =
        widget.displayMode == SidebarMode.expanded
            ? widget.padding.add(EdgeInsets.only(left: depth * 16.0))
            : EdgeInsets.only(
              top: 12.0,
              bottom: 12.0,
              right: 8.0,
              // Add left padding for children items even in compact mode
              left: depth > 0 ? 16.0 : 8.0,
            );

    Widget menuItemContent;

    if (widget.displayMode == SidebarMode.compact) {
      // Icon-only version with tooltip
      Widget iconWidget =
          item.iconWidget ??
          (item.icon != null
              ? Icon(
                IconData(int.parse(item.icon!), fontFamily: 'MaterialIcons'),
                color:
                    isSelected
                        ? accentColor
                        : Theme.of(context).iconTheme.color,
                size: 24,
              )
              : const Icon(Icons.circle, size: 8));

      menuItemContent = Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? accentColor.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            iconWidget,
            // Add small indicator for items with children
            if (hasChildren)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isExpanded ? accentColor : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      );

      // Wrap with tooltip if enabled
      if (widget.enableTooltips) {
        menuItemContent = Tooltip(
          message: item.title ?? item.name ?? '',
          waitDuration: const Duration(milliseconds: 500),
          showDuration: const Duration(seconds: 2),
          child: menuItemContent,
        );
      }
    } else {
      // Full expanded version
      menuItemContent = Row(
        children: [
          if (item.iconWidget != null) ...[
            item.iconWidget!,
            const SizedBox(width: 12),
          ] else if (item.icon != null) ...[
            Icon(
              IconData(int.parse(item.icon!), fontFamily: 'MaterialIcons'),
              color: isSelected ? accentColor : null,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title ?? item.name ?? '',
                    style: TextStyle(
                      color:
                          isSelected
                              ? accentColor
                              : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          if (hasChildren)
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodySmall?.color,
                size: 20,
              ),
            ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (hasChildren) {
            _toggleExpanded(item);
          }
          _selectMenu(item);
        },
        splashColor: accentColor.withValues(alpha: 0.1),
        highlightColor: accentColor.withValues(alpha: 0.05),
        borderRadius:
            widget.displayMode == SidebarMode.compact
                ? BorderRadius.circular(8)
                : null,
        child: Container(
          padding: itemPadding,
          decoration: BoxDecoration(
            color:
                widget.displayMode == SidebarMode.expanded && isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.transparent,
            border:
                widget.displayMode == SidebarMode.expanded
                    ? Border(
                      left: BorderSide(
                        color: isSelected ? accentColor : Colors.transparent,
                        width: 3,
                      ),
                    )
                    : null,
          ),
          child: menuItemContent,
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(
    List<FeatureRoutes> items,
    Color accentColor,
    Color backgroundColor,
    int depth, [
    bool isParent = true,
  ]) {
    final List<Widget> widgets = [];
    for (final item in items) {
      if (item.enabled != false) {
        widgets.add(_buildMenuItem(item, accentColor, backgroundColor, depth));

        // Allow children to be shown in both modes if the parent is expanded
        if (_isExpanded(item) && item.items.isNotEmpty && isParent) {
          widgets.addAll(
            _buildMenuItems(
              item.items,
              accentColor,
              backgroundColor,
              depth + 1,
              false,
            ),
          );
        }
      }
    }

    return widgets;
  }
}
