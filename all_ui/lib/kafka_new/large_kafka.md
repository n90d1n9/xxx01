import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Models
class KafkaCluster {
  final String id;
  final String name;
  final String endpoint;
  final String status;
  final int brokerCount;
  final int topicCount;

  KafkaCluster({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.status,
    required this.brokerCount,
    required this.topicCount,
  });

  factory KafkaCluster.fromJson(Map<String, dynamic> json) {
    return KafkaCluster(
      id: json['id'],
      name: json['name'],
      endpoint: json['endpoint'],
      status: json['status'],
      brokerCount: json['broker_count'],
      topicCount: json['topic_count'],
    );
  }
}

class KafkaTopic {
  final String name;
  final int partitions;
  final int replicationFactor;
  final Map<String, dynamic> configs;
  final int messageCount;
  final double throughput;

  KafkaTopic({
    required this.name,
    required this.partitions,
    required this.replicationFactor,
    required this.configs,
    required this.messageCount,
    required this.throughput,
  });

  factory KafkaTopic.fromJson(Map<String, dynamic> json) {
    return KafkaTopic(
      name: json['name'],
      partitions: json['partitions'],
      replicationFactor: json['replication_factor'],
      configs: json['configs'] ?? {},
      messageCount: json['message_count'] ?? 0,
      throughput: json['throughput'] ?? 0.0,
    );
  }
}

class KafkaBroker {
  final String id;
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
      isController: json['is_controller'] ?? false,
      metrics: json['metrics'] ?? {},
    );
  }
}

class TopicMetrics {
  final String name;
  final List<MetricPoint> messagesPerSecond;
  final List<MetricPoint> bytesInPerSecond;
  final List<MetricPoint> bytesOutPerSecond;

  TopicMetrics({
    required this.name,
    required this.messagesPerSecond,
    required this.bytesInPerSecond,
    required this.bytesOutPerSecond,
  });
}

class MetricPoint {
  final DateTime timestamp;
  final double value;

  MetricPoint({required this.timestamp, required this.value});
}

// API Service
class KafkaApiService {
  final Dio _dio = Dio();
  
  Future<void> configureEndpoint(String endpoint, String? apiKey, String? apiSecret) async {
    _dio.options.baseUrl = endpoint;
    
    if (apiKey != null && apiSecret != null) {
      _dio.options.headers = {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
        'Content-Type': 'application/json',
      };
    }
  }

