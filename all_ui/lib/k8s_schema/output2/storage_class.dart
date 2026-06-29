import 'topology_selector_term.dart';
import 'object_meta.dart';

class StorageClass {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final String provisioner;
  final Map<String, String>? parameters;
  final String? reclaimPolicy;
  final List<String>? mountOptions;
  final bool? allowVolumeExpansion;
  final String? volumeBindingMode;
  final List<TopologySelectorTerm>? allowedTopologies;
  StorageClass({
    this.apiVersion = 'storage.k8s.io/v1',
    this.kind = 'StorageClass',
    required this.metadata,
    required this.provisioner,
    this.parameters,
    this.reclaimPolicy,
    this.mountOptions,
    this.allowVolumeExpansion,
    this.volumeBindingMode,
    this.allowedTopologies,
  });
  factory StorageClass.fromJson(Map<String, dynamic> json) {
    return StorageClass(
      apiVersion: json['apiVersion'] ?? 'storage.k8s.io/v1',
      kind: json['kind'] ?? 'StorageClass',
      metadata: ObjectMeta.fromJson(json['metadata']),
      provisioner: json['provisioner'],
      parameters:
          json['parameters'] != null
              ? Map<String, String>.from(json['parameters'])
              : null,
      reclaimPolicy: json['reclaimPolicy'],
      mountOptions:
          json['mountOptions'] != null
              ? List<String>.from(json['mountOptions'])
              : null,
      allowVolumeExpansion: json['allowVolumeExpansion'],
      volumeBindingMode: json['volumeBindingMode'],
      allowedTopologies:
          json['allowedTopologies'] != null
              ? (json['allowedTopologies'] as List)
                  .map((e) => TopologySelectorTerm.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'provisioner': provisioner,
      if (parameters != null) 'parameters': parameters,
      if (reclaimPolicy != null) 'reclaimPolicy': reclaimPolicy,
      if (mountOptions != null) 'mountOptions': mountOptions,
      if (allowVolumeExpansion != null)
        'allowVolumeExpansion': allowVolumeExpansion,
      if (volumeBindingMode != null) 'volumeBindingMode': volumeBindingMode,
      if (allowedTopologies != null)
        'allowedTopologies': allowedTopologies!.map((e) => e.toJson()).toList(),
    };
  }
}
