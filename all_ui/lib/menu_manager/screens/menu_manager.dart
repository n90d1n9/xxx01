import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/menu_item.dart';
import '../states/menu_provider.dart';
import '../widgets/custom.dart';
import '../widgets/nav.dart';

class MenuManagerScreen extends ConsumerStatefulWidget {
  const MenuManagerScreen({Key? key}) : super(key: key);

  @override
  _MenuManagerScreenState createState() => _MenuManagerScreenState();
}

class _MenuManagerScreenState extends ConsumerState<MenuManagerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuProvider);
    final selectedItem = ref.watch(selectedMenuItemProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Sidebar
              if (constraints.maxWidth > 600)
                NavigationSidebar(
                  menuItems: menuItems,
                  onItemSelected: (item) {
                    ref.read(selectedMenuItemProvider.notifier).state = item;
                  },
                  onEditMenu: () => _showMenuEditDialog(context, ref),
                ),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top Toolbar
                    const CustomAppBar(),

                    // Content Area
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            selectedItem?.title ?? 'Select a menu item',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenuItemDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Menu Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _routeController,
                  decoration: const InputDecoration(labelText: 'Route'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final newItem = MenuItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    icon: Icons.menu_outlined,
                    route: _routeController.text,
                  );
                  ref.read(menuProvider.notifier).addMenuItem(newItem);

                  // Clear controllers
                  _titleController.clear();
                  _routeController.clear();

                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showMenuEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Manage Menu Items'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ref.read(menuProvider).length,
                itemBuilder: (context, index) {
                  final item = ref.read(menuProvider)[index];
                  return ListTile(
                    title: Text(item.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Implement edit functionality
                            _showEditItemDialog(context, ref, item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              item.isEditable
                                  ? () => ref
                                      .read(menuProvider.notifier)
                                      .removeMenuItem(item.id)
                                  : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showEditItemDialog(BuildContext context, WidgetRef ref, MenuItem item) {
    final titleController = TextEditingController(text: item.title);
    final routeController = TextEditingController(text: item.route);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Menu Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: routeController,
                  decoration: const InputDecoration(labelText: 'Route'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final updatedItem = MenuItem(
                    id: item.id,
                    title: titleController.text,
                    icon: item.icon,
                    route: routeController.text,
                    isEditable: item.isEditable,
                    isVisible: item.isVisible,
                  );

                  ref.read(menuProvider.notifier).updateMenuItem(updatedItem);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
