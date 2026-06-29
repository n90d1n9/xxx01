import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kafka_cluster.dart';
import '../states/providers.dart';
import '../widgets/cluster_detail_view.dart';

class OverviewScreen extends ConsumerWidget {
  final List<KafkaCluster> clusters;

  const OverviewScreen({super.key, required this.clusters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Kafka Clusters Overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              DropdownButton<String>(
                value: selectedClusterId,
                hint: const Text('Select Cluster'),
                onChanged: (String? newValue) {
                  ref.read(selectedClusterIdProvider.notifier).state = newValue;
                },
                items:
                    clusters.map<DropdownMenuItem<String>>((
                      KafkaCluster cluster,
                    ) {
                      return DropdownMenuItem<String>(
                        value: cluster.id,
                        child: Text(cluster.name),
                      );
                    }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (selectedClusterId != null) ...[
            Expanded(child: ClusterDetailsView(clusterId: selectedClusterId)),
          ] else ...[
            Expanded(
              child: Center(
                child: Text(
                  'Select a cluster to view details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
