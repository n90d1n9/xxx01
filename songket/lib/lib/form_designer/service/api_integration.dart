class APIIntegration {
  final String endpoint;
  final String method; // GET, POST, PUT, DELETE
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final String? authType; // none, bearer, apiKey, basic
  final String? authToken;

  const APIIntegration({
    required this.endpoint,
    this.method = 'POST',
    this.headers,
    this.body,
    this.authType,
    this.authToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      'headers': headers,
      'body': body,
      'authType': authType,
      'authToken': authToken,
    };
  }
}
