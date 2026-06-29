import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/performance_alert.dart';
import '../models/performance_mentric.dart';
import 'select_route_provider.dart';

final performanceMetricsProvider = Provider<PerformanceMetrics>((ref) {
  final route = ref.watch(selectedRouteProvider);
  if (route == null) {
    return PerformanceMetrics(
      totalNodes: 0,
      totalConnections: 0,
      averageProcessingTime: Duration.zero,
      messagesProcessed: 0,
      throughput: 0.0,
      nodeExecutionCounts: {},
      nodeProcessingTimes: {},
    );
  }

  final totalConnections = route.nodes.fold<int>(
    0,
    (sum, node) => sum + node.connections.length,
  );

  // Simulated metrics
  final nodeExecutionCounts = <String, int>{};
  final nodeProcessingTimes = <String, Duration>{};
  final alerts = <PerformanceAlert>[];

  for (final node in route.nodes) {
    nodeExecutionCounts[node.id] = math.Random().nextInt(1000) + 100;
    nodeProcessingTimes[node.id] = Duration(
      milliseconds: math.Random().nextInt(500) + 50,
    );
  }

  // Generate alerts based on metrics
  if (route.nodes.length > 20) {
    alerts.add(
      PerformanceAlert(
        severity: 'warning',
        message:
            'Route has ${route.nodes.length} nodes. Consider splitting into smaller routes.',
        timestamp: DateTime.now(),
      ),
    );
  }

  if (totalConnections > route.nodes.length * 2) {
    alerts.add(
      PerformanceAlert(
        severity: 'info',
        message:
            'Complex routing detected. Review for optimization opportunities.',
        timestamp: DateTime.now(),
      ),
    );
  }

  return PerformanceMetrics(
    totalNodes: route.nodes.length,
    totalConnections: totalConnections,
    averageProcessingTime: const Duration(milliseconds: 150),
    messagesProcessed: 12500,
    throughput: 83.3,
    nodeExecutionCounts: nodeExecutionCounts,
    nodeProcessingTimes: nodeProcessingTimes,
    alerts: alerts,
  );
});
