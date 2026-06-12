import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// Menu Item Model
class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final String route;

  MenuItem({
    required this.id, 
    required this.title, 
    required this.icon, 
    required this.route
  });
}

// Menu Provider
final menuProvider = StateNotifierProvider<MenuNotifier, List<MenuItem>>((ref) {
  return MenuNotifier();
});

// Selected Menu Item Provider
final selectedMenuItemProvider = StateProvider<MenuItem?>((ref) => null);

// Menu Notifier
class MenuNotifier extends StateNotifier<List<MenuItem>> {
  MenuNotifier() : super([
    MenuItem(
      id: '1', 
      title: 'Dashboard', 
      icon: Icons.dashboard_outlined, 
      route: '/dashboard'
    ),
    MenuItem(
      id: '2', 
      title: 'Analytics', 
      icon: Icons.analytics_outlined, 
      route: '/analytics'
    ),
    MenuItem(
      id: '3', 
      title: 'Settings', 
      icon: Icons.settings_outlined, 
      route: '/settings'
    ),
  ]);

  void addMenuItem(MenuItem item) {
    state = [...state, item];
  }

  void removeMenuItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

class MenuManagerScreen extends ConsumerWidget {
  const MenuManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    );
  }
}

class NavigationSidebar extends StatelessWidget {
  final List<MenuItem> menuItems;
  final Function(MenuItem) onItemSelected;

  const NavigationSidebar({
    Key? key, 
    required this.menuItems,
    required this.onItemSelected,
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
            child: Text(
              'Menu Manager',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
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
                  selected: true, // You can modify this based on selection logic
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        'Menu Management',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: MenuManagerScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}