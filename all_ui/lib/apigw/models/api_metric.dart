import '../monitor/models/error_metric.dart';
import '../monitor/models/etcd.dart';
import '../monitor/models/http_conn.dart';
import '../monitor/models/node_info.dart';
import '../monitor/models/shared_dict.dart';

class ApiMetrics {
  final List<EtcdMetric> etcdMetrics;
  final NodeInfo nodeInfo;
  final int httpRequestsTotal;
  final HttpConnections httpConnections;
  final List<SharedDictMetric> sharedDictMetrics;
  final ErrorMetrics errorMetrics;
  final DateTime timestamp;

  ApiMetrics({
    required this.etcdMetrics,
    required this.nodeInfo,
    required this.httpRequestsTotal,
    required this.httpConnections,
    required this.sharedDictMetrics,
    required this.errorMetrics,
    required this.timestamp,
  });

  factory ApiMetrics.fromJson(Map<String, dynamic> json) {
    return ApiMetrics(
      etcdMetrics:
          (json['etcd_metrics'] as List)
              .map((metric) => EtcdMetric.fromJson(metric))
              .toList(),
      nodeInfo: NodeInfo.fromJson(json['node_info']),
      httpRequestsTotal: json['http_requests_total'],
      httpConnections: HttpConnections.fromJson(json['http_connections']),
      sharedDictMetrics:
          (json['shared_dict_metrics'] as List)
              .map((metric) => SharedDictMetric.fromJson(metric))
              .toList(),
      errorMetrics: ErrorMetrics.fromJson(json['error_metrics']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
