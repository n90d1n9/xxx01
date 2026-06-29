import 'code_template.dart';

class CodeGenerationTarget {
  final String platform;
  final String? version;
  final String? outputPath;
  final List<CodeTemplate>? templates;

  CodeGenerationTarget({
    required this.platform,
    this.version,
    this.outputPath,
    this.templates,
  });

  factory CodeGenerationTarget.fromJson(Map<String, dynamic> json) {
    return CodeGenerationTarget(
      platform: json['platform'] as String,
      version: json['version'] as String?,
      outputPath: json['outputPath'] as String?,
      templates: json['templates'] != null
          ? (json['templates'] as List)
                .map((e) => CodeTemplate.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      if (version != null) 'version': version,
      if (outputPath != null) 'outputPath': outputPath,
      if (templates != null)
        'templates': templates!.map((e) => e.toJson()).toList(),
    };
  }
}
