import 'list_meta.dart';
import 'pod.dart';

class PodList {
  final String apiVersion;
  final String kind;
  final ListMeta? metadata;
  final List<Pod> items;
  PodList({
    this.apiVersion = 'v1',
    this.kind = 'PodList',
    this.metadata,
    required this.items,
  });
  factory PodList.fromJson(Map<String, dynamic> json) {
    return PodList(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'PodList',
      metadata:
          json['metadata'] != null ? ListMeta.fromJson(json['metadata']) : null,
      items: (json['items'] as List).map((e) => Pod.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      if (metadata != null) 'metadata': metadata!.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
