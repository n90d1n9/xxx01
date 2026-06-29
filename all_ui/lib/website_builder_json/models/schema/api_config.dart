import 'auth_config.dart';
import 'retry_config.dart';

class ApiConfig {
  final String url;
  final String method; // GET, POST, PUT, DELETE, PATCH
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final Map<String, String>? queryParams;
  final AuthConfig? auth;
  final RetryConfig? retry;

  ApiConfig({
    required this.url,
    required this.method,
    this.headers,
    this.body,
    this.queryParams,
    this.auth,
    this.retry,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      url: json['url'] as String,
      method: json['method'] as String,
      headers:
          json['headers'] != null
              ? Map<String, String>.from(json['headers'] as Map)
              : null,
      body: json['body'] as Map<String, dynamic>?,
      queryParams:
          json['queryParams'] != null
              ? Map<String, String>.from(json['queryParams'] as Map)
              : null,
      auth:
          json['auth'] != null
              ? AuthConfig.fromJson(json['auth'] as Map<String, dynamic>)
              : null,
      retry:
          json['retry'] != null
              ? RetryConfig.fromJson(json['retry'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'method': method,
    if (headers != null) 'headers': headers,
    if (body != null) 'body': body,
    if (queryParams != null) 'queryParams': queryParams,
    if (auth != null) 'auth': auth!.toJson(),
    if (retry != null) 'retry': retry!.toJson(),
  };
}
