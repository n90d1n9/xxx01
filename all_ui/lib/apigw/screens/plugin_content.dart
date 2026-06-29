import 'package:flutter/material.dart';

import 'dev_tools_screen.dart';
import 'monitoring_screen.dart';
import 'plugin_screen.dart';
import 'security_screen.dart';
import 'trafic_screen.dart';

class PluginContent extends StatelessWidget {
  const PluginContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and manage your Iket  settings',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 24),

          // Quick Stats Cards
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                title: 'Total APIs',
                value: '32',
                icon: Icons.api,
                color: Colors.blue,
              ),
              _buildStatCard(
                context,
                title: 'Active Endpoints',
                value: '124',
                icon: Icons.link,
                color: Colors.green,
              ),
              _buildStatCard(
                context,
                title: 'Security Alerts',
                value: '3',
                icon: Icons.security,
                color: Colors.red,
              ),
              _buildStatCard(
                context,
                title: 'Today\'s Requests',
                value: '1.4M',
                icon: Icons.bar_chart,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Feature Quick Access Section
          Text('Quick Access', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  title: 'Security',
                  description:
                      'Configure authentication, authorization, and protection',
                  icon: Icons.shield,
                  color: Colors.indigo,
                  onTap: () => _navigateToFeature(context, 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  title: 'Monitoring',
                  description: 'View metrics, traces, and logs',
                  icon: Icons.computer,
                  color: Colors.teal,
                  onTap: () => _navigateToFeature(context, 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  title: 'Traffic Management',
                  description:
                      'Configure routing, load balancing, and traffic splitting',
                  icon: Icons.route,
                  color: Colors.amber.shade700,
                  onTap: () => _navigateToFeature(context, 3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  title: 'Developer Tools',
                  description: 'API documentation, testing, and integration',
                  icon: Icons.code,
                  color: Colors.deepPurple,
                  onTap: () => _navigateToFeature(context, 4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Activity
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    context,
                    title: 'Rate limit updated',
                    description:
                        'Changed from 100 to 200 req/s for /api/v1/users',
                    time: '5 min ago',
                    icon: Icons.speed,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    context,
                    title: 'New security certificate',
                    description:
                        'Added new TLS certificate for api.example.com',
                    time: '1 hour ago',
                    icon: Icons.verified,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    context,
                    title: 'Canary release started',
                    description:
                        '10% traffic to new version of /api/v2/payments',
                    time: '3 hours ago',
                    icon: Icons.call_split,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Icon(Icons.more_horiz, color: colorScheme.onSurface),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Configure',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String description,
    required String time,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  void _navigateToFeature(BuildContext context, int index) {
    final parent = context.findAncestorStateOfType<_DashboardScreenState>();
    if (parent != null) {
      parent.setState(() {
        parent._selectedIndex = index;
      });
    }
  }
}

class _DashboardScreenState extends State<PluginScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard_outlined),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.security),
                selectedIcon: Icon(Icons.security_outlined),
                label: Text('Security'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monitor),
                selectedIcon: Icon(Icons.monitor_outlined),
                label: Text('Monitoring'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.route),
                selectedIcon: Icon(Icons.route_outlined),
                label: Text('Traffic'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.code),
                selectedIcon: Icon(Icons.code_outlined),
                label: Text('Dev Tools'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return const PluginContent();
      case 1:
        return const SecurityFeaturesScreen();
      case 2:
        return const MonitoringScreen();
      case 3:
        return const TrafficManagementScreen();
      case 4:
        return const DeveloperToolsScreen();
      default:
        return const PluginContent();
    }
  }
}
