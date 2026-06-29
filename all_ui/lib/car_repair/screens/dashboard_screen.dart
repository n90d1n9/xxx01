import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildUpcomingServicesCard(),
          const SizedBox(height: 20),
          _buildRecentServicesCard(),
          const SizedBox(height: 20),
          _buildVehicleStatusCard(),
        ],
      ),
    );
  }

  Widget _buildUpcomingServicesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.calendar_today),
              ],
            ),
            const Divider(),
            _buildServiceItem(
              'Oil Change',
              'Honda Civic',
              DateTime.now().add(const Duration(days: 5)),
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildServiceItem(
              'Tire Rotation',
              'Toyota Camry',
              DateTime.now().add(const Duration(days: 12)),
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildServiceItem(
              'Brake Inspection',
              'Honda Civic',
              DateTime.now().add(const Duration(days: 18)),
              Colors.green,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to full upcoming services list
              },
              child: const Text('View All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    String service,
    String vehicle,
    DateTime date,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$vehicle • ${DateFormat('MMM dd, yyyy').format(date)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: () {
            // Navigate to service details
          },
        ),
      ],
    );
  }

  Widget _buildRecentServicesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.history),
              ],
            ),
            const Divider(),
            _buildRecentServiceItem(
              'Brake Pad Replacement',
              'Honda Civic',
              DateTime.now().subtract(const Duration(days: 5)),
              '\$220.00',
            ),
            const Divider(),
            _buildRecentServiceItem(
              'Oil Change',
              'Toyota Camry',
              DateTime.now().subtract(const Duration(days: 15)),
              '\$45.00',
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to full history
              },
              child: const Text('View History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentServiceItem(
    String service,
    String vehicle,
    DateTime date,
    String cost,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$vehicle • ${DateFormat('MMM dd, yyyy').format(date)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cost, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Completed',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.speed),
              ],
            ),
            const Divider(),
            _buildVehicleStatusItem(
              'Honda Civic',
              '2020',
              85,
              'Oil: 70%, Brakes: 65%, Tires: 80%',
            ),
            const Divider(),
            _buildVehicleStatusItem(
              'Toyota Camry',
              '2018',
              72,
              'Oil: 50%, Brakes: 85%, Tires: 60%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleStatusItem(
    String vehicle,
    String year,
    int healthPercent,
    String details,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$vehicle ($year)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    healthPercent > 80
                        ? Colors.green
                        : healthPercent > 60
                        ? Colors.orange
                        : Colors.red,
                child: Text(
                  '$healthPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: healthPercent / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              healthPercent > 80
                  ? Colors.green
                  : healthPercent > 60
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
