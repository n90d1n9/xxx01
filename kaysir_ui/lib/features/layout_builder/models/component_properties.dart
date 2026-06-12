const Object _unset = Object();

class ComponentProperties {
  final Map<String, dynamic> style;
  final Map<String, dynamic> attributes;
  final Map<String, String> events;
  final String? parentId;
  final List<String>? childrenIds;

  const ComponentProperties({
    this.style = const {},
    this.attributes = const {},
    this.events = const {},
    this.parentId,
    this.childrenIds,
  });

  ComponentProperties copyWith({
    Map<String, dynamic>? style,
    Map<String, dynamic>? attributes,
    Map<String, String>? events,
    Object? parentId = _unset,
    Object? childrenIds = _unset,
  }) {
    return ComponentProperties(
      style: style ?? this.style,
      attributes: attributes ?? this.attributes,
      events: events ?? this.events,
      parentId:
          identical(parentId, _unset) ? this.parentId : parentId as String?,
      childrenIds:
          identical(childrenIds, _unset)
              ? this.childrenIds
              : childrenIds as List<String>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'style': style,
      'attributes': attributes,
      'events': events,
      'parentId': parentId,
      'childrenIds': childrenIds,
    };
  }

  factory ComponentProperties.fromJson(Map<String, dynamic> json) {
    return ComponentProperties(
      style: Map<String, dynamic>.from(json['style'] as Map? ?? const {}),
      attributes: Map<String, dynamic>.from(
        json['attributes'] as Map? ?? const {},
      ),
      events: Map<String, String>.from(json['events'] as Map? ?? const {}),
      parentId: json['parentId'] as String?,
      childrenIds:
          (json['childrenIds'] as List?)?.map((item) => '$item').toList(),
    );
  }
}
