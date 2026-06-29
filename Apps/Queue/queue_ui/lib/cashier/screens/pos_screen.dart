import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_theme.dart';
import '../states/cashier_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';
import '../widgets/payment_button.dart';
import '../widgets/product_card.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Point of Sale',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Products section (left side)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(filteredProductsProvider.notifier)
                                      .setSearchQuery('');
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      ref
                          .read(filteredProductsProvider.notifier)
                          .setSearchQuery(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategory == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = null;
                            });
                            ref
                                .read(filteredProductsProvider.notifier)
                                .setCategory(null);
                          },
                        ),
                        const SizedBox(width: 8),
                        ...categories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                });
                                ref
                                    .read(filteredProductsProvider.notifier)
                                    .setCategory(selected ? category : null);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        filteredProducts.isEmpty
                            ? const Center(child: Text('No products found'))
                            : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.85,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ProductCard(
                                  product: product,
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addProduct(product);
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),

          // Cart section (right side)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppThemeCashier.primaryColor,
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Current Sale',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        if (cart.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed:
                                () =>
                                    ref.read(cartProvider.notifier).clearCart(),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        cart.isEmpty
                            ? const Center(
                              child: Text(
                                'Cart is empty',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                            : ListView.builder(
                              itemCount: cart.length,
                              itemBuilder: (context, index) {
                                final item = cart[index];
                                return CartItemTile(
                                  item: item,
                                  onQuantityChanged: (quantity) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          item.product.id,
                                          quantity,
                                        );
                                  },
                                  onRemove: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .removeProduct(item.product.id);
                                  },
                                );
                              },
                            ),
                  ),
                  CartSummary(cartTotal: cartTotal),
                  PaymentButtons(
                    onPaymentSelected: (paymentMethod) {
                      if (cart.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cart is empty')),
                        );
                        return;
                      }

                      ref
                          .read(recentOrdersProvider.notifier)
                          .addOrder(List.from(cart), cartTotal, paymentMethod);

                      ref.read(cartProvider.notifier).clearCart();

                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Payment Successful'),
                              content: const Text(
                                'Order has been completed successfully.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
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
}
