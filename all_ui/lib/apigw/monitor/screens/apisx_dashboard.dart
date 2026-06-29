import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/api_metric.dart';
import '../models/etcd.dart';
import '../models/http_conn.dart';
import '../states/api_provider.dart';
import '../states/request_provider.dart';
import '../widgets/conn_chart.dart';
import '../widgets/memory_used_chart.dart';
import '../widgets/metrics_card.dart';
import '../widgets/request_chart.dart';

class ApisixDashboard extends ConsumerWidget {
  const ApisixDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsStream = ref.watch(apiMetricsStreamProvider);

    // Use listen to handle updates without modifying during build
    metricsStream.whenData((metrics) {
      Future.microtask(() {
        ref
            .read(httpConnectionsHistoryProvider.notifier)
            .addEntry(metrics.timestamp, metrics.httpConnections);
        ref
            .read(requestsCounterProvider.notifier)
            .addEntry(metrics.timestamp, metrics.httpRequestsTotal);
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iket  Performance'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(apiMetricsStreamProvider);
            },
          ),
        ],
      ),
      body: metricsStream.when(
        data: (metrics) => _buildDashboard(context, metrics, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading metrics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.refresh(apiMetricsStreamProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    ApiMetrics metrics,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(apiMetricsStreamProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context, metrics),
            const SizedBox(height: 24),
            Text(
              'HTTP Connections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const ConnectionsChart(),
            const SizedBox(height: 16),
            _buildConnectionsGrid(context, metrics.httpConnections),
            const SizedBox(height: 24),
            Text(
              'HTTP Requests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const RequestsChart(),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Total Requests',
              value: metrics.httpRequestsTotal.toString(),
              icon: Icons.http,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text('Memory Usage', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            MemoryUsageChart(metrics: metrics.sharedDictMetrics),
            const SizedBox(height: 24),
            Text('ETCD Metrics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildEtcdMetricsGrid(context, metrics.etcdMetrics),
            const SizedBox(height: 24),
            Text(
              'Error Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            MetricCard(
              title: 'Nginx Errors',
              value: metrics.errorMetrics.nginxErrors.toString(),
              icon: Icons.error_outline,
              color:
                  metrics.errorMetrics.nginxErrors > 0
                      ? Colors.red
                      : Colors.green,
            ),
            const SizedBox(height: 24),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Last updated: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(metrics.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, ApiMetrics metrics) {
    bool isHealthy =
        metrics.errorMetrics.nginxErrors == 0 &&
        metrics.httpConnections.active < metrics.httpConnections.handled * 0.9;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isHealthy
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isHealthy
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isHealthy ? Colors.green : Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy ? 'Iket  Healthy' : 'Iket  Warning',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHealthy ? Colors.green : Colors.amber,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hostname: ${metrics.nodeInfo.hostname}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsGrid(
    BuildContext context,
    HttpConnections connections,
  ) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      children: [
        MetricCard(
          title: 'Active',
          value: connections.active.toString(),
          icon: Icons.timeline,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Accepted',
          value: connections.accepted.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        MetricCard(
          title: 'Handled',
          value: connections.handled.toString(),
          icon: Icons.handshake,
          color: Colors.indigo,
        ),
        MetricCard(
          title: 'Reading',
          value: connections.reading.toString(),
          icon: Icons.download,
          color: Colors.teal,
        ),
        MetricCard(
          title: 'Writing',
          value: connections.writing.toString(),
          icon: Icons.upload,
          color: Colors.deepPurple,
        ),
        MetricCard(
          title: 'Waiting',
          value: connections.waiting.toString(),
          icon: Icons.hourglass_empty,
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildEtcdMetricsGrid(BuildContext context, List<EtcdMetric> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return MetricCard(
          title: metric.key,
          value: metric.value.toString(),
          icon: Icons.storage,
          color: Colors.blueGrey,
        );
      },
    );
  }
}
