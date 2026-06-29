import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/providers.dart';

class BrokersScreen extends ConsumerWidget {
  const BrokersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);

    if (selectedClusterId == null) {
      return const Center(child: Text('Select a cluster to view brokers'));
    }

    final brokersAsync = ref.watch(brokersProvider(selectedClusterId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kafka Brokers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: brokersAsync.when(
              data: (brokers) {
                if (brokers.isEmpty) {
                  return const Center(
                    child: Text('No brokers found in this cluster'),
                  );
                }

                return ListView.builder(
                  itemCount: brokers.length,
                  itemBuilder: (context, index) {
                    final broker = brokers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Broker ID: ${broker.id}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(width: 8),
                                if (broker.isController)
                                  const Chip(
                                    label: Text('Controller'),
                                    backgroundColor: Colors.blue,
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                            const Divider(),
                            _buildBrokerDetailRow('Host', broker.host),
                            _buildBrokerDetailRow('Port', '${broker.port}'),
                            const SizedBox(height: 16),
                            Text(
                              'Metrics',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if (broker.metrics.isNotEmpty)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 3,
                                    ),
                                itemCount: broker.metrics.length,
                                itemBuilder: (context, i) {
                                  final key = broker.metrics.keys.elementAt(i);
                                  final value = broker.metrics[key];
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            key,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$value',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              const Text('No metrics available'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Center(
                    child: Text('Error loading brokers: ${error.toString()}'),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
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
}
