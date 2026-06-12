import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(
    const ProviderScope(child: MaterialApp(home: const ShipmentDashboard())),
  );
}

// Data models
class Shipment {
  final String id;
  final String customerName;
  final String origin;
  final String destination;
  final DateTime createdDate;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final ShipmentStatus status;
  final double weight;
  final List<TrackingEvent> trackingHistory;
  final LatLng currentLocation;

  Shipment({
    required this.id,
    required this.customerName,
    required this.origin,
    required this.destination,
    required this.createdDate,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.status,
    required this.weight,
    required this.trackingHistory,
    required this.currentLocation,
  });

  bool get isDelayed =>
      estimatedDelivery != null &&
      actualDelivery == null &&
      status != ShipmentStatus.delivered &&
      DateTime.now().isAfter(estimatedDelivery!);
}

enum ShipmentStatus {
  processing,
  inTransit,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

class TrackingEvent {
  final DateTime timestamp;
  final String location;
  final String description;
  final LatLng coordinates;

  TrackingEvent({
    required this.timestamp,
    required this.location,
    required this.description,
    required this.coordinates,
  });
}

// Sample data provider
final shipmentsProvider =
    StateNotifierProvider<ShipmentsNotifier, List<Shipment>>((ref) {
      return ShipmentsNotifier();
    });

class ShipmentsNotifier extends StateNotifier<List<Shipment>> {
  ShipmentsNotifier()
    : super([
        Shipment(
          id: 'SHP-001',
          customerName: 'John Smith',
          origin: 'New York, NY',
          destination: 'Chicago, IL',
          createdDate: DateTime.now().subtract(Duration(days: 5)),
          estimatedDelivery: DateTime.now().add(Duration(days: 1)),
          actualDelivery: null,
          status: ShipmentStatus.inTransit,
          weight: 12.5,
          trackingHistory: [
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 5)),
              location: 'New York, NY',
              description: 'Package received at sorting center',
              coordinates: LatLng(40.7128, -74.0060),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 3)),
              location: 'Cleveland, OH',
              description: 'Package in transit',
              coordinates: LatLng(41.4993, -81.6944),
            ),
          ],
          currentLocation: LatLng(41.4993, -81.6944),
        ),
        Shipment(
          id: 'SHP-002',
          customerName: 'Alice Johnson',
          origin: 'Los Angeles, CA',
          destination: 'Phoenix, AZ',
          createdDate: DateTime.now().subtract(Duration(days: 3)),
          estimatedDelivery: DateTime.now().add(Duration(days: 2)),
          actualDelivery: null,
          status: ShipmentStatus.processing,
          weight: 5.2,
          trackingHistory: [
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 3)),
              location: 'Los Angeles, CA',
              description: 'Package received at sorting center',
              coordinates: LatLng(34.0522, -118.2437),
            ),
          ],
          currentLocation: LatLng(34.0522, -118.2437),
        ),
        Shipment(
          id: 'SHP-003',
          customerName: 'Robert Brown',
          origin: 'Miami, FL',
          destination: 'Atlanta, GA',
          createdDate: DateTime.now().subtract(Duration(days: 7)),
          estimatedDelivery: DateTime.now().subtract(Duration(days: 1)),
          actualDelivery: DateTime.now().subtract(Duration(hours: 12)),
          status: ShipmentStatus.delivered,
          weight: 8.7,
          trackingHistory: [
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 7)),
              location: 'Miami, FL',
              description: 'Package received at sorting center',
              coordinates: LatLng(25.7617, -80.1918),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 5)),
              location: 'Jacksonville, FL',
              description: 'Package in transit',
              coordinates: LatLng(30.3322, -81.6557),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 3)),
              location: 'Savannah, GA',
              description: 'Package in transit',
              coordinates: LatLng(32.0809, -81.0912),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 2)),
              location: 'Atlanta, GA',
              description: 'Package arrived at local facility',
              coordinates: LatLng(33.7490, -84.3880),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(hours: 12)),
              location: 'Atlanta, GA',
              description: 'Package delivered',
              coordinates: LatLng(33.7490, -84.3880),
            ),
          ],
          currentLocation: LatLng(33.7490, -84.3880),
        ),
        Shipment(
          id: 'SHP-004',
          customerName: 'Emma Wilson',
          origin: 'Seattle, WA',
          destination: 'Portland, OR',
          createdDate: DateTime.now().subtract(Duration(days: 2)),
          estimatedDelivery: DateTime.now().add(Duration(days: 1)),
          actualDelivery: null,
          status: ShipmentStatus.outForDelivery,
          weight: 3.1,
          trackingHistory: [
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 2)),
              location: 'Seattle, WA',
              description: 'Package received at sorting center',
              coordinates: LatLng(47.6062, -122.3321),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 1)),
              location: 'Tacoma, WA',
              description: 'Package in transit',
              coordinates: LatLng(47.2529, -122.4443),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(hours: 6)),
              location: 'Portland, OR',
              description: 'Package out for delivery',
              coordinates: LatLng(45.5152, -122.6784),
            ),
          ],
          currentLocation: LatLng(45.5152, -122.6784),
        ),
        Shipment(
          id: 'SHP-005',
          customerName: 'Michael Davis',
          origin: 'Boston, MA',
          destination: 'New York, NY',
          createdDate: DateTime.now().subtract(Duration(days: 4)),
          estimatedDelivery: DateTime.now().subtract(Duration(days: 1)),
          actualDelivery: null,
          status: ShipmentStatus.inTransit,
          weight: 10.0,
          trackingHistory: [
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 4)),
              location: 'Boston, MA',
              description: 'Package received at sorting center',
              coordinates: LatLng(42.3601, -71.0589),
            ),
            TrackingEvent(
              timestamp: DateTime.now().subtract(Duration(days: 3)),
              location: 'Providence, RI',
              description: 'Package in transit',
              coordinates: LatLng(41.8240, -71.4128),
            ),
          ],
          currentLocation: LatLng(41.8240, -71.4128),
        ),
      ]);

  void updateShipmentStatus(String id, ShipmentStatus newStatus) {
    state = [
      for (final shipment in state)
        if (shipment.id == id)
          Shipment(
            id: shipment.id,
            customerName: shipment.customerName,
            origin: shipment.origin,
            destination: shipment.destination,
            createdDate: shipment.createdDate,
            estimatedDelivery: shipment.estimatedDelivery,
            actualDelivery: newStatus == ShipmentStatus.delivered
                ? DateTime.now()
                : shipment.actualDelivery,
            status: newStatus,
            weight: shipment.weight,
            trackingHistory: newStatus == ShipmentStatus.delivered
                ? [
                    ...shipment.trackingHistory,
                    TrackingEvent(
                      timestamp: DateTime.now(),
                      location: shipment.destination,
                      description: 'Package delivered',
                      coordinates: LatLng(
                        shipment.trackingHistory.last.coordinates.latitude,
                        shipment.trackingHistory.last.coordinates.longitude,
                      ),
                    ),
                  ]
                : shipment.trackingHistory,
            currentLocation: shipment.currentLocation,
          )
        else
          shipment,
    ];
  }
}

