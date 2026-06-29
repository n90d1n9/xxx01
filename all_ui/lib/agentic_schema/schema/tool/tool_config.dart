import '../common/rate_limit.dart';
import '../security/authentication.dart';

class ToolConfig {
  final String? endpoint;
  final String? method;
  final Map<String, dynamic>? headers;
  final Authentication? authentication;
  final Map<String, dynamic>? inputSchema;
  final Map<String, dynamic>? outputSchema;
  final int? timeout;
  final RateLimit? rateLimit;

  ToolConfig({
    this.endpoint,
    this.method,
    this.headers,
    this.authentication,
    this.inputSchema,
    this.outputSchema,
    this.timeout = 30000,
    this.rateLimit,
  });

  factory ToolConfig.fromJson(Map<String, dynamic> json) {
    return ToolConfig(
      endpoint: json['endpoint'] as String?,
      method: json['method'] as String?,
      headers: json['headers'] != null
          ? Map<String, dynamic>.from(json['headers'] as Map)
          : null,
      authentication: json['authentication'] != null
          ? Authentication.fromJson(
              json['authentication'] as Map<String, dynamic>,
            )
          : null,
      inputSchema: json['inputSchema'] != null
          ? Map<String, dynamic>.from(json['inputSchema'] as Map)
          : null,
      outputSchema: json['outputSchema'] != null
          ? Map<String, dynamic>.from(json['outputSchema'] as Map)
          : null,
      timeout: json['timeout'] as int?,
      rateLimit: json['rateLimit'] != null
          ? RateLimit.fromJson(json['rateLimit'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (headers != null) 'headers': headers,
      if (authentication != null) 'authentication': authentication!.toJson(),
      if (inputSchema != null) 'inputSchema': inputSchema,
      if (outputSchema != null) 'outputSchema': outputSchema,
      if (timeout != null) 'timeout': timeout,
      if (rateLimit != null) 'rateLimit': rateLimit!.toJson(),
    };
  }
}
