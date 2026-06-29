// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Cashier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const CashierScreen(),
    );
  }
}

// Models
class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String barcode;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.barcode,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

// Repository
class ProductRepository {
  Future<List<Product>> getProducts() async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Product(
        id: '1',
        name: 'Organic Bananas',
        price: 2.99,
        category: 'Fruits',
        imageUrl: 'assets/banana.png',
        barcode: '8901234567890',
      ),
      Product(
        id: '2',
        name: 'Whole Milk',
        price: 3.49,
        category: 'Dairy',
        imageUrl: 'assets/milk.png',
        barcode: '7890123456789',
      ),
      Product(
        id: '3',
        name: 'Whole Wheat Bread',
        price: 4.29,
        category: 'Bakery',
        imageUrl: 'assets/bread.png',
        barcode: '6789012345678',
      ),
      Product(
        id: '4',
        name: 'Chicken Breast',
        price: 8.99,
        category: 'Meat',
        imageUrl: 'assets/chicken.png',
        barcode: '5678901234567',
      ),
      Product(
        id: '5',
        name: 'Spinach',
        price: 3.99,
        category: 'Vegetables',
        imageUrl: 'assets/spinach.png',
        barcode: '4567890123456',
      ),
    ];
  }

  Future<Product?> findByBarcode(String barcode) async {
    final products = await getProducts();
    final index = products.indexWhere((product) => product.barcode == barcode);

    if (index != -1) {
      return products[index];
    }

    return null;
  }
}

// Providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProducts();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return products.whenData((productList) {
    if (searchQuery.isEmpty) {
      return productList;
    }

    return productList.where((product) {
      return product.name.toLowerCase().contains(searchQuery) ||
          product.barcode.contains(searchQuery);
    }).toList();
  });
});

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final updatedState = [...state];
      updatedState[index] = CartItem(
        product: updatedState[index].product,
        quantity: updatedState[index].quantity + 1,
      );
      state = updatedState;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void decreaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final item = state[index];

      if (item.quantity > 1) {
        final updatedState = [...state];
        updatedState[index] = CartItem(
          product: item.product,
          quantity: item.quantity - 1,
        );
        state = updatedState;
      } else {
        removeProduct(productId);
      }
    }
  }

  void increaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final updatedState = [...state];
      updatedState[index] = CartItem(
        product: updatedState[index].product,
        quantity: updatedState[index].quantity + 1,
      );
      state = updatedState;
    }
  }

  void clearCart() {
    state = [];
  }

  double get total {
    return state.fold(0, (sum, item) => sum + item.total);
  }
}

// Screens
class CashierScreen extends ConsumerWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Left panel - Products
          Expanded(
            flex: 3,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products or scan barcode',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => _scanBarcode(context, ref),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final productsAsyncValue = ref.watch(
                          filteredProductsProvider,
                        );

                        return productsAsyncValue.when(
                          data: (products) {
                            if (products.isEmpty) {
                              return const Center(
                                child: Text('No products found'),
                              );
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];

                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addProduct(product);
                                  },
                                );
                              },
                            );
                          },
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (error, stackTrace) =>
                                  Center(child: Text('Error: $error')),
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
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Order',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Clear Cart',
                          onPressed: () {
                            ref.read(cartProvider.notifier).clearCart();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final cartItems = ref.watch(cartProvider);

                        if (cartItems.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Cart is empty',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];

                            return CartItemTile(
                              item: item,
                              onDecrease: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .decreaseQuantity(item.product.id);
                              },
                              onIncrease: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .increaseQuantity(item.product.id);
                              },
                              onRemove: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .removeProduct(item.product.id);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Consumer(
                    builder: (context, ref, child) {
                      final cartItems = ref.watch(cartProvider);
                      final total = cartItems.fold(
                        0.0,
                        (sum, item) => sum + item.total,
                      );
                      final tax = total * 0.08; // 8% tax
                      final grandTotal = total + tax;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text('\$${total.toStringAsFixed(2)}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tax (8%)'),
                                Text('\$${tax.toStringAsFixed(2)}'),
                              ],
                            ),
                            const Divider(),
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
                                  '\$${grandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    cartItems.isEmpty
                                        ? null
                                        : () => _processPayment(context, ref),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Process Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context, WidgetRef ref) async {
    // Simulating barcode scanning
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Barcode Scanner'),
            content: const Text('Scanning... (This is a simulation)'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Simulate finding a product
                  final repository = ref.read(productRepositoryProvider);
                  final product = await repository.findByBarcode(
                    '8901234567890',
                  );

                  if (product != null) {
                    ref.read(cartProvider.notifier).addProduct(product);
                  }

                  Navigator.of(context).pop();
                },
                child: const Text('Scan'),
              ),
            ],
          ),
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref) async {
    // Payment processing simulation
    final cartItems = ref.read(cartProvider);
    final total = cartItems.fold(0.0, (sum, item) => sum + item.total);
    final tax = total * 0.08;
    final grandTotal = total + tax;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Method'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Amount: \$${grandTotal.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text('Choose payment method:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PaymentMethodButton(
                      icon: Icons.credit_card,
                      label: 'Card',
                      onTap: () => _completeTransaction(context, ref, 'Card'),
                    ),
                    PaymentMethodButton(
                      icon: Icons.money,
                      label: 'Cash',
                      onTap: () => _completeTransaction(context, ref, 'Cash'),
                    ),
                    PaymentMethodButton(
                      icon: Icons.phone_android,
                      label: 'Mobile',
                      onTap:
                          () => _completeTransaction(
                            context,
                            ref,
                            'Mobile Payment',
                          ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _completeTransaction(
    BuildContext context,
    WidgetRef ref,
    String paymentMethod,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Processing payment...'),
              ],
            ),
          ),
    );

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    Navigator.of(context).pop();

    // Close payment method dialog
    Navigator.of(context).pop();

    // Generate receipt number
    final receiptNumber =
        '${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // Show success dialog with receipt
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Payment Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receipt #: $receiptNumber'),
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                ),
                Text('Payment Method: $paymentMethod'),
                const SizedBox(height: 16),
                const Text('Thank you for your purchase!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(cartProvider.notifier).clearCart();
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(cartProvider.notifier).clearCart();
                  // Print receipt functionality would go here
                },
                child: const Text('Print Receipt'),
              ),
            ],
          ),
    );
  }
}

