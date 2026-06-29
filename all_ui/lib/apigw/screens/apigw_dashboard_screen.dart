import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert.dart';
import '../models/api_endpoint.dart';
import '../models/gateway_status.dart';
import '../models/traffic_data.dart';
import '../states/alert_provider.dart';
import '../states/deployment_provider.dart';
import '../states/endpoint_provider.dart';
import '../states/gateway_provider.dart';
import '../states/traffic_provider.dart';

class ApiGatewayDashboard extends ConsumerStatefulWidget {
  const ApiGatewayDashboard({super.key});

  @override
  ConsumerState<ApiGatewayDashboard> createState() =>
      _ApiGatewayDashboardState();
}

class _ApiGatewayDashboardState extends ConsumerState<ApiGatewayDashboard> {
  int _selectedIndex = 0;
  String? _selectedEndpointId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Navigation Rail
          _buildNavigationRail(),
          // Main Content
          Expanded(child: _buildMainContent()),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 2
              ? FloatingActionButton(
                onPressed: () => _showAddEndpointDialog(),
                backgroundColor: const Color(0xFF6366F1),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  AppBar _buildAppBar() {
    final alertsAsync = ref.watch(alertsProvider);
    final unreadCount =
        alertsAsync.whenOrNull(
          data: (alerts) => alerts.where((alert) => !alert.isRead).length,
        ) ??
        0;

    return AppBar(
      title: const Text(
        'Iket  Management',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotificationsPanel(),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _navigateTo(4), // Go to Settings
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
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      extended: true,
      minExtendedWidth: 200,
      backgroundColor: Colors.white,
      labelType: NavigationRailLabelType.none,
      onDestinationSelected: (index) => _navigateTo(index),
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
            Consumer(
              builder: (context, ref, child) {
                final deploymentState = ref.watch(deploymentProvider);
                return deploymentState.maybeWhen(
                  data:
                      (isDeployed) =>
                          isDeployed
                              ? const SizedBox.shrink()
                              : ElevatedButton.icon(
                                onPressed: () => _showDeployConfirmation(),
                                icon: const Icon(Icons.upload),
                                label: const Text('Deploy Changes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                  loading:
                      () => const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 16),
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
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Analytics'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.api_outlined),
          selectedIcon: Icon(Icons.api),
          label: Text('Endpoints'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: Text('Security'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: Text('Logs'),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return _buildAnalyticsScreen();
      case 2:
        return _selectedEndpointId != null
            ? _buildEndpointDetailScreen(_selectedEndpointId!)
            : _buildEndpointsScreen();
      case 3:
        return _buildSecurityScreen();
      case 4:
        return _buildSettingsScreen();
      case 5:
        return _buildLogsScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  // Dashboard Screen
  Widget _buildDashboardScreen() {
    final endpointsData = ref.watch(endpointsProvider);
    final trafficData = ref.watch(trafficDataProvider);
    ref.read(gatewayStatusProvider.notifier).fetchStatus();
    final gatewayStatus = ref.watch(gatewayStatusProvider).data;

    print('Gateway Status: $gatewayStatus');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Cards
            /* gatewayStatus.when(
              data: (status) => _buildStatusCards(status),
              loading: () => const ShimmerStatusCards(),
              error: (_, __) => const Text('Failed to load status'),
            ), */
            _buildStatusCards(gatewayStatus!),
            const SizedBox(height: 24),

            // Traffic Chart
            const Text(
              'API Traffic',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (_, __) => const Center(
                      child: Text('Failed to load traffic data'),
                    ),
              ),
            ),

            const SizedBox(height: 24),

            // Top Endpoints Table
            const Text(
              'Top Endpoints',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                data: (endpoints) {
                  // Sort by request count and take top 5
                  final topEndpoints = List<ApiEndpoint>.from(endpoints)
                    ..sort((a, b) => b.requestCount.compareTo(a.requestCount));

                  return _buildTopEndpointsTable(topEndpoints.take(5).toList());
                },
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error:
                    (_, __) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Failed to load endpoints'),
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Alerts
            const Text(
              'Recent Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildRecentAlerts(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards(GatewayStatus status) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            title: 'Status',
            value: status.isOnline ? 'Online' : 'Offline',
            icon: Icons.power_settings_new,
            iconColor: status.isOnline ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            title: 'Response Time',
            value: '${status.averageResponseTime.toStringAsFixed(2)} ms',
            icon: Icons.speed,
            iconColor: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            title: 'Success Rate',
            value: '${(status.successRate * 100).toStringAsFixed(1)}%',
            icon: Icons.check_circle_outline,
            iconColor: _getSuccessRateColor(status.successRate),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            title: 'Total Endpoints',
            value: status.totalEndpoints.toString(),
            icon: Icons.api,
            iconColor: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.98) return Colors.green;
    if (rate >= 0.95) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
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
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficChart(List<TrafficData> data) {
    // Implement chart using fl_chart or other charting library
    // For now, we'll just show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Traffic chart with ${data.length} data points',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTopEndpointsTable(List<ApiEndpoint> endpoints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 20,
        columns: const [
          DataColumn(label: Text('Path')),
          DataColumn(label: Text('Method')),
          DataColumn(label: Text('Requests'), numeric: true),
          DataColumn(label: Text('Avg. Response')),
          DataColumn(label: Text('Success Rate')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            endpoints.map((endpoint) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      endpoint.path,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(endpoint.requestCount.toString())),
                  DataCell(
                    Text('${endpoint.avgResponseTime.toStringAsFixed(2)} ms'),
                  ),
                  DataCell(
                    Text('${(endpoint.successRate * 100).toStringAsFixed(1)}%'),
                  ),
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
                                : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        endpoint.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: endpoint.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed:
                              () => _navigateToEndpointDetail(endpoint.id),
                          tooltip: 'Edit',
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed:
                              () => _showDeleteEndpointDialog(endpoint.id),
                          tooltip: 'Delete',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecentAlerts() {
    final alertsAsync = ref.watch(alertsProvider);

    return Container(
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
      child: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text('No recent alerts')),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length > 5 ? 5 : alerts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getAlertSeverityColor(
                      alert.severity,
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAlertSeverityIcon(alert.severity),
                    color: _getAlertSeverityColor(alert.severity),
                  ),
                ),
                title: Text(alert.title),
                subtitle: Text(
                  alert.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAlertTime(alert.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    if (!alert.isRead)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () => _showAlertDetails(alert),
              );
            },
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
        error:
            (_, __) => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Failed to load alerts'),
              ),
            ),
      ),
    );
  }

  IconData _getAlertSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.warning_amber;
      case 'high':
        return Icons.error_outline;
      case 'medium':
        return Icons.info_outline;
      case 'low':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getAlertSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatAlertTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Analytics Screen
  Widget _buildAnalyticsScreen() {
    // Implement analytics screen
    return const Center(child: Text('Analytics Screen - Coming Soon'));
  }

  // Endpoints Screen
  Widget _buildEndpointsScreen() {
    final endpointsAsync = ref.watch(endpointsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'API Endpoints',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEndpointDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Endpoint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: endpointsAsync.when(
              data: (endpoints) {
                if (endpoints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.api_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No endpoints configured',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEndpointDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Endpoint'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildEndpointsTable(endpoints);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) =>
                      const Center(child: Text('Failed to load endpoints')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointsTable(List<ApiEndpoint> endpoints) {
    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('Path')),
            DataColumn(label: Text('Method')),
            DataColumn(label: Text('Target')),
            DataColumn(label: Text('Requests'), numeric: true),
            DataColumn(label: Text('Avg. Response')),
            DataColumn(label: Text('Success Rate')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows:
              endpoints.map((endpoint) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        endpoint.path,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () => _navigateToEndpointDetail(endpoint.id),
                    ),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(endpoint.targetUrl!)),
                    DataCell(Text(endpoint.requestCount.toString())),
                    DataCell(
                      Text('${endpoint.avgResponseTime.toStringAsFixed(2)} ms'),
                    ),
                    DataCell(
                      Text(
                        '${(endpoint.successRate * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: endpoint.isActive,
                        onChanged:
                            (value) =>
                                _toggleEndpointStatus(endpoint.id, value),
                        activeColor: const Color(0xFF6366F1),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed:
                                () => _navigateToEndpointDetail(endpoint.id),
                            tooltip: 'View Details',
                            color: Colors.blue,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _showEditEndpointDialog(endpoint),
                            tooltip: 'Edit',
                            color: const Color(0xFF6366F1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed:
                                () => _showDeleteEndpointDialog(endpoint.id),
                            tooltip: 'Delete',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  // Endpoint Detail Screen
  Widget _buildEndpointDetailScreen(String endpointId) {
    final endpointsAsync = ref.watch(endpointsProvider);

    return endpointsAsync.when(
      data: (endpoints) {
        final endpoint = endpoints.firstWhere(
          (e) => e.id == endpointId,
          orElse: () => throw Exception('Endpoint not found'),
        );

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedEndpointId = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Endpoint: ${endpoint.path}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Switch(
                    value: endpoint.isActive,
                    onChanged:
                        (value) => _toggleEndpointStatus(endpoint.id, value),
                    activeColor: const Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditEndpointDialog(endpoint),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _showDeleteEndpointDialog(endpoint.id).then((_) {
                        if (mounted) {
                          setState(() {
                            _selectedEndpointId = null;
                          });
                        }
                      });
                    },
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildEndpointDetailTabs(endpoint)),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load endpoint')),
    );
  }

  Widget _buildEndpointDetailTabs(ApiEndpoint endpoint) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Request Stats'),
                Tab(text: 'Configuration'),
                Tab(text: 'Logs'),
              ],
              labelColor: Color(0xFF6366F1),
              unselectedLabelColor: Colors.black54,
              indicatorColor: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              children: [
                _buildEndpointOverviewTab(endpoint),
                _buildEndpointStatsTab(endpoint),
                _buildEndpointConfigTab(endpoint),
                _buildEndpointLogsTab(endpoint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointOverviewTab(ApiEndpoint endpoint) {
    // Implement endpoint overview
    return const Center(child: Text('Endpoint Overview - Coming Soon'));
  }

  Widget _buildEndpointStatsTab(ApiEndpoint endpoint) {
    // Implement endpoint stats
    return const Center(child: Text('Endpoint Stats - Coming Soon'));
  }

  Widget _buildEndpointConfigTab(ApiEndpoint endpoint) {
    // Implement endpoint configuration
    return const Center(child: Text('Endpoint Configuration - Coming Soon'));
  }

  Widget _buildEndpointLogsTab(ApiEndpoint endpoint) {
    // Implement endpoint logs
    return const Center(child: Text('Endpoint Logs - Coming Soon'));
  }

  // Security Screen
  Widget _buildSecurityScreen() {
    // Implement security screen
    return const Center(child: Text('Security Screen - Coming Soon'));
  }

  // Settings Screen
  Widget _buildSettingsScreen() {
    // Implement settings screen
    return const Center(child: Text('Settings Screen - Coming Soon'));
  }

  // Logs Screen
  Widget _buildLogsScreen() {
    // Implement logs screen
    return const Center(child: Text('Logs Screen - Coming Soon'));
  }

  // Helper Methods
  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedEndpointId = null;
    });
  }

  void _navigateToEndpointDetail(String endpointId) {
    setState(() {
      _selectedIndex = 2; // Endpoints tab
      _selectedEndpointId = endpointId;
    });
  }

  Future<void> _showNotificationsPanel() async {
    // Implement notifications panel
  }

  Future<void> _showDeployConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Deploy Changes'),
            content: const Text(
              'Are you sure you want to deploy all changes to the Iket ?\n\n'
              'This will affect all live traffic immediately.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Deploy'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(deploymentProvider.notifier).deploy();
    }
  }

  Future<void> _showAddEndpointDialog() async {
    // Implement add endpoint dialog
  }

  Future<void> _showEditEndpointDialog(ApiEndpoint endpoint) async {
    // Implement edit endpoint dialog
  }

  Future<void> _showDeleteEndpointDialog(String endpointId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Endpoint'),
            content: const Text(
              'Are you sure you want to delete this endpoint?\n\n'
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(endpointsProvider.notifier).deleteEndpoint(endpointId);
    }
  }

  void _toggleEndpointStatus(String endpointId, bool isActive) {
    ref
        .read(endpointsProvider.notifier)
        .updateEndpointStatus(endpointId, isActive);
  }

  void _showAlertDetails(Alert alert) {
    // Mark alert as read
    ref.read(alertsProvider.notifier).markAlertAsRead(alert.id);

    // Show alert details
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(alert.title),
            content: Text(alert.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
