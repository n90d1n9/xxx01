import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Models
class ShippingOrder {
  final String id;
  final String trackingNumber;
  final String origin;
  final String destination;
  final DateTime estimatedDelivery;
  final OrderStatus status;
  final List<TrackingEvent> events;
  final ShipmentDetails shipmentDetails;

  ShippingOrder({
    required this.id,
    required this.trackingNumber,
    required this.origin,
    required this.destination,
    required this.estimatedDelivery,
    required this.status,
    required this.events,
    required this.shipmentDetails,
  });
}

class TrackingEvent {
  final String location;
  final String description;
  final DateTime timestamp;
  final OrderStatus status;

  TrackingEvent({
    required this.location,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}

class ShipmentDetails {
  final String packageType;
  final double weight;
  final String dimensions;
  final String courier;
  final String senderName;
  final String recipientName;

  ShipmentDetails({
    required this.packageType,
    required this.weight,
    required this.dimensions,
    required this.courier,
    required this.senderName,
    required this.recipientName,
  });
}

enum OrderStatus { processing, inTransit, outForDelivery, delivered, exception }

// Providers
final selectedOrderIdProvider = StateProvider<String>((ref) => '1');

final ordersProvider = Provider<List<ShippingOrder>>((ref) {
  // Mock data - in a real app, this would come from an API
  return [
    ShippingOrder(
      id: '1',
      trackingNumber: 'TRK29384756',
      origin: 'New York, NY',
      destination: 'San Francisco, CA',
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      status: OrderStatus.inTransit,
      events: [
        TrackingEvent(
          location: 'Chicago, IL',
          description: 'Package arrived at sorting facility',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          status: OrderStatus.inTransit,
        ),
        TrackingEvent(
          location: 'New York, NY',
          description: 'Package departed from origin facility',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: OrderStatus.inTransit,
        ),
        TrackingEvent(
          location: 'New York, NY',
          description: 'Package processed at origin facility',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          status: OrderStatus.processing,
        ),
      ],
      shipmentDetails: ShipmentDetails(
        packageType: 'Standard Box',
        weight: 5.2,
        dimensions: '12×10×8 in',
        courier: 'FastShip Express',
        senderName: 'John Smith',
        recipientName: 'Jane Doe',
      ),
    ),
    ShippingOrder(
      id: '2',
      trackingNumber: 'TRK76543210',
      origin: 'Miami, FL',
      destination: 'Seattle, WA',
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      status: OrderStatus.processing,
      events: [
        TrackingEvent(
          location: 'Miami, FL',
          description: 'Package processed at origin facility',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          status: OrderStatus.processing,
        ),
      ],
      shipmentDetails: ShipmentDetails(
        packageType: 'Padded Envelope',
        weight: 1.3,
        dimensions: '9×12×1 in',
        courier: 'GlobalPost',
        senderName: 'Sarah Johnson',
        recipientName: 'Mike Wilson',
      ),
    ),
  ];
});

final selectedOrderProvider = Provider<ShippingOrder>((ref) {
  final orderId = ref.watch(selectedOrderIdProvider);
  final orders = ref.watch(ordersProvider);
  return orders.firstWhere((order) => order.id == orderId);
});

// UI Components
class ShippingOrderScreen extends ConsumerWidget {
  const ShippingOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOrder = ref.watch(selectedOrderProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Track Order',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Consumer(
                builder: (context, ref, _) {
                  final orders = ref.watch(ordersProvider);
                  final selectedOrderId = ref.watch(selectedOrderIdProvider);

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Order',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedOrderId,
                    items:
                        orders.map((order) {
                          return DropdownMenuItem(
                            value: order.id,
                            child: Text('Order #${order.trackingNumber}'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(selectedOrderIdProvider.notifier).state =
                            value;
                      }
                    },
                  );
                },
              ),
            ),

            // Order Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        selectedOrder.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      selectedOrder.status,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusText(selectedOrder.status),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Estimated Delivery',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(selectedOrder.estimatedDelivery),
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Route
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 24,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FROM',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedOrder.origin,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.flag_outlined,
                              size: 24,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TO',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedOrder.destination,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(height: 1, color: Colors.grey[200]),

                  // Tracking Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRACKING NUMBER',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              selectedOrder.trackingNumber,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                // Copy to clipboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tracking number copied to clipboard',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              color: Colors.blueGrey,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tracking Timeline
            Container(
              margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(selectedOrder.events.length, (index) {
                    final event = selectedOrder.events[index];
                    final isLast = index == selectedOrder.events.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _getStatusColor(event.status),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 70,
                                color: Colors.grey[300],
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'MMM dd, h:mm a',
                                ).format(event.timestamp),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Shipment Details
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Shipment Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(height: 1, color: Colors.grey[200]),
                  _buildDetailRow(
                    'Package Type',
                    selectedOrder.shipmentDetails.packageType,
                  ),
                  _buildDetailRow(
                    'Weight',
                    '${selectedOrder.shipmentDetails.weight} kg',
                  ),
                  _buildDetailRow(
                    'Dimensions',
                    selectedOrder.shipmentDetails.dimensions,
                  ),
                  _buildDetailRow(
                    'Courier',
                    selectedOrder.shipmentDetails.courier,
                  ),
                  _buildDetailRow(
                    'Sender',
                    selectedOrder.shipmentDetails.senderName,
                  ),
                  _buildDetailRow(
                    'Recipient',
                    selectedOrder.shipmentDetails.recipientName,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.message_outlined),
                      label: const Text('Support'),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Manage Order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Shipments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.amber;
      case OrderStatus.inTransit:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.exception:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.exception:
        return 'Exception';
    }
  }
}

// Main App
class ShippingApp extends StatelessWidget {
  const ShippingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shipping Order Tracker',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          fontFamily: GoogleFonts.poppins().fontFamily,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const ShippingOrderScreen(),
      ),
    );
  }
}

void main() {
  runApp(const ShippingApp());
}
