import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// MODELS
class Menu {
  final String id;
  final String name;
  final bool isActive;
  final List<MenuCategory> categories;

  Menu({
    required this.id,
    required this.name,
    required this.isActive,
    required this.categories,
  });

  Menu copyWith({
    String? id,
    String? name,
    bool? isActive,
    List<MenuCategory>? categories,
  }) {
    return Menu(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      categories: categories ?? this.categories,
    );
  }
}

class MenuCategory {
  final String id;
  final String name;
  final int displayOrder;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.items,
  });

  MenuCategory copyWith({
    String? id,
    String? name,
    int? displayOrder,
    List<MenuItem>? items,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      items: items ?? this.items,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;
  final String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    this.imageUrl,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// RIVERPOD STATE NOTIFIERS
class MenusNotifier extends StateNotifier<List<Menu>> {
  MenusNotifier()
    : super([
        Menu(
          id: '1',
          name: 'Lunch Menu',
          isActive: true,
          categories: [
            MenuCategory(
              id: '1',
              name: 'Appetizers',
              displayOrder: 1,
              items: [
                MenuItem(
                  id: '1',
                  name: 'Spinach Dip',
                  description: 'Creamy spinach dip with tortilla chips',
                  price: 8.99,
                  isAvailable: true,
                  imageUrl: 'https://example.com/spinach-dip.jpg',
                ),
                MenuItem(
                  id: '2',
                  name: 'Mozzarella Sticks',
                  description: 'Fried mozzarella with marinara sauce',
                  price: 7.99,
                  isAvailable: true,
                ),
              ],
            ),
            MenuCategory(
              id: '2',
              name: 'Main Courses',
              displayOrder: 2,
              items: [
                MenuItem(
                  id: '3',
                  name: 'Grilled Salmon',
                  description: 'Fresh salmon with vegetables',
                  price: 18.99,
                  isAvailable: true,
                  imageUrl: 'https://example.com/salmon.jpg',
                ),
              ],
            ),
          ],
        ),
        Menu(id: '2', name: 'Dinner Menu', isActive: false, categories: []),
      ]);

  void addMenu(Menu menu) {
    state = [...state, menu];
  }

  void updateMenu(Menu updatedMenu) {
    state =
        state
            .map((menu) => menu.id == updatedMenu.id ? updatedMenu : menu)
            .toList();
  }

  void deleteMenu(String menuId) {
    state = state.where((menu) => menu.id != menuId).toList();
  }

  void addCategory(String menuId, MenuCategory category) {
    state =
        state.map((menu) {
          if (menu.id == menuId) {
            return menu.copyWith(categories: [...menu.categories, category]);
          }
          return menu;
        }).toList();
  }

  void updateCategory(String menuId, MenuCategory updatedCategory) {
    state =
        state.map((menu) {
          if (menu.id == menuId) {
            return menu.copyWith(
              categories:
                  menu.categories
                      .map(
                        (category) =>
                            category.id == updatedCategory.id
                                ? updatedCategory
                                : category,
                      )
                      .toList(),
            );
          }
          return menu;
        }).toList();
  }

  void deleteCategory(String menuId, String categoryId) {
    state =
        state.map((menu) {
          if (menu.id == menuId) {
            return menu.copyWith(
              categories:
                  menu.categories
                      .where((category) => category.id != categoryId)
                      .toList(),
            );
          }
          return menu;
        }).toList();
  }

  void addMenuItem(String menuId, String categoryId, MenuItem item) {
    state =
        state.map((menu) {
          if (menu.id == menuId) {
            return menu.copyWith(
              categories:
                  menu.categories.map((category) {
                    if (category.id == categoryId) {
                      return category.copyWith(
                        items: [...category.items, item],
                      );
                    }
                    return category;
                  }).toList(),
            );
          }
          return menu;
        }).toList();
  }

  void updateMenuItem(String menuId, String categoryId, MenuItem updatedItem) {
    state =
        state.map((menu) {
          if (menu.id == menuId) {
            return menu.copyWith(
              categories:
                  menu.categories.map((category) {
                    if (category.id == categoryId) {
                      return category.copyWith(
                        items:
                            category.items
                                .map(
                                  (item) =>
                                      item.id == updatedItem.id
                                          ? updatedItem
                                          : item,
                                )
                                .toList(),
                      );
                    }
                    return category;
                  }).toList(),
            );
          }
          return menu;
        }).toList();
  }

  void deleteMenuItem(String menuId, String categoryId, String itemId) {
    state =
        state.map((menu) {
          if (menu.id == menuId) {
            return menu.copyWith(
              categories:
                  menu.categories.map((category) {
                    if (category.id == categoryId) {
                      return category.copyWith(
                        items:
                            category.items
                                .where((item) => item.id != itemId)
                                .toList(),
                      );
                    }
                    return category;
                  }).toList(),
            );
          }
          return menu;
        }).toList();
  }
}

// PROVIDERS
final menusProvider = StateNotifierProvider<MenusNotifier, List<Menu>>((ref) {
  return MenusNotifier();
});

final selectedMenuProvider = StateProvider<String?>((ref) => null);

// UI COMPONENTS
class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MenuManagementScreen> createState() =>
      _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Select the first menu by default if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menus = ref.read(menusProvider);
      if (menus.isNotEmpty) {
        ref.read(selectedMenuProvider.notifier).state = menus.first.id;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _menuNameController.dispose();
    _categoryNameController.dispose();
    _itemNameController.dispose();
    _itemDescController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menus = ref.watch(menusProvider);
    final selectedMenuId = ref.watch(selectedMenuProvider);

    final selectedMenu =
        menus.where((m) => m.id == selectedMenuId).isEmpty
            ? null
            : menus.firstWhere((m) => m.id == selectedMenuId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Menus'), Tab(text: 'Categories & Items')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Menus Tab
          _buildMenusTab(menus),

          // Categories & Items Tab
          _buildCategoriesItemsTab(selectedMenu),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddMenuDialog();
          } else if (_tabController.index == 1 && selectedMenu != null) {
            _showAddCategoryDialog(selectedMenu.id);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenusTab(List<Menu> menus) {
    final selectedMenuId = ref.watch(selectedMenuProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        final isSelected = menu.id == selectedMenuId;

        return Card(
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                isSelected
                    ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _showEditMenuDialog(menu),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (_) => _deleteMenu(menu.id),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                menu.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                '${menu.categories.length} categories • ${menu.categories.fold<int>(0, (sum, category) => sum + category.items.length)} items',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          menu.isActive ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      menu.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color:
                            menu.isActive
                                ? Colors.green[800]
                                : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                ref.read(selectedMenuProvider.notifier).state = menu.id;
                _tabController.animateTo(1);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesItemsTab(Menu? selectedMenu) {
    if (selectedMenu == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No menu selected',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('Select a Menu'),
            ),
          ],
        ),
      );
    }

    if (selectedMenu.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No categories in ${selectedMenu.name}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAddCategoryDialog(selectedMenu.id),
              child: const Text('Add Category'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedMenu.categories.length,
      itemBuilder: (context, index) {
        final category = selectedMenu.categories[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Display Order: ${category.displayOrder}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCategoryDialog(selectedMenu.id, category);
                        } else if (value == 'delete') {
                          _deleteCategory(selectedMenu.id, category.id);
                        } else if (value == 'add_item') {
                          _showAddMenuItemDialog(selectedMenu.id, category.id);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit Category'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'add_item',
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle, size: 20),
                                  SizedBox(width: 8),
                                  Text('Add Item'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete Category',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),

              // Menu Items
              if (category.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No items in this category',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

              ...category.items
                  .map(
                    (item) => Slidable(
                      key: ValueKey(item.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed:
                                (_) => _showEditMenuItemDialog(
                                  selectedMenu.id,
                                  category.id,
                                  item,
                                ),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed:
                                (_) => _deleteMenuItem(
                                  selectedMenu.id,
                                  category.id,
                                  item.id,
                                ),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading:
                              item.imageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  : Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Colors.grey,
                                    ),
                                  ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      item.isAvailable
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.isAvailable
                                      ? 'Available'
                                      : 'Unavailable',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        item.isAvailable
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                  )
                  .toList(),

              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed:
                      () =>
                          _showAddMenuItemDialog(selectedMenu.id, category.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Dialog Methods
  void _showAddMenuDialog() {
    _menuNameController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Menu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _menuNameController,
                  decoration: const InputDecoration(
                    labelText: 'Menu Name',
                    hintText: 'Enter menu name',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_menuNameController.text.isNotEmpty) {
                    final newMenu = Menu(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _menuNameController.text.trim(),
                      isActive: false,
                      categories: [],
                    );

                    ref.read(menusProvider.notifier).addMenu(newMenu);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditMenuDialog(Menu menu) {
    _menuNameController.text = menu.name;
    bool isActive = menu.isActive;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Menu'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _menuNameController,
                        decoration: const InputDecoration(
                          labelText: 'Menu Name',
                          hintText: 'Enter menu name',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Menu Active'),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_menuNameController.text.isNotEmpty) {
                          final updatedMenu = menu.copyWith(
                            name: _menuNameController.text.trim(),
                            isActive: isActive,
                          );

                          ref
                              .read(menusProvider.notifier)
                              .updateMenu(updatedMenu);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteMenu(String menuId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Menu'),
            content: const Text(
              'Are you sure you want to delete this menu? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(menusProvider.notifier).deleteMenu(menuId);
                  if (ref.read(selectedMenuProvider) == menuId) {
                    ref.read(selectedMenuProvider.notifier).state = null;
                  }
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showAddCategoryDialog(String menuId) {
    _categoryNameController.clear();
    int displayOrder = 1;

    final menu = ref
        .read(menusProvider)
        .firstWhere((menu) => menu.id == menuId);
    if (menu.categories.isNotEmpty) {
      displayOrder =
          menu.categories
              .map((c) => c.displayOrder)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'Enter category name',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_categoryNameController.text.isNotEmpty) {
                    final newCategory = MenuCategory(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _categoryNameController.text.trim(),
                      displayOrder: displayOrder,
                      items: [],
                    );

                    ref
                        .read(menusProvider.notifier)
                        .addCategory(menuId, newCategory);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditCategoryDialog(String menuId, MenuCategory category) {
    _categoryNameController.text = category.name;
    int displayOrder = category.displayOrder;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Category'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _categoryNameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          hintText: 'Enter category name',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Display Order:'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed:
                                displayOrder > 1
                                    ? () => setState(() => displayOrder--)
                                    : null,
                          ),
                          Text(
                            displayOrder.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => displayOrder++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_categoryNameController.text.isNotEmpty) {
                          final updatedCategory = category.copyWith(
                            name: _categoryNameController.text.trim(),
                            displayOrder: displayOrder,
                          );

                          ref
                              .read(menusProvider.notifier)
                              .updateCategory(menuId, updatedCategory);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteCategory(String menuId, String categoryId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: const Text(
              'Are you sure you want to delete this category and all its items? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(menusProvider.notifier)
                      .deleteCategory(menuId, categoryId);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showAddMenuItemDialog(String menuId, String categoryId) {
    _itemNameController.clear();
    _itemDescController.clear();
    _itemPriceController.clear();
    bool isAvailable = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Menu Item'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _itemNameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            hintText: 'Enter item name',
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _itemDescController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter item description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _itemPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            hintText: 'Enter price',
                            prefixText: '\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Available'),
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_itemNameController.text.isNotEmpty &&
                            _itemPriceController.text.isNotEmpty) {
                          double? price = double.tryParse(
                            _itemPriceController.text,
                          );
                          if (price != null) {
                            final newItem = MenuItem(
                              id:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              name: _itemNameController.text.trim(),
                              description: _itemDescController.text.trim(),
                              price: price,
                              isAvailable: isAvailable,
                            );

                            ref
                                .read(menusProvider.notifier)
                                .addMenuItem(menuId, categoryId, newItem);
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditMenuItemDialog(
    String menuId,
    String categoryId,
    MenuItem item,
  ) {
    _itemNameController.text = item.name;
    _itemDescController.text = item.description;
    _itemPriceController.text = item.price.toString();
    bool isAvailable = item.isAvailable;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Menu Item'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _itemNameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            hintText: 'Enter item name',
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _itemDescController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter item description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _itemPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            hintText: 'Enter price',
                            prefixText: '\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Available'),
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_itemNameController.text.isNotEmpty &&
                            _itemPriceController.text.isNotEmpty) {
                          double? price = double.tryParse(
                            _itemPriceController.text,
                          );
                          if (price != null) {
                            final updatedItem = item.copyWith(
                              name: _itemNameController.text.trim(),
                              description: _itemDescController.text.trim(),
                              price: price,
                              isAvailable: isAvailable,
                            );

                            ref
                                .read(menusProvider.notifier)
                                .updateMenuItem(
                                  menuId,
                                  categoryId,
                                  updatedItem,
                                );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteMenuItem(String menuId, String categoryId, String itemId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Menu Item'),
            content: const Text(
              'Are you sure you want to delete this item? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(menusProvider.notifier)
                      .deleteMenuItem(menuId, categoryId, itemId);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

// Main App for testing
class MenuManagementApp extends StatelessWidget {
  const MenuManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Menu Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const MenuManagementScreen(),
      ),
    );
  }
}

// Entry point
void main() {
  runApp(const MenuManagementApp());
}
