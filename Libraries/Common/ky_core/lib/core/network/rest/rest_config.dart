class RestConfig {
  final String baseUrl;
  final int timeoutConnection;
  final int timeoutReceive;
  final String? tokenKey;
  final String? refreshTokenKey;
  RestConfig({
    this.baseUrl = "http://localhost:8080",
    this.timeoutConnection = 100,
    this.timeoutReceive = 300,
    this.refreshTokenKey = 'refresh_token',
    this.tokenKey = 'auth_token',
  });

  RestConfig copyWith({
    String? baseUrl,
    int? timeoutConnection,
    int? timeoutReceive,
  }) {
    return RestConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      timeoutConnection: timeoutConnection ?? this.timeoutConnection,
      timeoutReceive: timeoutReceive ?? this.timeoutReceive,
    );
  }
}
