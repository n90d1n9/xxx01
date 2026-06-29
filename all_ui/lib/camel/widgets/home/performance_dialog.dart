import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/performance_metric_provider.dart';
import '../../states/select_route_provider.dart';

class PerformanceDialog extends ConsumerWidget {
  const PerformanceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Performance Metrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final metrics = ref.watch(performanceMetricsProvider);
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overview metrics
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Total Nodes',
                              metrics.totalNodes.toString(),
                              Icons.account_tree,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              'Connections',
                              metrics.totalConnections.toString(),
                              Icons.cable,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Avg Processing',
                              '${metrics.averageProcessingTime.inMilliseconds}ms',
                              Icons.timer,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              'Throughput',
                              '${metrics.throughput.toStringAsFixed(1)}/s',
                              Icons.speed,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Alerts
                      if (metrics.alerts.isNotEmpty) ...[
                        const Text(
                          'Alerts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...metrics.alerts.map(
                          (alert) => Card(
                            color:
                                alert.severity == 'critical'
                                    ? Colors.red.shade50
                                    : alert.severity == 'warning'
                                    ? Colors.orange.shade50
                                    : Colors.blue.shade50,
                            child: ListTile(
                              leading: Icon(
                                alert.severity == 'critical'
                                    ? Icons.error
                                    : alert.severity == 'warning'
                                    ? Icons.warning
                                    : Icons.info,
                                color:
                                    alert.severity == 'critical'
                                        ? Colors.red
                                        : alert.severity == 'warning'
                                        ? Colors.orange
                                        : Colors.blue,
                              ),
                              title: Text(alert.message),
                              subtitle: Text(
                                alert.timestamp.toString().substring(0, 19),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Node execution counts
                      const Text(
                        'Node Execution Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...metrics.nodeExecutionCounts.entries.map((entry) {
                        final route = ref.watch(selectedRouteProvider);
                        final node = route?.nodes.firstWhere(
                          (n) => n.id == entry.key,
                        );
                        final processingTime =
                            metrics.nodeProcessingTimes[entry.key];

                        return Card(
                          child: ListTile(
                            leading:
                                node != null
                                    ? Icon(node.icon, color: node.color)
                                    : const Icon(Icons.circle),
                            title: Text(node?.name ?? 'Unknown'),
                            subtitle: Text(
                              'Processing time: ${processingTime?.inMilliseconds ?? 0}ms',
                            ),
                            trailing: Text(
                              '${entry.value} executions',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
