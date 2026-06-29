import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';

// Models
class ApiEndpoint {
  final String name;
  final String path;
  final String method;
  final int requestCount;
  final double averageResponseTime;
  final double successRate;
  final String lastAccessed;
  final bool isActive;

  ApiEndpoint({
    required this.name,
    required this.path,
    required this.method,
    required this.requestCount,
    required this.averageResponseTime,
    required this.successRate,
    required this.lastAccessed,
    required this.isActive,
  });
}

class TrafficData {
  final DateTime time;
  final int requests;

  TrafficData(this.time, this.requests);
}

// API Service
class ApiGatewayService {
  Future<List<ApiEndpoint>> getEndpoints() async {
    // Simulated API call
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      ApiEndpoint(
        name: 'User Authentication',
        path: '/api/v1/auth',
        method: 'POST',
        requestCount: 5243,
        averageResponseTime: 120.5,
        successRate: 99.8,
        lastAccessed: '3 min ago',
        isActive: true,
      ),
      ApiEndpoint(
        name: 'Product Catalog',
        path: '/api/v1/products',
        method: 'GET',
        requestCount: 12532,
        averageResponseTime: 85.2,
        successRate: 100.0,
        lastAccessed: '30 sec ago',
        isActive: true,
      ),
      ApiEndpoint(
        name: 'Order Processing',
        path: '/api/v1/orders',
        method: 'POST',
        requestCount: 3256,
        averageResponseTime: 230.7,
        successRate: 98.5,
        lastAccessed: '1 min ago',
        isActive: true,
      ),
      ApiEndpoint(
        name: 'Legacy Payment',
        path: '/api/v1/payment/legacy',
        method: 'POST',
        requestCount: 126,
        averageResponseTime: 310.2,
        successRate: 97.2,
        lastAccessed: '2 hours ago',
        isActive: false,
      ),
      ApiEndpoint(
        name: 'User Profile',
        path: '/api/v1/users/profile',
        method: 'GET',
        requestCount: 7821,
        averageResponseTime: 92.6,
        successRate: 99.9,
        lastAccessed: '45 sec ago',
        isActive: true,
      ),
    ];
  }

  Future<List<TrafficData>> getTrafficData() async {
    // Simulated API call
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');

    return List.generate(24, (index) {
      final time = now.subtract(Duration(hours: 23 - index));
      final randomValue = 200 + (index * 20) + (index % 3 == 0 ? 150 : 0);
      return TrafficData(time, randomValue);
    });
  }

  Future<Map<String, dynamic>> getGatewayStatus() async {
    // Simulated API call
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'status': 'operational',
      'activeEndpoints': 12,
      'totalEndpoints': 14,
      'averageLatency': 110.5,
      'requestsPerSecond': 42.3,
      'cpuUsage': 28.5,
      'memoryUsage': 42.7,
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 2)),
    };
  }
}

// Providers
final apiServiceProvider = Provider<ApiGatewayService>((ref) {
  return ApiGatewayService();
});

final endpointsProvider = FutureProvider<List<ApiEndpoint>>((ref) {
  return ref.read(apiServiceProvider).getEndpoints();
});

final trafficDataProvider = FutureProvider<List<TrafficData>>((ref) {
  return ref.read(apiServiceProvider).getTrafficData();
});

final gatewayStatusProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(apiServiceProvider).getGatewayStatus();
});

