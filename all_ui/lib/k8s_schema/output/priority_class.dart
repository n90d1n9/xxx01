import 'object_meta.dart';

class PriorityClass {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final int value;
  final bool? globalDefault;
  final String? description;
  final String? preemptionPolicy;
  PriorityClass({
    this.apiVersion = 'scheduling.k8s.io/v1',
    this.kind = 'PriorityClass',
    required this.metadata,
    required this.value,
    this.globalDefault,
    this.description,
    this.preemptionPolicy,
  });
  factory PriorityClass.fromJson(Map<String, dynamic> json) {
    return PriorityClass(
      apiVersion: json['apiVersion'] ?? 'scheduling.k8s.io/v1',
      kind: json['kind'] ?? 'PriorityClass',
      metadata: ObjectMeta.fromJson(json['metadata']),
      value: json['value'],
      globalDefault: json['globalDefault'],
      description: json['description'],
      preemptionPolicy: json['preemptionPolicy'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'value': value,
      if (globalDefault != null) 'globalDefault': globalDefault,
      if (description != null) 'description': description,
      if (preemptionPolicy != null) 'preemptionPolicy': preemptionPolicy,
    };
  }
}
