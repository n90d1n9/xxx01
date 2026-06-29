import 'object_meta.dart';

class Secret {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final Map<String, String>? data;
  final Map<String, String>? stringData;
  final String? type;
  final bool? immutable;
  Secret({
    this.apiVersion = 'v1',
    this.kind = 'Secret',
    required this.metadata,
    this.data,
    this.stringData,
    this.type,
    this.immutable,
  });
  factory Secret.fromJson(Map<String, dynamic> json) {
    return Secret(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Secret',
      metadata: ObjectMeta.fromJson(json['metadata']),
      data:
          json['data'] != null ? Map<String, String>.from(json['data']) : null,
      stringData:
          json['stringData'] != null
              ? Map<String, String>.from(json['stringData'])
              : null,
      type: json['type'],
      immutable: json['immutable'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (data != null) 'data': data,
      if (stringData != null) 'stringData': stringData,
      if (type != null) 'type': type,
      if (immutable != null) 'immutable': immutable,
    };
  }
}
