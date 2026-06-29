import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../models/api_metric.dart';

class ApiService {
  final String baseUrl;
  final String username;
  final String password;

  ApiService({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  Stream<ApiMetrics> getMetricsStream() async* {
    final uri = Uri.parse('$baseUrl/sse');

    debugPrint('Connecting to SSE endpoint: $uri');

    final credentials = base64Encode(utf8.encode('$username:$password'));

    try {
      final request = http.Request('GET', uri);
      request.headers['Authorization'] = 'Basic $credentials';

      final response = await http.Client().send(request);
      debugPrint('Response status: ${response.statusCode}');
      await for (final chunk in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (chunk.startsWith('data: ')) {
          final jsonData = chunk.substring(6);
          try {
            final metricsData = jsonDecode(jsonData);
            yield ApiMetrics.fromJson(metricsData);
          } catch (e) {
            print('Error parsing SSE data: $e');
          }
        }
      }
    } catch (e) {
      print('Error connecting to SSE endpoint: $e');
      yield* Stream.error(e);
    }
  }
}