  Future<List<KafkaCluster>> getClusters() async {
    try {
      final response = await _dio.get('/clusters');
      return (response.data as List)
          .map((json) => KafkaCluster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load clusters: $e');
    }
  }

  Future<List<KafkaTopic>> getTopics(String clusterId) async {
    try {
      final response = await _dio.get('/clusters/$clusterId/topics');
      return (response.data as List)
          .map((json) => KafkaTopic.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  Future<List<KafkaBroker>> getBrokers(String clusterId) async {
    try {
      final response = await _dio.get('/clusters/$clusterId/brokers');
      return (response.data as List)
          .map((json) => KafkaBroker.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load brokers: $e');
    }
  }

  Future<TopicMetrics> getTopicMetrics(String clusterId, String topicName) async {
    try {
      final response = await _dio.get('/clusters/$clusterId/topics/$topicName/metrics');
      
      // Parse timestamps and values
      List<MetricPoint> messagesPerSecond = _parseMetricPoints(response.data['messages_per_second']);
      List<MetricPoint> bytesInPerSecond = _parseMetricPoints(response.data['bytes_in_per_second']);
      List<MetricPoint> bytesOutPerSecond = _parseMetricPoints(response.data['bytes_out_per_second']);

      return TopicMetrics(
        name: topicName,
        messagesPerSecond: messagesPerSecond,
        bytesInPerSecond: bytesInPerSecond,
        bytesOutPerSecond: bytesOutPerSecond,
      );
    } catch (e) {
      throw Exception('Failed to load topic metrics: $e');
    }
  }

  List<MetricPoint> _parseMetricPoints(List<dynamic> data) {
    return data.map((point) {
      return MetricPoint(
        timestamp: DateTime.fromMillisecondsSinceEpoch(point['timestamp']),
        value: point['value'].toDouble(),
      );
    }).toList();
  }

  Future<void> createTopic(String clusterId, String name, int partitions, int replicationFactor, Map<String, dynamic> configs) async {
    try {
      await _dio.post(
        '/clusters/$clusterId/topics',
        data: {
          'name': name,
          'partitions': partitions,
          'replication_factor': replicationFactor,
          'configs': configs,
        },
      );
    } catch (e) {
      throw Exception('Failed to create topic: $e');
    }
  }

  Future<void> deleteTopic(String clusterId, String topicName) async {
    try {
      await _dio.delete('/clusters/$clusterId/topics/$topicName');
    } catch (e) {
      throw Exception('Failed to delete topic: $e');
    }
  }

  Future<void> updateTopicConfig(String clusterId, String topicName, Map<String, dynamic> configs) async {
    try {
      await _dio.put(
        '/clusters/$clusterId/topics/$topicName/configs',
        data: {'configs': configs},
      );
    } catch (e) {
      throw Exception('Failed to update topic configuration: $e');
    }
  }
}

// Riverpod Providers
final kafkaApiServiceProvider = Provider<KafkaApiService>((ref) {
  return KafkaApiService();
});

final selectedClusterIdProvider = StateProvider<String?>((ref) => null);

final clustersProvider = FutureProvider<List<KafkaCluster>>((ref) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getClusters();
});

final topicsProvider = FutureProvider.family<List<KafkaTopic>, String>((ref, clusterId) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getTopics(clusterId);
});

final brokersProvider = FutureProvider.family<List<KafkaBroker>, String>((ref, clusterId) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getBrokers(clusterId);
});

final topicMetricsProvider = FutureProvider.family<TopicMetrics, (String, String)>((ref, params) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getTopicMetrics(params.$1, params.$2);
});

final endpointConfigProvider = StateNotifierProvider<EndpointConfigNotifier, EndpointConfig>((ref) {
  return EndpointConfigNotifier();
});

class EndpointConfig {
  final String endpoint;
  final String? apiKey;
  final String? apiSecret;

  EndpointConfig({required this.endpoint, this.apiKey, this.apiSecret});
}

class EndpointConfigNotifier extends StateNotifier<EndpointConfig> {
  EndpointConfigNotifier() : super(EndpointConfig(endpoint: ''));

  Future<void> loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString('kafka_endpoint') ?? '';
    final apiKey = prefs.getString('kafka_api_key');
    final apiSecret = prefs.getString('kafka_api_secret');
    
    state = EndpointConfig(
      endpoint: endpoint,
      apiKey: apiKey,
      apiSecret: apiSecret,
    );
  }

  Future<void> saveConfig(String endpoint, String? apiKey, String? apiSecret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kafka_endpoint', endpoint);
    
    if (apiKey != null) await prefs.setString('kafka_api_key', apiKey);
    if (apiSecret != null) await prefs.setString('kafka_api_secret', apiSecret);
    
    state = EndpointConfig(
      endpoint: endpoint,
      apiKey: apiKey,
      apiSecret: apiSecret,
    );
  }
}

// Main App
void main() {
  runApp(const ProviderScope(child: KafkaManagerApp()));
}

class KafkaManagerApp extends ConsumerWidget {
  const KafkaManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Kafka Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SetupScreen(),
    );
  }
}

