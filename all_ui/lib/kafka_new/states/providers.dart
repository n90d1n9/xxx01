// Riverpod Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/endpoint_config.dart';
import '../models/kafka_broker.dart';
import '../models/kafka_cluster.dart';
import '../models/kafka_topic.dart';
import '../models/topic_metrics.dart';
import '../services/kafka_service.dart';

final kafkaApiServiceProvider = Provider<KafkaApiService>((ref) {
  return KafkaApiService();
});

final selectedClusterIdProvider = StateProvider<String?>((ref) => null);

final clustersProvider = FutureProvider<List<KafkaCluster>>((ref) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getClusters();
});

final topicsProvider = FutureProvider.family<List<KafkaTopic>, String>((
  ref,
  clusterId,
) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getTopics(clusterId);
});

final brokersProvider = FutureProvider.family<List<KafkaBroker>, String>((
  ref,
  clusterId,
) async {
  final apiService = ref.watch(kafkaApiServiceProvider);
  return await apiService.getBrokers(clusterId);
});

final topicMetricsProvider =
    FutureProvider.family<TopicMetrics, (String, String)>((ref, params) async {
      final apiService = ref.watch(kafkaApiServiceProvider);
      return await apiService.getTopicMetrics(params.$1, params.$2);
    });

final endpointConfigProvider =
    StateNotifierProvider<EndpointConfigNotifier, EndpointConfig>((ref) {
      return EndpointConfigNotifier();
    });

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

  Future<void> saveConfig(
    String endpoint,
    String? apiKey,
    String? apiSecret,
  ) async {
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
