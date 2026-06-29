import '../common/metadata.dart';
import '../node/edge_condition.dart';
import '../node/edge_interceptor.dart';

enum EdgeType {
  defaultType,
  conditional,
  fallback,
  loop,
  error,
  wireTap,
  multicast,
  straight,
  dataFlow,
}

enum ChannelType { direct, queue, topic, pubsub, requestReply }

class WorkflowEdge {
  final String id;
  final String source;
  final String target;
  final String? sourceHandle;
  final String? targetHandle;
  final EdgeType? type;
  final ChannelType? channelType;
  final EdgeCondition? condition;
  final List<EdgeInterceptor>? interceptors;
  final String? label;
  final bool? animated;
  final Metadata? metadata;

  WorkflowEdge({
    required this.id,
    required this.source,
    required this.target,
    this.sourceHandle,
    this.targetHandle,
    this.type,
    this.channelType,
    this.condition,
    this.interceptors,
    this.label,
    this.animated = true,
    this.metadata,
  });

  factory WorkflowEdge.fromJson(Map<String, dynamic> json) {
    return WorkflowEdge(
      id: json['id'] as String,
      source: json['source'] as String,
      target: json['target'] as String,
      sourceHandle: json['sourceHandle'] as String?,
      targetHandle: json['targetHandle'] as String?,
      type: json['type'] != null ? _parseEdgeType(json['type']) : null,
      channelType: json['channelType'] != null
          ? _parseChannelType(json['channelType'])
          : null,
      condition: json['condition'] != null
          ? EdgeCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      interceptors: json['interceptors'] != null
          ? (json['interceptors'] as List)
                .map((e) => EdgeInterceptor.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      label: json['label'] as String?,
      animated: json['animated'] as bool?,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'target': target,
      if (sourceHandle != null) 'sourceHandle': sourceHandle,
      if (targetHandle != null) 'targetHandle': targetHandle,
      if (type != null) 'type': type!.name,
      if (channelType != null) 'channelType': channelType!.name,
      if (condition != null) 'condition': condition!.toJson(),
      if (interceptors != null)
        'interceptors': interceptors!.map((e) => e.toJson()).toList(),
      if (label != null) 'label': label,
      if (animated != null) 'animated': animated,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  static EdgeType _parseEdgeType(dynamic value) {
    if (value is EdgeType) return value;
    final stringValue = value.toString();
    return EdgeType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => EdgeType.defaultType,
    );
  }

  static ChannelType _parseChannelType(dynamic value) {
    if (value is ChannelType) return value;
    final stringValue = value.toString();
    return ChannelType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => ChannelType.direct,
    );
  }

  WorkflowEdge copyWith({
    String? id,
    String? source,
    String? target,
    String? sourceHandle,
    String? targetHandle,
    EdgeType? type,
    ChannelType? channelType,
    EdgeCondition? condition,
    List<EdgeInterceptor>? interceptors,
    String? label,
    bool? animated,
    Metadata? metadata,
  }) {
    return WorkflowEdge(
      id: id ?? this.id,
      source: source ?? this.source,
      target: target ?? this.target,
      sourceHandle: sourceHandle ?? this.sourceHandle,
      targetHandle: targetHandle ?? this.targetHandle,
      type: type ?? this.type,
      channelType: channelType ?? this.channelType,
      condition: condition ?? this.condition,
      interceptors: interceptors ?? this.interceptors,
      label: label ?? this.label,
      animated: animated ?? this.animated,
      metadata: metadata ?? this.metadata,
    );
  }
}
