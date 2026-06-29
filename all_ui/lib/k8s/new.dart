import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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

class ClusterInfo {
  final String name;
  final String endpoint;
  final String version;
  final String provider;
  final String region;
  final String status;

  ClusterInfo({
    required this.name,
    required this.endpoint,
    required this.version,
    required this.provider,
    required this.region,
    required this.status,
  });
}

class ClusterMetrics {
  final int totalNodes;
  final int healthyNodes;
  final double cpuUsage;
  final double memoryUsage;
  final double storageUsage;
  final int totalPods;
  final int runningPods;

  ClusterMetrics({
    required this.totalNodes,
    required this.healthyNodes,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storageUsage,
    required this.totalPods,
    required this.runningPods,
  });
}

class ComponentHealth {
  final String name;
  final String status;
  final DateTime lastCheck;
  final String? message;

  ComponentHealth({
    required this.name,
    required this.status,
    required this.lastCheck,
    this.message,
  });
}

class ClusterHealth {
  final String status;
  final DateTime lastCheck;
  final List<ComponentHealth> components;
  final List<String> alerts;

  ClusterHealth({
    required this.status,
    required this.lastCheck,
    required this.components,
    required this.alerts,
  });
}

class ClusterConfiguration {
  final String kubeconfig;
  final String context;
  final String namespace;
  final bool rbacEnabled;
  final String serviceAccount;
  final List<String> enabledFeatures;

