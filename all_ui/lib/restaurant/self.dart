import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:mobile_scanner/mobile_scanner.dart';

// Models
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> tags;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.tags = const [],
    this.isAvailable = true,
  });
}

class CartItem {
  final MenuItem item;
  int quantity;
  String? specialInstructions;

  CartItem({required this.item, this.quantity = 1, this.specialInstructions});

  double get totalPrice => item.price * quantity;
}

class Order {
  String? tableNumber;
  final List<CartItem> items;
  final DateTime createdAt;

  Order({this.tableNumber, required this.items, required this.createdAt});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
}

// Providers
final tableNumberProvider = StateProvider<String?>((ref) => null);

final menuCategoriesProvider = Provider<List<String>>(
  (ref) => ['Popular', 'Appetizers', 'Main Course', 'Desserts', 'Drinks'],
);

final selectedCategoryProvider = StateProvider<String>((ref) => 'Popular');

final menuItemsProvider = Provider<List<MenuItem>>(
  (ref) => [
    MenuItem(
      id: '1',
      name: 'Truffle Pasta',
      description: 'Handmade pasta with fresh truffle sauce',
      price: 18.99,
      imageUrl: 'assets/images/truffle_pasta.jpg',
      category: 'Main Course',
      tags: ['Chef\'s Special', 'Vegetarian'],
    ),
    MenuItem(
      id: '2',
      name: 'Avocado Toast',
      description: 'Sourdough bread with smashed avocado and poached egg',
      price: 12.99,
      imageUrl: 'assets/images/avocado_toast.jpg',
      category: 'Appetizers',
      tags: ['Healthy', 'Breakfast'],
    ),
    MenuItem(
      id: '3',
      name: 'Berry Smoothie',
      description: 'Mixed berries with yogurt and honey',
      price: 7.99,
      imageUrl: 'assets/images/berry_smoothie.jpg',
      category: 'Drinks',
      tags: ['Healthy', 'Cold'],
    ),
    // Add more items as needed
  ],
);

final filteredMenuItemsProvider = Provider<List<MenuItem>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final allItems = ref.watch(menuItemsProvider);

  if (selectedCategory == 'Popular') {
    return allItems
        .where((item) => item.tags.contains('Chef\'s Special'))
        .toList();
  }

  return allItems.where((item) => item.category == selectedCategory).toList();
});

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item) {
    final existingItemIndex = state.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingItemIndex >= 0) {
      final updatedItems = [...state];
      updatedItems[existingItemIndex] = CartItem(
        item: updatedItems[existingItemIndex].item,
        quantity: updatedItems[existingItemIndex].quantity + 1,
        specialInstructions:
            updatedItems[existingItemIndex].specialInstructions,
      );
      state = updatedItems;
    } else {
      state = [...state, CartItem(item: item)];
    }
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.item.id != itemId).toList();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    state = [
      for (final item in state)
        if (item.item.id == itemId)
          CartItem(
            item: item.item,
            quantity: quantity,
            specialInstructions: item.specialInstructions,
          )
        else
          item,
    ];
  }

  void updateSpecialInstructions(String itemId, String instructions) {
    state = [
      for (final item in state)
        if (item.item.id == itemId)
          CartItem(
            item: item.item,
            quantity: item.quantity,
            specialInstructions: instructions,
          )
        else
          item,
    ];
  }

  void clearCart() {
    state = [];
  }
}

// UI Components
void main() {
  runApp(const ProviderScope(child: RestaurantApp()));
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dine Ease',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          secondary: const Color(0xFFEADDFF),
          tertiary: const Color(0xFF625B71),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const TableSelectionScreen(),
    );
  }
}

