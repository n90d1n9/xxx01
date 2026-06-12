import 'action_definition.dart';

class HttpRequestAction extends ActionDefinition {
  final String method;
  final String urlTemplate;
  final Map<String, String> headers;
  final String? bodyTemplate;
  final String? authType;
  final Map<String, dynamic>? authConfig;
  final Map<String, dynamic>? responseMapping;

  HttpRequestAction({
    required this.method,
    required this.urlTemplate,
    this.headers = const {},
    this.bodyTemplate,
    this.authType,
    this.authConfig,
    this.responseMapping,
  }) : super('http_request');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'method': method,
    'urlTemplate': urlTemplate,
    'headers': headers,
    'bodyTemplate': bodyTemplate,
    'authType': authType,
    'authConfig': authConfig,
    'responseMapping': responseMapping,
  };

  factory HttpRequestAction.fromJson(Map<String, dynamic> json) =>
      HttpRequestAction(
        method: json['method'],
        urlTemplate: json['urlTemplate'],
        headers: Map<String, String>.from(json['headers'] ?? {}),
        bodyTemplate: json['bodyTemplate'],
        authType: json['authType'],
        authConfig: json['authConfig'],
        responseMapping: json['responseMapping'],
      );
}
