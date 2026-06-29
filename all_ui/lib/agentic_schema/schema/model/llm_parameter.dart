class LLMParameters {
  final double? temperature;
  final int? maxTokens;
  final double? topP;
  final int? topK;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final List<String>? stopSequences;
  final String? systemPrompt;

  LLMParameters({
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.topP = 1.0,
    this.topK,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.stopSequences,
    this.systemPrompt,
  });

  factory LLMParameters.fromJson(Map<String, dynamic> json) {
    return LLMParameters(
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : null,
      maxTokens: json['maxTokens'] as int?,
      topP: json['topP'] != null ? (json['topP'] as num).toDouble() : null,
      topK: json['topK'] as int?,
      frequencyPenalty: json['frequencyPenalty'] != null
          ? (json['frequencyPenalty'] as num).toDouble()
          : null,
      presencePenalty: json['presencePenalty'] != null
          ? (json['presencePenalty'] as num).toDouble()
          : null,
      stopSequences: json['stopSequences'] != null
          ? List<String>.from(json['stopSequences'] as List)
          : null,
      systemPrompt: json['systemPrompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'maxTokens': maxTokens,
      if (topP != null) 'topP': topP,
      if (topK != null) 'topK': topK,
      if (frequencyPenalty != null) 'frequencyPenalty': frequencyPenalty,
      if (presencePenalty != null) 'presencePenalty': presencePenalty,
      if (stopSequences != null) 'stopSequences': stopSequences,
      if (systemPrompt != null) 'systemPrompt': systemPrompt,
    };
  }
}
