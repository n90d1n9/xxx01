import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// Models
class KubernetesCluster {
  final String name;
  final String status;
  final int nodes;
  final int pods;
  final double cpuUsage;
  final double memoryUsage;

  KubernetesCluster({
    required this.name,
    required this.status,
    required this.nodes,
    required this.pods,
    required this.cpuUsage,
    required this.memoryUsage,
  });
}

class PodMetrics {
  final String name;
  final String namespace;
  final String status;
  final double cpuUsage;
  final double memoryUsage;
  final DateTime lastRestart;

  PodMetrics({
    required this.name,
    required this.namespace,
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.lastRestart,
  });
}

// Providers
final selectedClusterProvider = StateProvider<String>(
  (ref) => 'production-cluster',
);

final clustersProvider = Provider<List<KubernetesCluster>>(
  (ref) => [
    KubernetesCluster(
      name: 'production-cluster',
      status: 'Healthy',
      nodes: 12,
      pods: 156,
      cpuUsage: 68.5,
      memoryUsage: 72.3,
    ),
    KubernetesCluster(
      name: 'staging-cluster',
      status: 'Healthy',
      nodes: 6,
      pods: 89,
      cpuUsage: 45.2,
      memoryUsage: 38.7,
    ),
    KubernetesCluster(
      name: 'development-cluster',
      status: 'Warning',
      nodes: 4,
      pods: 34,
      cpuUsage: 23.1,
      memoryUsage: 45.8,
    ),
  ],
);

final podsProvider = Provider<List<PodMetrics>>(
  (ref) => [
    PodMetrics(
      name: 'web-app-7d9f8b6c4d-xz2k9',
      namespace: 'production',
      status: 'Running',
      cpuUsage: 125.4,
      memoryUsage: 512.7,
      lastRestart: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PodMetrics(
      name: 'api-gateway-5c8d9e7f2a-m4n8p',
      namespace: 'production',
      status: 'Running',
      cpuUsage: 89.2,
      memoryUsage: 256.3,
      lastRestart: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    PodMetrics(
      name: 'database-6f4a2b8c9d-q7r3s',
      namespace: 'production',
      status: 'Running',
      cpuUsage: 234.7,
      memoryUsage: 1024.5,
      lastRestart: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PodMetrics(
      name: 'cache-redis-3e5f7g9h1j-t8u2v',
      namespace: 'production',
      status: 'Running',
      cpuUsage: 45.8,
      memoryUsage: 128.9,
      lastRestart: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ],
);

class KubernetesConsoleScreen extends ConsumerWidget {
  const KubernetesConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clusters = ref.watch(clustersProvider);
    final selectedCluster = ref.watch(selectedClusterProvider);
    final pods = ref.watch(podsProvider);

    final currentCluster = clusters.firstWhere(
      (cluster) => cluster.name == selectedCluster,
      orElse: () => clusters.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E16),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1E2E),
              border: Border(
                right: BorderSide(color: Color(0xFF2A2E3E), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings_applications,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'K8s Console',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildNavItem(
                        Icons.dashboard_outlined,
                        'Dashboard',
                        true,
                      ),
                      _buildNavItem(
                        Icons.workspaces_outline,
                        'Clusters',
                        false,
                      ),
                      _buildNavItem(Icons.storage_outlined, 'Workloads', false),
                      _buildNavItem(Icons.network_check, 'Services', false),
                      _buildNavItem(Icons.security, 'Security', false),
                      _buildNavItem(Icons.dashboard, 'Monitoring', false),
                      _buildNavItem(Icons.settings, 'Settings', false),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1E2E),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF2A2E3E), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Kubernetes Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      // Cluster Selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2E3E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4F46E5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCluster,
                            icon: const Icon(
                              Icons.expand_more,
                              color: Colors.white,
                            ),
                            dropdownColor: const Color(0xFF2A2E3E),
                            style: const TextStyle(color: Colors.white),
                            items:
                                clusters.map((cluster) {
                                  return DropdownMenuItem<String>(
                                    value: cluster.name,
                                    child: Text(cluster.name),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(selectedClusterProvider.notifier)
                                    .state = value;
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Notifications
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2E3E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dashboard Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Metrics Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Total Nodes',
                                currentCluster.nodes.toString(),
                                Icons.dns,
                                const Color(0xFF10B981),
                                '+2 this week',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildMetricCard(
                                'Running Pods',
                                currentCluster.pods.toString(),
                                Icons.widgets,
                                const Color(0xFF3B82F6),
                                '+12 today',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildMetricCard(
                                'CPU Usage',
                                '${currentCluster.cpuUsage.toStringAsFixed(1)}%',
                                Icons.memory,
                                const Color(0xFFF59E0B),
                                'Normal range',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildMetricCard(
                                'Memory Usage',
                                '${currentCluster.memoryUsage.toStringAsFixed(1)}%',
                                Icons.storage,
                                const Color(0xFFEF4444),
                                'Above average',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Charts and Tables Row
                        Expanded(
                          child: Row(
                            children: [
                              // Resource Usage Chart
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1E2E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF2A2E3E),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Resource Usage Trends',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              horizontalInterval: 20,
                                              getDrawingHorizontalLine: (
                                                value,
                                              ) {
                                                return FlLine(
                                                  color: const Color(
                                                    0xFF2A2E3E,
                                                  ),
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (
                                                    value,
                                                    meta,
                                                  ) {
                                                    const titles = [
                                                      '00:00',
                                                      '04:00',
                                                      '08:00',
                                                      '12:00',
                                                      '16:00',
                                                      '20:00',
                                                      '24:00',
                                                    ];
                                                    if (value.toInt() <
                                                        titles.length) {
                                                      return Text(
                                                        titles[value.toInt()],
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                          fontSize: 12,
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox();
                                                  },
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  interval: 20,
                                                  getTitlesWidget: (
                                                    value,
                                                    meta,
                                                  ) {
                                                    return Text(
                                                      '${value.toInt()}%',
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF9CA3AF,
                                                        ),
                                                        fontSize: 12,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: [
                                                  const FlSpot(0, 30),
                                                  const FlSpot(1, 45),
                                                  const FlSpot(2, 40),
                                                  const FlSpot(3, 55),
                                                  const FlSpot(4, 68),
                                                  const FlSpot(5, 72),
                                                  const FlSpot(6, 68),
                                                ],
                                                isCurved: true,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF4F46E5),
                                                    Color(0xFF7C3AED),
                                                  ],
                                                ),
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(show: false),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(
                                                        0xFF4F46E5,
                                                      ).withOpacity(0.3),
                                                      const Color(
                                                        0xFF7C3AED,
                                                      ).withOpacity(0.1),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
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
                              ),

                              const SizedBox(width: 24),

                              // Pods Table
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1E2E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF2A2E3E),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Running Pods',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'All Healthy',
                                              style: TextStyle(
                                                color: Color(0xFF10B981),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: pods.length,
                                          itemBuilder: (context, index) {
                                            final pod = pods[index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A2E3E),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFF10B981,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          pod.name,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          pod.namespace,
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF9CA3AF,
                                                                ),
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'CPU: ${pod.cpuUsage.toStringAsFixed(1)}m',
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'MEM: ${pod.memoryUsage.toStringAsFixed(0)}Mi',
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF9CA3AF,
                                                          ),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF9CA3AF),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? const Color(0xFF4F46E5).withOpacity(0.1) : null,
        onTap: () {},
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2E3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

void main(List<String> args) {
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const KubernetesConsoleScreen(),
      ),
    ),
  );
}
