import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Models
class CoffeeItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final List<String> tags;

  CoffeeItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.tags,
  });
}

class CartItem {
  final CoffeeItem item;
  int quantity;
  final List<String> customizations;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.customizations = const [],
  });

  double get totalPrice => item.price * quantity;
}

class Promotion {
  final String id;
  final String name;
  final double discount; // Can be percentage or fixed amount

  Promotion({required this.id, required this.name, required this.discount});
}

class SplitBill {
  final int numberOfPeople;
  final double amountPerPerson;

  SplitBill({required this.numberOfPeople, required this.amountPerPerson});
}

// State management with Riverpod
final coffeeItemsProvider = Provider<List<CoffeeItem>>((ref) {
  return [
    CoffeeItem(
      id: '1',
      name: 'Espresso',
      price: 3.50,
      imageUrl: 'assets/espresso.png',
      tags: ['Hot', 'Strong'],
    ),
    CoffeeItem(
      id: '2',
      name: 'Cappuccino',
      price: 4.50,
      imageUrl: 'assets/cappuccino.png',
      tags: ['Hot', 'Milk'],
    ),
    CoffeeItem(
      id: '3',
      name: 'Latte',
      price: 4.75,
      imageUrl: 'assets/latte.png',
      tags: ['Hot', 'Milk'],
    ),
    CoffeeItem(
      id: '4',
      name: 'Iced Coffee',
      price: 4.25,
      imageUrl: 'assets/iced_coffee.png',
      tags: ['Cold', 'Refreshing'],
    ),
    CoffeeItem(
      id: '5',
      name: 'Mocha',
      price: 5.00,
      imageUrl: 'assets/mocha.png',
      tags: ['Hot', 'Chocolate'],
    ),
  ];
});

final categoryProvider = StateProvider<String>((ref) => 'All');

final filteredCoffeeItemsProvider = Provider<List<CoffeeItem>>((ref) {
  final coffeeItems = ref.watch(coffeeItemsProvider);
  final selectedCategory = ref.watch(categoryProvider);

  if (selectedCategory == 'All') {
    return coffeeItems;
  }

  return coffeeItems.where((item) {
    return item.tags.contains(selectedCategory);
  }).toList();
});

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final promotionProvider = StateProvider<Promotion?>((ref) => null);

//final splitBillProvider = StateProvider<SplitBill?>((ref) => null);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(CoffeeItem item, [List<String> customizations = const []]) {
    final existingIndex = state.indexWhere(
      (cartItem) =>
          cartItem.item.id == item.id &&
          _areListsEqual(cartItem.customizations, customizations),
    );

    if (existingIndex >= 0) {
      state = [
        ...state.sublist(0, existingIndex),
        CartItem(
          item: state[existingIndex].item,
          quantity: state[existingIndex].quantity + 1,
          customizations: state[existingIndex].customizations,
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(item: item, customizations: customizations)];
    }
  }

  void removeFromCart(int index) {
    state = [...state]..removeAt(index);
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeFromCart(index);
      return;
    }

    state = [
      ...state.sublist(0, index),
      CartItem(
        item: state[index].item,
        quantity: quantity,
        customizations: state[index].customizations,
      ),
      ...state.sublist(index + 1),
    ];
  }

  void clearCart() {
    state = [];
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

final totalPriceProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  final promotion = ref.watch(promotionProvider);
  double total = cartItems.fold(0, (total, item) => total + item.totalPrice);
  if (promotion != null) {
    total -= promotion.discount;
  }
  return total < 0 ? 0 : total;
});

final splitBillStateProvider = StateProvider<SplitBill?>((ref) => null);

final splitBillProvider = Provider<SplitBill?>((ref) {
  final totalPrice = ref.watch(totalPriceProvider);
  final splitBill = ref.watch(splitBillStateProvider);
  if (splitBill != null) {
    return SplitBill(
      numberOfPeople: splitBill.numberOfPeople,
      amountPerPerson: totalPrice / splitBill.numberOfPeople,
    );
  }
  return null;
});

