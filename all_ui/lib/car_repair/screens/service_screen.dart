import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Services'),
              Tab(text: 'Packages'),
              Tab(text: 'History'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildServicesTab(),
                _buildPackagesTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCategorySection('Maintenance', [
            _buildServiceItem('Oil Change', 'From \$30', Icons.opacity),
            _buildServiceItem('Tire Rotation', 'From \$20', Icons.tire_repair),
            _buildServiceItem(
              'Brake Service',
              'From \$100',
              Icons.browser_not_supported,
            ),
            _buildServiceItem(
              'Battery Replacement',
              'From \$120',
              Icons.battery_charging_full,
            ),
          ]),
          const SizedBox(height: 20),
          _buildServiceCategorySection('Repairs', [
            _buildServiceItem('Engine Repair', 'From \$300', Icons.engineering),
            _buildServiceItem(
              'Transmission Repair',
              'From \$500',
              Icons.settings,
            ),
            _buildServiceItem('Electrical System', 'From \$150', Icons.bolt),
            _buildServiceItem('AC Service', 'From \$120', Icons.ac_unit),
          ]),
          const SizedBox(height: 20),
          _buildServiceCategorySection('Diagnostics', [
            _buildServiceItem('Engine Diagnostics', 'From \$80', Icons.search),
            _buildServiceItem(
              'Computer Diagnostics',
              'From \$100',
              Icons.computer,
            ),
            _buildServiceItem('Emissions Test', 'From \$50', Icons.cloud),
          ]),
        ],
      ),
    );
  }

  Widget _buildServiceCategorySection(String title, List<Widget> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: services,
        ),
      ],
    );
  }

  Widget _buildServiceItem(String name, String price, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to service details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Packages',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildPackageCard(
            'Basic Maintenance',
            '\$99.99',
            'Regular maintenance package for vehicles under 50,000 miles',
            [
              'Oil & Filter Change',
              'Tire Rotation',
              'Fluid Check & Top-off',
              'Multi-point Inspection',
            ],
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildPackageCard(
            'Premium Maintenance',
            '\$179.99',
            'Comprehensive service for vehicles over 50,000 miles',
            [
              'Oil & Filter Change',
              'Tire Rotation',
              'Brake Inspection',
              'Air Filter Replacement',
              'Cabin Filter Replacement',
              'Battery Test',
              'Full Vehicle Inspection',
            ],
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildPackageCard(
            'Complete Tune-Up',
            '\$299.99',
            'Full service tune-up to restore performance',
            [
              'Spark Plug Replacement',
              'Fuel Injection Service',
              'Throttle Body Cleaning',
              'Oil & Filter Change',
              'Air Filter Replacement',
              'Fuel Filter Replacement',
              'Computerized Engine Analysis',
            ],
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    String name,
    String price,
    String description,
    List<String> services,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Includes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...services.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: color, size: 18),
                        const SizedBox(width: 8),
                        Text(service),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Book this package
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Service History',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildHistoryItem(
          'Oil Change & Tire Rotation',
          'Honda Civic',
          DateTime.now().subtract(const Duration(days: 15)),
          '\$65.99',
          'Completed',
          Colors.green,
        ),
        _buildHistoryItem(
          'Brake Pad Replacement',
          'Honda Civic',
          DateTime.now().subtract(const Duration(days: 45)),
          '\$220.00',
          'Completed',
          Colors.green,
        ),
        _buildHistoryItem(
          'AC System Repair',
          'Toyota Camry',
          DateTime.now().subtract(const Duration(days: 60)),
          '\$350.00',
          'Completed',
          Colors.green,
        ),
        _buildHistoryItem(
          'Engine Diagnostics',
          'Toyota Camry',
          DateTime.now().subtract(const Duration(days: 90)),
          '\$80.00',
          'Completed',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    String service,
    String vehicle,
    DateTime date,
    String cost,
    String status,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(cost, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  vehicle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View service details
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
