import 'owner_reference.dart';

class ObjectMeta {
  final String? name;
  final String? namespace;
  final String? uid;
  final String? resourceVersion;
  final String? generation;
  final DateTime? creationTimestamp;
  final DateTime? deletionTimestamp;
  final Map<String, String>? labels;
  final Map<String, String>? annotations;
  final List<OwnerReference>? ownerReferences;
  final List<String>? finalizers;
  ObjectMeta({
    this.name,
    this.namespace,
    this.uid,
    this.resourceVersion,
    this.generation,
    this.creationTimestamp,
    this.deletionTimestamp,
    this.labels,
    this.annotations,
    this.ownerReferences,
    this.finalizers,
  });
  factory ObjectMeta.fromJson(Map<String, dynamic> json) {
    return ObjectMeta(
      name: json['name'],
      namespace: json['namespace'],
      uid: json['uid'],
      resourceVersion: json['resourceVersion'],
      generation: json['generation']?.toString(),
      creationTimestamp:
          json['creationTimestamp'] != null
              ? DateTime.parse(json['creationTimestamp'])
              : null,
      deletionTimestamp:
          json['deletionTimestamp'] != null
              ? DateTime.parse(json['deletionTimestamp'])
              : null,
      labels:
          json['labels'] != null
              ? Map<String, String>.from(json['labels'])
              : null,
      annotations:
          json['annotations'] != null
              ? Map<String, String>.from(json['annotations'])
              : null,
      ownerReferences:
          json['ownerReferences'] != null
              ? (json['ownerReferences'] as List)
                  .map((e) => OwnerReference.fromJson(e))
                  .toList()
              : null,
      finalizers:
          json['finalizers'] != null
              ? List<String>.from(json['finalizers'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (namespace != null) 'namespace': namespace,
      if (uid != null) 'uid': uid,
      if (resourceVersion != null) 'resourceVersion': resourceVersion,
      if (generation != null) 'generation': generation,
      if (creationTimestamp != null)
        'creationTimestamp': creationTimestamp!.toIso8601String(),
      if (deletionTimestamp != null)
        'deletionTimestamp': deletionTimestamp!.toIso8601String(),
      if (labels != null) 'labels': labels,
      if (annotations != null) 'annotations': annotations,
      if (ownerReferences != null)
        'ownerReferences': ownerReferences!.map((e) => e.toJson()).toList(),
      if (finalizers != null) 'finalizers': finalizers,
    };
  }
}
