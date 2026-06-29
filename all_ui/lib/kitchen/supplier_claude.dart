import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
class Supplier {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final double rating;
  final bool isPreferred;

  Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.rating,
    this.isPreferred = false,
  });
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final DateTime orderDate;
  final String status;
  final double totalAmount;
  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.items,
  });
}

class PurchaseOrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  PurchaseOrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

// Repositories
class SupplierRepository {
  Future<List<Supplier>> getSuppliers() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      Supplier(
        id: '1',
        name: 'TechSupply Inc.',
        email: 'contact@techsupply.com',
        phone: '(555) 123-4567',
        address: '123 Tech Lane, Silicon Valley, CA',
        rating: 4.8,
        isPreferred: true,
      ),
      Supplier(
        id: '2',
        name: 'Global Parts Ltd.',
        email: 'info@globalparts.com',
        phone: '(555) 987-6543',
        address: '456 Industrial Blvd, Detroit, MI',
        rating: 4.2,
      ),
      Supplier(
        id: '3',
        name: 'Innovative Materials',
        email: 'sales@innovativematerials.com',
        phone: '(555) 345-6789',
        address: '789 Innovation Way, Boston, MA',
        rating: 4.5,
        isPreferred: true,
      ),
    ];
  }

  Future<List<PurchaseOrder>> getPurchaseOrdersForSupplier(
    String supplierId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      PurchaseOrder(
        id: 'PO-2023-001',
        supplierId: supplierId,
        orderDate: DateTime.now().subtract(const Duration(days: 30)),
        status: 'Delivered',
        totalAmount: 5280.00,
        items: [
          PurchaseOrderItem(
            id: 'POI-001',
            productName: 'Component A',
            quantity: 100,
            unitPrice: 42.80,
            total: 4280.00,
          ),
          PurchaseOrderItem(
            id: 'POI-002',
            productName: 'Component B',
            quantity: 50,
            unitPrice: 20.00,
            total: 1000.00,
          ),
        ],
      ),
      PurchaseOrder(
        id: 'PO-2023-002',
        supplierId: supplierId,
        orderDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'In Transit',
        totalAmount: 3200.00,
        items: [
          PurchaseOrderItem(
            id: 'POI-003',
            productName: 'Component C',
            quantity: 80,
            unitPrice: 40.00,
            total: 3200.00,
          ),
        ],
      ),
    ];
  }
}

// Providers
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository();
});

final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.getSuppliers();
});

final selectedSupplierIdProvider = StateProvider<String?>((ref) => null);

final purchaseOrdersProvider =
    FutureProvider.family<List<PurchaseOrder>, String>((ref, supplierId) async {
      final repository = ref.watch(supplierRepositoryProvider);
      return repository.getPurchaseOrdersForSupplier(supplierId);
    });

