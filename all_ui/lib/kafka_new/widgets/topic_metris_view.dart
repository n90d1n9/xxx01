import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/metric_point.dart';
import '../states/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/topic_metrics.dart';

class TopicMetricsView extends ConsumerWidget {
  final String clusterId;
  final String topicName;
  final int timeRangeHours;

  const TopicMetricsView({
    super.key,
    required this.clusterId,
    required this.topicName,
    required this.timeRangeHours,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(
      topicMetricsProvider((clusterId, topicName)),
    );

    return metricsAsync.when(
      data: (metrics) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metrics for Topic: $topicName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Messages Per Second'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  titlesData: const FlTitlesData(show: true),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bytes In Per Second'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  titlesData: const FlTitlesData(show: true),
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
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.green.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bytes Out Per Second'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: true),
                                  titlesData: const FlTitlesData(show: true),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _createSpots(
                                        metrics.bytesOutPerSecond,
                                      ),
                                      isCurved: true,
                                      color: Colors.orange,
                                      barWidth: 2,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.orange.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Message Count'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatNumber(metrics.totalMessages),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Messages',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatCard(
                                        context,
                                        'Current Rate',
                                        '${metrics.currentMessagesPerSecond!.toStringAsFixed(1)}/s',
                                        Icons.speed,
                                      ),
                                      _buildStatCard(
                                        context,
                                        'Avg Size',
                                        _formatBytes(
                                          metrics.averageMessageSize,
                                        ),
                                        Icons.data_usage,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Partition Distribution'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _getMaxPartitionSize(metrics),
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              'P${value.toInt()}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Text(
                                              _formatBytes(value.toDouble()),
                                              style: const TextStyle(
                                                fontSize: 9,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withValues(
                                          alpha: 0.3,
                                        ),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  barGroups: _getPartitionBarGroups(metrics),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Topic Health'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHealthItem(
                                    context,
                                    'Partitions',
                                    '${metrics.partitionCount}',
                                    Icons.grid_view,
                                    Colors.blue,
                                  ),
                                  const Divider(),
                                  _buildHealthItem(
                                    context,
                                    'Replication Factor',
                                    '${metrics.replicationFactor}',
                                    Icons.copy_all,
                                    Colors.green,
                                  ),
                                  const Divider(),
                                  _buildHealthItem(
                                    context,
                                    'Under-replicated Partitions',
                                    metrics.underReplicatedPartitions! > 0
                                        ? '${metrics.underReplicatedPartitions}'
                                        : 'None',
                                    Icons.warning_amber,
                                    metrics.underReplicatedPartitions! > 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const Divider(),
                                  _buildHealthItem(
                                    context,
                                    'ISR Shrinking',
                                    metrics.isrShrinking ? 'Yes' : 'No',
                                    Icons.warning,
                                    metrics.isrShrinking
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const Divider(),
                                  _buildHealthItem(
                                    context,
                                    'Total Size',
                                    _formatBytes(metrics.totalSizeBytes),
                                    Icons.storage,
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildConsumerGroups(context, metrics),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Text(
              'Failed to load metrics: ${error.toString()}',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
    );
  }

  Widget _buildHealthItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildConsumerGroups(BuildContext context, TopicMetrics metrics) {
    return SizedBox(
      height: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consumer Groups',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${metrics.consumerGroups!.length} Groups',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    metrics.consumerGroups!.isNotEmpty
                        ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('Group ID')),
                              DataColumn(label: Text('Consumers')),
                              DataColumn(label: Text('Total Lag')),
                              DataColumn(label: Text('Max Lag')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Last Commit')),
                            ],
                            rows:
                                metrics.consumerGroups!.map((group) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(group.id)),
                                      DataCell(
                                        Text('${group.activeConsumers}'),
                                      ),
                                      DataCell(
                                        Text(
                                          _formatNumber(group.totalLag),
                                          style: TextStyle(
                                            color: _getLagColor(group.totalLag),
                                            fontWeight:
                                                group.totalLag > 1000
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _formatNumber(group.maxLag),
                                          style: TextStyle(
                                            color: _getLagColor(group.maxLag),
                                            fontWeight:
                                                group.maxLag > 1000
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
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
                                            color: _getStatusColor(
                                              group.status!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            group.status!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _formatTimestamp(
                                            group.lastCommitTimestamp!,
                                          ),
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        )
                        : const Center(
                          child: Text(
                            'No consumer groups found for this topic',
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _createSpots(List<MetricPoint> metrics) {
    return metrics
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();
  }

  double _getMaxPartitionSize(TopicMetrics metrics) {
    if (metrics.partitionSizes!.isEmpty) return 100;
    double maxSize = 0;
    for (var size in metrics.partitionSizes!) {
      maxSize = max(maxSize, size.toDouble());
    }
    return maxSize * 1.2; // Add 20% padding
  }

  List<BarChartGroupData> _getPartitionBarGroups(TopicMetrics metrics) {
    return List.generate(metrics.partitionSizes!.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: metrics.partitionSizes![index].toDouble(),
            color: index % 2 == 0 ? Colors.blue[400] : Colors.blue[600],
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  String _formatBytes(double bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(timestamp);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
        return Colors.green;
      case 'rebalancing':
        return Colors.orange;
      case 'dead':
        return Colors.red;
      case 'empty':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getLagColor(int lag) {
    if (lag > 10000) {
      return Colors.red;
    } else if (lag > 1000) {
      return Colors.orange;
    } else {
      return Colors.black;
    }
  }
}
