import 'package:flutter/material.dart';

class TrafficManagementScreen extends StatefulWidget {
  const TrafficManagementScreen({super.key});

  @override
  State<TrafficManagementScreen> createState() =>
      _TrafficManagementScreenState();
}

class _TrafficManagementScreenState extends State<TrafficManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: (bool newValue) {}),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Traffic Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure routing, load balancing, and traffic control policies',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),

        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Routing'),
            Tab(text: 'Load Balancing'),
            Tab(text: 'Resilience'),
            Tab(text: 'Deployment Strategies'),
          ],
          dividerColor: Colors.transparent,
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRoutingTab(context),
              _buildLoadBalancingTab(context),
              _buildResilienceTab(context),
              _buildDeploymentStrategiesTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Route Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure dynamic routing based on path, headers, and query parameters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // Route List Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configured Routes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Add Route'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  for (int i = 0; i < 3; i++) _buildRouteCard(context, i),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // HTTP Methods Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HTTP Methods',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMethodChip(context, 'GET', true),
                      _buildMethodChip(context, 'POST', true),
                      _buildMethodChip(context, 'PUT', true),
                      _buildMethodChip(context, 'DELETE', true),
                      _buildMethodChip(context, 'PATCH', true),
                      _buildMethodChip(context, 'HEAD', false),
                      _buildMethodChip(context, 'OPTIONS', false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Advanced Routing Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Routing Features',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'URL Rewriting',
                    subtitle: 'Modify request URLs before sending to backend',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Header-based Routing',
                    subtitle: 'Route based on HTTP headers',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Query Parameter Routing',
                    subtitle: 'Route based on query string parameters',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Cookie-based Routing',
                    subtitle: 'Route based on cookie values',
                    value: false,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Path-based Routing',
                    subtitle: 'Route based on URL path patterns',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Method-based Routing',
                    subtitle: 'Route based on HTTP method',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Host-based Routing',
                    subtitle: 'Route based on host header',
                    value: false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // CORS Configuration Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'CORS Configuration',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Allowed Origins',
                    hint: '*, example.com, localhost:3000',
                    icon: Icons.language,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Allowed Methods',
                    hint: 'GET, POST, PUT, DELETE',
                    icon: Icons.send,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Allowed Headers',
                    hint: 'Content-Type, Authorization',
                    icon: Icons.view_headline,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Max Age (seconds)',
                    hint: '3600',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Allow Credentials',
                    subtitle: 'Allow cookies in CORS requests',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }
  /* 
  Widget _buildLoadBalancingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Load Balancing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Text(
            'Configure load balancing algorithms and backend health checks',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 24),
          
          // Load Balancing Algorithms Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all( */

  Widget _buildMethodChip(
    BuildContext context,
    String method,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(method),
      selected: isSelected,
      onSelected: (bool value) {},
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final routes = [
      {
        'path': '/api/v1/users',
        'target': 'user-service:8080',
        'methods': ['GET', 'POST'],
        'priority': 'High',
      },
      {
        'path': '/api/v1/products',
        'target': 'product-service:8080',
        'methods': ['GET', 'POST', 'PUT'],
        'priority': 'Medium',
      },
      {
        'path': '/api/v1/orders',
        'target': 'order-service:8080',
        'methods': ['GET', 'POST', 'DELETE'],
        'priority': 'High',
      },
    ];

    final route = routes[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    route['path'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(route['priority'] as String),
                  backgroundColor:
                      route['priority'] == 'High'
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : colorScheme.secondary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color:
                        route['priority'] == 'High'
                            ? colorScheme.primary
                            : colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.dns, size: 16, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(route['target'] as String),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.http, size: 16, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children:
                        (route['methods'] as List<String>)
                            .map(
                              (method) => Chip(
                                label: Text(method),
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  tooltip: 'Edit Route',
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  tooltip: 'Delete Route',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadBalancingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Load Balancing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure load balancing algorithms and backend health checks',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // Load Balancing Algorithms Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Load Balancing Algorithm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Radio buttons for algorithm selection
                  _buildRadioOption(
                    context,
                    'Round Robin',
                    'Distribute requests sequentially across backends',
                    true,
                  ),
                  const SizedBox(height: 8),

                  _buildRadioOption(
                    context,
                    'Least Connections',
                    'Route to backend with fewest active connections',
                    false,
                  ),
                  const SizedBox(height: 8),

                  _buildRadioOption(
                    context,
                    'IP Hash',
                    'Consistent routing based on client IP address',
                    false,
                  ),
                  const SizedBox(height: 8),

                  _buildRadioOption(
                    context,
                    'Weighted Round Robin',
                    'Round robin with configurable weights per backend',
                    false,
                  ),
                  const SizedBox(height: 8),

                  _buildRadioOption(
                    context,
                    'Random',
                    'Random backend selection',
                    false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Backend Services Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Backend Services',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Add Backend'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  for (int i = 0; i < 3; i++)
                    _buildBackendServiceCard(context, i),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Health Checks Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Check Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Health Check Endpoint',
                    hint: '/health, /status, or /ping',
                    icon: Icons.monitor_heart,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          context,
                          label: 'Interval (seconds)',
                          hint: '5',
                          icon: Icons.timer,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          context,
                          label: 'Timeout (seconds)',
                          hint: '3',
                          icon: Icons.timer_off,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          context,
                          label: 'Healthy Threshold',
                          hint: '2',
                          icon: Icons.check_circle,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          context,
                          label: 'Unhealthy Threshold',
                          hint: '3',
                          icon: Icons.error,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Active Health Checks',
                    subtitle: 'Actively probe backends for health status',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Passive Health Checks',
                    subtitle: 'Monitor real traffic for failures',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Session Persistence Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Session Persistence',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildRadioOption(
                    context,
                    'Cookie-based',
                    'Use cookies to maintain session affinity',
                    true,
                  ),
                  const SizedBox(height: 8),

                  _buildRadioOption(
                    context,
                    'IP-based',
                    'Use client IP address for session affinity',
                    false,
                  ),
                  const SizedBox(height: 8),

                  _buildRadioOption(
                    context,
                    'Header-based',
                    'Use HTTP header value for session affinity',
                    false,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Cookie Name (if cookie-based)',
                    hint: 'SESSIONID',
                    icon: Icons.cookie,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Timeout (minutes)',
                    hint: '30',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<bool>(value: true, groupValue: isSelected, onChanged: (value) {}),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackendServiceCard(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final backends = [
      {
        'name': 'user-service',
        'endpoint': 'user-service:8080',
        'weight': 100,
        'status': 'Healthy',
      },
      {
        'name': 'product-service',
        'endpoint': 'product-service:8080',
        'weight': 80,
        'status': 'Healthy',
      },
      {
        'name': 'order-service',
        'endpoint': 'order-service:8080',
        'weight': 100,
        'status': 'Degraded',
      },
    ];

    final backend = backends[index];
    final isHealthy = backend['status'] == 'Healthy';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    backend['name'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(backend['status'] as String),
                  backgroundColor:
                      isHealthy
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isHealthy ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.dns, size: 16, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(backend['endpoint'] as String),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.balance, size: 16, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text('Weight: ${backend['weight']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  tooltip: 'Edit Backend',
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  tooltip: 'Delete Backend',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResilienceTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Resilience Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure circuit breaking, retries, timeouts, and fault tolerance',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // Circuit Breaker Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Circuit Breaker',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Automatically detect failing endpoints and stop sending traffic to them',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Error Threshold (%)',
                    hint: '50',
                    icon: Icons.error_outline,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Consecutive Errors',
                    hint: '5',
                    icon: Icons.repeat,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Reset Timeout (seconds)',
                    hint: '30',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Half-Open State',
                    subtitle: 'Allow test requests when circuit is open',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Retry Policy Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Retry Policy',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Max Retries',
                    hint: '3',
                    icon: Icons.refresh,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Retry Interval (ms)',
                    hint: '1000',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Retry On:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMethodChip(context, '5xx Errors', true),
                      _buildMethodChip(context, 'Connection Timeout', true),
                      _buildMethodChip(context, 'Connection Error', true),
                      _buildMethodChip(context, '4xx Errors', false),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Exponential Backoff',
                    subtitle: 'Increase retry interval exponentially',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Timeout Settings Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timeout Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Connection Timeout (ms)',
                    hint: '1000',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Request Timeout (ms)',
                    hint: '5000',
                    icon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Idle Timeout (ms)',
                    hint: '60000',
                    icon: Icons.hourglass_empty,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bulkhead Pattern Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Bulkhead Pattern',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Isolate failures to prevent cascading failures across services',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Max Concurrent Requests',
                    hint: '100',
                    icon: Icons.fork_right,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Queue Size',
                    hint: '25',
                    icon: Icons.queue,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Fallback Responses Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Fallback Responses',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Configure responses when backend services are unavailable',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Default Status Code',
                    hint: '503',
                    icon: Icons.error_outline,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Response Body Template',
                    hint: '{"error": "Service temporarily unavailable"}',
                    icon: Icons.format_align_left,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Cache Last Successful Response',
                    subtitle: 'Return cached response when backend fails',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeploymentStrategiesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Deployment Strategies',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure canary releases, A/B testing, and blue-green deployment strategies',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // Canary Releases Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Canary Releases',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Gradually roll out new versions to a subset of users',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildCanaryReleaseCard(context),

                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Canary Rule'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // A/B Testing Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'A/B Testing',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Route traffic based on request attributes for feature testing',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildAbTestCard(context),

                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add A/B Test Rule'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Blue-Green Deployment Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Blue-Green Deployment',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Switch between two identical production environments for zero-downtime deployments',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildBlueGreenCard(context),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feature Flags Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Feature Flags',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: true, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Enable or disable features dynamically based on request attributes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureFlagList(context),

                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Feature Flag'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Shadow Traffic Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Shadow Traffic',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(value: false, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Mirror traffic to a test environment for validation without affecting the user',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Shadow Service Endpoint',
                    hint: 'new-service:8080',
                    icon: Icons.filter_tilt_shift,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Percentage of Traffic',
                    hint: '10',
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Ignore Shadow Responses',
                    subtitle: 'Only send traffic, don\'t wait for responses',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(onPressed: () {}, child: const Text('Save Changes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCanaryReleaseCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'New API Service v2.1',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: const Text('Active'),
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Version',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text('api-service:8080 (v2.0)'),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: colorScheme.onSurface),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Canary Version',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text('api-service-canary:8080 (v2.1)'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traffic Split: 20% to Canary',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: 20,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '20%',
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Automatic promotion at: 04/10/2025 14:00',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel),
                  label: const Text('Rollback'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Promote'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbTestCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'New Checkout Flow Test',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: const Text('Running'),
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Variant A (Control)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text('checkout-service:8080/v1'),
                      Text(
                        '60% of traffic',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.compare_arrows, color: colorScheme.onSurface),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Variant B (Test)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text('checkout-service:8080/v2'),
                      Text(
                        '40% of traffic',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Targeting Criteria:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'User-Agent contains "Mobile" OR Cookie "beta_tester"="true"',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Running since: 03/25/2025 (12 days)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.analytics),
                  label: const Text('View Results'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueGreenCard(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Environment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.blue.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Blue Environment (Active)',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('api-service-blue:8080'),
                          Text('Version: v2.0.3'),
                          Text('Deployed: 03/28/2025'),
                          const SizedBox(height: 8),
                          Text(
                            '100% of traffic',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.green.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pending, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Green Environment (Standby)',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('api-service-green:8080'),
                          Text('Version: v2.1.0'),
                          Text('Deployed: 04/05/2025'),
                          const SizedBox(height: 8),
                          Text(
                            '0% of traffic',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Switch to Green Environment'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureFlagList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<Map<String, dynamic>> featureFlags = [
      {
        'name': 'New Recommendation Engine',
        'key': 'new_rec_engine',
        'enabled': true,
        'criteria': 'User ID % 10 == 0',
      },
      {
        'name': 'Redesigned Dashboard',
        'key': 'new_dashboard_ui',
        'enabled': true,
        'criteria': 'Header "beta-features" contains "dashboard"',
      },
      {
        'name': 'AI-Powered Search',
        'key': 'ai_search',
        'enabled': false,
        'criteria': 'Query param "enable_ai" == "true"',
      },
    ];

    return Column(
      children:
          featureFlags.map((flag) {
            final bool isEnabled = flag['enabled'] as bool;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            flag['name'] as String,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Switch(value: isEnabled, onChanged: (value) {}),
                      ],
                    ),
                    Text(
                      'Key: ${flag['key']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Criteria: ${flag['criteria']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.edit, color: colorScheme.primary),
                          tooltip: 'Edit Flag',
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.delete, color: colorScheme.error),
                          tooltip: 'Delete Flag',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
