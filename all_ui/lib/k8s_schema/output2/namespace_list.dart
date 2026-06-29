import 'list_meta.dart';
import 'namespace.dart';

class NamespaceList {
  final String apiVersion;
  final String kind;
  final ListMeta? metadata;
  final List<Namespace> items;
  NamespaceList({
    this.apiVersion = 'v1',
    this.kind = 'NamespaceList',
    this.metadata,
    required this.items,
  });
  factory NamespaceList.fromJson(Map<String, dynamic> json) {
    return NamespaceList(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'NamespaceList',
      metadata:
          json['metadata'] != null ? ListMeta.fromJson(json['metadata']) : null,
      items: (json['items'] as List).map((e) => Namespace.fromJson(e)).toList(),
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
