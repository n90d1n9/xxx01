import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// Models
class ClusterMetrics {
  final int totalNodes;
  final int healthyNodes;
  final int totalPods;
  final int runningPods;
  final double cpuUsage;
  final double memoryUsage;
  final double storageUsage;

  ClusterMetrics({
    required this.totalNodes,
    required this.healthyNodes,
    required this.totalPods,
    required this.runningPods,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storageUsage,
  });
}

class PodInfo {
  final String name;
  final String namespace;
  final String status;
  final String node;
  final DateTime createdAt;

  PodInfo({
    required this.name,
    required this.namespace,
    required this.status,
    required this.node,
    required this.createdAt,
  });
}

class ServiceInfo {
  final String name;
  final String namespace;
  final String type;
  final String clusterIP;
  final List<int> ports;

  ServiceInfo({
    required this.name,
    required this.namespace,
    required this.type,
    required this.clusterIP,
    required this.ports,
  });
}

// Providers
final clusterMetricsProvider =
    StateNotifierProvider<ClusterMetricsNotifier, ClusterMetrics>((ref) {
      return ClusterMetricsNotifier();
    });

final podsProvider = StateNotifierProvider<PodsNotifier, List<PodInfo>>((ref) {
  return PodsNotifier();
});

final servicesProvider =
    StateNotifierProvider<ServicesNotifier, List<ServiceInfo>>((ref) {
      return ServicesNotifier();
    });

// State Notifiers
class ClusterMetricsNotifier extends StateNotifier<ClusterMetrics> {
  ClusterMetricsNotifier()
    : super(
        ClusterMetrics(
          totalNodes: 12,
          healthyNodes: 11,
          totalPods: 156,
          runningPods: 142,
          cpuUsage: 67.5,
          memoryUsage: 82.3,
          storageUsage: 45.8,
        ),
      );

  void updateMetrics() {
    // Simulate real-time updates
    state = ClusterMetrics(
      totalNodes: state.totalNodes,
      healthyNodes: state.healthyNodes,
      totalPods: state.totalPods,
      runningPods: state.runningPods,
      cpuUsage: (state.cpuUsage + (DateTime.now().millisecond % 10 - 5)).clamp(
        0,
        100,
      ),
      memoryUsage: (state.memoryUsage + (DateTime.now().millisecond % 8 - 4))
          .clamp(0, 100),
      storageUsage: (state.storageUsage + (DateTime.now().millisecond % 6 - 3))
          .clamp(0, 100),
    );
  }
}