class TableSelectionScreen extends ConsumerWidget {
  const TableSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Dine Ease',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please select your table to start ordering',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _TableSelectionOption(
                      title: 'Scan QR Code',
                      icon: Icons.qr_code_scanner,
                      onTap: () => _showQRScanner(context, ref),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TableSelectionOption(
                      title: 'Enter Table Number',
                      icon: Icons.table_bar,
                      onTap: () => _showTableNumberDialog(context, ref),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/table_illustration.svg',
                      height: 250,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Enjoy a contactless ordering experience',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRScanner(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Scan Table QR Code'),
                centerTitle: true,
              ),
              body: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final tableNumber = barcode.rawValue;
                    if (tableNumber != null) {
                      ref.read(tableNumberProvider.notifier).state =
                          tableNumber;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MenuScreen(),
                        ),
                      );
                      break;
                    }
                  }
                },
              ),
            ),
      ),
    );
  }

  void _showTableNumberDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        String tableNumber = '';
        return AlertDialog(
          title: const Text('Enter Table Number'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g. 12',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              tableNumber = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (tableNumber.isNotEmpty) {
                  ref.read(tableNumberProvider.notifier).state = tableNumber;
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MenuScreen()),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class _TableSelectionOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _TableSelectionOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends ConsumerWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableNumber = ref.watch(tableNumberProvider);
    final categories = ref.watch(menuCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final menuItems = ref.watch(filteredMenuItemsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableNumber'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Badge(
              label: Text(cart.length.toString()),
              isLabelVisible: cart.isNotEmpty,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      }
                    },
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    selectedColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _MenuItemCard(
                  menuItem: item,
                  onAddToCart: () {
                    ref.read(cartProvider.notifier).addItem(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} added to cart'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback onAddToCart;

  const _MenuItemCard({required this.menuItem, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(menuItem.imageUrl, fit: BoxFit.cover),
                ),
                if (menuItem.tags.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        menuItem.tags.first,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuItem.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menuItem.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${menuItem.price.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  menuItem.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      menuItem.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\$${menuItem.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    menuItem.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor:
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                menuItem.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onAddToCart();
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Order'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableNumber = ref.watch(tableNumberProvider);
    final cartItems = ref.watch(cartProvider);

    final totalAmount = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order (Table $tableNumber)'),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(context, ref),
            ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some delicious items from the menu',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Browse Menu'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        return _CartItemTile(
                          cartItem: cartItem,
                          onQuantityChanged: (quantity) {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(cartItem.item.id, quantity);
                          },
                          onRemove: () {
                            ref
                                .read(cartProvider.notifier)
                                .removeItem(cartItem.item.id);
                          },
                          onSpecialInstructionsChanged: (instructions) {
                            ref
                                .read(cartProvider.notifier)
                                .updateSpecialInstructions(
                                  cartItem.item.id,
                                  instructions,
                                );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total'),
                              Text(
                                '\$${totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  () => _showOrderConfirmationDialog(
                                    context,
                                    ref,
                                  ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('Place Order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cart?'),
            content: const Text('Are you sure you want to remove all items?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).clearCart();
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, WidgetRef ref) {
    final tableNumber = ref.watch(tableNumberProvider);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Order'),
            content: Text('Place your order for Table $tableNumber?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  // In a real app, we would send the order to a backend here
                  Navigator.pop(context);
                  _showOrderSuccessDialog(context, ref);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showOrderSuccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Order Placed'),
              ],
            ),
            content: const Text(
              'Your order has been received and is being prepared. You will be notified when it\'s ready.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).clearCart();
                  // Pop to root and clear navigation stack
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Menu'),
              ),
            ],
          ),
    );
  }
}

class _CartItemTile extends StatefulWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final Function(String) onSpecialInstructionsChanged;

  const _CartItemTile({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onSpecialInstructionsChanged,
  });

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  late TextEditingController _instructionsController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _instructionsController = TextEditingController(
      text: widget.cartItem.specialInstructions,
    );
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.cartItem.item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cartItem.item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.cartItem.item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          () => widget.onQuantityChanged(
                            widget.cartItem.quantity - 1,
                          ),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Text(
                      '${widget.cartItem.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed:
                          () => widget.onQuantityChanged(
                            widget.cartItem.quantity + 1,
                          ),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${widget.cartItem.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Special instructions',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  hintText: 'Any special requests?',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onSpecialInstructionsChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Additional screens and widgets can be added as needed
