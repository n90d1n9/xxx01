class MemoryConfigSettings {
  final int? maxMessages;
  final int? windowSize;
  final int? summaryInterval;
  final String? embeddingModel;
  final double? similarityThreshold;
  final String? connectionString;

  MemoryConfigSettings({
    this.maxMessages = 1000,
    this.windowSize = 10,
    this.summaryInterval = 50,
    this.embeddingModel,
    this.similarityThreshold = 0.8,
    this.connectionString,
  });

  factory MemoryConfigSettings.fromJson(Map<String, dynamic> json) {
    return MemoryConfigSettings(
      maxMessages: json['maxMessages'] as int?,
      windowSize: json['windowSize'] as int?,
      summaryInterval: json['summaryInterval'] as int?,
      embeddingModel: json['embeddingModel'] as String?,
      similarityThreshold: json['similarityThreshold'] != null
          ? (json['similarityThreshold'] as num).toDouble()
          : null,
      connectionString: json['connectionString'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maxMessages != null) 'maxMessages': maxMessages,
      if (windowSize != null) 'windowSize': windowSize,
      if (summaryInterval != null) 'summaryInterval': summaryInterval,
      if (embeddingModel != null) 'embeddingModel': embeddingModel,
      if (similarityThreshold != null)
        'similarityThreshold': similarityThreshold,
      if (connectionString != null) 'connectionString': connectionString,
    };
  }
}
