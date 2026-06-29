import 'object_meta.dart';

class ControllerRevision {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final Map<String, dynamic>? data;
  final int revision;
  ControllerRevision({
    this.apiVersion = 'apps/v1',
    this.kind = 'ControllerRevision',
    required this.metadata,
    this.data,
    required this.revision,
  });
  factory ControllerRevision.fromJson(Map<String, dynamic> json) {
    return ControllerRevision(
      apiVersion: json['apiVersion'] ?? 'apps/v1',
      kind: json['kind'] ?? 'ControllerRevision',
      metadata: ObjectMeta.fromJson(json['metadata']),
      data: json['data'],
      revision: json['revision'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (data != null) 'data': data,
      'revision': revision,
    };
  }
}
