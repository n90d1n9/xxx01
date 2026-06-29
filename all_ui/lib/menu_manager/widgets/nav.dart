import 'package:flutter/material.dart';

import '../models/menu_item.dart';

class NavigationSidebar extends StatelessWidget {
  final List<MenuItem> menuItems;
  final Function(MenuItem) onItemSelected;
  final VoidCallback? onEditMenu;

  const NavigationSidebar({
    Key? key,
    required this.menuItems,
    required this.onItemSelected,
    this.onEditMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo or Brand Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu Manager',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                if (onEditMenu != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditMenu,
                    tooltip: 'Edit Menu',
                  ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  onTap: () => onItemSelected(item),
                  selected:
                      true, // You can modify this based on selection logic
                  selectedTileColor: Colors.blue[50],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