// Widgets
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'bakery':
        return Icons.breakfast_dining;
      case 'dairy':
        return Icons.egg;
      case 'meat':
        return Icons.restaurant;
      default:
        return Icons.shopping_basket;
    }
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(item.product.category),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${item.product.price.toStringAsFixed(2)} each',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrease,
              iconSize: 20,
            ),
            Text(
              item.quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrease,
              iconSize: 20,
            ),
          ],
        ),
        const SizedBox(width: 16),
        Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onRemove,
          color: Colors.red,
          iconSize: 20,
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'bakery':
        return Icons.breakfast_dining;
      case 'dairy':
        return Icons.egg;
      case 'meat':
        return Icons.restaurant;
      default:
        return Icons.shopping_basket;
    }
  }
}

class PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PaymentMethodButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// Add a dashboard screen for analytics
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample analytics data
    final salesData = [
      {'date': 'Mon', 'sales': 1200.0},
      {'date': 'Tue', 'sales': 1500.0},
      {'date': 'Wed', 'sales': 1350.0},
      {'date': 'Thu', 'sales': 1800.0},
      {'date': 'Fri', 'sales': 2100.0},
      {'date': 'Sat', 'sales': 2500.0},
      {'date': 'Sun', 'sales': 1700.0},
    ];

    final topSellingProducts = [
      {'name': 'Organic Bananas', 'quantity': 145, 'revenue': 433.55},
      {'name': 'Whole Milk', 'quantity': 132, 'revenue': 460.68},
      {'name': 'Whole Wheat Bread', 'quantity': 98, 'revenue': 420.42},
      {'name': 'Chicken Breast', 'quantity': 85, 'revenue': 764.15},
      {'name': 'Spinach', 'quantity': 76, 'revenue': 303.24},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CashierScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Analytics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Today\'s Sales',
                    '\$2,548.75',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Items Sold',
                    '187',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Transactions',
                    '43',
                    Icons.receipt_long,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Average Sale',
                    '\$59.27',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Sales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            // Here you would add a chart using fl_chart or another charting library
                            child: Center(
                              child: Text(
                                'Sales Chart Would Appear Here',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top Selling Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...topSellingProducts
                              .map(
                                (product) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          product['name'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${product['quantity']} sold',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '\$${(product['revenue'] as double).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      'Receipt #${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 10) + index.toString()}',
                    ),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.now().subtract(Duration(minutes: index * 15)),
                      ),
                    ),
                    trailing: Text(
                      '\$${(75.0 + index * 12.5).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Show receipt details
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const InventoryScreen()),
          );
        },
        child: const Icon(Icons.inventory),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Inventory Management Screen
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search inventory',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddProductDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ID',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Product Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Category',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Stock',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: 20,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final id = (index + 1).toString().padLeft(3, '0');
                            final name = _getProductName(index);
                            final category = _getCategory(index);
                            final price = _getPrice(index);
                            final stock = _getStock(index);

                            return Row(
                              children: [
                                Expanded(flex: 1, child: Text('#$id')),
                                Expanded(flex: 3, child: Text(name)),
                                Expanded(flex: 2, child: Text(category)),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    stock.toString(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: stock < 10 ? Colors.red : null,
                                      fontWeight:
                                          stock < 10 ? FontWeight.bold : null,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () {
                                          // Edit product
                                        },
                                        tooltip: 'Edit',
                                        color: Colors.blue,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          // Delete product
                                        },
                                        tooltip: 'Delete',
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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

  String _getProductName(int index) {
    final products = [
      'Organic Bananas',
      'Whole Milk',
      'Whole Wheat Bread',
      'Chicken Breast',
      'Spinach',
      'Avocado',
      'Eggs',
      'Greek Yogurt',
      'Ground Beef',
      'Tomatoes',
    ];
    return products[index % products.length];
  }

  String _getCategory(int index) {
    final categories = ['Fruits', 'Dairy', 'Bakery', 'Meat', 'Vegetables'];
    return categories[index % categories.length];
  }

  double _getPrice(int index) {
    final basePrice = 2.99;
    return basePrice + (index % 10) * 0.5;
  }

  int _getStock(int index) {
    return 5 + (index % 30);
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Initial Stock',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Barcode',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save new product
                  Navigator.of(context).pop();
                },
                child: const Text('Add Product'),
              ),
            ],
          ),
    );
  }
}

// Main App with navigation
class GroceryCashierApp extends StatelessWidget {
  const GroceryCashierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Cashier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 2),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CashierScreen(),
    const DashboardScreen(),
    const InventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.point_of_sale),
                selectedIcon: Icon(Icons.point_of_sale),
                label: Text('Cashier'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                selectedIcon: Icon(Icons.inventory),
                label: Text('Inventory'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
