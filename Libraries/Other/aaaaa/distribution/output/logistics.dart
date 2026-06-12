import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// CLASSS

class ShipmentStatus {
  final String id;
  final String name;
  final Color color;
  const ShipmentStatus({
    required this.id,
    required this.name,
    required this.color,
  });
}

class Shipment {
  final String id;
  final String trackingNumber;
  final String origin;
  final String destination;
  final DateTime estimatedDelivery;
  final ShipmentStatus status;
  final double progress;
  const Shipment({
    required this.id,
    required this.trackingNumber,
    required this.origin,
    required this.destination,
    required this.estimatedDelivery,
    required this.status,
    required this.progress,
  });
}

class LogisticsOverviewScreen extends ConsumerWidget {
  const LogisticsOverviewScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final shipmentsByStatus = ref.watch(shipmentsByStatusProvider);
    final statuses = ref.watch(shipmentStatusesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Logistics Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment Calendar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(
                            Duration(days: index),
                          );
                          final isSelected =
                              DateFormat('yyyy-MM-dd').format(date) ==
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                          return GestureDetector(
                            onTap: () =>
                                ref.read(selectedDateProvider.notifier).state =
                                    date,
                            child: Container(
                              width: 65,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF3D5AF1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF3D5AF1)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat(
                                      'E',
                                    ).format(date).substring(0, 1),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('d').format(date),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      'Total Shipments',
                      shipmentsByStatus.values
                          .fold(0, (a, b) => a + b)
                          .toString(),
                      Icons.inventory_2_outlined,
                      const Color(0xFF3D5AF1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusCard(
                      'In Transit',
                      shipmentsByStatus['in_transit'].toString(),
                      Icons.local_shipping_outlined,
                      const Color(0xFF22BABB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      'Delivered',
                      shipmentsByStatus['delivered'].toString(),
                      Icons.check_circle_outline,
                      const Color(0xFF02A85C),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusCard(
                      'Delayed',
                      shipmentsByStatus['delayed'].toString(),
                      Icons.error_outline,
                      const Color(0xFFFF6C44),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment Analytics',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: statuses.map((status) {
                            final count = shipmentsByStatus[status.id] ?? 0;
                            final total = shipmentsByStatus.values.fold(
                              0,
                              (a, b) => a + b,
                            );
                            return PieChartSectionData(
                              color: status.color,
                              value: count.toDouble(),
                              title:
                                  '${(count / total * 100).toStringAsFixed(0)}%',
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: statuses.map((status) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const ShipmentListSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF3D5AF1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Track'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3D5AF1),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ShipmentListSection extends ConsumerWidget {
  const ShipmentListSection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredShipments = ref.watch(filteredShipmentsProvider);
    final selectedShipmentId = ref.watch(selectedShipmentProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Shipments',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF3D5AF1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          filteredShipments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No shipments found for this date',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredShipments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final shipment = filteredShipments[index];
                    final isSelected = selectedShipmentId == shipment.id;
                    return InkWell(
                      onTap: () =>
                          ref.read(selectedShipmentProvider.notifier).state =
                              isSelected ? null : shipment.id,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? const Color(0xFFF0F3FF)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: shipment.status.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: shipment.status.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shipment.trackingNumber,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${shipment.origin} → ${shipment.destination}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: shipment.status.color.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        shipment.status.name,
                                        style: TextStyle(
                                          color: shipment.status.color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'h:mm a',
                                      ).format(shipment.estimatedDelivery),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: shipment.progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  shipment.status.color,
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Estimated delivery: ${DateFormat('MMM d, yyyy • h:mm a').format(shipment.estimatedDelivery)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Track'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF3D5AF1),
                                      side: const BorderSide(
                                        color: Color(0xFF3D5AF1),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      minimumSize: const Size(0, 36),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Update'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3D5AF1),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      minimumSize: const Size(0, 36),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class LogisticsApp extends StatelessWidget {
  const LogisticsApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Logistics Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF3D5AF1),
          scaffoldBackgroundColor: const Color(0xFFF8F9FD),
          fontFamily: GoogleFonts.poppins().fontFamily,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const LogisticsOverviewScreen(),
      ),
    );
  }
}

// FUNCTIONS

void main() {
  runApp(const LogisticsApp());
}

// TOP_LEVEL_VARIABLES

final shipmentStatusesProvider = Provider<List<ShipmentStatus>>((ref) {
  return [
    ShipmentStatus(id: 'pending', name: 'Pending', color: Colors.orange),
    ShipmentStatus(id: 'in_transit', name: 'In Transit', color: Colors.blue),
    ShipmentStatus(id: 'delivered', name: 'Delivered', color: Colors.green),
    ShipmentStatus(id: 'delayed', name: 'Delayed', color: Colors.red),
  ];
});

final shipmentsProvider = Provider<List<Shipment>>((ref) {
  final statuses = ref.watch(shipmentStatusesProvider);
  return [
    Shipment(
      id: '1',
      trackingNumber: 'LGS-12345',
      origin: 'New York, NY',
      destination: 'Los Angeles, CA',
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      status: statuses.firstWhere((s) => s.id == 'in_transit'),
      progress: 0.65,
    ),
    Shipment(
      id: '2',
      trackingNumber: 'LGS-23456',
      origin: 'Chicago, IL',
      destination: 'Miami, FL',
      estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
      status: statuses.firstWhere((s) => s.id == 'in_transit'),
      progress: 0.8,
    ),
    Shipment(
      id: '3',
      trackingNumber: 'LGS-34567',
      origin: 'Seattle, WA',
      destination: 'Boston, MA',
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      status: statuses.firstWhere((s) => s.id == 'pending'),
      progress: 0.2,
    ),
    Shipment(
      id: '4',
      trackingNumber: 'LGS-45678',
      origin: 'Austin, TX',
      destination: 'Denver, CO',
      estimatedDelivery: DateTime.now().add(const Duration(hours: 12)),
      status: statuses.firstWhere((s) => s.id == 'delayed'),
      progress: 0.5,
    ),
    Shipment(
      id: '5',
      trackingNumber: 'LGS-56789',
      origin: 'San Francisco, CA',
      destination: 'Portland, OR',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 1)),
      status: statuses.firstWhere((s) => s.id == 'delivered'),
      progress: 1.0,
    ),
  ];
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final filteredShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return shipments.where((shipment) {
    return DateFormat('yyyy-MM-dd').format(shipment.estimatedDelivery) ==
        DateFormat('yyyy-MM-dd').format(selectedDate);
  }).toList();
});

final shipmentsByStatusProvider = Provider<Map<String, int>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  final statuses = ref.watch(shipmentStatusesProvider);
  final Map<String, int> counts = {};
  for (final status in statuses) {
    counts[status.id] = shipments.where((s) => s.status.id == status.id).length;
  }
  return counts;
});

final selectedShipmentProvider = StateProvider<String?>((ref) => null);
