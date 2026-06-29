import '../data/data_format.dart';

class NodeOutput {
  final String name;
  final String type;
  final String? mapping;
  final DataFormat? format;

  NodeOutput({
    required this.name,
    required this.type,
    this.mapping,
    this.format,
  });

  factory NodeOutput.fromJson(Map<String, dynamic> json) {
    return NodeOutput(
      name: json['name'] as String,
      type: json['type'] as String,
      mapping: json['mapping'] as String?,
      format: json['format'] != null
          ? DataFormat.fromJson(json['format'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (mapping != null) 'mapping': mapping,
      if (format != null) 'format': format!.toJson(),
    };
  }
}