// UI Components
class SupplierManagementScreen extends ConsumerWidget {
  const SupplierManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersProvider);
    final selectedSupplierId = ref.watch(selectedSupplierIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add Supplier functionality coming soon'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(suppliersProvider);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Supplier List Panel
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Suppliers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildSearchField(context),
                      ],
                    ),
                  ),
                  Expanded(
                    child: suppliersAsync.when(
                      data:
                          (suppliers) => ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: suppliers.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              final isSelected =
                                  selectedSupplierId == supplier.id;

                              return ListTile(
                                selected: isSelected,
                                selectedTileColor:
                                    Theme.of(context).primaryColor,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text(
                                    supplier.name[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      supplier.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (supplier.isPreferred)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Preferred',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(supplier.email),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildRatingStars(supplier.rating),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  ref
                                      .read(selectedSupplierIdProvider.notifier)
                                      .state = supplier.id;
                                },
                              );
                            },
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) => Center(
                            child: Text('Error loading suppliers: $error'),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Supplier Details Panel
          Expanded(
            flex: 3,
            child:
                selectedSupplierId == null
                    ? const Center(
                      child: Text('Select a supplier to view details'),
                    )
                    : _buildSupplierDetails(context, ref, selectedSupplierId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New Order functionality coming soon'),
            ),
          );
        },
        tooltip: 'Create New Order',
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      width: 200,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          hintText: 'Search suppliers...',
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, size: 18),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 2),
        Text(rating.toString(), style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSupplierDetails(
    BuildContext context,
    WidgetRef ref,
    String supplierId,
  ) {
    final suppliersAsync = ref.watch(suppliersProvider);
    final purchaseOrdersAsync = ref.watch(purchaseOrdersProvider(supplierId));

    return suppliersAsync.when(
      data: (suppliers) {
        final supplier = suppliers.firstWhere((s) => s.id == supplierId);

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        supplier.name[0],
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            supplier.address,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text('Contact'),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Supplier info and Purchase Orders
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoItem(
                              Icons.email,
                              'Email',
                              supplier.email,
                            ),
                            _buildInfoItem(
                              Icons.phone,
                              'Phone',
                              supplier.phone,
                            ),
                            _buildInfoItem(
                              Icons.location_on,
                              'Address',
                              supplier.address,
                            ),
                            _buildInfoItem(
                              Icons.star,
                              'Rating',
                              '${supplier.rating} / 5.0',
                            ),
                            const Divider(height: 32),
                            const Text(
                              'Performance Metrics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPerformanceMetric(
                              context,
                              'On-time Delivery',
                              0.92,
                              Colors.green,
                            ),
                            _buildPerformanceMetric(
                              context,
                              'Quality Score',
                              0.88,
                              Colors.blue,
                            ),
                            _buildPerformanceMetric(
                              context,
                              'Response Time',
                              0.78,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Purchase Orders
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Purchase Orders',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: purchaseOrdersAsync.when(
                                data:
                                    (orders) =>
                                        orders.isEmpty
                                            ? const Center(
                                              child: Text(
                                                'No purchase orders found',
                                              ),
                                            )
                                            : ListView.builder(
                                              itemCount: orders.length,
                                              itemBuilder: (context, index) {
                                                final order = orders[index];
                                                return Card(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 12,
                                                  ),
                                                  elevation: 1,
                                                  child: ExpansionTile(
                                                    title: Text(
                                                      'Order #${order.id}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Row(
                                                      children: [
                                                        Text(
                                                          DateFormat(
                                                            'MMM dd, yyyy',
                                                          ).format(
                                                            order.orderDate,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        _buildStatusChip(
                                                          context,
                                                          order.status,
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: Text(
                                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                        color:
                                                            Colors.grey.shade50,
                                                        child: Column(
                                                          children: [
                                                            ...order.items.map(
                                                              (item) => Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child: Text(
                                                                        item.productName,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Text(
                                                                        '${item.quantity}x',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Text(
                                                                        '\$${item.unitPrice.toStringAsFixed(2)}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Text(
                                                                        '\$${item.total.toStringAsFixed(2)}',
                                                                        textAlign:
                                                                            TextAlign.right,
                                                                        style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const Divider(),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 8,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  const Spacer(),
                                                                  const Text(
                                                                    'Total: ',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '\$${order.totalAmount.toStringAsFixed(2)}',
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ButtonBar(
                                                              alignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                TextButton.icon(
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .receipt,
                                                                  ),
                                                                  label:
                                                                      const Text(
                                                                        'Invoice',
                                                                      ),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                                TextButton.icon(
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .visibility,
                                                                  ),
                                                                  label:
                                                                      const Text(
                                                                        'Details',
                                                                      ),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                loading:
                                    () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                error:
                                    (error, stack) => Center(
                                      child: Text(
                                        'Error loading orders: $error',
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
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading supplier details: $error')),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'in transit':
        color = Colors.blue;
        break;
      case 'processing':
        color = Colors.orange;
        break;
      case 'pending':
        color = Colors.amber;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

// Main App
class SupplierManagementApp extends StatelessWidget {
  const SupplierManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supplier Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const SupplierManagementScreen(),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: SupplierManagementApp()));
}
