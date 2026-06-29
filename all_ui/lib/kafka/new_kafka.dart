// Main application entry point
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const ProviderScope(child: KafkaManagerApp()));
}

class KafkaManagerApp extends StatelessWidget {
  const KafkaManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kafka Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

// Models
class KafkaCluster {
  final String id;
  final String name;
  final String bootstrapServers;
  final bool isConnected;
  final int topicCount;
  final int brokerCount;

  KafkaCluster({
    required this.id,
    required this.name,
    required this.bootstrapServers,
    required this.isConnected,
    required this.topicCount,
    required this.brokerCount,
  });

  factory KafkaCluster.fromJson(Map<String, dynamic> json) {
    return KafkaCluster(
      id: json['id'],
      name: json['name'],
      bootstrapServers: json['bootstrapServers'],
      isConnected: json['isConnected'],
      topicCount: json['topicCount'],
      brokerCount: json['brokerCount'],
    );
  }
}

class KafkaTopic {
  final String name;
  final int partitionCount;
  final int replicationFactor;
  final Map<String, dynamic> configs;

  KafkaTopic({
    required this.name,
    required this.partitionCount,
    required this.replicationFactor,
    required this.configs,
  });

  factory KafkaTopic.fromJson(Map<String, dynamic> json) {
    return KafkaTopic(
      name: json['name'],
      partitionCount: json['partitionCount'],
      replicationFactor: json['replicationFactor'],
      configs: json['configs'],
    );
  }
}

class KafkaBroker {
  final int id;
  final String host;
  final int port;
  final bool isController;
  final Map<String, dynamic> metrics;

  KafkaBroker({
    required this.id,
    required this.host,
    required this.port,
    required this.isController,
    required this.metrics,
  });

  factory KafkaBroker.fromJson(Map<String, dynamic> json) {
    return KafkaBroker(
      id: json['id'],
      host: json['host'],
      port: json['port'],
      isController: json['isController'],
      metrics: json['metrics'],
    );
  }
}

// Services
class KafkaService {
  final String baseUrl;
  final http.Client _client = http.Client();

  KafkaService({required this.baseUrl});

  Future<List<KafkaCluster>> getClusters() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/clusters'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => KafkaCluster.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load clusters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Kafka service: $e');
    }
  }

  Future<List<KafkaTopic>> getTopics(String clusterId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/clusters/$clusterId/topics'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => KafkaTopic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  Future<List<KafkaBroker>> getBrokers(String clusterId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/clusters/$clusterId/brokers'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => KafkaBroker.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load brokers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load brokers: $e');
    }
  }

  Future<void> createTopic(
    String clusterId,
    String name,
    int partitions,
    int replicationFactor,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/clusters/$clusterId/topics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'partitionCount': partitions,
          'replicationFactor': replicationFactor,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create topic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create topic: $e');
    }
  }

  Future<void> deleteTopic(String clusterId, String topicName) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/clusters/$clusterId/topics/$topicName'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete topic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete topic: $e');
    }
  }

  Future<Map<String, dynamic>> getClusterMetrics(String clusterId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/clusters/$clusterId/metrics'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load metrics: $e');
    }
  }
}

// Providers
final kafkaServiceProvider = Provider<KafkaService>((ref) {
  return KafkaService(baseUrl: 'https://api.kafkamanager.example.com/v1');
});

final clustersProvider = FutureProvider<List<KafkaCluster>>((ref) async {
  final kafkaService = ref.watch(kafkaServiceProvider);
  return await kafkaService.getClusters();
});

final selectedClusterIdProvider = StateProvider<String?>((ref) => null);

final topicsProvider = FutureProvider.family<List<KafkaTopic>, String>((
  ref,
  clusterId,
) async {
  final kafkaService = ref.watch(kafkaServiceProvider);
  return await kafkaService.getTopics(clusterId);
});

final brokersProvider = FutureProvider.family<List<KafkaBroker>, String>((
  ref,
  clusterId,
) async {
  final kafkaService = ref.watch(kafkaServiceProvider);
  return await kafkaService.getBrokers(clusterId);
});

final metricsProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  clusterId,
) async {
  final kafkaService = ref.watch(kafkaServiceProvider);
  return await kafkaService.getClusterMetrics(clusterId);
});

final metricsStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((
      ref,
      clusterId,
    ) async* {
      final kafkaService = ref.watch(kafkaServiceProvider);

      while (true) {
        yield await kafkaService.getClusterMetrics(clusterId);
        await Future.delayed(const Duration(seconds: 5));
      }
    });

// UI Components
class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kafka Manager'), elevation: 2),
      drawer: const AppDrawer(),
      body:
          selectedClusterId == null
              ? const ClusterListScreen()
              : ClusterDetailScreen(clusterId: selectedClusterId),
    );
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);
    final clusters = ref.watch(clustersProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kafka Manager',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Monitor and manage your Kafka clusters',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: selectedClusterId == null,
            onTap: () {
              ref.read(selectedClusterIdProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'CLUSTERS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          clusters.when(
            data:
                (clusters) => Column(
                  children:
                      clusters
                          .map(
                            (cluster) => ListTile(
                              leading: Icon(
                                Icons.cloud,
                                color:
                                    cluster.isConnected
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              title: Text(cluster.name),
                              subtitle: Text(cluster.bootstrapServers),
                              selected: selectedClusterId == cluster.id,
                              onTap: () {
                                ref
                                    .read(selectedClusterIdProvider.notifier)
                                    .state = cluster.id;
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class ClusterListScreen extends ConsumerWidget {
  const ClusterListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clusters = ref.watch(clustersProvider);

    return clusters.when(
      data:
          (clusters) =>
              clusters.isEmpty
                  ? const Center(child: Text('No Kafka clusters found'))
                  : ListView.builder(
                    itemCount: clusters.length,
                    itemBuilder: (context, index) {
                      final cluster = clusters[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            cluster.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(cluster.bootstrapServers),
                          leading: CircleAvatar(
                            backgroundColor:
                                cluster.isConnected ? Colors.green : Colors.red,
                            child: const Icon(Icons.cloud, color: Colors.white),
                          ),
                          trailing: Text(
                            '${cluster.topicCount} topics',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            ref.read(selectedClusterIdProvider.notifier).state =
                                cluster.id;
                          },
                        ),
                      );
                    },
                  ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load clusters',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(clustersProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }
}

class ClusterDetailScreen extends ConsumerWidget {
  final String clusterId;

  const ClusterDetailScreen({Key? key, required this.clusterId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cluster Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Topics'),
              Tab(text: 'Brokers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewTab(clusterId: clusterId),
            TopicsTab(clusterId: clusterId),
            BrokersTab(clusterId: clusterId),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => CreateTopicDialog(clusterId: clusterId),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class OverviewTab extends ConsumerWidget {
  final String clusterId;

  const OverviewTab({Key? key, required this.clusterId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsStream = ref.watch(metricsStreamProvider(clusterId));
    final topics = ref.watch(topicsProvider(clusterId));
    final brokers = ref.watch(brokersProvider(clusterId));

    return SingleChildScrollView(
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
                    'Cluster Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  metricsStream.when(
                    data:
                        (metrics) => Column(
                          children: [
                            StatusMetricRow(
                              label: 'Messages In/sec',
                              value:
                                  '${(metrics['messagesInPerSec'] ?? 0).toStringAsFixed(2)}',
                            ),
                            StatusMetricRow(
                              label: 'Bytes In/sec',
                              value:
                                  '${_formatBytes(metrics['bytesInPerSec'] ?? 0)}/s',
                            ),
                            StatusMetricRow(
                              label: 'Bytes Out/sec',
                              value:
                                  '${_formatBytes(metrics['bytesOutPerSec'] ?? 0)}/s',
                            ),
                          ],
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Topics',
                  topics.when(
                    data: (data) => data.length.toString(),
                    loading: () => '...',
                    error: (_, __) => 'Error',
                  ),
                  Icons.topic,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Brokers',
                  brokers.when(
                    data: (data) => data.length.toString(),
                    loading: () => '...',
                    error: (_, __) => 'Error',
                  ),
                  Icons.storage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumer Groups',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text('Not implemented yet'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  String _formatBytes(dynamic bytes) {
    if (bytes is! num) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double b = bytes.toDouble();
    while (b >= 1024 && i < suffixes.length - 1) {
      b /= 1024;
      i++;
    }
    return '${b.toStringAsFixed(2)} ${suffixes[i]}';
  }
}

class StatusMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const StatusMetricRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class TopicsTab extends ConsumerWidget {
  final String clusterId;

  const TopicsTab({Key? key, required this.clusterId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider(clusterId));

    return topics.when(
      data:
          (topics) =>
              topics.isEmpty
                  ? const Center(child: Text('No topics found'))
                  : ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ExpansionTile(
                          title: Text(topic.name),
                          subtitle: Text(
                            'Partitions: ${topic.partitionCount}, Replication: ${topic.replicationFactor}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Configuration',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...topic.configs.entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${entry.key}:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              entry.value.toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Show topic details
                                        },
                                        child: const Text('View Details'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Delete Topic',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete the topic "${topic.name}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        final kafkaService = ref
                                                            .read(
                                                              kafkaServiceProvider,
                                                            );
                                                        kafkaService
                                                            .deleteTopic(
                                                              clusterId,
                                                              topic.name,
                                                            )
                                                            .then((_) {
                                                              ref.refresh(
                                                                topicsProvider(
                                                                  clusterId,
                                                                ),
                                                              );
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            })
                                                            .catchError((
                                                              error,
                                                            ) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Error: $error',
                                                                  ),
                                                                ),
                                                              );
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            });
                                                      },
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load topics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(topicsProvider(clusterId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }
}

class BrokersTab extends ConsumerWidget {
  final String clusterId;

  const BrokersTab({Key? key, required this.clusterId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokers = ref.watch(brokersProvider(clusterId));

    return brokers.when(
      data:
          (brokers) =>
              brokers.isEmpty
                  ? const Center(child: Text('No brokers found'))
                  : ListView.builder(
                    itemCount: brokers.length,
                    itemBuilder: (context, index) {
                      final broker = brokers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ExpansionTile(
                          title: Text('Broker ${broker.id}'),
                          subtitle: Text('${broker.host}:${broker.port}'),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(broker.id.toString()),
                          ),
                          trailing:
                              broker.isController
                                  ? Chip(
                                    label: const Text('Controller'),
                                    backgroundColor: Colors.green.withValues(
                                      alpha: 0.2,
                                    ),
                                  )
                                  : null,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Metrics',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...broker.metrics.entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${entry.key}:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              entry.value.toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // Show broker details
                                      },
                                      child: const Text('View Details'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load brokers',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(brokersProvider(clusterId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }
}

class CreateTopicDialog extends ConsumerStatefulWidget {
  final String clusterId;

  const CreateTopicDialog({Key? key, required this.clusterId})
    : super(key: key);

  @override
  ConsumerState<CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends ConsumerState<CreateTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _partitions = 1;
  int _replicationFactor = 1;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Topic'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Topic Name',
                hintText: 'Enter topic name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a topic name';
                }
                if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
                  return 'Topic name can only contain letters, numbers, dots, underscores, and hyphens';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Partitions'),
                    value: _partitions,
                    items:
                        List.generate(10, (index) => index + 1)
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _partitions = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Replication Factor',
                    ),
                    value: _replicationFactor,
                    items:
                        List.generate(3, (index) => index + 1)
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e,
                                child: Text('$e'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _replicationFactor = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isCreating
                  ? null
                  : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isCreating = true;
                      });

                      try {
                        final kafkaService = ref.read(kafkaServiceProvider);
                        await kafkaService.createTopic(
                          widget.clusterId,
                          _nameController.text,
                          _partitions,
                          _replicationFactor,
                        );

                        ref.refresh(topicsProvider(widget.clusterId));

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Topic "${_nameController.text}" created successfully',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                          setState(() {
                            _isCreating = false;
                          });
                        }
                      }
                    }
                  },
          child:
              _isCreating
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Create'),
        ),
      ],
    );
  }
}

// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.api),
            title: Text('API Configuration'),
            subtitle: Text('Configure Kafka API endpoints'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Alerts'),
            subtitle: Text('Configure monitoring alerts'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.sync),
            title: Text('Refresh Interval'),
            subtitle: Text('Configure data refresh intervals'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Theme'),
            subtitle: Text('Configure application theme'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Application information'),
          ),
        ],
      ),
    );
  }
}

// Kafka Consumer Group Management
class ConsumerGroupModel {
  final String id;
  final String topic;
  final List<ConsumerMember> members;
  final Map<String, int> partitionAssignments;
  final String state;
  final double lagSum;

  ConsumerGroupModel({
    required this.id,
    required this.topic,
    required this.members,
    required this.partitionAssignments,
    required this.state,
    required this.lagSum,
  });

  factory ConsumerGroupModel.fromJson(Map<String, dynamic> json) {
    return ConsumerGroupModel(
      id: json['id'],
      topic: json['topic'],
      members:
          (json['members'] as List)
              .map((m) => ConsumerMember.fromJson(m))
              .toList(),
      partitionAssignments: Map.from(json['partitionAssignments']),
      state: json['state'],
      lagSum: json['lagSum'],
    );
  }
}

class ConsumerMember {
  final String id;
  final String clientId;
  final String host;
  final List<int> assignedPartitions;

  ConsumerMember({
    required this.id,
    required this.clientId,
    required this.host,
    required this.assignedPartitions,
  });

  factory ConsumerMember.fromJson(Map<String, dynamic> json) {
    return ConsumerMember(
      id: json['id'],
      clientId: json['clientId'],
      host: json['host'],
      assignedPartitions: List<int>.from(json['assignedPartitions']),
    );
  }
}

// Kafka message model
class KafkaMessage {
  final String key;
  final String value;
  final int partition;
  final int offset;
  final DateTime timestamp;
  final Map<String, dynamic> headers;

  KafkaMessage({
    required this.key,
    required this.value,
    required this.partition,
    required this.offset,
    required this.timestamp,
    required this.headers,
  });

  factory KafkaMessage.fromJson(Map<String, dynamic> json) {
    return KafkaMessage(
      key: json['key'],
      value: json['value'],
      partition: json['partition'],
      offset: json['offset'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      headers: Map.from(json['headers']),
    );
  }
}

// Extension methods for Kafka Service
extension KafkaServiceExtension on KafkaService {
  Future<List<ConsumerGroupModel>> getConsumerGroups(String clusterId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/clusters/$clusterId/consumer-groups'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ConsumerGroupModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load consumer groups: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load consumer groups: $e');
    }
  }

  Future<List<KafkaMessage>> getMessages(
    String clusterId,
    String topicName, {
    int limit = 100,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$baseUrl/clusters/$clusterId/topics/$topicName/messages?limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => KafkaMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<void> produceMessage(
    String clusterId,
    String topicName,
    String key,
    String value,
    Map<String, String> headers,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/clusters/$clusterId/topics/$topicName/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': key, 'value': value, 'headers': headers}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to produce message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to produce message: $e');
    }
  }
}

// Additional providers
final consumerGroupsProvider =
    FutureProvider.family<List<ConsumerGroupModel>, String>((
      ref,
      clusterId,
    ) async {
      final kafkaService = ref.watch(kafkaServiceProvider);
      return await kafkaService.getConsumerGroups(clusterId);
    });

final messagesProvider =
    FutureProvider.family<List<KafkaMessage>, MessageRequest>((
      ref,
      request,
    ) async {
      final kafkaService = ref.watch(kafkaServiceProvider);
      return await kafkaService.getMessages(
        request.clusterId,
        request.topicName,
        limit: request.limit,
      );
    });

class MessageRequest {
  final String clusterId;
  final String topicName;
  final int limit;

  MessageRequest({
    required this.clusterId,
    required this.topicName,
    this.limit = 100,
  });
}

// Topic Details Screen
class TopicDetailsScreen extends ConsumerWidget {
  final String clusterId;
  final String topicName;

  const TopicDetailsScreen({
    Key? key,
    required this.clusterId,
    required this.topicName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageRequest = MessageRequest(
      clusterId: clusterId,
      topicName: topicName,
      limit: 50,
    );
    final messages = ref.watch(messagesProvider(messageRequest));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Topic: $topicName'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Messages'), Tab(text: 'Configuration')],
          ),
        ),
        body: TabBarView(
          children: [
            messages.when(
              data:
                  (messages) =>
                      messages.isEmpty
                          ? const Center(child: Text('No messages found'))
                          : ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ExpansionTile(
                                  title: Text('Offset: ${message.offset}'),
                                  subtitle: Text(
                                    'Partition: ${message.partition}, Key: ${message.key}',
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Value:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(message.value),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Headers:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...message.headers.entries.map(
                                            (entry) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${entry.key}:',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      entry.value.toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Timestamp: ${message.timestamp.toLocal()}',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            const Center(child: Text('Configuration tab content')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => ProduceMessageDialog(
                    clusterId: clusterId,
                    topicName: topicName,
                  ),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Produce Message',
        ),
      ),
    );
  }
}

// Produce Message Dialog
class ProduceMessageDialog extends ConsumerStatefulWidget {
  final String clusterId;
  final String topicName;

  const ProduceMessageDialog({
    Key? key,
    required this.clusterId,
    required this.topicName,
  }) : super(key: key);

  @override
  ConsumerState<ProduceMessageDialog> createState() =>
      _ProduceMessageDialogState();
}

class _ProduceMessageDialogState extends ConsumerState<ProduceMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _headers = <String, String>{};
  final _headerKeyController = TextEditingController();
  final _headerValueController = TextEditingController();
  bool _isProducing = false;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _headerKeyController.dispose();
    _headerValueController.dispose();
    super.dispose();
  }

  void _addHeader() {
    if (_headerKeyController.text.isNotEmpty) {
      setState(() {
        _headers[_headerKeyController.text] = _headerValueController.text;
        _headerKeyController.clear();
        _headerValueController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Produce Message'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Key',
                  hintText: 'Enter message key',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter message value',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message value';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Headers',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._headers.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text('${entry.key}: ${entry.value}')),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _headers.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _headerKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Header Key',
                        hintText: 'Enter key',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _headerValueController,
                      decoration: const InputDecoration(
                        labelText: 'Header Value',
                        hintText: 'Enter value',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addHeader,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isProducing
                  ? null
                  : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isProducing = true;
                      });

                      try {
                        final kafkaService = ref.read(kafkaServiceProvider);
                        await kafkaService.produceMessage(
                          widget.clusterId,
                          widget.topicName,
                          _keyController.text,
                          _valueController.text,
                          _headers,
                        );

                        ref.refresh(
                          messagesProvider(
                            MessageRequest(
                              clusterId: widget.clusterId,
                              topicName: widget.topicName,
                            ),
                          ),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message produced successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                          setState(() {
                            _isProducing = false;
                          });
                        }
                      }
                    }
                  },
          child:
              _isProducing
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Produce'),
        ),
      ],
    );
  }
}

// Consumer Groups Screen
class ConsumerGroupsScreen extends ConsumerWidget {
  final String clusterId;

  const ConsumerGroupsScreen({Key? key, required this.clusterId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumerGroups = ref.watch(consumerGroupsProvider(clusterId));

    return Scaffold(
      appBar: AppBar(title: const Text('Consumer Groups')),
      body: consumerGroups.when(
        data:
            (groups) =>
                groups.isEmpty
                    ? const Center(child: Text('No consumer groups found'))
                    : ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            title: Text(group.id),
                            subtitle: Text('Topic: ${group.topic}'),
                            trailing: Chip(
                              label: Text(group.state),
                              backgroundColor: _getStateColor(group.state),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lag Sum: ${group.lagSum.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Members',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...group.members.map(
                                      (member) => Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('ID: ${member.id}'),
                                              Text(
                                                'Client: ${member.clientId}',
                                              ),
                                              Text('Host: ${member.host}'),
                                              Text(
                                                'Partitions: ${member.assignedPartitions.join(", ")}',
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
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'stable':
        return Colors.green.withValues(alpha: 0.2);
      case 'rebalancing':
        return Colors.orange.withValues(alpha: 0.2);
      case 'dead':
        return Colors.red.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }
}
