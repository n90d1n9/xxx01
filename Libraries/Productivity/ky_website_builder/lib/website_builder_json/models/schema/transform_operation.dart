class TransformOperation {
  final String type; // filter, map, sort, reduce, group
  final Map<String, dynamic>? params;

  TransformOperation({required this.type, this.params});

  factory TransformOperation.fromJson(Map<String, dynamic> json) {
    return TransformOperation(
      type: json['type'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (params != null) 'params': params,
  };
}
