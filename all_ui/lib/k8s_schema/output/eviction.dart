import 'delete_options.dart';
import 'object_meta.dart';

class Eviction {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final DeleteOptions? deleteOptions;
  Eviction({
    this.apiVersion = 'policy/v1',
    this.kind = 'Eviction',
    required this.metadata,
    this.deleteOptions,
  });
  factory Eviction.fromJson(Map<String, dynamic> json) {
    return Eviction(
      apiVersion: json['apiVersion'] ?? 'policy/v1',
      kind: json['kind'] ?? 'Eviction',
      metadata: ObjectMeta.fromJson(json['metadata']),
      deleteOptions:
          json['deleteOptions'] != null
              ? DeleteOptions.fromJson(json['deleteOptions'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (deleteOptions != null) 'deleteOptions': deleteOptions!.toJson(),
    };
  }
}
