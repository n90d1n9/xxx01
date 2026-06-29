import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

// MODELS
class Variant {
  final String id;
  final String name;
  final double price;

  Variant({required this.id, required this.name, required this.price});
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double basePrice; // Renamed from price to basePrice
  final String imageUrl;
  final String category;
  final List<String> tags;
  final List<Variant>? variants; // List of variants

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imageUrl,
    required this.category,
    required this.tags,
    this.variants,
  });

  // Helper method to get the total price including selected variants
  double getPrice(List<Variant>? selectedVariants) {
    double total = basePrice;
    if (selectedVariants != null) {
      total += selectedVariants.fold(0, (sum, variant) => sum + variant.price);
    }
    return total;
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;
  final List<Variant>? selectedVariants; // Selected variants

  CartItem({required this.menuItem, this.quantity = 1, this.selectedVariants});

  // Update totalPrice to include variant prices
  double get totalPrice => menuItem.getPrice(selectedVariants) * quantity;
}

// PROVIDERS
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final menuItemsProvider = Provider<List<MenuItem>>((ref) {
  // Mock data - in a real app, this would come from an API or database
  return [
    MenuItem(
      id: '1',
      name: 'Avocado Toast',
      description:
          'Freshly smashed avocado on artisanal sourdough bread with cherry tomatoes',
      basePrice: 12.99,
      imageUrl: 'https://picsum.photos/id/292/300/200',
      category: 'Breakfast',
      tags: ['Vegetarian', 'Healthy'],
      variants: [
        Variant(id: '1', name: 'Extra Avocado', price: 2.99),
        Variant(id: '2', name: 'Add Egg', price: 1.99),
      ],
    ),
    MenuItem(
      id: '2',
      name: 'Acai Bowl',
      description:
          'Blended acai berries topped with granola, fresh fruit and honey',
      basePrice: 14.99,
      imageUrl: 'https://picsum.photos/id/175/300/200',
      category: 'Breakfast',
      tags: ['Vegan', 'Healthy'],
      variants: [
        Variant(id: '1', name: 'Extra Avocado', price: 2.99),
        Variant(id: '2', name: 'Add Egg', price: 1.99),
      ],
    ),
    MenuItem(
      id: '3',
      name: 'Truffle Pasta',
      description:
          'Fresh fettuccine with creamy truffle sauce and wild mushrooms',
      basePrice: 24.99,
      imageUrl: 'https://picsum.photos/id/231/300/200',
      category: 'Mains',
      tags: ['Popular', 'Vegetarian'],
    ),
    MenuItem(
      id: '4',
      name: 'Wagyu Burger',
      description:
          'Premium wagyu beef patty with caramelized onions and special sauce',
      basePrice: 18.99,
      imageUrl: 'https://picsum.photos/id/1080/300/200',
      category: 'Mains',
      tags: ['Popular', 'Meat'],
    ),
    MenuItem(
      id: '5',
      name: 'Matcha Latte',
      description: 'Ceremonial grade matcha with steamed oat milk',
      basePrice: 5.99,
      imageUrl: 'https://picsum.photos/id/225/300/200',
      category: 'Drinks',
      tags: ['Vegan', 'Hot'],
    ),
    MenuItem(
      id: '6',
      name: 'Mango Smoothie',
      description: 'Fresh mango blended with coconut milk and honey',
      basePrice: 7.99,
      imageUrl: 'https://picsum.photos/id/1080/300/200',
      category: 'Drinks',
      tags: ['Cold', 'Healthy'],
    ),
  ];
});

final filteredMenuItemsProvider = Provider<List<MenuItem>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final menuItems = ref.watch(menuItemsProvider);

  if (selectedCategory == 'All') {
    return menuItems;
  }

  return menuItems.where((item) => item.category == selectedCategory).toList();
});

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item, {List<Variant>? selectedVariants}) {
    final existingIndex = state.indexWhere(
      (cartItem) =>
          cartItem.menuItem.id == item.id &&
          _areVariantsEqual(cartItem.selectedVariants, selectedVariants),
    );

    if (existingIndex >= 0) {
      final updatedCart = [...state];
      updatedCart[existingIndex].quantity += 1;
      state = updatedCart;
    } else {
      state = [
        ...state,
        CartItem(menuItem: item, selectedVariants: selectedVariants),
      ];
    }
  }

  // Helper method to compare two lists of variants
  bool _areVariantsEqual(List<Variant>? a, List<Variant>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void removeItem(MenuItem item) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id,
    );

    if (existingIndex >= 0) {
      final updatedCart = [...state];

      if (updatedCart[existingIndex].quantity > 1) {
        updatedCart[existingIndex].quantity -= 1;
        state = updatedCart;
      } else {
        updatedCart.removeAt(existingIndex);
        state = updatedCart;
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }
}

final totalAmountProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (total, item) => total + item.totalPrice);
});

// SCREENS
class MenuScreen extends ConsumerWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final menuItems = ref.watch(filteredMenuItemsProvider);
    final cart = ref.watch(cartProvider);
    final totalAmount = ref.watch(totalAmountProvider);

    final categories = ['All', 'Breakfast', 'Mains', 'Drinks'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Urban Plate',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Self-service menu',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap:
                          () =>
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = category,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return MenuItemCard(item: item);
                },
              ),
            ),

            // Cart Summary
            if (cart.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cart.length} item${cart.length > 1 ? 's' : ''} in cart',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to checkout screen
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const CartBottomSheet(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View Cart'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MenuItemCard extends ConsumerStatefulWidget {
  final MenuItem item;

  const MenuItemCard({Key? key, required this.item}) : super(key: key);

  @override
  ConsumerState<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends ConsumerState<MenuItemCard> {
  List<Variant>? selectedVariants;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.firstWhere(
      (cartItem) =>
          cartItem.menuItem.id == widget.item.id &&
          _areVariantsEqual(cartItem.selectedVariants, selectedVariants),
      orElse: () => CartItem(menuItem: widget.item, quantity: 0),
    );

    final isInCart = cartItem.quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and other details remain the same...

          // Variant Selection
          if (widget.item.variants != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Options:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...widget.item.variants!.map((variant) {
                    return CheckboxListTile(
                      title: Text(variant.name),
                      subtitle: Text('\$${variant.price.toStringAsFixed(2)}'),
                      value: selectedVariants?.contains(variant) ?? false,
                      onChanged: (value) {
                        setState(() {
                          selectedVariants ??= [];
                          if (value == true) {
                            selectedVariants!.add(variant);
                          } else {
                            selectedVariants!.remove(variant);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

          // Add to Cart Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isInCart) ...[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed:
                        () => ref
                            .read(cartProvider.notifier)
                            .removeItem(widget.item),
                    color: Colors.black,
                  ),
                  Text(
                    cartItem.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed:
                        () => ref
                            .read(cartProvider.notifier)
                            .addItem(
                              widget.item,
                              selectedVariants: selectedVariants,
                            ),
                    color: Colors.black,
                  ),
                ] else
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => ref
                              .read(cartProvider.notifier)
                              .addItem(
                                widget.item,
                                selectedVariants: selectedVariants,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _areVariantsEqual(List<Variant>? a, List<Variant>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalAmount = ref.watch(totalAmountProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      // Use 80% of screen height
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Cart',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Cart Items
          Expanded(
            child:
                cart.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Browse Menu'),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final cartItem = cart[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItem.menuItem.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.menuItem.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${cartItem.menuItem.basePrice.toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed:
                                        () => ref
                                            .read(cartProvider.notifier)
                                            .removeItem(cartItem.menuItem),
                                    color: Colors.black,
                                    iconSize: 20,
                                  ),
                                  /* Text(
                                    cartItem.quantity.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ), */
                                  // In the CartBottomSheet widget, update the cart item display:
                                  Text(
                                    cartItem.menuItem.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (cartItem.selectedVariants != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          cartItem.selectedVariants!.map((
                                            variant,
                                          ) {
                                            return Text(
                                              '- ${variant.name} (\$${variant.price.toStringAsFixed(2)})',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed:
                                        () => ref
                                            .read(cartProvider.notifier)
                                            .addItem(cartItem.menuItem),
                                    color: Colors.black,
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          // Summary and Checkout
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  // Price Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('\$${totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax (10%)'),
                      Text('\$${(totalAmount * 0.1).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${(totalAmount * 1.1).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Checkout Button
                  ElevatedButton(
                    onPressed: () {
                      // Process order
                      showDialog(
                        context: context,
                        builder: (context) => const OrderConfirmationDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class OrderConfirmationDialog extends ConsumerWidget {
  const OrderConfirmationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)} has been placed',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Clear cart and close all modals
                  ref.read(cartProvider.notifier).clearCart();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Return to Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MAIN APP
class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Urban Plate Self-Service',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            primary: Colors.black,
          ),
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        home: const MenuScreen(),
      ),
    );
  }
}

void main() {
  runApp(const RestaurantMenuApp());
}
