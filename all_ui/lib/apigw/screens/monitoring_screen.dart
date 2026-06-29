import 'package:flutter/material.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
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
                'Observability & Monitoring',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure metrics, tracing, logging, and debugging tools',
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
            Tab(text: 'Metrics'),
            Tab(text: 'Tracing'),
            Tab(text: 'Logging'),
            Tab(text: 'Debugging'),
          ],
          dividerColor: Colors.transparent,
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMetricsTab(context),
              _buildTracingTab(context),
              _buildLoggingTab(context),
              _buildDebuggingTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Real-time Metrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure metrics collection and visualization using Prometheus and Grafana',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prometheus Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Prometheus Endpoint',
                    hint: 'http://prometheus:9090',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Metrics Endpoint Path',
                    hint: '/metrics',
                    icon: Icons.route,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Scrape Interval (seconds)',
                    hint: '15',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metrics Collection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Request Rate',
                    subtitle: 'Track total requests per second',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Response Status Codes',
                    subtitle: 'Track response status code distribution',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Response Latency',
                    subtitle: 'Track response time percentiles',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Request Size',
                    subtitle: 'Track request payload size',
                    value: false,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Response Size',
                    subtitle: 'Track response payload size',
                    value: false,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Circuit Breaker States',
                    subtitle: 'Track circuit breaker status',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grafana Integration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Grafana URL',
                    hint: 'http://grafana:3000',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Auto-provision Dashboards',
                    subtitle: 'Automatically create default dashboards',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Configure Alerts',
                    subtitle: 'Setup default alerting rules',
                    value: true,
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Grafana Dashboard'),
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

  Widget _buildTracingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Distributed Tracing',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure distributed tracing with Jaeger, Zipkin, or SkyWalking',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracing Provider',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Provider',
                    items: ['Jaeger', 'Zipkin', 'SkyWalking', 'OpenTelemetry'],
                    value: 'Jaeger',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Collector Endpoint',
                    hint: 'http://jaeger:14268/api/traces',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Service Name',
                    hint: 'api-gateway',
                    icon: Icons.badge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sampling Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Sampling Type',
                    items: ['Probabilistic', 'Rate Limiting', 'Adaptive'],
                    value: 'Probabilistic',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Sampling Rate',
                    hint: '0.25',
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trace Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Propagate Headers',
                    subtitle: 'Forward trace headers to backend services',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Client IP in Spans',
                    subtitle: 'Include client IP information in spans',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Error Detection',
                    subtitle: 'Mark spans with error for non-2xx responses',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Baggage Propagation',
                    subtitle:
                        'Enable context propagation for additional information',
                    value: false,
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Tracing Dashboard'),
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

  Widget _buildLoggingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Logging Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure logging with ELK, Fluentd, or Kafka',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Destination',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Output Type',
                    items: [
                      'Elasticsearch',
                      'Fluentd',
                      'Kafka',
                      'Loki',
                      'File',
                    ],
                    value: 'Elasticsearch',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Endpoint URL',
                    hint: 'http://elasticsearch:9200',
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Index Pattern',
                    hint: 'api-gateway-%Y.%m.%d',
                    icon: Icons.format_shapes,
                  ),

                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Authentication',
                    hint: 'Basic, API Key, or none',
                    icon: Icons.security,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Format & Fields',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Format',
                    items: ['JSON', 'Text', 'GELF'],
                    value: 'JSON',
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Log Level',
                    items: ['DEBUG', 'INFO', 'WARN', 'ERROR'],
                    value: 'INFO',
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Include Fields:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(context, 'timestamp', true),
                      _buildChip(context, 'client_ip', true),
                      _buildChip(context, 'method', true),
                      _buildChip(context, 'uri', true),
                      _buildChip(context, 'status', true),
                      _buildChip(context, 'response_time', true),
                      _buildChip(context, 'user_agent', false),
                      _buildChip(context, 'request_id', true),
                      _buildChip(context, 'trace_id', true),
                      _buildChip(context, 'request_size', false),
                      _buildChip(context, 'response_size', false),
                      _buildChip(context, 'referer', false),
                      _buildChip(context, 'headers', false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Rotation & Retention',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Rotation Size (MB)',
                    hint: '100',
                    icon: Icons.sd_storage,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Retention Period (days)',
                    hint: '30',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Compression',
                    subtitle: 'Compress rotated logs',
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

  Widget _buildDebuggingTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Dynamic Debugging',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Switch(value: true, onChanged: (value) {}),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Configure request/response capture and debugging tools',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request/Response Capture',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Enable Capture',
                    subtitle: 'Record request/response pairs for debugging',
                    value: true,
                  ),

                  _buildFormField(
                    context,
                    label: 'Capture Rate (%)',
                    hint: '1',
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Max Capture Size (KB)',
                    hint: '256',
                    icon: Icons.sd_storage,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Retention Period (hours)',
                    hint: '24',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter & Conditions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Capture Mode',
                    items: ['All Traffic', 'Errors Only', 'Custom Filter'],
                    value: 'Errors Only',
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    context,
                    label: 'Path Filter Regex',
                    hint: '/(api|v1)/',
                    icon: Icons.filter_alt,
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    context,
                    label: 'Status Codes',
                    items: [
                      'All',
                      '4xx Only',
                      '5xx Only',
                      '4xx and 5xx',
                      'Custom',
                    ],
                    value: '4xx and 5xx',
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'Include Headers',
                    subtitle: 'Capture request and response headers',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Include Bodies',
                    subtitle: 'Capture request and response bodies',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Mask Sensitive Data',
                    subtitle: 'Automatically mask sensitive information',
                    value: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Debug Tools',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSwitchTile(
                    context,
                    title: 'API Inspector',
                    subtitle: 'Live inspection of API requests and responses',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Health Dashboard',
                    subtitle: 'Monitor API health in real-time',
                    value: true,
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Remote Debugging',
                    subtitle: 'Enable remote debugging capabilities',
                    value: false,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open Debug Console'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history),
                        label: const Text('View Capture History'),
                      ),
                    ],
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

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required List<String> items,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: (String? newValue) {},
        ),
      ],
    );
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

  Widget _buildChip(BuildContext context, String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) {},
    );
  }
}
