import 'llm_parameter.dart';
import '../config/retry_config.dart';

enum LLMProvider {
  openai,
  anthropic,
  google,
  cohere,
  azure,
  aws,
  huggingface,
  ollama,
  custom,
}

class LLMConfig {
  final LLMProvider provider;
  final String model;
  final String? apiKey;
  final String? apiEndpoint;
  final LLMParameters? parameters;
  final List<String>? fallbackModels;
  final RetryConfig? retryConfig;

  LLMConfig({
    required this.provider,
    required this.model,
    this.apiKey,
    this.apiEndpoint,
    this.parameters,
    this.fallbackModels,
    this.retryConfig,
  });

  factory LLMConfig.fromJson(Map<String, dynamic> json) {
    return LLMConfig(
      provider: _parseLLMProvider(json['provider']),
      model: json['model'] as String,
      apiKey: json['apiKey'] as String?,
      apiEndpoint: json['apiEndpoint'] as String?,
      parameters: json['parameters'] != null
          ? LLMParameters.fromJson(json['parameters'] as Map<String, dynamic>)
          : null,
      fallbackModels: json['fallbackModels'] != null
          ? List<String>.from(json['fallbackModels'] as List)
          : null,
      retryConfig: json['retryConfig'] != null
          ? RetryConfig.fromJson(json['retryConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'model': model,
      if (apiKey != null) 'apiKey': apiKey,
      if (apiEndpoint != null) 'apiEndpoint': apiEndpoint,
      if (parameters != null) 'parameters': parameters!.toJson(),
      if (fallbackModels != null) 'fallbackModels': fallbackModels,
      if (retryConfig != null) 'retryConfig': retryConfig!.toJson(),
    };
  }

  static LLMProvider _parseLLMProvider(dynamic value) {
    if (value is LLMProvider) return value;
    final stringValue = value.toString();
    return LLMProvider.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => LLMProvider.custom,
    );
  }
}
