import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/providers.dart';

class ClusterDetailsView extends ConsumerWidget {
  final String clusterId;

  const ClusterDetailsView({super.key, required this.clusterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider(clusterId));
    final brokersAsync = ref.watch(brokersProvider(clusterId));
    final selectedCluster = ref
        .watch(clustersProvider)
        .maybeWhen(
          data: (clusters) => clusters.firstWhere((c) => c.id == clusterId),
          orElse: () => null,
        );

    if (selectedCluster == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cluster summary cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Cluster Status',
                selectedCluster.status,
                selectedCluster.status == 'ONLINE' ? Colors.green : Colors.red,
                Icons.cloud_circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Brokers',
                '${selectedCluster.brokerCount}',
                Colors.blue,
                Icons.computer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Topics',
                '${selectedCluster.topicCount}',
                Colors.orange,
                Icons.topic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topics overview
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.topic),
                            const SizedBox(width: 8),
                            Text(
                              'Topics Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: topicsAsync.when(
                            data: (topics) {
                              if (topics.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No topics found in this cluster',
                                  ),
                                );
                              }

                              // Sort topics by message count
                              final sortedTopics = List.from(topics)..sort(
                                (a, b) =>
                                    b.messageCount.compareTo(a.messageCount),
                              );

                              return ListView.builder(
                                itemCount:
                                    sortedTopics.length > 5
                                        ? 5
                                        : sortedTopics.length,
                                itemBuilder: (context, index) {
                                  final topic = sortedTopics[index];
                                  return ListTile(
                                    title: Text(topic.name),
                                    subtitle: Text(
                                      'Partitions: ${topic.partitions}, Replication: ${topic.replicationFactor}',
                                    ),
                                    trailing: Text(
                                      '${topic.messageCount} msgs',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, _) => Center(
                                  child: Text('Error: ${error.toString()}'),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Brokers overview
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.computer),
                            const SizedBox(width: 8),
                            Text(
                              'Brokers Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: brokersAsync.when(
                            data: (brokers) {
                              if (brokers.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No brokers found in this cluster',
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: brokers.length,
                                itemBuilder: (context, index) {
                                  final broker = brokers[index];
                                  return ListTile(
                                    title: Text('Broker ID: ${broker.id}'),
                                    subtitle: Text(
                                      '${broker.host}:${broker.port}',
                                    ),
                                    trailing:
                                        broker.isController
                                            ? const Chip(
                                              label: Text('Controller'),
                                              backgroundColor: Colors.blue,
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                            : null,
                                  );
                                },
                              );
                            },
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, _) => Center(
                                  child: Text('Error: ${error.toString()}'),
                                ),
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
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
