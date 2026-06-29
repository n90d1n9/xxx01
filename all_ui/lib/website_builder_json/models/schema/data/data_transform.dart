import '../transform_operation.dart';

class DataTransform {
  final String? path; // JSONPath or dot notation for extracting data
  final List<TransformOperation>? operations;
  final Map<String, String>? mapping; // Field mapping

  DataTransform({this.path, this.operations, this.mapping});

  factory DataTransform.fromJson(Map<String, dynamic> json) {
    return DataTransform(
      path: json['path'] as String?,
      operations:
          json['operations'] != null
              ? (json['operations'] as List)
                  .map(
                    (o) =>
                        TransformOperation.fromJson(o as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      mapping:
          json['mapping'] != null
              ? Map<String, String>.from(json['mapping'] as Map)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (path != null) 'path': path,
    if (operations != null)
      'operations': operations!.map((o) => o.toJson()).toList(),
    if (mapping != null) 'mapping': mapping,
  };
}
