import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kafka_topic.dart';
import '../models/metric_point.dart';
import '../states/providers.dart';
import '../widgets/topic_config_dialog.dart';

class TopicDetailsScreen extends ConsumerWidget {
  final String clusterId;
  final KafkaTopic topic;

  const TopicDetailsScreen({
    super.key,
    required this.clusterId,
    required this.topic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(
      topicMetricsProvider((clusterId, topic.name)),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Topic: ${topic.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildDetailRow('Name', topic.name),
                    _buildDetailRow('Partitions', '${topic.partitions}'),
                    _buildDetailRow(
                      'Replication Factor',
                      '${topic.replicationFactor}',
                    ),
                    _buildDetailRow('Message Count', '${topic.messageCount}'),
                    _buildDetailRow(
                      'Throughput',
                      '${topic.throughput.toStringAsFixed(2)} msgs/sec',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Metrics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: metricsAsync.when(
                data: (metrics) {
                  return Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Messages Per Second'),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: true),
                                      titlesData: const FlTitlesData(
                                        show: true,
                                      ),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _createSpots(
                                            metrics.messagesPerSecond,
                                          ),
                                          isCurved: true,
                                          color: Colors.blue,
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bytes In/Out Per Second'),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: true),
                                      titlesData: const FlTitlesData(
                                        show: true,
                                      ),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _createSpots(
                                            metrics.bytesInPerSecond,
                                          ),
                                          isCurved: true,
                                          color: Colors.green,
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: true),
                                        ),
                                        LineChartBarData(
                                          spots: _createSpots(
                                            metrics.bytesOutPerSecond,
                                          ),
                                          isCurved: true,
                                          color: Colors.orange,
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: true),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, _) => Center(
                      child: Text('Error loading metrics: ${error.toString()}'),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Topic Configuration'),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Configuration'),
                            onPressed: () {
                              _showTopicConfigDialog(
                                context,
                                ref,
                                clusterId,
                                topic,
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: topic.configs.length,
                          itemBuilder: (context, index) {
                            final key = topic.configs.keys.elementAt(index);
                            final value = topic.configs[key];
                            return ListTile(
                              title: Text(key),
                              subtitle: Text('$value'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createSpots(List<MetricPoint> points) {
    return points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showTopicConfigDialog(
    BuildContext context,
    WidgetRef ref,
    String clusterId,
    KafkaTopic topic,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => TopicConfigDialog(clusterId: clusterId, topic: topic),
    );
  }
}
