import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum OrderStatus { draft, confirmed, received, cancelled }

// Providers
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) {
    return ProductsNotifier();
  },
);

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final filter = ref.watch(productFilterProvider);

  if (filter.isEmpty) return products;

  return products
      .where(
        (product) =>
            product.name.toLowerCase().contains(filter.toLowerCase()) ||
            product.sku.toLowerCase().contains(filter.toLowerCase()) ||
            product.category.toLowerCase().contains(filter.toLowerCase()),
      )
      .toList();
});

final productFilterProvider = StateProvider<String>((ref) => '');

// Notifiers
class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier()
    : super([
        Product(
          id: '1',
          name: 'Wireless Earbuds',
          sku: 'WE-001',
          category: 'Electronics',
          price: 89.99,
          currentStock: 45,
          imageUrl: 'https://example.com/earbuds.jpg',
          description: 'High-quality wireless earbuds with noise cancellation',
        ),
        Product(
          id: '2',
          name: 'Fitness Tracker',
          sku: 'FT-002',
          category: 'Wearables',
          price: 59.99,
          currentStock: 32,
          imageUrl: 'https://example.com/tracker.jpg',
          description:
              'Water-resistant fitness tracker with heart rate monitoring',
        ),
        Product(
          id: '3',
          name: 'Smart Speaker',
          sku: 'SS-003',
          category: 'Electronics',
          price: 129.99,
          currentStock: 18,
          imageUrl: 'https://example.com/speaker.jpg',
          description: 'Voice-controlled smart speaker with premium sound',
        ),
      ]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void updateStock(String productId, int newStock) {
    state =
        state
            .map(
              (p) => p.id == productId ? p.copyWith(currentStock: newStock) : p,
            )
            .toList();
  }
}

/* 
class _InventoryDashboardState extends State<InventoryDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ProductsScreen(),
    StockMovementsScreen(),
    PurchaseOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.swap_horiz_outlined),
                selectedIcon: Icon(Icons.swap_horiz),
                label: Text('Stock Movements'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Purchase Orders'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
 */
// Products Screen
class ProductsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to add product screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditProductScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(productFilterProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child:
                products.isEmpty
                    ? Center(child: Text('No products found'))
                    : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 1200
                                ? 4
                                : MediaQuery.of(context).size.width > 800
                                ? 3
                                : 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(product: product);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final stockStatus =
        product.currentStock > 20
            ? StockStatus.inStock
            : product.currentStock > 5
            ? StockStatus.limited
            : StockStatus.low;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 48,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      StockStatusBadge(status: stockStatus),
                    ],
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

// Add Stock Movement Screen

// Create Purchase Order Screen

// Add Order Item Dialog

// Dashboard Widgets

// Updates to InventoryDashboardState to include Dashboard

// Inventory Analytics Screen
class InventoryAnalyticsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final stockMovements = ref.watch(stockMovementsProvider);

    // Group products by category for visualization
    final categoryMap = <String, int>{};
    final categoryValueMap = <String, double>{};

    for (var product in products) {
      categoryMap[product.category] = (categoryMap[product.category] ?? 0) + 1;
      categoryValueMap[product.category] =
          (categoryValueMap[product.category] ?? 0) +
          (product.price * product.currentStock);
    }

    // Calculate turnover rate (if there are stock movements)
    final Map<String, double> turnoverRates = {};

    if (stockMovements.isNotEmpty) {
      // Group movements by product
      final productMovements = <String, List<StockMovement>>{};

      for (var movement in stockMovements) {
        if (!productMovements.containsKey(movement.productId)) {
          productMovements[movement.productId] = [];
        }
        productMovements[movement.productId]!.add(movement);
      }

      // Calculate turnover for each product with movements
      for (var productId in productMovements.keys) {
        final product = products.firstWhere(
          (p) => p.id == productId,
          orElse:
              () => Product(
                id: productId,
                name: 'Unknown',
                sku: 'Unknown',
                category: 'Unknown',
                price: 0,
                currentStock: 0,
                imageUrl: '',
                description: '',
              ),
        );

        final outboundMovements =
            productMovements[productId]!
                .where((m) => m.type == MovementType.outbound)
                .toList();

        if (outboundMovements.isNotEmpty && product.currentStock > 0) {
          final totalOutbound = outboundMovements.fold(
            0,
            (sum, movement) => sum + movement.quantity,
          );

          // Basic turnover calculation (outbound / average inventory)
          turnoverRates[product.name] = totalOutbound / product.currentStock;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Inventory Analytics')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: _buildCategoryDistributionChart(categoryMap),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Value by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: _buildInventoryValueChart(categoryValueMap),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            turnoverRates.isEmpty
                ? SizedBox()
                : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Turnover Rates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: _buildTurnoverRateChart(turnoverRates),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart(Map<String, int> categoryMap) {
    // Placeholder for chart (in a real app, you'd use a chart library)
    return Center(
      child: ListView(
        children:
            categoryMap.entries.map((entry) {
              final percentage =
                  (entry.value /
                      categoryMap.values.fold(0, (sum, count) => sum + count)) *
                  100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key} (${entry.value} products)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 20,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildInventoryValueChart(Map<String, double> categoryValueMap) {
    // Placeholder for chart (in a real app, you'd use a chart library)
    return Center(
      child: ListView(
        children:
            categoryValueMap.entries.map((entry) {
              final totalValue = categoryValueMap.values.fold(
                0.0,
                (sum, value) => sum + value,
              );
              final percentage = (entry.value / totalValue) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key} (\$${entry.value.toStringAsFixed(2)})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 20,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTurnoverRateChart(Map<String, double> turnoverRates) {
    // Placeholder for chart (in a real app, you'd use a chart library)
    final sortedProducts =
        turnoverRates.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Center(
      child: ListView(
        children:
            sortedProducts.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: entry.value > 1.0 ? 1.0 : entry.value,
                            minHeight: 20,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${entry.value.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

// Add Analytics option to the navigation rail
class _InventoryDashboardStateWithAnalytics extends State<InventoryDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    ProductsScreen(),
    StockMovementsScreen(),
    PurchaseOrdersScreen(),
    InventoryAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.swap_horiz_outlined),
                selectedIcon: Icon(Icons.swap_horiz),
                label: Text('Stock Movements'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Purchase Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

// Main function
void main() {
  runApp(InventoryApp());
}
