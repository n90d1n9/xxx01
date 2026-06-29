class CamelImplementation {
  final String? routeTemplate;
  final List<String>? components;

  CamelImplementation({this.routeTemplate, this.components});

  factory CamelImplementation.fromJson(Map<String, dynamic> json) {
    return CamelImplementation(
      routeTemplate: json['routeTemplate'] as String?,
      components: json['components'] != null
          ? List<String>.from(json['components'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (routeTemplate != null) 'routeTemplate': routeTemplate,
      if (components != null) 'components': components,
    };
  }
}
