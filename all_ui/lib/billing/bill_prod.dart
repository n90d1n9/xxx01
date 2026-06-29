import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Tenant {
  final String id;
  final String name;
  final String logoUrl;

  Tenant({required this.id, required this.name, required this.logoUrl});
}

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
  });
}

class CartItem {
  final Product product;
  int quantity;
  final String tenantId;

  CartItem({required this.product, this.quantity = 1, required this.tenantId});

  double get total => product.price * quantity;
}

// Providers
final currentTenantProvider = StateProvider<Tenant?>((ref) => null);

final productsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  tenantId,
) async {
  // In a real app, fetch products from an API based on tenantId
  await Future.delayed(
    const Duration(milliseconds: 800),
  ); // Simulate network delay
  return [
    Product(
      id: 'p1',
      name: 'Business Plan',
      price: 79.99,
      category: 'Subscription',
      imageUrl: 'assets/business_plan.png',
    ),
    Product(
      id: 'p2',
      name: 'Premium Support',
      price: 29.99,
      category: 'Service',
      imageUrl: 'assets/support.png',
    ),
    Product(
      id: 'p3',
      name: 'Website Hosting',
      price: 15.99,
      category: 'Hosting',
      imageUrl: 'assets/hosting.png',
    ),
    Product(
      id: 'p4',
      name: 'Custom Domain',
      price: 12.99,
      category: 'Domain',
      imageUrl: 'assets/domain.png',
    ),
    Product(
      id: 'p5',
      name: 'Pro Analytics',
      price: 49.99,
      category: 'Add-on',
      imageUrl: 'assets/analytics.png',
    ),
  ];
});

final categoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredProductsProvider =
    Provider.family<AsyncValue<List<Product>>, String>((ref, tenantId) {
      final productsAsync = ref.watch(productsProvider(tenantId));
      final categoryFilter = ref.watch(categoryFilterProvider);

      return productsAsync.whenData((products) {
        if (categoryFilter == null) return products;
        return products.where((p) => p.category == categoryFilter).toList();
      });
    });

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Product product, String tenantId) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id && item.tenantId == tenantId,
    );

    if (existingIndex >= 0) {
      final updatedState = [...state];
      updatedState[existingIndex] = CartItem(
        product: product,
        quantity: updatedState[existingIndex].quantity + 1,
        tenantId: tenantId,
      );
      state = updatedState;
    } else {
      state = [...state, CartItem(product: product, tenantId: tenantId)];
    }
  }

  void removeFromCart(String productId, String tenantId) {
    state =
        state
            .where(
              (item) =>
                  !(item.product.id == productId && item.tenantId == tenantId),
            )
            .toList();
  }

  void updateQuantity(String productId, String tenantId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId, tenantId);
      return;
    }

    final updatedState = [...state];
    final index = updatedState.indexWhere(
      (item) => item.product.id == productId && item.tenantId == tenantId,
    );

    if (index >= 0) {
      updatedState[index] = CartItem(
        product: updatedState[index].product,
        quantity: quantity,
        tenantId: tenantId,
      );
      state = updatedState;
    }
  }

  void clearCart() {
    state = [];
  }

  double getTotal() {
    return state.fold(0, (sum, item) => sum + item.total);
  }

  int getItemCount() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

// UI components
class BillingScreen extends ConsumerWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTenant = ref.watch(currentTenantProvider);

    // If no tenant is selected, show tenant selection
    if (currentTenant == null) {
      return const TenantSelectionScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(currentTenant.logoUrl),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Text(
              currentTenant.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF4A5568)),
            onPressed: () {
              // Open filter menu
              _showFilterBottomSheet(context, ref);
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF4A5568),
                ),
                onPressed: () {
                  _showCartBottomSheet(context, ref);
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${ref.watch(cartProvider.notifier).getItemCount()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4A5568)),
            onPressed: () {
              ref.read(currentTenantProvider.notifier).state = null;
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Products & Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
          // Category filter chips
          _buildCategoryFilter(ref, currentTenant.id),
          // Product grid
          Expanded(child: _buildProductGrid(ref, currentTenant)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref),
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref, String tenantId) {
    final selectedCategory = ref.watch(categoryFilterProvider);
    final productsAsync = ref.watch(productsProvider(tenantId));

    return productsAsync.when(
      data: (products) {
        // Extract unique categories
        final categories = products.map((p) => p.category).toSet().toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                selected: selectedCategory == null,
                label: const Text('All'),
                onSelected: (selected) {
                  if (selected) {
                    ref.read(categoryFilterProvider.notifier).state = null;
                  }
                },
                selectedColor: const Color(0xFFBEE3F8),
                checkmarkColor: const Color(0xFF2B6CB0),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        selectedCategory == null
                            ? const Color(0xFF2B6CB0)
                            : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: selectedCategory == category,
                        label: Text(category),
                        onSelected: (selected) {
                          ref.read(categoryFilterProvider.notifier).state =
                              selected ? category : null;
                        },
                        selectedColor: const Color(0xFFBEE3F8),
                        checkmarkColor: const Color(0xFF2B6CB0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                selectedCategory == category
                                    ? const Color(0xFF2B6CB0)
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load categories')),
    );
  }

  Widget _buildProductGrid(WidgetRef ref, Tenant tenant) {
    final productsAsync = ref.watch(filteredProductsProvider(tenant.id));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products found in this category',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(product: product, tenantId: tenant.id);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load products')),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).getTotal();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 16,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(total),
                    style: const TextStyle(
                      color: Color(0xFF1A202C),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed:
                  cartItems.isEmpty
                      ? null
                      : () => _showCheckoutDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Checkout (${cartItems.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Filter options could be added here
              Text('Additional filter options would go here'),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showCartBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return CartBottomSheet(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    final cartItems = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).getTotal();
    final currentTenant = ref.read(currentTenantProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tenant: ${currentTenant?.name}'),
              const SizedBox(height: 8),
              const Text('Selected items:'),
              ...cartItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} x ${item.quantity}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(item.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                // Process the purchase
                ref.read(cartProvider.notifier).clearCart();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchase completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  final String tenantId;

  const _ProductCard({required this.product, required this.tenantId, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEBF4FF),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image:
                    product.imageUrl != null
                        ? DecorationImage(
                          image: AssetImage(product.imageUrl!),
                          fit: BoxFit.contain,
                        )
                        : null,
              ),
              width: double.infinity,
              child:
                  product.imageUrl == null
                      ? Center(
                        child: Icon(
                          _getCategoryIcon(product.category),
                          size: 48,
                          color: const Color(0xFF3B82F6),
                        ),
                      )
                      : null,
            ),
          ),
          // Product details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      NumberFormat.currency(symbol: '\$').format(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .addToCart(product, tenantId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'subscription':
        return Icons.sync_alt;
      case 'service':
        return Icons.support_agent;
      case 'hosting':
        return Icons.dns;
      case 'domain':
        return Icons.language;
      case 'add-on':
        return Icons.extension;
      default:
        return Icons.shop;
    }
  }
}

class CartBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const CartBottomSheet({required this.scrollController, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).getTotal();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Your Cart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (cartItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
          ),
          // Cart items
          Expanded(
            child:
                cartItems.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Color(0xFFCBD5E0),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return CartItemTile(cartItem: item);
                      },
                    ),
          ),
          // Checkout button
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Checkout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to checkout or show checkout dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}

class CartItemTile extends ConsumerWidget {
  final CartItem cartItem;

  const CartItemTile({required this.cartItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF4FF),
              borderRadius: BorderRadius.circular(12),
              image:
                  cartItem.product.imageUrl != null
                      ? DecorationImage(
                        image: AssetImage(cartItem.product.imageUrl!),
                        fit: BoxFit.contain,
                      )
                      : null,
            ),
            child:
                cartItem.product.imageUrl == null
                    ? Icon(
                      _getCategoryIcon(cartItem.product.category),
                      size: 30,
                      color: const Color(0xFF3B82F6),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat.currency(symbol: '\$').format(cartItem.product.price)} per unit',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Quantity control
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .updateQuantity(
                              cartItem.product.id,
                              cartItem.tenantId,
                              cartItem.quantity - 1,
                            );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .updateQuantity(
                              cartItem.product.id,
                              cartItem.tenantId,
                              cartItem.quantity + 1,
                            );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$').format(cartItem.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53E3E),
                  size: 20,
                ),
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .removeFromCart(cartItem.product.id, cartItem.tenantId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'subscription':
        return Icons.sync_alt;
      case 'service':
        return Icons.support_agent;
      case 'hosting':
        return Icons.dns;
      case 'domain':
        return Icons.language;
      case 'add-on':
        return Icons.extension;
      default:
        return Icons.shop;
    }
  }
}

class TenantSelectionScreen extends ConsumerWidget {
  const TenantSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample tenant data
    final tenants = [
      Tenant(
        id: 't1',
        name: 'Acme Corp',
        logoUrl:
            'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon/150',
      ),
      Tenant(
        id: 't2',
        name: 'TechStart Inc',
        logoUrl:
            'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon/150/0000FF',
      ),
      Tenant(
        id: 't3',
        name: 'Bright Solutions',
        logoUrl:
            'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon/150/00FF00',
      ),
      Tenant(
        id: 't4',
        name: 'Global Services',
        logoUrl:
            'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon/150/FF0000',
      ),
      Tenant(
        id: 't5',
        name: 'Metro Media',
        logoUrl:
            'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon/150/FFFF00',
      ),
      Tenant(
        id: 't6',
        name: 'Health Partners',
        logoUrl:
            'https://https://api.uplead.com/v2/company-name-to-domain?company_name=amazon/150/FF00FF',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Tenant',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the tenant to manage billing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final tenant = tenants[index];
                  return TenantCard(
                    tenant: tenant,
                    onTap: () {
                      ref.read(currentTenantProvider.notifier).state = tenant;
                    },
                  );
                }, childCount: tenants.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onTap;

  const TenantCard({required this.tenant, required this.onTap, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(tenant.logoUrl),
                radius: 32,
              ),
              const SizedBox(height: 12),
              Text(
                tenant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main application
class BillingApp extends StatelessWidget {
  const BillingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Multi-Tenant Billing',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF8F9FC),
          appBarTheme: const AppBarTheme(
            color: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF4A5568)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const BillingScreen(),
      ),
    );
  }
}

// For running the app
void main() {
  runApp(const BillingApp());
}
