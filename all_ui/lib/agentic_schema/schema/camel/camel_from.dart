class CamelFrom {
  final String uri;
  final Map<String, dynamic>? parameters;

  CamelFrom({required this.uri, this.parameters});

  factory CamelFrom.fromJson(Map<String, dynamic> json) {
    return CamelFrom(
      uri: json['uri'] as String,
      parameters: json['parameters'] != null
          ? Map<String, dynamic>.from(json['parameters'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uri': uri, if (parameters != null) 'parameters': parameters};
  }
}
