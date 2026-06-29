import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kafka_topic.dart';
import '../states/providers.dart';
import '../widgets/topic_config_dialog.dart';
import 'topic_detail_screen.dart';

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);

    if (selectedClusterId == null) {
      return const Center(child: Text('Select a cluster to view topics'));
    }

    final topicsAsync = ref.watch(topicsProvider(selectedClusterId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kafka Topics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: topicsAsync.when(
              data: (topics) {
                if (topics.isEmpty) {
                  return const Center(
                    child: Text('No topics found in this cluster'),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      columns: const [
                        DataColumn2(
                          label: Text('Topic Name'),
                          size: ColumnSize.L,
                        ),
                        DataColumn(label: Text('Partitions'), numeric: true),
                        DataColumn(label: Text('Replication'), numeric: true),
                        DataColumn(label: Text('Messages'), numeric: true),
                        DataColumn(
                          label: Text('Throughput (msg/s)'),
                          numeric: true,
                        ),
                        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                      ],
                      rows:
                          topics.map((topic) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    topic.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    _showTopicDetails(
                                      context,
                                      ref,
                                      selectedClusterId,
                                      topic,
                                    );
                                  },
                                ),
                                DataCell(Text('${topic.partitions}')),
                                DataCell(Text('${topic.replicationFactor}')),
                                DataCell(Text('${topic.messageCount}')),
                                DataCell(
                                  Text(topic.throughput.toStringAsFixed(2)),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.settings,
                                          size: 20,
                                        ),
                                        tooltip: 'Configure',
                                        onPressed: () {
                                          _showTopicConfigDialog(
                                            context,
                                            ref,
                                            selectedClusterId,
                                            topic,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Delete',
                                        onPressed: () {
                                          _showDeleteTopicDialog(
                                            context,
                                            ref,
                                            selectedClusterId,
                                            topic.name,
                                          );
                                        },
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
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Center(
                    child: Text('Error loading topics: ${error.toString()}'),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopicDetails(
    BuildContext context,
    WidgetRef ref,
    String clusterId,
    KafkaTopic topic,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TopicDetailsScreen(clusterId: clusterId, topic: topic),
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

  void _showDeleteTopicDialog(
    BuildContext context,
    WidgetRef ref,
    String clusterId,
    String topicName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Topic: $topicName'),
            content: Text(
              'Are you sure you want to delete this topic? This action cannot be undone and all data will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    await ref
                        .read(kafkaApiServiceProvider)
                        .deleteTopic(clusterId, topicName);

                    if (context.mounted) {
                      Navigator.of(context).pop();

                      // Refresh topics list
                      ref.refresh(topicsProvider(clusterId));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Topic "$topicName" deleted successfully',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
