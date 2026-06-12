import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ProviderScope(child: const MaterialApp(home: LaundryApp())));
}

// Models
class LaundryItem {
  final String id;
  final String name;
  final double price;
  final String icon;
  int quantity;

  LaundryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    this.quantity = 0,
  });
}

class Order {
  final List<LaundryItem> items;
  final double deliveryFee;
  final DateTime pickupDate;
  final DateTime deliveryDate;

  Order({
    required this.items,
    this.deliveryFee = 2.99,
    required this.pickupDate,
    required this.deliveryDate,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get total => subtotal + deliveryFee;
}

// Providers
final laundryItemsProvider = StateProvider<List<LaundryItem>>((ref) {
  return [
    LaundryItem(id: '1', name: 'T-Shirt', price: 1.99, icon: '👕'),
    LaundryItem(id: '2', name: 'Pants', price: 2.99, icon: '👖'),
    LaundryItem(id: '3', name: 'Dress', price: 5.99, icon: '👗'),
    LaundryItem(id: '4', name: 'Suit', price: 8.99, icon: '🧥'),
    LaundryItem(id: '5', name: 'Bedsheet', price: 4.99, icon: '🛏️'),
    LaundryItem(id: '6', name: 'Towel', price: 1.49, icon: '🧖'),
  ];
});

final pickupDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now().add(const Duration(days: 1));
});

final deliveryDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now().add(const Duration(days: 2));
});

final orderProvider = Provider<Order>((ref) {
  final items = ref.watch(laundryItemsProvider);
  final pickupDate = ref.watch(pickupDateProvider);
  final deliveryDate = ref.watch(deliveryDateProvider);

  return Order(
    items: items,
    pickupDate: pickupDate,
    deliveryDate: deliveryDate,
  );
});

// Main Widget
class LaundryOrderScreen extends ConsumerWidget {
  const LaundryOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(laundryItemsProvider);
    final order = ref.watch(orderProvider);
    final pickupDate = ref.watch(pickupDateProvider);
    final deliveryDate = ref.watch(deliveryDateProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'New Order',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Delivery Options Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDateSelector(
                            context,
                            'Pickup',
                            pickupDate,
                            (date) =>
                                ref.read(pickupDateProvider.notifier).state =
                                    date,
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildDateSelector(
                            context,
                            'Delivery',
                            deliveryDate,
                            (date) =>
                                ref.read(deliveryDateProvider.notifier).state =
                                    date,
                            Icons.local_shipping_outlined,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Services Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Services',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Laundry Items Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildItemCard(context, ref, item);
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildOrderSummary(context, order),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onDateChanged,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 14)),
        );
        if (selectedDate != null) {
          onDateChanged(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, LaundryItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (item.quantity > 0) {
                      final updatedItems = [...ref.read(laundryItemsProvider)];
                      final index = updatedItems.indexWhere(
                        (i) => i.id == item.id,
                      );
                      updatedItems[index].quantity--;
                      ref.read(laundryItemsProvider.notifier).state =
                          updatedItems;
                    }
                  },
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: item.quantity > 0 ? Colors.blue : Colors.grey[300],
                  ),
                ),
                Text(
                  '${item.quantity}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final updatedItems = [...ref.read(laundryItemsProvider)];
                    final index = updatedItems.indexWhere(
                      (i) => i.id == item.id,
                    );
                    updatedItems[index].quantity++;
                    ref.read(laundryItemsProvider.notifier).state =
                        updatedItems;
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, Order order) {
    final hasItems = order.items.any((item) => item.quantity > 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasItems) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  Text(
                    '\$${order.subtotal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Fee',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  Text(
                    '\$${order.deliveryFee.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasItems ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  hasItems ? 'Place Order' : 'Add Items to Cart',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// For usage in main.dart
class LaundryApp extends ConsumerWidget {
  const LaundryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[800]),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const LaundryOrderScreen(),
    );
  }
}
