class EventSource {
  final String? component;
  final String? host;
  EventSource({this.component, this.host});
  factory EventSource.fromJson(Map<String, dynamic> json) {
    return EventSource(component: json['component'], host: json['host']);
  }
  Map<String, dynamic> toJson() {
    return {
      if (component != null) 'component': component,
      if (host != null) 'host': host,
    };
  }
}
