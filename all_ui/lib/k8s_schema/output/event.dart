import 'event_source.dart';
import 'event_series.dart';
import 'object_reference.dart';
import 'object_meta.dart';

class Event {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final ObjectReference? involvedObject;
  final String? reason;
  final String? message;
  final EventSource? source;
  final DateTime? firstTimestamp;
  final DateTime? lastTimestamp;
  final int? count;
  final String? type;
  final DateTime? eventTime;
  final EventSeries? series;
  final String? action;
  final ObjectReference? related;
  final String? reportingComponent;
  final String? reportingInstance;
  Event({
    this.apiVersion = 'v1',
    this.kind = 'Event',
    required this.metadata,
    this.involvedObject,
    this.reason,
    this.message,
    this.source,
    this.firstTimestamp,
    this.lastTimestamp,
    this.count,
    this.type,
    this.eventTime,
    this.series,
    this.action,
    this.related,
    this.reportingComponent,
    this.reportingInstance,
  });
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      apiVersion: json['apiVersion'] ?? 'v1',
      kind: json['kind'] ?? 'Event',
      metadata: ObjectMeta.fromJson(json['metadata']),
      involvedObject:
          json['involvedObject'] != null
              ? ObjectReference.fromJson(json['involvedObject'])
              : null,
      reason: json['reason'],
      message: json['message'],
      source:
          json['source'] != null ? EventSource.fromJson(json['source']) : null,
      firstTimestamp:
          json['firstTimestamp'] != null
              ? DateTime.parse(json['firstTimestamp'])
              : null,
      lastTimestamp:
          json['lastTimestamp'] != null
              ? DateTime.parse(json['lastTimestamp'])
              : null,
      count: json['count'],
      type: json['type'],
      eventTime:
          json['eventTime'] != null ? DateTime.parse(json['eventTime']) : null,
      series:
          json['series'] != null ? EventSeries.fromJson(json['series']) : null,
      action: json['action'],
      related:
          json['related'] != null
              ? ObjectReference.fromJson(json['related'])
              : null,
      reportingComponent: json['reportingComponent'],
      reportingInstance: json['reportingInstance'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      if (involvedObject != null) 'involvedObject': involvedObject!.toJson(),
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
      if (source != null) 'source': source!.toJson(),
      if (firstTimestamp != null)
        'firstTimestamp': firstTimestamp!.toIso8601String(),
      if (lastTimestamp != null)
        'lastTimestamp': lastTimestamp!.toIso8601String(),
      if (count != null) 'count': count,
      if (type != null) 'type': type,
      if (eventTime != null) 'eventTime': eventTime!.toIso8601String(),
      if (series != null) 'series': series!.toJson(),
      if (action != null) 'action': action,
      if (related != null) 'related': related!.toJson(),
      if (reportingComponent != null) 'reportingComponent': reportingComponent,
      if (reportingInstance != null) 'reportingInstance': reportingInstance,
    };
  }
}
