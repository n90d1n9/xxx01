import '../common/circuit_breaker.dart';
import '../common/retry_policy.dart';
import '../security/authentication.dart';
import 'connection_pool.dart';

class ConnectionConfig {
  final String? uri;
  final String? host;
  final int? port;
  final String? protocol;
  final Authentication? authentication;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParameters;
  final int? timeout;
  final RetryPolicy? retryPolicy;
  final CircuitBreaker? circuitBreaker;
  final ConnectionPool? connectionPool;

  ConnectionConfig({
    this.uri,
    this.host,
    this.port,
    this.protocol,
    this.authentication,
    this.headers,
    this.queryParameters,
    this.timeout,
    this.retryPolicy,
    this.circuitBreaker,
    this.connectionPool,
  });

  factory ConnectionConfig.fromJson(Map<String, dynamic> json) {
    return ConnectionConfig(
      uri: json['uri'] as String?,
      host: json['host'] as String?,
      port: json['port'] as int?,
      protocol: json['protocol'] as String?,
      authentication: json['authentication'] != null
          ? Authentication.fromJson(
              json['authentication'] as Map<String, dynamic>,
            )
          : null,
      headers: json['headers'] != null
          ? Map<String, dynamic>.from(json['headers'] as Map)
          : null,
      queryParameters: json['queryParameters'] != null
          ? Map<String, dynamic>.from(json['queryParameters'] as Map)
          : null,
      timeout: json['timeout'] as int?,
      retryPolicy: json['retryPolicy'] != null
          ? RetryPolicy.fromJson(json['retryPolicy'] as Map<String, dynamic>)
          : null,
      circuitBreaker: json['circuitBreaker'] != null
          ? CircuitBreaker.fromJson(
              json['circuitBreaker'] as Map<String, dynamic>,
            )
          : null,
      connectionPool: json['connectionPool'] != null
          ? ConnectionPool.fromJson(
              json['connectionPool'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (uri != null) 'uri': uri,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (protocol != null) 'protocol': protocol,
      if (authentication != null) 'authentication': authentication!.toJson(),
      if (headers != null) 'headers': headers,
      if (queryParameters != null) 'queryParameters': queryParameters,
      if (timeout != null) 'timeout': timeout,
      if (retryPolicy != null) 'retryPolicy': retryPolicy!.toJson(),
      if (circuitBreaker != null) 'circuitBreaker': circuitBreaker!.toJson(),
      if (connectionPool != null) 'connectionPool': connectionPool!.toJson(),
    };
  }
}
