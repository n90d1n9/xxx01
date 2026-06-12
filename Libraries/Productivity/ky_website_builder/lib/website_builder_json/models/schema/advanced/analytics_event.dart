class AnalyticsEvent {
  final String name;
  final String trigger; // click, pageView, formSubmit, custom
  final String? componentId;
  final Map<String, dynamic>? properties;

  AnalyticsEvent({
    required this.name,
    required this.trigger,
    this.componentId,
    this.properties,
  });

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'] as String,
      trigger: json['trigger'] as String,
      componentId: json['componentId'] as String?,
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'trigger': trigger,
    if (componentId != null) 'componentId': componentId,
    if (properties != null) 'properties': properties,
  };
}
