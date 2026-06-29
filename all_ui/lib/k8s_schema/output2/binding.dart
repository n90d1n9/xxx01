import 'object_reference.dart';
import 'object_meta.dart';

class Binding {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final ObjectReference target;
  Binding({
    this.apiVersion = 'v1',
    this.kind = 'Binding',
    required this.metadata,
    required this.target,
  });
  factory Binding.fromJson(Map<String, dynamic> json) {
    return Binding(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Binding',
      metadata: ObjectMeta.fromJson(json['metadata']),
      target: ObjectReference.fromJson(json['target']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'target': target.toJson(),
    };
  }
}