// Derived providers
final totalShipmentsProvider = Provider<int>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  return shipments.length;
});

final inTransitShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  return shipments
      .where((shipment) => shipment.status == ShipmentStatus.inTransit)
      .toList();
});

final outForDeliveryShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  return shipments
      .where((shipment) => shipment.status == ShipmentStatus.outForDelivery)
      .toList();
});

final deliveredShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  return shipments
      .where((shipment) => shipment.status == ShipmentStatus.delivered)
      .toList();
});

final delayedShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  return shipments.where((shipment) => shipment.isDelayed).toList();
});

final shipmentsByStatusProvider = Provider<Map<ShipmentStatus, int>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  final result = <ShipmentStatus, int>{};

  for (final status in ShipmentStatus.values) {
    result[status] = shipments
        .where((shipment) => shipment.status == status)
        .length;
  }

  return result;
});

final selectedShipmentProvider = StateProvider<Shipment?>((ref) => null);

// Dashboard Widget
class ShipmentDashboard extends ConsumerWidget {
  const ShipmentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalShipments = ref.watch(totalShipmentsProvider);
    final inTransitShipments = ref.watch(inTransitShipmentsProvider);
    final outForDeliveryShipments = ref.watch(outForDeliveryShipmentsProvider);
    final deliveredShipments = ref.watch(deliveredShipmentsProvider);
    final delayedShipments = ref.watch(delayedShipmentsProvider);
    final shipmentsByStatus = ref.watch(shipmentsByStatusProvider);
    final allShipments = ref.watch(shipmentsProvider);
    final selectedShipment = ref.watch(selectedShipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notifications logic
            },
          ),
        ],
      ),
      body: selectedShipment == null
          ? _buildDashboardView(
              context,
              totalShipments,
              inTransitShipments,
              outForDeliveryShipments,
              deliveredShipments,
              delayedShipments,
              shipmentsByStatus,
              allShipments,
              ref,
            )
          : _buildShipmentDetailView(context, selectedShipment, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new shipment logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardView(
    BuildContext context,
    int totalShipments,
    List<Shipment> inTransitShipments,
    List<Shipment> outForDeliveryShipments,
    List<Shipment> deliveredShipments,
    List<Shipment> delayedShipments,
    Map<ShipmentStatus, int> shipmentsByStatus,
    List<Shipment> allShipments,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildKpiCard(
                context,
                'Total Shipments',
                totalShipments.toString(),
                Icons.local_shipping,
                Colors.blue,
              ),
              _buildKpiCard(
                context,
                'In Transit',
                inTransitShipments.length.toString(),
                Icons.airport_shuttle,
                Colors.orange,
              ),
              _buildKpiCard(
                context,
                'Out for Delivery',
                outForDeliveryShipments.length.toString(),
                Icons.delivery_dining,
                Colors.green,
              ),
              _buildKpiCard(
                context,
                'Delayed',
                delayedShipments.length.toString(),
                Icons.schedule,
                Colors.red,
                isWarning: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Map View
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shipment Locations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 300, child: _buildMapView(allShipments)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Shipment Status Chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shipments by Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          _buildPieChartSection(
                            shipmentsByStatus[ShipmentStatus.processing] ?? 0,
                            'Processing',
                            Colors.blue,
                          ),
                          _buildPieChartSection(
                            shipmentsByStatus[ShipmentStatus.inTransit] ?? 0,
                            'In Transit',
                            Colors.orange,
                          ),
                          _buildPieChartSection(
                            shipmentsByStatus[ShipmentStatus.outForDelivery] ??
                                0,
                            'Out for Delivery',
                            Colors.green,
                          ),
                          _buildPieChartSection(
                            shipmentsByStatus[ShipmentStatus.delivered] ?? 0,
                            'Delivered',
                            Colors.purple,
                          ),
                          _buildPieChartSection(
                            shipmentsByStatus[ShipmentStatus.cancelled] ?? 0,
                            'Cancelled',
                            Colors.red,
                          ),
                          _buildPieChartSection(
                            shipmentsByStatus[ShipmentStatus.returned] ?? 0,
                            'Returned',
                            Colors.grey,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildStatusIndicator('Processing', Colors.blue),
                      _buildStatusIndicator('In Transit', Colors.orange),
                      _buildStatusIndicator('Out for Delivery', Colors.green),
                      _buildStatusIndicator('Delivered', Colors.purple),
                      _buildStatusIndicator('Cancelled', Colors.red),
                      _buildStatusIndicator('Returned', Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Active Shipments
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Shipments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all shipments
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allShipments
                        .where(
                          (s) =>
                              s.status != ShipmentStatus.delivered &&
                              s.status != ShipmentStatus.cancelled,
                        )
                        .length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final shipment = allShipments
                          .where(
                            (s) =>
                                s.status != ShipmentStatus.delivered &&
                                s.status != ShipmentStatus.cancelled,
                          )
                          .toList()[index];
                      return _buildShipmentItem(context, shipment, ref);
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

  Widget _buildShipmentDetailView(
    BuildContext context,
    Shipment shipment,
    WidgetRef ref,
  ) {
    final dateFormatter = DateFormat('MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(selectedShipmentProvider.notifier).state = null;
                },
              ),
              const Text(
                'Shipment Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Shipment info card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tracking #${shipment.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusChip(shipment.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Customer', shipment.customerName),
                  _buildDetailRow('Origin', shipment.origin),
                  _buildDetailRow('Destination', shipment.destination),
                  _buildDetailRow(
                    'Created Date',
                    dateFormatter.format(shipment.createdDate),
                  ),
                  _buildDetailRow(
                    'Estimated Delivery',
                    shipment.estimatedDelivery != null
                        ? dateFormatter.format(shipment.estimatedDelivery!)
                        : 'N/A',
                  ),
                  _buildDetailRow(
                    'Actual Delivery',
                    shipment.actualDelivery != null
                        ? dateFormatter.format(shipment.actualDelivery!)
                        : 'Pending',
                  ),
                  _buildDetailRow('Weight', '${shipment.weight} kg'),
                  if (shipment.isDelayed)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This shipment is delayed',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Shipment location map
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildSingleShipmentMap(shipment),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tracking history
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tracking History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shipment.trackingHistory.length,
                    itemBuilder: (context, index) {
                      final event =
                          shipment.trackingHistory[shipment
                                  .trackingHistory
                                  .length -
                              1 -
                              index];
                      final isFirst = index == 0;
                      final isLast =
                          index == shipment.trackingHistory.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isFirst ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.location,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dateFormatter.format(event.timestamp)} at ${timeFormatter.format(event.timestamp)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          if (shipment.status != ShipmentStatus.delivered &&
              shipment.status != ShipmentStatus.cancelled)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ShipmentStatus>(
                            value: shipment.status,
                            decoration: const InputDecoration(
                              labelText: 'Update Status',
                              border: OutlineInputBorder(),
                            ),
                            items: ShipmentStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_getStatusLabel(status)),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                ref
                                    .read(shipmentsProvider.notifier)
                                    .updateShipmentStatus(
                                      shipment.id,
                                      newStatus,
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isWarning = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: isWarning && int.parse(value) > 0 ? Colors.red : null,
              ),
            ),
            if (isWarning && int.parse(value) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Needs attention',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(List<Shipment> shipments) {
    // This is a placeholder for a real map implementation
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Map View - Showing ${shipments.length} shipments',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildSingleShipmentMap(Shipment shipment) {
    // This is a placeholder for a real map implementation
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Map View - ${shipment.currentLocation.latitude}, ${shipment.currentLocation.longitude}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(
    int value,
    String title,
    Color color,
  ) {
    final double percentage = value > 0
        ? value / 5 * 100
        : 0; // Convert to percentage based on total

    return PieChartSectionData(
      value: value.toDouble(),
      title: '$value',
      color: color,
      radius: 80,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }

  Widget _buildShipmentItem(
    BuildContext context,
    Shipment shipment,
    WidgetRef ref,
  ) {
    return InkWell(
      onTap: () {
        ref.read(selectedShipmentProvider.notifier).state = shipment;
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(shipment.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(shipment.status),
                  color: _getStatusColor(shipment.status),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${shipment.id} - ${shipment.customerName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildStatusChip(shipment.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shipment.origin} → ${shipment.destination}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. Delivery: ${shipment.estimatedDelivery != null ? DateFormat('MMM d, yyyy').format(shipment.estimatedDelivery!) : 'N/A'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (shipment.isDelayed) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Delayed',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ShipmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.processing:
        return Colors.blue;
      case ShipmentStatus.inTransit:
        return Colors.orange;
      case ShipmentStatus.outForDelivery:
        return Colors.green;
      case ShipmentStatus.delivered:
        return Colors.purple;
      case ShipmentStatus.cancelled:
        return Colors.red;
      case ShipmentStatus.returned:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.processing:
        return Icons.inventory_2;
      case ShipmentStatus.inTransit:
        return Icons.local_shipping;
      case ShipmentStatus.outForDelivery:
        return Icons.delivery_dining;
      case ShipmentStatus.delivered:
        return Icons.check_circle;
      case ShipmentStatus.cancelled:
        return Icons.cancel;
      case ShipmentStatus.returned:
        return Icons.assignment_return;
    }
  }

  String _getStatusLabel(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.processing:
        return 'Processing';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.outForDelivery:
        return 'Out for Delivery';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.cancelled:
        return 'Cancelled';
      case ShipmentStatus.returned:
        return 'Returned';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Main app
class ShipmentDashboardApp extends StatelessWidget {
  const ShipmentDashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Shipment Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const ShipmentDashboard(),
      ),
    );
  }
}

// To use this widget for actual map implementation, replace the placeholder map widgets with
// actual flutter_map implementation. For example:
/* 
Widget _buildActualMapView(List<Shipment> shipments) {
  return FlutterMap(
    options: MapOptions(
      center: LatLng(39.8283, -98.5795), // Center of US
      zoom: 3.0,
    ),
    layers: [
      TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c'],
      ),
      MarkerLayerOptions(
        markers: shipments.map((shipment) {
          return Marker(
            width: 80.0,
            height: 80.0,
            point: shipment.currentLocation,
            builder: (ctx) => Container(
              child: Icon(
                _getStatusIcon(shipment.status),
                color: _getStatusColor(shipment.status),
                size: 30,
              ),
            ),
          );
        }).toList(),
      ),
    ], children: [],
  );
}

Widget _buildActualSingleShipmentMap(Shipment shipment) {
  return FlutterMap(
    options: MapOptions(
      center: shipment.currentLocation,
      zoom: 6.0,
    ),
    layers: [
      TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c'],
      ),
      PolylineLayerOptions(
        polylines: [
          Polyline(
            points: shipment.trackingHistory.map((event) => event.coordinates).toList(),
            strokeWidth: 4.0,
            color: Colors.blue,
          ),
        ],
      ),
      MarkerLayerOptions(
        markers: [
          Marker(
            width: 80.0,
            height: 80.0,
            point: shipment.currentLocation,
            builder: (ctx) => Container(
              child: Icon(
                _getStatusIcon(shipment.status),
                color: _getStatusColor(shipment.status),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
 */
// Add these functions to implement real-time data updates with a proper backend

void fetchShipments() async {
  // API call to fetch shipments from backend
  // Update state with the fetched data
}

void updateShipmentLocation(String id, LatLng newLocation) {
  // API call to update shipment location
  // Update state with the new location
}

// To add search and filtering functionality
class ShipmentFilters {
  final ShipmentStatus? status;
  final String? searchText;
  final DateTime? startDate;
  final DateTime? endDate;

  ShipmentFilters({this.status, this.searchText, this.startDate, this.endDate});

  bool matchesShipment(Shipment shipment) {
    // Check if shipment matches current filters
    if (status != null && shipment.status != status) {
      return false;
    }

    if (searchText != null && searchText!.isNotEmpty) {
      final searchLower = searchText!.toLowerCase();
      if (!shipment.id.toLowerCase().contains(searchLower) &&
          !shipment.customerName.toLowerCase().contains(searchLower) &&
          !shipment.origin.toLowerCase().contains(searchLower) &&
          !shipment.destination.toLowerCase().contains(searchLower)) {
        return false;
      }
    }

    if (startDate != null && shipment.createdDate.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && shipment.createdDate.isAfter(endDate!)) {
      return false;
    }

    return true;
  }
}

// Add a filter provider to implement the filtering functionality
final shipmentFiltersProvider = StateProvider<ShipmentFilters>((ref) {
  return ShipmentFilters();
});

final filteredShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(shipmentsProvider);
  final filters = ref.watch(shipmentFiltersProvider);

  return shipments
      .where((shipment) => filters.matchesShipment(shipment))
      .toList();
});
