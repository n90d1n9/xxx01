class StructuredData {
  final String type; // Organization, WebSite, Article, Product, etc.
  final Map<String, dynamic> data;

  StructuredData({required this.type, required this.data});

  factory StructuredData.fromJson(Map<String, dynamic> json) {
    return StructuredData(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'data': data};
}
