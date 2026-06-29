import 'endpoint_subset.dart';
import 'object_meta.dart';

class Endpoints {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final List<EndpointSubset>? subsets;
  Endpoints({
    this.apiVersion = 'v1',
    this.kind = 'Endpoints',
    required this.metadata,
    this.subsets,
  });
  factory Endpoints.fromJson(Map<String, dynamic> json) {
    return Endpoints(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Endpoints',
      metadata: ObjectMeta.fromJson(json['metadata']),
      subsets:
          json['subsets'] != null
              ? (json['subsets'] as List)
                  .map((e) => EndpointSubset.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (subsets != null) 'subsets': subsets!.map((e) => e.toJson()).toList(),
    };
  }
}
