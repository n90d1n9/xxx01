import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/menu_item.dart';

class SidebarItem extends StatelessWidget {
  final MenuItem item;
  final bool isMinimized;
  const SidebarItem({super.key, required this.item, required this.isMinimized});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.children.isEmpty) {
      return _buildSimpleMenuItem(isMinimized, item, context);
    }

    // In minimized mode, show parent menu items as simple items with tooltip
    if (isMinimized) {
      return Tooltip(
        message: item.title,
        child: ListTile(
          leading: Icon(item.icon, size: 24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            // Show submenu in a popup or expand sidebar temporarily
            _showSubmenuPopup(context, item);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return ExpansionTile(
      leading: Icon(item.icon, size: 24),
      title: Text(item.title),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.only(left: 32),
      children: item.children.map((child) {
        return _buildSimpleMenuItem(isMinimized, child, context);
      }).toList(),
    );
  }

  Widget _buildSimpleMenuItem(
      bool isMinimized, MenuItem item, BuildContext context) {
    return Tooltip(
      message: isMinimized ? item.title : '',
      child: ListTile(
        leading: Icon(item.icon, size: 20),
        title: isMinimized ? null : Text(item.title),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {
          if (item.route != null) {
            // Navigate using your existing routing mechanism
            context.go(item.route!);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSubmenuPopup(
    BuildContext context,
    MenuItem item,
  ) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + 80, // Sidebar width + some padding
        position.dy,
        position.dx + 300,
        position.dy + 200,
      ),
      items: item.children.map((child) {
        return PopupMenuItem<String>(
          value: child.route,
          child: Row(
            children: [
              Icon(child.icon, size: 20),
              const SizedBox(width: 12),
              Text(child.title),
            ],
          ),
        );
      }).toList(),
    ).then((route) {
      if (route != null) {
        // Navigate to the selected route
        // context.go(route);
      }
    });
  }
}
