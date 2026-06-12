import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/admin/states/sidebar_provider.dart';
import 'submenu_item.dart';

class MenuItemWithSubmenu extends ConsumerStatefulWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isExpanded;
  final List<SubmenuItem> children;

  const MenuItemWithSubmenu({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = false,
    this.isExpanded = true,
    required this.children,
  });

  @override
  ConsumerState<MenuItemWithSubmenu> createState() =>
      _MenuItemWithSubmenuState();
}

class _MenuItemWithSubmenuState extends ConsumerState<MenuItemWithSubmenu> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSidebarExpanded = ref.watch(sidebarExpandedProvider);

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.isExpanded) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color:
                  widget.isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color:
                      widget.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color:
                            widget.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            widget.isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded && (widget.isExpanded || !isSidebarExpanded))
          Padding(
            padding: EdgeInsets.only(left: widget.isExpanded ? 30 : 0),
            child: Column(children: widget.children),
          ),
      ],
    );
  }
}