  ClusterConfiguration({
    required this.kubeconfig,
    required this.context,
    required this.namespace,
    required this.rbacEnabled,
    required this.serviceAccount,
    required this.enabledFeatures,
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
final selectedTabProvider = StateProvider<int>((ref) => 0);

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

final clusterInfoProvider = Provider.family<ClusterInfo, String>((
  ref,
  clusterName,
) {
  final infoMap = {
    'production-cluster': ClusterInfo(
      name: 'production-cluster',
      endpoint: 'https://prod-k8s-api.company.com',
      version: 'v1.28.4',
      provider: 'AWS EKS',
      region: 'us-west-2',
      status: 'Healthy',
    ),
    'staging-cluster': ClusterInfo(
      name: 'staging-cluster',
      endpoint: 'https://staging-k8s-api.company.com',
      version: 'v1.28.2',
      provider: 'Google GKE',
      region: 'us-central1',
      status: 'Healthy',
    ),
    'development-cluster': ClusterInfo(
      name: 'development-cluster',
      endpoint: 'https://dev-k8s-api.company.com',
      version: 'v1.27.8',
      provider: 'Azure AKS',
      region: 'eastus',
      status: 'Warning',
    ),
  };
  return infoMap[clusterName] ?? infoMap['production-cluster']!;
});

final clusterMetricsProvider = Provider.family<ClusterMetrics, String>((
  ref,
  clusterName,
) {
  final metricsMap = {
    'production-cluster': ClusterMetrics(
      totalNodes: 12,
      healthyNodes: 12,
      cpuUsage: 68.5,
      memoryUsage: 72.3,
      storageUsage: 45.2,
      totalPods: 156,
      runningPods: 154,
    ),
    'staging-cluster': ClusterMetrics(
      totalNodes: 6,
      healthyNodes: 6,
      cpuUsage: 45.2,
      memoryUsage: 38.7,
      storageUsage: 32.1,
      totalPods: 89,
      runningPods: 87,
    ),
    'development-cluster': ClusterMetrics(
      totalNodes: 4,
      healthyNodes: 3,
      cpuUsage: 23.1,
      memoryUsage: 45.8,
      storageUsage: 28.4,
      totalPods: 34,
      runningPods: 32,
    ),
  };
  return metricsMap[clusterName] ?? metricsMap['production-cluster']!;
});

final clusterHealthProvider = Provider.family<ClusterHealth, String>((
  ref,
  clusterName,
) {
  return ClusterHealth(
    status: clusterName == 'development-cluster' ? 'Warning' : 'Healthy',
    lastCheck: DateTime.now().subtract(const Duration(minutes: 2)),
    components: [
      ComponentHealth(
        name: 'API Server',
        status: 'Healthy',
        lastCheck: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      ComponentHealth(
        name: 'etcd',
        status: 'Healthy',
        lastCheck: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      ComponentHealth(
        name: 'Controller Manager',
        status: clusterName == 'development-cluster' ? 'Warning' : 'Healthy',
        lastCheck: DateTime.now().subtract(const Duration(minutes: 2)),
        message:
            clusterName == 'development-cluster'
                ? 'High CPU usage detected'
                : null,
      ),
      ComponentHealth(
        name: 'Scheduler',
        status: 'Healthy',
        lastCheck: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      ComponentHealth(
        name: 'CoreDNS',
        status: 'Healthy',
        lastCheck: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ],
    alerts:
        clusterName == 'development-cluster'
            ? [
              'High CPU usage on controller-manager',
              'Node disk usage above 80%',
            ]
            : [],
  );
});

final clusterConfigProvider = Provider.family<ClusterConfiguration, String>((
  ref,
  clusterName,
) {
  final configMap = {
    'production-cluster': ClusterConfiguration(
      kubeconfig: '~/.kube/prod-config',
      context: 'arn:aws:eks:us-west-2:123456789012:cluster/production-cluster',
      namespace: 'default',
      rbacEnabled: true,
      serviceAccount: 'cluster-admin',
      enabledFeatures: [
        'RBAC',
        'Network Policies',
        'Pod Security Standards',
        'Audit Logging',
      ],
    ),
    'staging-cluster': ClusterConfiguration(
      kubeconfig: '~/.kube/staging-config',
      context: 'gke_project-id_us-central1_staging-cluster',
      namespace: 'staging',
      rbacEnabled: true,
      serviceAccount: 'staging-admin',
      enabledFeatures: ['RBAC', 'Network Policies', 'Workload Identity'],
    ),
    'development-cluster': ClusterConfiguration(
      kubeconfig: '~/.kube/dev-config',
      context: 'dev-cluster-context',
      namespace: 'development',
      rbacEnabled: false,
      serviceAccount: 'dev-user',
      enabledFeatures: ['Basic Auth', 'Admission Controllers'],
    ),
  };
  return configMap[clusterName] ?? configMap['production-cluster']!;
});

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
    final selectedCluster = ref.watch(selectedClusterProvider);
    final selectedTab = ref.watch(selectedTabProvider);

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
                        'Overview',
                        selectedTab == 0,
                        () {
                          ref.read(selectedTabProvider.notifier).state = 0;
                        },
                      ),
                      _buildNavItem(
                        Icons.info_outline,
                        'Cluster Info',
                        selectedTab == 1,
                        () {
                          ref.read(selectedTabProvider.notifier).state = 1;
                        },
                      ),
                      _buildNavItem(
                        Icons.analytics_outlined,
                        'Metrics',
                        selectedTab == 2,
                        () {
                          ref.read(selectedTabProvider.notifier).state = 2;
                        },
                      ),
                      _buildNavItem(
                        Icons.health_and_safety_outlined,
                        'Health',
                        selectedTab == 3,
                        () {
                          ref.read(selectedTabProvider.notifier).state = 3;
                        },
                      ),
                      _buildNavItem(
                        Icons.settings_outlined,
                        'Configuration',
                        selectedTab == 4,
                        () {
                          ref.read(selectedTabProvider.notifier).state = 4;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNavItem(
                        Icons.workspaces_outline,
                        'Workloads',
                        false,
                        () {},
                      ),
                      _buildNavItem(
                        Icons.network_check,
                        'Services',
                        false,
                        () {},
                      ),
                      _buildNavItem(Icons.security, 'Security', false, () {}),
                      _buildNavItem(
                        Icons.dashboard,
                        'Monitoring',
                        false,
                        () {},
                      ),
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
                      Text(
                        _getPageTitle(selectedTab),
                        style: const TextStyle(
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
                                ref.watch(clustersProvider).map((cluster) {
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

                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _buildContent(selectedTab, selectedCluster, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int tab) {
    switch (tab) {
      case 0:
        return 'Kubernetes Dashboard';
      case 1:
        return 'Cluster Information';
      case 2:
        return 'Cluster Metrics';
      case 3:
        return 'Cluster Health';
      case 4:
        return 'Cluster Configuration';
      default:
        return 'Kubernetes Console';
    }
  }

  Widget _buildContent(int selectedTab, String selectedCluster, WidgetRef ref) {
    switch (selectedTab) {
      case 0:
        return _buildOverviewTab(selectedCluster, ref);
      case 1:
        return _buildClusterInfoTab(selectedCluster, ref);
      case 2:
        return _buildClusterMetricsTab(selectedCluster, ref);
      case 3:
        return _buildClusterHealthTab(selectedCluster, ref);
      case 4:
        return _buildClusterConfigTab(selectedCluster, ref);
      default:
        return _buildOverviewTab(selectedCluster, ref);
    }
  }

  Widget _buildOverviewTab(String selectedCluster, WidgetRef ref) {
    final clusters = ref.watch(clustersProvider);
    final pods = ref.watch(podsProvider);
    final currentCluster = clusters.firstWhere(
      (cluster) => cluster.name == selectedCluster,
      orElse: () => clusters.first,
    );

    return Column(
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
              Expanded(flex: 2, child: _buildResourceChart()),

              const SizedBox(width: 24),

              // Pods Table
              Expanded(flex: 3, child: _buildPodsTable(pods)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClusterInfoTab(String selectedCluster, WidgetRef ref) {
    final clusterInfo = ref.watch(clusterInfoProvider(selectedCluster));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('Cluster Details', [
                  _buildInfoRow('Name', clusterInfo.name, Icons.label),
                  _buildInfoRow('Endpoint', clusterInfo.endpoint, Icons.link),
                  _buildInfoRow('Version', clusterInfo.version, Icons.code),
                  _buildInfoRow('Provider', clusterInfo.provider, Icons.cloud),
                  _buildInfoRow(
                    'Region',
                    clusterInfo.region,
                    Icons.location_on,
                  ),
                  _buildStatusRow('Status', clusterInfo.status),
                ]),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildInfoCard('Quick Actions', [
                  _buildActionButton(
                    'Update Cluster',
                    Icons.system_update,
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Scale Nodes',
                    Icons.trending_up,
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Backup Config',
                    Icons.backup,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'View Logs',
                    Icons.description,
                    const Color(0xFF8B5CF6),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClusterMetricsTab(String selectedCluster, WidgetRef ref) {
    final metrics = ref.watch(clusterMetricsProvider(selectedCluster));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Node Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Nodes',
                  metrics.totalNodes.toString(),
                  Icons.dns,
                  const Color(0xFF3B82F6),
                  '${metrics.healthyNodes} healthy',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildMetricCard(
                  'Healthy Nodes',
                  metrics.healthyNodes.toString(),
                  Icons.check_circle,
                  const Color(0xFF10B981),
                  '${((metrics.healthyNodes / metrics.totalNodes) * 100).toStringAsFixed(1)}% uptime',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildMetricCard(
                  'Total Pods',
                  metrics.totalPods.toString(),
                  Icons.widgets,
                  const Color(0xFF8B5CF6),
                  '${metrics.runningPods} running',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Resource Usage
          Row(
            children: [
              Expanded(
                child: _buildUsageCard(
                  'CPU Usage',
                  metrics.cpuUsage,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildUsageCard(
                  'Memory Usage',
                  metrics.memoryUsage,
                  const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildUsageCard(
                  'Storage Usage',
                  metrics.storageUsage,
                  const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Detailed Charts
          _buildResourceChart(),
        ],
      ),
    );
  }

  Widget _buildClusterHealthTab(String selectedCluster, WidgetRef ref) {
    final health = ref.watch(clusterHealthProvider(selectedCluster));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Overview
          Row(
            children: [
              Expanded(child: _buildHealthOverviewCard(health)),
              const SizedBox(width: 24),
              Expanded(child: _buildAlertsCard(health.alerts)),
            ],
          ),

          const SizedBox(height: 32),

          // Components Health
          _buildComponentsHealthCard(health.components),
        ],
      ),
    );
  }

  Widget _buildClusterConfigTab(String selectedCluster, WidgetRef ref) {
    final config = ref.watch(clusterConfigProvider(selectedCluster));

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('Configuration', [
                  _buildInfoRow(
                    'Kubeconfig',
                    config.kubeconfig,
                    Icons.settings,
                  ),
                  _buildInfoRow('Context', config.context, Icons.account_tree),
                  _buildInfoRow('Namespace', config.namespace, Icons.folder),
                  _buildInfoRow(
                    'Service Account',
                    config.serviceAccount,
                    Icons.account_circle,
                  ),
                  _buildBooleanRow('RBAC Enabled', config.rbacEnabled),
                ]),
              ),
              const SizedBox(width: 24),
              Expanded(child: _buildFeaturesCard(config.enabledFeatures)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
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
            fontWeight: isActive ? FontWeight.normal : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? const Color(0xFF4F46E5).withOpacity(0.1) : null,
        onTap: onTap,
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
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'status',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanRow(String label, bool value) {
    final color = value ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const Spacer(),
          Text(
            value ? 'Enabled' : 'Disabled',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildUsageCard(String title, double usage, Color color) {
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${usage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: usage / 100,
            backgroundColor: const Color(0xFF2A2E3E),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            usage > 80
                ? 'High Usage'
                : usage > 60
                ? 'Medium Usage'
                : 'Normal Usage',
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverviewCard(ClusterHealth health) {
    final statusColor =
        health.status == 'Healthy'
            ? const Color(0xFF10B981)
            : health.status == 'Warning'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

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
              Text(
                'Cluster Health',
                style: const TextStyle(
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  health.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            'Overall Status',
            health.status,
            Icons.health_and_safety,
          ),
          _buildInfoRow(
            'Last Check',
            _formatDateTime(health.lastCheck),
            Icons.schedule,
          ),
          _buildInfoRow(
            'Components',
            '${health.components.length} monitored',
            Icons.widgets,
          ),
          _buildInfoRow(
            'Active Alerts',
            '${health.alerts.length}',
            Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(List<String> alerts) {
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
              const Text(
                'Active Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (alerts.isNotEmpty)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      alerts.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (alerts.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No Active Alerts',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
          else
            ...alerts
                .map(
                  (alert) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildComponentsHealthCard(List<ComponentHealth> components) {
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
          const Text(
            'Component Health',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...components.map((component) {
            final statusColor =
                component.status == 'Healthy'
                    ? const Color(0xFF10B981)
                    : component.status == 'Warning'
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2E3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          component.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last check: ${_formatDateTime(component.lastCheck)}',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                        if (component.message != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            component.message!,
                            style: TextStyle(color: statusColor, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      component.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(List<String> features) {
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
          const Text(
            'Enabled Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                features
                    .map(
                      (feature) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceChart() {
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
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF2A2E3E),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          '00:00',
                          '04:00',
                          '08:00',
                          '12:00',
                          '16:00',
                          '20:00',
                          '24:00',
                        ];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
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
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
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
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4F46E5).withOpacity(0.3),
                          const Color(0xFF7C3AED).withOpacity(0.1),
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
    );
  }

  Widget _buildPodsTable(List<PodMetrics> pods) {
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
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'All Healthy',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
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
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2E3E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pod.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pod.namespace,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'CPU: ${pod.cpuUsage.toStringAsFixed(1)}m',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'MEM: ${pod.memoryUsage.toStringAsFixed(0)}Mi',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9CA3AF), size: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    final color =
        status == 'Healthy'
            ? const Color(0xFF10B981)
            : status == 'Warning'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            Icons.health_and_safety,
            color: const Color(0xFF9CA3AF),
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text('subtitle', style: TextStyle(color: color, fontSize: 12)),
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