// Setup Screen
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    await ref.read(endpointConfigProvider.notifier).loadSavedConfig();
    final config = ref.read(endpointConfigProvider);
    
    _endpointController.text = config.endpoint;
    _apiKeyController.text = config.apiKey ?? '';
    _apiSecretController.text = config.apiSecret ?? '';
    
    setState(() {
      _isLoading = false;
    });
    
    if (config.endpoint.isNotEmpty) {
      ref.read(kafkaApiServiceProvider).configureEndpoint(
        config.endpoint,
        config.apiKey,
        config.apiSecret,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      await ref.read(endpointConfigProvider.notifier).saveConfig(
        _endpointController.text,
        _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
        _apiSecretController.text.isNotEmpty ? _apiSecretController.text : null,
      );
      
      ref.read(kafkaApiServiceProvider).configureEndpoint(
        _endpointController.text,
        _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
        _apiSecretController.text.isNotEmpty ? _apiSecretController.text : null,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kafka Manager Setup'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Configure Kafka REST API Endpoint',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _endpointController,
                      decoration: const InputDecoration(
                        labelText: 'Kafka REST API Endpoint',
                        hintText: 'https://your-kafka-rest-api.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an endpoint URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiSecretController,
                      decoration: const InputDecoration(
                        labelText: 'API Secret (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Connect to Kafka API'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(endpointConfigProvider);
    final clustersAsync = ref.watch(clustersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kafka Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetupScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            minExtendedWidth: 200,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.topic),
                label: Text('Topics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.computer),
                label: Text('Brokers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insights),
                label: Text('Monitoring'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: clustersAsync.when(
              data: (clusters) {
                if (clusters.isEmpty) {
                  return const Center(
                    child: Text('No Kafka clusters found. Check your API configuration.'),
                  );
                }
                
                // Auto-select the first cluster if none is selected
                if (ref.read(selectedClusterIdProvider) == null && clusters.isNotEmpty) {
                  ref.read(selectedClusterIdProvider.notifier).state = clusters.first.id;
                }
                
                // Different screens based on the selected index
                switch (_selectedIndex) {
                  case 0:
                    return OverviewScreen(clusters: clusters);
                  case 1:
                    return const TopicsScreen();
                  case 2:
                    return const BrokersScreen();
                  case 3:
                    return const MonitoringScreen();
                  default:
                    return const Center(child: Text('Unknown screen'));
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error loading clusters: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                _showCreateTopicDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateTopicDialog(BuildContext context) {
    final clusterId = ref.read(selectedClusterIdProvider);
    if (clusterId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => CreateTopicDialog(clusterId: clusterId),
    );
  }
}

// Overview Screen
class OverviewScreen extends ConsumerWidget {
  final List<KafkaCluster> clusters;
  
  const OverviewScreen({
    Key? key,
    required this.clusters,
  }) : super(key: key);

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
                items: clusters.map<DropdownMenuItem<String>>((KafkaCluster cluster) {
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
            Expanded(
              child: ClusterDetailsView(clusterId: selectedClusterId),
            ),
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

class ClusterDetailsView extends ConsumerWidget {
  final String clusterId;
  
  const ClusterDetailsView({
    Key? key,
    required this.clusterId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider(clusterId));
    final brokersAsync = ref.watch(brokersProvider(clusterId));
    final selectedCluster = ref.watch(clustersProvider).maybeWhen(
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
                                  child: Text('No topics found in this cluster'),
                                );
                              }
                              
                              // Sort topics by message count
                              final sortedTopics = List.from(topics)
                                ..sort((a, b) => b.messageCount.compareTo(a.messageCount));
                              
                              return ListView.builder(
                                itemCount: sortedTopics.length > 5 ? 5 : sortedTopics.length,
                                itemBuilder: (context, index) {
                                  final topic = sortedTopics[index];
                                  return ListTile(
                                    title: Text(topic.name),
                                    subtitle: Text(
                                      'Partitions: ${topic.partitions}, Replication: ${topic.replicationFactor}',
                                    ),
                                    trailing: Text(
                                      '${topic.messageCount} msgs',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(
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
                                  child: Text('No brokers found in this cluster'),
                                );
                              }
                              
                              return ListView.builder(
                                itemCount: brokers.length,
                                itemBuilder: (context, index) {
                                  final broker = brokers[index];
                                  return ListTile(
                                    title: Text('Broker ID: ${broker.id}'),
                                    subtitle: Text('${broker.host}:${broker.port}'),
                                    trailing: broker.isController
                                        ? const Chip(
                                            label: Text('Controller'),
                                            backgroundColor: Colors.blue,
                                            labelStyle: TextStyle(color: Colors.white),
                                          )
                                        : null,
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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

// Topics Screen
class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);
    
    if (selectedClusterId == null) {
      return const Center(
        child: Text('Select a cluster to view topics'),
      );
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
                        DataColumn(
                          label: Text('Partitions'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Replication'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Messages'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text('Throughput (msg/s)'),
                          numeric: true,
                        ),
                        DataColumn2(
                          label: Text('Actions'),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: topics.map((topic) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                topic.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                _showTopicDetails(context, ref, selectedClusterId, topic);
                              },
                            ),
                            DataCell(Text('${topic.partitions}')),
                            DataCell(Text('${topic.replicationFactor}')),
                            DataCell(Text('${topic.messageCount}')),
                            DataCell(Text(topic.throughput.toStringAsFixed(2))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.settings, size: 20),
                                    tooltip: 'Configure',
                                    onPressed: () {
                                      _showTopicConfigDialog(context, ref, selectedClusterId, topic);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      _showDeleteTopicDialog(context, ref, selectedClusterId, topic.name);
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
              error: (error, _) => Center(
                child: Text('Error loading topics: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopicDetails(BuildContext context, WidgetRef ref, String clusterId, KafkaTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailsScreen(
          clusterId: clusterId,
          topic: topic,
        ),
      ),
    );
  }

  void _showTopicConfigDialog(BuildContext context, WidgetRef ref, String clusterId, KafkaTopic topic) {
    showDialog(
      context: context,
      builder: (context) => TopicConfigDialog(
        clusterId: clusterId,
        topic: topic,
      ),
    );
  }

  void _showDeleteTopicDialog(BuildContext context, WidgetRef ref, String clusterId, String topicName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                await ref.read(kafkaApiServiceProvider).deleteTopic(clusterId, topicName);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Refresh topics list
                  ref.refresh(topicsProvider(clusterId));
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Topic "$topicName" deleted successfully'),
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

// Topic Details Screen
class TopicDetailsScreen extends ConsumerWidget {
  final String clusterId;
  final KafkaTopic topic;
  
  const TopicDetailsScreen({
    Key? key,
    required this.clusterId,
    required this.topic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(topicMetricsProvider((clusterId, topic.name)));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Topic: ${topic.name}'),
      ),
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
                    _buildDetailRow('Replication Factor', '${topic.replicationFactor}'),
                    _buildDetailRow('Message Count', '${topic.messageCount}'),
                    _buildDetailRow('Throughput', '${topic.throughput.toStringAsFixed(2)} msgs/sec'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                                      titlesData: const FlTitlesData(show: true),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _createSpots(metrics.messagesPerSecond),
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
                                      titlesData: const FlTitlesData(show: true),
                                      borderData: FlBorderData(show: true),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _createSpots(metrics.bytesInPerSecond),
                                          isCurved: true,
                                          color: Colors.green,
                                          barWidth: 2,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(show: true),
                                        ),
                                        LineChartBarData(
                                          spots: _createSpots(metrics.bytesOutPerSecond),
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
                error: (error, _) => Center(
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
                              _showTopicConfigDialog(context, ref, clusterId, topic);
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

  void _showTopicConfigDialog(BuildContext context, WidgetRef ref, String clusterId, KafkaTopic topic) {
    showDialog(
      context: context,
      builder: (context) => TopicConfigDialog(
        clusterId: clusterId,
        topic: topic,
      ),
    );
  }
}

// Topic Config Dialog
class TopicConfigDialog extends ConsumerStatefulWidget {
  final String clusterId;
  final KafkaTopic topic;
  
  const TopicConfigDialog({
    Key? key,
    required this.clusterId,
    required this.topic,
  }) : super(key: key);

  @override
  _TopicConfigDialogState createState() => _TopicConfigDialogState();
}

class _TopicConfigDialogState extends ConsumerState<TopicConfigDialog> {
  late Map<String, dynamic> configs;
  
  @override
  void initState() {
    super.initState();
    configs = Map.from(widget.topic.configs);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure Topic: ${widget.topic.name}'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: ListView(
          children: configs.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              subtitle: TextField(
                controller: TextEditingController(text: entry.value.toString()),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  // Try to parse as number if possible
                  if (double.tryParse(value) != null) {
                    configs[entry.key] = double.parse(value);
                  } else {
                    configs[entry.key] = value;
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref.read(kafkaApiServiceProvider).updateTopicConfig(
                widget.clusterId,
                widget.topic.name,
                configs,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                
                // Refresh topics
                ref.refresh(topicsProvider(widget.clusterId));
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration updated successfully'),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Create Topic Dialog
class CreateTopicDialog extends ConsumerStatefulWidget {
  final String clusterId;
  
  const CreateTopicDialog({
    Key? key,
    required this.clusterId,
  }) : super(key: key);

  @override
  _CreateTopicDialogState createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends ConsumerState<CreateTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _partitions = 1;
  int _replicationFactor = 1;
  final Map<String, dynamic> _configs = {
    'retention.ms': 604800000, // 7 days
    'cleanup.policy': 'delete',
  };
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Topic'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Topic Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a topic name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Partitions',
                          border: OutlineInputBorder(),
                        ),
                        value: _partitions,
                        items: List.generate(12, (index) => index + 1)
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('$e'),
                                ))
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
                          border: OutlineInputBorder(),
                        ),
                        value: _replicationFactor,
                        items: List.generate(3, (index) => index + 1)
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('$e'),
                                ))
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
                const SizedBox(height: 16),
                const Text(
                  'Configuration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Retention time
                Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Retention Time:')),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        value: _configs['retention.ms'],
                        items: [
                          DropdownMenuItem(
                            value: 86400000,
                            child: const Text('1 day'),
                          ),
                          DropdownMenuItem(
                            value: 604800000,
                            child: const Text('7 days'),
                          ),
                          DropdownMenuItem(
                            value: 2592000000,
                            child: const Text('30 days'),
                          ),
                          DropdownMenuItem(
                            value: -1,
                            child: const Text('Unlimited'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _configs['retention.ms'] = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Cleanup policy
                Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Cleanup Policy:')),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        value: _configs['cleanup.policy'],
                        items: const [
                          DropdownMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          DropdownMenuItem(
                            value: 'compact',
                            child: Text('Compact'),
                          ),
                          DropdownMenuItem(
                            value: 'compact,delete',
                            child: Text('Compact and Delete'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _configs['cleanup.policy'] = value;
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await ref.read(kafkaApiServiceProvider).createTopic(
                  widget.clusterId,
                  _nameController.text,
                  _partitions,
                  _replicationFactor,
                  _configs,
                );
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Refresh topics
                  ref.refresh(topicsProvider(widget.clusterId));
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Topic "${_nameController.text}" created successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// Brokers Screen
class BrokersScreen extends ConsumerWidget {
  const BrokersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClusterId = ref.watch(selectedClusterIdProvider);
    
    if (selectedClusterId == null) {
      return const Center(
        child: Text('Select a cluster to view brokers'),
      );
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
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                            style: const TextStyle(fontSize: 16),
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
              error: (error, _) => Center(
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

// Monitoring Screen
class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  _MonitoringScreenState createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  String? _selectedTopicName;
  int _timeRangeHours = 24;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      items: topics.map((topic) {
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

class TopicMetricsView extends ConsumerWidget {
  final String clusterId;
  final String topicName;
  final int timeRangeHours;
  
  const TopicMetricsView({
    Key? key,
    required this.clusterId,
    required this.topicName,
    required this.timeRangeHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(topicMetricsProvider((clusterId, topicName)));
    
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
                                      spots: _createSpots(metrics.messagesPerSecond),
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
                  const SizedBox