// Main Screen
class CoffeeShopCashierScreen extends ConsumerWidget {
  const CoffeeShopCashierScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems = ref.watch(filteredCoffeeItemsProvider);
    final cart = ref.watch(cartProvider);
    final totalPrice = ref.watch(totalPriceProvider);
    final splitBill = ref.watch(splitBillProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: SafeArea(
        child: Row(
          children: [
            // Left panel - Menu catalog
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.brown[800],
                          child: const Icon(Icons.coffee, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bean Bliss',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[900],
                              ),
                            ),
                            Text(
                              'Cashier System',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.brown[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          onPressed: () {},
                          color: Colors.brown[700],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search coffee, tea, etc.',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.brown[400],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip(ref, 'All'),
                          _buildCategoryChip(ref, 'Hot'),
                          _buildCategoryChip(ref, 'Cold'),
                          _buildCategoryChip(ref, 'Milk'),
                          _buildCategoryChip(ref, 'Strong'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Coffee items grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                            onTap: () =>
                                ref.read(cartProvider.notifier).addToCart(item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Placeholder for image
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.brown[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.coffee,
                                          size: 40,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${item.price.toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: Colors.brown[700],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.brown[700],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right panel - Cart
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    bottomLeft: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Order',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Walk-in Customer',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Expanded(
                        child: cart.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Cart is empty',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'Add items to start an order',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: cart.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.grey[200],
                                  height: 24,
                                ),
                                itemBuilder: (context, index) {
                                  final cartItem = cart[index];
                                  return Row(
                                    children: [
                                      // Coffee icon placeholder
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.brown[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.coffee,
                                            color: Colors.brown[800],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Item details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartItem.item.name,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if (cartItem
                                                .customizations
                                                .isNotEmpty)
                                              Text(
                                                cartItem.customizations.join(
                                                  ', ',
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Quantity controls
                                      Row(
                                        children: [
                                          _buildQuantityButton(
                                            icon: Icons.remove,
                                            onPressed: () => ref
                                                .read(cartProvider.notifier)
                                                .updateQuantity(
                                                  index,
                                                  cartItem.quantity - 1,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          _buildQuantityButton(
                                            icon: Icons.add,
                                            onPressed: () => ref
                                                .read(cartProvider.notifier)
                                                .updateQuantity(
                                                  index,
                                                  cartItem.quantity + 1,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      // Price
                                      Text(
                                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 16),

                      const Divider(),

                      // Order summary
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            _buildOrderSummaryRow(
                              'Subtotal',
                              '\$${totalPrice.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            _buildOrderSummaryRow(
                              'Tax (10%)',
                              '\$${(totalPrice * 0.1).toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            _buildOrderSummaryRow(
                              'Total',
                              '\$${(totalPrice * 1.1).toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                            if (splitBill != null)
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  _buildOrderSummaryRow(
                                    'Amount per person (${splitBill.numberOfPeople})',
                                    '\$${splitBill.amountPerPerson.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Promotion and Split Bill Options
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Show promotion dialog
                                _showPromotionDialog(context, ref);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Apply Promotion',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Show split bill dialog
                                _showSplitBillDialog(context, ref);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Split Bill',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Payment buttons
                      Row(
                        children: [
                          // Clear cart button
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () =>
                                  ref.read(cartProvider.notifier).clearCart(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.grey[800],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Clear',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Checkout button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: cart.isEmpty ? null : () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.brown[300],
                              ),
                              child: Text(
                                'Checkout',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromotionDialog(BuildContext context, WidgetRef ref) {
    final promotions = [
      Promotion(id: '1', name: '10% Off', discount: 0.10),
      Promotion(id: '2', name: '20% Off', discount: 0.20),
      Promotion(id: '3', name: '\$5 Off', discount: 5.00),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Promotion', style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: promotions.map((promotion) {
              return ListTile(
                title: Text(promotion.name, style: GoogleFonts.poppins()),
                onTap: () {
                  ref.read(promotionProvider.notifier).state = promotion;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSplitBillDialog(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Split Bill', style: GoogleFonts.poppins()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Number of people',
              hintStyle: GoogleFonts.poppins(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final numberOfPeople = int.tryParse(controller.text) ?? 1;
                ref.read(splitBillStateProvider.notifier).state = SplitBill(
                  numberOfPeople: numberOfPeople,
                  amountPerPerson:
                      ref.read(totalPriceProvider) / numberOfPeople,
                );
                Navigator.pop(context);
              },
              child: Text('Apply', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(WidgetRef ref, String category) {
    final selectedCategory = ref.watch(categoryProvider);
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          category,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.brown[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: Colors.brown[700],
        onSelected: (selected) {
          if (selected) {
            ref.read(categoryProvider.notifier).state = category;
          }
        },
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildOrderSummaryRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.brown[900] : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.brown[900] : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

// Main app
class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Bean Bliss Coffee Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.brown[800],
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const CoffeeShopCashierScreen(),
      ),
    );
  }
}

void main() {
  runApp(const CoffeeShopApp());
}
