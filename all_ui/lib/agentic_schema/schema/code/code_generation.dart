import 'code_generation_target.dart';
import 'code_mappings.dart';

class CodeGeneration {
  final List<CodeGenerationTarget>? targets;
  final CodeMappings? mappings;

  CodeGeneration({this.targets, this.mappings});

  factory CodeGeneration.fromJson(Map<String, dynamic> json) {
    return CodeGeneration(
      targets: json['targets'] != null
          ? (json['targets'] as List)
                .map(
                  (e) =>
                      CodeGenerationTarget.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      mappings: json['mappings'] != null
          ? CodeMappings.fromJson(json['mappings'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (targets != null) 'targets': targets!.map((e) => e.toJson()).toList(),
      if (mappings != null) 'mappings': mappings!.toJson(),
    };
  }
}
