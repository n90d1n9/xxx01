enum DataSourceType {
  local,
  api,
  database,
  csv,
  excel,
  googleSheets,
  firestore,
  supabase,
  graphql,
  custom,
}

class DataSource {
  final String id;
  final String name;
  final DataSourceType type;
  final Map<String, dynamic> connectionConfig;
  final String? query;
  final Map<String, String> headers;
  final Duration cacheTimeout;
  final bool requiresAuth;
  final String? authToken;
  final DateTime? lastSync;
  final bool isHealthy;

  DataSource({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionConfig,
    this.query,
    this.headers = const {},
    this.cacheTimeout = const Duration(minutes: 5),
    this.requiresAuth = false,
    this.authToken,
    this.lastSync,
    this.isHealthy = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'connectionConfig': connectionConfig,
    'query': query,
    'headers': headers,
    'cacheTimeoutMinutes': cacheTimeout.inMinutes,
    'requiresAuth': requiresAuth,
    'lastSync': lastSync?.toIso8601String(),
    'isHealthy': isHealthy,
  };

  factory DataSource.fromJson(Map<String, dynamic> json) => DataSource(
    id: json['id'],
    name: json['name'],
    type: DataSourceType.values.firstWhere((e) => e.name == json['type']),
    connectionConfig: json['connectionConfig'],
    query: json['query'],
    headers: Map<String, String>.from(json['headers'] ?? {}),
    cacheTimeout: Duration(minutes: json['cacheTimeoutMinutes'] ?? 5),
    requiresAuth: json['requiresAuth'] ?? false,
    authToken: json['authToken'],
    lastSync: json['lastSync'] != null
        ? DateTime.parse(json['lastSync'])
        : null,
    isHealthy: json['isHealthy'] ?? true,
  );
}