class PodsNotifier extends StateNotifier<List<PodInfo>> {
  PodsNotifier()
    : super([
        PodInfo(
          name: 'nginx-deployment-7d5c6b8f9d-x2m4k',
          namespace: 'default',
          status: 'Running',
          node: 'worker-01',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        PodInfo(
          name: 'redis-master-6b8d9c7f5e-p9n3q',
          namespace: 'redis',
          status: 'Running',
          node: 'worker-02',
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
        ),
        PodInfo(
          name: 'postgres-statefulset-0',
          namespace: 'database',
          status: 'Running',
          node: 'worker-03',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        PodInfo(
          name: 'api-gateway-5f7d8c9b2a-h4j6k',
          namespace: 'api',
          status: 'Pending',
          node: 'worker-01',
          createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        ),
        PodInfo(
          name: 'monitoring-prometheus-0',
          namespace: 'monitoring',
          status: 'Running',
          node: 'worker-02',
          createdAt: DateTime.now().subtract(Duration(hours: 12)),
        ),
      ]);
}

class ServicesNotifier extends StateNotifier<List<ServiceInfo>> {
  ServicesNotifier()
    : super([
        ServiceInfo(
          name: 'nginx-service',
          namespace: 'default',
          type: 'LoadBalancer',
          clusterIP: '10.96.1.45',
          ports: [80, 443],
        ),
        ServiceInfo(
          name: 'redis-service',
          namespace: 'redis',
          type: 'ClusterIP',
          clusterIP: '10.96.2.12',
          ports: [6379],
        ),
        ServiceInfo(
          name: 'postgres-service',
          namespace: 'database',
          type: 'ClusterIP',
          clusterIP: '10.96.3.8',
          ports: [5432],
        ),
        ServiceInfo(
          name: 'api-gateway-service',
          namespace: 'api',
          type: 'NodePort',
          clusterIP: '10.96.4.22',
          ports: [8080, 8443],
        ),
      ]);
}

// Main Dashboard Screen
class KubernetesDashboard extends ConsumerStatefulWidget {
  @override
  ConsumerState<KubernetesDashboard> createState() =>
      _KubernetesDashboardState();
}

class _KubernetesDashboardState extends ConsumerState<KubernetesDashboard> {
  @override
  void initState() {
    super.initState();
    // Simulate real-time updates
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        ref.read(clusterMetricsProvider.notifier).updateMetrics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(clusterMetricsProvider);
    final pods = ref.watch(podsProvider);
    final services = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Color(0xFF0A0A0B),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 32),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildMetricsOverview(metrics),
                          SizedBox(height: 24),
                          Expanded(child: _buildChartsSection(metrics)),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(child: _buildPodsSection(pods)),
                          SizedBox(height: 24),
                          Expanded(child: _buildServicesSection(services)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF2A2A3E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.hub, color: Color(0xFF00D4FF), size: 28),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kubernetes Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Production Cluster - us-west-2',
                style: TextStyle(fontSize: 16, color: Color(0xFF8A8A9E)),
              ),
            ],
          ),
          Spacer(),
          _buildStatusIndicator('Healthy', Colors.green),
          SizedBox(width: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF00D4FF), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh, color: Color(0xFF00D4FF), size: 18),
                SizedBox(width: 8),
                Text(
                  'Auto-refresh',
                  style: TextStyle(color: Color(0xFF00D4FF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsOverview(ClusterMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Nodes',
            '${metrics.healthyNodes}/${metrics.totalNodes}',
            Icons.storage,
            Color(0xFF00D4FF),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Pods',
            '${metrics.runningPods}/${metrics.totalPods}',
            Icons.widgets,
            Color(0xFF00E676),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'CPU',
            '${metrics.cpuUsage.toStringAsFixed(1)}%',
            Icons.memory,
            Color(0xFFFF6B6B),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Memory',
            '${metrics.memoryUsage.toStringAsFixed(1)}%',
            Icons.pie_chart,
            Color(0xFFFFD93D),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2A2A3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9E))),
        ],
      ),
    );
  }

  Widget _buildChartsSection(ClusterMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildResourceChart(
            'CPU Usage',
            metrics.cpuUsage,
            Color(0xFFFF6B6B),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildResourceChart(
            'Memory Usage',
            metrics.memoryUsage,
            Color(0xFFFFD93D),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildResourceChart(
            'Storage Usage',
            metrics.storageUsage,
            Color(0xFF00E676),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceChart(String title, double value, Color color) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2A2A3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Color(0xFF2A2A3E),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2A2A3E),
                      ),
                    ),
                    CircularProgressIndicator(
                      value: value / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Center(
                      child: Text(
                        '${value.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }

  Widget _buildPodsSection(List<PodInfo> pods) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2A2A3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Pods',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pods.length} items',
                  style: TextStyle(color: Color(0xFF00D4FF), fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: pods.length,
              itemBuilder: (context, index) {
                final pod = pods[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F1419),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF2A2A3E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pod.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(pod.status),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            pod.namespace,
                            style: TextStyle(
                              color: Color(0xFF8A8A9E),
                              fontSize: 12,
                            ),
                          ),
                          Spacer(),
                          Text(
                            pod.node,
                            style: TextStyle(
                              color: Color(0xFF8A8A9E),
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
    );
  }

  Widget _buildServicesSection(List<ServiceInfo> services) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2A2A3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${services.length} active',
                  style: TextStyle(color: Color(0xFF00D4FF), fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F1419),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF2A2A3E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF00E676).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFF00E676).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              service.type,
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        service.clusterIP,
                        style: TextStyle(
                          color: Color(0xFF8A8A9E),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ports: ${service.ports.join(', ')}',
                        style: TextStyle(
                          color: Color(0xFF8A8A9E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'running':
        color = Color(0xFF00E676);
        break;
      case 'pending':
        color = Color(0xFFFFD93D);
        break;
      case 'failed':
        color = Color(0xFFFF6B6B);
        break;
      default:
        color = Color(0xFF8A8A9E);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// App Entry Point
class KubernetesDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Kubernetes Dashboard',
        theme: ThemeData.dark(),
        home: KubernetesDashboard(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void main() {
  runApp(KubernetesDashboardApp());
}
