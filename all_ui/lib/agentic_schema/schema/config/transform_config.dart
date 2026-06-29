import '../data/data_format.dart';

class TransformConfig {
  final String type;
  final String? script;
  final Map<String, dynamic>? mapping;
  final DataFormat? inputFormat;
  final DataFormat? outputFormat;

  TransformConfig({
    required this.type,
    this.script,
    this.mapping,
    this.inputFormat,
    this.outputFormat,
  });

  factory TransformConfig.fromJson(Map<String, dynamic> json) {
    return TransformConfig(
      type: json['type'] as String,
      script: json['script'] as String?,
      mapping: json['mapping'] != null
          ? Map<String, dynamic>.from(json['mapping'] as Map)
          : null,
      inputFormat: json['inputFormat'] != null
          ? DataFormat.fromJson(json['inputFormat'] as Map<String, dynamic>)
          : null,
      outputFormat: json['outputFormat'] != null
          ? DataFormat.fromJson(json['outputFormat'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (script != null) 'script': script,
      if (mapping != null) 'mapping': mapping,
      if (inputFormat != null) 'inputFormat': inputFormat!.toJson(),
      if (outputFormat != null) 'outputFormat': outputFormat!.toJson(),
    };
  }
}
