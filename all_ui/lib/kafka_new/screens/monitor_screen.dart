import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/providers.dart';
import '../widgets/topic_metris_view.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({super.key});

  @override
  _MonitoringScreenState createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  String? _selectedTopicName;
  int _timeRangeHours = 24;

  @override
  Widget build(BuildContext context) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);

    if (selectedClusterId == null) {
      return const Center(
        child: Text('Select a cluster to view monitoring data'),
      );
    }

    final topicsAsync = ref.watch(topicsProvider(selectedClusterId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kafka Monitoring',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DropdownButton<int>(
                value: _timeRangeHours,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Last 1 hour')),
                  DropdownMenuItem(value: 6, child: Text('Last 6 hours')),
                  DropdownMenuItem(value: 24, child: Text('Last 24 hours')),
                  DropdownMenuItem(value: 72, child: Text('Last 3 days')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _timeRangeHours = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 24),
              Expanded(
                child: topicsAsync.when(
                  data: (topics) {
                    return DropdownButton<String>(
                      hint: const Text('Select a topic'),
                      isExpanded: true,
                      value: _selectedTopicName,
                      items:
                          topics.map((topic) {
                            return DropdownMenuItem<String>(
                              value: topic.name,
                              child: Text(topic.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTopicName = value;
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading topics'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_selectedTopicName != null) ...[
            Expanded(
              child: TopicMetricsView(
                clusterId: selectedClusterId,
                topicName: _selectedTopicName!,
                timeRangeHours: _timeRangeHours,
              ),
            ),
          ] else ...[
            Expanded(
              child: const Center(
                child: Text('Select a topic to view its metrics'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
