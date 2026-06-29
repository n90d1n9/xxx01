import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Models
class DeliveryItem {
  final String id;
  final String productName;
  final String destination;
  final DateTime scheduledDate;
  final String status;
  final double quantity;
  final String unit;
  final String imageUrl;

  DeliveryItem({
    required this.id,
    required this.productName,
    required this.destination,
    required this.scheduledDate,
    required this.status,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
  });
}

// Sample data
final List<DeliveryItem> initialDeliveries = [
  DeliveryItem(
    id: 'DEL-1001',
    productName: 'Organic Apples',
    destination: 'GreenMart Superstore',
    scheduledDate: DateTime.now().add(Duration(days: 1)),
    status: 'Pending',
    quantity: 500,
    unit: 'kg',
    imageUrl: 'assets/apple.png',
  ),
  DeliveryItem(
    id: 'DEL-1002',
    productName: 'Premium Coffee Beans',
    destination: 'Urban Cafe Chain',
    scheduledDate: DateTime.now(),
    status: 'In Transit',
    quantity: 200,
    unit: 'kg',
    imageUrl: 'assets/coffee.png',
  ),
  DeliveryItem(
    id: 'DEL-1003',
    productName: 'Dairy Products',
    destination: 'QuickShop Markets',
    scheduledDate: DateTime.now().add(Duration(days: 2)),
    status: 'Scheduled',
    quantity: 350,
    unit: 'liters',
    imageUrl: 'assets/dairy.png',
  ),
  DeliveryItem(
    id: 'DEL-1004',
    productName: 'Fresh Bread',
    destination: 'Morning Bakeries',
    scheduledDate: DateTime.now(),
    status: 'Delivered',
    quantity: 100,
    unit: 'boxes',
    imageUrl: 'assets/bread.png',
  ),
];

// State notifiers and providers
class DeliveryNotifier extends StateNotifier<List<DeliveryItem>> {
  DeliveryNotifier() : super(initialDeliveries);

  void filterByStatus(String status) {
    if (status == 'All') {
      state = initialDeliveries;
    } else {
      state = initialDeliveries.where((item) => item.status == status).toList();
    }
  }

  void searchDeliveries(String query) {
    if (query.isEmpty) {
      state = initialDeliveries;
    } else {
      state =
          initialDeliveries
              .where(
                (item) =>
                    item.productName.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    item.destination.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    item.id.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
  }
}

final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, List<DeliveryItem>>(
      (ref) => DeliveryNotifier(),
    );

final selectedFilterProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

// Main Screen
class GoodsDistributionScreen extends ConsumerWidget {
  const GoodsDistributionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(deliveryProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distribution Hub',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      Text(
                        'Manage your deliveries efficiently',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey[700],
                    child: IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  ref.read(deliveryProvider.notifier).searchDeliveries(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search deliveries...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.blueGrey[400]),
                  border: InputBorder.none,
                ),
              ),
            ),

            // Filter Chips
            Container(
              height: 60,
              margin: const EdgeInsets.only(top: 20),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', selectedFilter, ref),
                  _buildFilterChip('Pending', selectedFilter, ref),
                  _buildFilterChip('In Transit', selectedFilter, ref),
                  _buildFilterChip('Scheduled', selectedFilter, ref),
                  _buildFilterChip('Delivered', selectedFilter, ref),
                ],
              ),
            ),

            // Stats Cards
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard(
                    'Total Deliveries',
                    initialDeliveries.length.toString(),
                    Colors.blue,
                    Icons.local_shipping_outlined,
                  ),
                  _buildStatCard(
                    'In Transit',
                    initialDeliveries
                        .where((item) => item.status == 'In Transit')
                        .length
                        .toString(),
                    Colors.amber,
                    Icons.directions_car_outlined,
                  ),
                  _buildStatCard(
                    'Delivered',
                    initialDeliveries
                        .where((item) => item.status == 'Delivered')
                        .length
                        .toString(),
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),

            // Deliveries List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Deliveries',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List of deliveries
            Expanded(
              child:
                  deliveries.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'No deliveries found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: deliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = deliveries[index];
                          return _buildDeliveryCard(delivery, context);
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedFilter, WidgetRef ref) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        ref.read(selectedFilterProvider.notifier).state = label;
        ref.read(deliveryProvider.notifier).filterByStatus(label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.blueGrey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    MaterialColor color,
    IconData icon,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color[700], size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: color[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryItem delivery, BuildContext context) {
    // Status color mapping
    final statusColors = {
      'Pending': Colors.orange,
      'In Transit': Colors.blue,
      'Scheduled': Colors.purple,
      'Delivered': Colors.green,
    };

    final color = statusColors[delivery.status] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Product Image or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: color[700],
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            // Delivery Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        delivery.productName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          delivery.status,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: color[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'To: ${delivery.destination}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueGrey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(delivery.scheduledDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${delivery.quantity} ${delivery.unit}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey[700],
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
  }
}

// Main app entry
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Goods Distribution Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const GoodsDistributionScreen(),
    );
  }
}
