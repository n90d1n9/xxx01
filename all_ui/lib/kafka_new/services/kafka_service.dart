import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/kafka_broker.dart';
import '../models/kafka_cluster.dart';
import '../models/kafka_topic.dart';
import '../models/metric_point.dart';
import '../models/topic_metrics.dart';

class KafkaApiService {
  final Dio _dio = Dio();

  Future<void> configureEndpoint(
    String endpoint,
    String? apiKey,
    String? apiSecret,
  ) async {
    _dio.options.baseUrl = endpoint;

    if (apiKey != null && apiSecret != null) {
      _dio.options.headers = {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
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

  Future<TopicMetrics> getTopicMetrics(
    String clusterId,
    String topicName,
  ) async {
    try {
      final response = await _dio.get(
        '/clusters/$clusterId/topics/$topicName/metrics',
      );

      // Parse timestamps and values
      List<MetricPoint> messagesPerSecond = _parseMetricPoints(
        response.data['messages_per_second'],
      );
      List<MetricPoint> bytesInPerSecond = _parseMetricPoints(
        response.data['bytes_in_per_second'],
      );
      List<MetricPoint> bytesOutPerSecond = _parseMetricPoints(
        response.data['bytes_out_per_second'],
      );

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

  Future<void> createTopic(
    String clusterId,
    String name,
    int partitions,
    int replicationFactor,
    Map<String, dynamic> configs,
  ) async {
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

  Future<void> updateTopicConfig(
    String clusterId,
    String topicName,
    Map<String, dynamic> configs,
  ) async {
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
