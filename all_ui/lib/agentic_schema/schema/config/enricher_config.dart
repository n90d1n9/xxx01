class EnricherConfig {
  final String? resourceUri;
  final String? enrichmentExpression;
  final String? aggregationStrategy;
  final bool? cacheResults;

  EnricherConfig({
    this.resourceUri,
    this.enrichmentExpression,
    this.aggregationStrategy = 'default',
    this.cacheResults = true,
  });

  factory EnricherConfig.fromJson(Map<String, dynamic> json) {
    return EnricherConfig(
      resourceUri: json['resourceUri'] as String?,
      enrichmentExpression: json['enrichmentExpression'] as String?,
      aggregationStrategy: json['aggregationStrategy'] as String?,
      cacheResults: json['cacheResults'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (resourceUri != null) 'resourceUri': resourceUri,
      if (enrichmentExpression != null)
        'enrichmentExpression': enrichmentExpression,
      if (aggregationStrategy != null)
        'aggregationStrategy': aggregationStrategy,
      if (cacheResults != null) 'cacheResults': cacheResults,
    };
  }
}
