class EnrichmentSource {
  final String type;
  final String? endpoint;
  final String? query;

  EnrichmentSource({required this.type, this.endpoint, this.query});

  factory EnrichmentSource.fromJson(Map<String, dynamic> json) {
    return EnrichmentSource(
      type: json['type'] as String,
      endpoint: json['endpoint'] as String?,
      query: json['query'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (endpoint != null) 'endpoint': endpoint,
      if (query != null) 'query': query,
    };
  }
}