// Main Screen
class ApiGatewayDashboard extends ConsumerWidget {
  const ApiGatewayDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpointsData = ref.watch(endpointsProvider);
    final trafficData = ref.watch(trafficDataProvider);
    final gatewayStatus = ref.watch(gatewayStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Iket  Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: 0,
            extended: true,
            minExtendedWidth: 200,
            backgroundColor: Colors.white,
            labelType: NavigationRailLabelType.none,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF6366F1),
                    child: Text(
                      'AG',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Iket ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.api_outlined),
                selectedIcon: Icon(Icons.api),
                label: Text('Endpoints'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shield_outlined),
                selectedIcon: Icon(Icons.shield),
                label: Text('Security'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('Logs'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Cards
                    gatewayStatus.when(
                      data: (status) => _buildStatusCards(status),
                      loading: () => const ShimmerStatusCards(),
                      error: (_, __) => const Text('Failed to load status'),
                    ),
                    const SizedBox(height: 24),

                    // Traffic Chart
                    const Text(
                      'API Traffic',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: trafficData.when(
                        data: (data) => _buildTrafficChart(data),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (_, __) => const Center(
                              child: Text('Failed to load traffic data'),
                            ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Endpoint Table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Endpoints Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add Endpoint'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: endpointsData.when(
                        data: (endpoints) => _buildEndpointsTable(endpoints),
                        loading:
                            () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        error:
                            (_, __) => const Center(
                              child: Text('Failed to load endpoints'),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatusCards(Map<String, dynamic> status) {
    final formatter = DateFormat('HH:mm');
    final lastUpdate = formatter.format(status['lastUpdated'] as DateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gateway Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    status['status'] == 'operational'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status['status'] == 'operational'
                        ? Icons.check_circle
                        : Icons.error,
                    size: 16,
                    color:
                        status['status'] == 'operational'
                            ? Colors.green
                            : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status['status'] == 'operational'
                        ? 'Operational'
                        : 'Issues Detected',
                    style: TextStyle(
                      color:
                          status['status'] == 'operational'
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'Last updated: $lastUpdate',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                title: 'Active Endpoints',
                value:
                    '${status['activeEndpoints']}/${status['totalEndpoints']}',
                icon: Icons.api,
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusCard(
                title: 'Avg. Latency',
                value: '${status['averageLatency'].toStringAsFixed(1)} ms',
                icon: Icons.speed,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusCard(
                title: 'Requests/sec',
                value: status['requestsPerSecond'].toStringAsFixed(1),
                icon: Icons.bar_chart,
                color: const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusCard(
                title: 'CPU Usage',
                value: '${status['cpuUsage'].toStringAsFixed(1)}%',
                icon: Icons.memory,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficChart(List<TrafficData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() % 4 != 0) {
                  return const SizedBox.shrink();
                }
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('HH:mm').format(data[index].time),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: data.map((e) => e.requests).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots:
                data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.requests.toDouble());
                }).toList(),
            isCurved: true,
            color: const Color(0xFF6366F1),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointsTable(List<ApiEndpoint> endpoints) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      columns: const [
        DataColumn2(label: Text('Name'), size: ColumnSize.L),
        DataColumn2(label: Text('Path'), size: ColumnSize.L),
        DataColumn2(label: Text('Method'), size: ColumnSize.S),
        DataColumn2(label: Text('Requests'), size: ColumnSize.S, numeric: true),
        DataColumn2(label: Text('Avg. Response'), numeric: true),
        DataColumn2(label: Text('Success Rate'), numeric: true),
        DataColumn2(label: Text('Last Accessed')),
        DataColumn2(label: Text('Status'), size: ColumnSize.S),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows:
          endpoints.map((endpoint) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    endpoint.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(endpoint.path)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMethodColor(
                        endpoint.method,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      endpoint.method,
                      style: TextStyle(
                        color: _getMethodColor(endpoint.method),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(NumberFormat('#,###').format(endpoint.requestCount)),
                ),
                DataCell(
                  Text('${endpoint.averageResponseTime.toStringAsFixed(1)} ms'),
                ),
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: endpoint.successRate / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getSuccessRateColor(endpoint.successRate),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${endpoint.successRate.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
                DataCell(Text(endpoint.lastAccessed)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          endpoint.isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      endpoint.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: endpoint.isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () {},
                        splashRadius: 20,
                        color: Colors.grey,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outlined, size: 18),
                        onPressed: () {},
                        splashRadius: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSuccessRateColor(double rate) {
    if (rate > 98) return Colors.green;
    if (rate > 95) return Colors.orange;
    return Colors.red;
  }
}

// Loading Shimmer Effect
class ShimmerStatusCards extends StatelessWidget {
  const ShimmerStatusCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iket  Management',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),
      home: const ApiGatewayDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
