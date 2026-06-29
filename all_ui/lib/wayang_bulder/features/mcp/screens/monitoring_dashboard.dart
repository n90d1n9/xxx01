import 'package:flutter/material.dart';

class MonitoringDashboard extends StatelessWidget {
  const MonitoringDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Monitoring',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildPerformanceMetricsCard(context)),
              const SizedBox(width: 24),
              Expanded(child: _buildResourceUtilizationCard(context)),
            ],
          ),
          const SizedBox(height: 24),
          _buildRequestAnalyticsCard(context),
          const SizedBox(height: 24),
          _buildErrorAnalyticsCard(context),
          const SizedBox(height: 24),
          _buildLatencyDistributionCard(context),
          const SizedBox(height: 24),
          _buildTopErrorsCard(context),
        ],
      ),
    );
  }

  // ==================== PERFORMANCE METRICS CARD ====================
  Widget _buildPerformanceMetricsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Avg Response Time', '45ms', '↓ 12%', Colors.green),
            _buildMetricRow(
              'P95 Response Time',
              '234ms',
              '↑ 5%',
              Colors.orange,
            ),
            _buildMetricRow('P99 Response Time', '567ms', '→ 0%', Colors.grey),
            _buildMetricRow('Throughput', '2.3K req/s', '↑ 8%', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    String trend,
    Color trendColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  color: trendColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== RESOURCE UTILIZATION CARD ====================
  Widget _buildResourceUtilizationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.memory,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resource Utilization',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressMetric('CPU Usage', 45.2, 80, context),
            const SizedBox(height: 14),
            _buildProgressMetric('Memory Usage', 64.5, 90, context),
            const SizedBox(height: 14),
            _buildProgressMetric('Disk Usage', 32.1, 100, context),
            const SizedBox(height: 14),
            _buildProgressMetric('Network I/O', 58.3, 100, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(
    String label,
    double current,
    double max,
    BuildContext context,
  ) {
    final percentage = (current / max) * 100;
    final color = percentage < 50
        ? Colors.green
        : percentage < 80
        ? Colors.orange
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / max,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  // ==================== REQUEST ANALYTICS CARD ====================
  Widget _buildRequestAnalyticsCard(BuildContext context) {
    final requestData = [
      ('00:00', 1200),
      ('04:00', 1500),
      ('08:00', 2300),
      ('12:00', 3200),
      ('16:00', 2800),
      ('20:00', 2200),
      ('24:00', 1800),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Request Analytics (24h)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: requestData.map((data) {
                          final (time, count) = data;
                          final maxCount = 3500.0;
                          final height = (count / maxCount) * 150;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Tooltip(
                                message: '$count requests',
                                child: Container(
                                  width: 24,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(time, style: const TextStyle(fontSize: 11)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRequestStat('Total Requests', '45.2K', Colors.blue),
                _buildRequestStat('Avg per Hour', '1.8K', Colors.purple),
                _buildRequestStat('Peak Hour', '3.2K', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // ==================== ERROR ANALYTICS CARD ====================
  Widget _buildErrorAnalyticsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Error Analytics (24h)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildErrorRow('500 Server Error', 12, Colors.red, 3.2),
            _buildErrorRow('401 Unauthorized', 45, Colors.orange, 12.1),
            _buildErrorRow('404 Not Found', 23, Colors.yellow, 6.2),
            _buildErrorRow('429 Rate Limited', 8, Colors.blue, 2.1),
            _buildErrorRow('503 Service Unavailable', 5, Colors.purple, 1.3),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRow(
    String label,
    int count,
    Color color,
    double percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
              Text(
                count.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LATENCY DISTRIBUTION CARD ====================
  Widget _buildLatencyDistributionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Latency Distribution',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLatencyBucket('0-50ms', 4250, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLatencyBucket(
                    '50-100ms',
                    1820,
                    Colors.lightGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLatencyBucket('100-200ms', 892, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildLatencyBucket('200ms+', 240, Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatencyBucket(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ==================== TOP ERRORS CARD ====================
  Widget _buildTopErrorsCard(BuildContext context) {
    final topErrors = [
      ('Database Connection Timeout', 'query_builder', 34, 'High', Colors.red),
      ('Memory Limit Exceeded', 'json_transformer', 28, 'High', Colors.red),
      ('Auth Token Expired', 'api_gateway', 19, 'Medium', Colors.orange),
      ('Rate Limit Exceeded', 'auth_service', 12, 'Low', Colors.yellow),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Errors This Hour',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Error')),
                  DataColumn(label: Text('Tool')),
                  DataColumn(label: Text('Count')),
                  DataColumn(label: Text('Severity')),
                ],
                rows: topErrors.map((error) {
                  final (errorMsg, tool, count, severity, color) = error;
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: color),
                            const SizedBox(width: 8),
                            Text(
                              errorMsg,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(tool, style: const TextStyle(fontSize: 12)),
                      ),
                      DataCell(
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            severity,
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final tabs = [
  ('dashboard', 'Dashboard', Icons.dashboard),
  ('monitoring', 'Monitoring', Icons.monitor_heart),
  ('security', 'Security & Audit', Icons.security),
  ('prompts', 'Prompt Templates', Icons.chat_bubble_outline),
  ('docker', 'Docker & Deploy', Icons.directions_boat),
  ('testing', 'Testing', Icons.bug_report),
  ('pipelines', 'CI/CD Pipelines', Icons.build),
  ('oauth', 'OAuth2 & Auth', Icons.vpn_key),
  ('api-docs', 'API Docs', Icons.description),
  ('resources', 'Resources', Icons.folder),
];
