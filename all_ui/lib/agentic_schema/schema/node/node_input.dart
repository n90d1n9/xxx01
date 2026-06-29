import '../data/data_format.dart';

class NodeInput {
  final String name;
  final String type;
  final String? source;
  final bool? required;
  final DataFormat? format;

  NodeInput({
    required this.name,
    required this.type,
    this.source,
    this.required = true,
    this.format,
  });

  factory NodeInput.fromJson(Map<String, dynamic> json) {
    return NodeInput(
      name: json['name'] as String,
      type: json['type'] as String,
      source: json['source'] as String?,
      required: json['required'] as bool?,
      format: json['format'] != null
          ? DataFormat.fromJson(json['format'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (source != null) 'source': source,
      if (required != null) 'required': required,
      if (format != null) 'format': format!.toJson(),
    };
  }
}
