import 'list_meta.dart';
import 'service.dart';

class ServiceList {
  final String apiVersion;
  final String kind;
  final ListMeta? metadata;
  final List<Service> items;
  ServiceList({
    this.apiVersion = 'v1',
    this.kind = 'ServiceList',
    this.metadata,
    required this.items,
  });
  factory ServiceList.fromJson(Map<String, dynamic> json) {
    return ServiceList(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'ServiceList',
      metadata:
          json['metadata'] != null ? ListMeta.fromJson(json['metadata']) : null,
      items: (json['items'] as List).map((e) => Service.fromJson(e)).toList(),
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
