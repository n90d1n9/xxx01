import 'event.dart';
import 'list_meta.dart';

class EventList {
  final String apiVersion;
  final String kind;
  final ListMeta? metadata;
  final List<Event> items;
  EventList({
    this.apiVersion = 'v1',
    this.kind = 'EventList',
    this.metadata,
    required this.items,
  });
  factory EventList.fromJson(Map<String, dynamic> json) {
    return EventList(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'EventList',
      metadata:
          json['metadata'] != null ? ListMeta.fromJson(json['metadata']) : null,
      items: (json['items'] as List).map((e) => Event.fromJson(e)).toList(),
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
