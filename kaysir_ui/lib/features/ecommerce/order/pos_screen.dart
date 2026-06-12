import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/models/app_theme.dart';
import '../cart/states/cart_providers.dart';
import '../cart/cart_item_tile.dart';
import '../cart/cart_summary.dart';
import '../catalog/states/catalog_provider.dart';
import 'states/order_provider.dart';
import '../payment_button.dart';
import '../../product/widgets/product_card.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(ecommerceCategoriesProvider);
    final catalogFilter = ref.watch(ecommerceCatalogFilterProvider);
    final filteredProducts = ref.watch(ecommerceFilteredProductsProvider);
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
                                      .read(
                                        ecommerceCatalogFilterProvider.notifier,
                                      )
                                      .state = catalogFilter.copyWith(
                                    query: '',
                                  );
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      ref
                          .read(ecommerceCatalogFilterProvider.notifier)
                          .state = catalogFilter.copyWith(query: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: catalogFilter.category == null,
                          onSelected: (selected) {
                            ref
                                .read(ecommerceCatalogFilterProvider.notifier)
                                .state = catalogFilter.copyWith(
                              clearCategory: true,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        ...categories
                            .where((category) => category != 'All')
                            .map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: catalogFilter.category == category,
                                  onSelected: (selected) {
                                    ref
                                        .read(
                                          ecommerceCatalogFilterProvider
                                              .notifier,
                                        )
                                        .state = catalogFilter.copyWith(
                                      category: selected ? category : null,
                                      clearCategory: !selected,
                                    );
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
                                  onSelected:
                                      ref
                                          .read(cartProvider.notifier)
                                          .addProduct,
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
                          .read(ecommerceOrdersProvider.notifier)
                          .addOrder(List.from(cart), paymentMethod);

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
