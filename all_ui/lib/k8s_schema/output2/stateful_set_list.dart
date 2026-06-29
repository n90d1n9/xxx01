import 'list_meta.dart';
import 'stateful_set.dart';

class StatefulSetList {
  final String apiVersion;
  final String kind;
  final ListMeta? metadata;
  final List<StatefulSet> items;
  StatefulSetList({
    this.apiVersion = 'apps/v1',
    this.kind = 'StatefulSetList',
    this.metadata,
    required this.items,
  });
  factory StatefulSetList.fromJson(Map<String, dynamic> json) {
    return StatefulSetList(
      apiVersion: json['apiVersion'] ?? 'apps/v1',
      kind: json['kind'] ?? 'StatefulSetList',
      metadata:
          json['metadata'] != null ? ListMeta.fromJson(json['metadata']) : null,
      items:
          (json['items'] as List).map((e) => StatefulSet.fromJson(e)).toList(),
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
