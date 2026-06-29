class ServiceAccountTokenProjection {
  final String path;
  final int? expirationSeconds;
  final String? audience;
  ServiceAccountTokenProjection({
    required this.path,
    this.expirationSeconds,
    this.audience,
  });
  factory ServiceAccountTokenProjection.fromJson(Map<String, dynamic> json) {
    return ServiceAccountTokenProjection(
      path: json['path'],
      expirationSeconds: json['expirationSeconds'],
      audience: json['audience'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      if (expirationSeconds != null) 'expirationSeconds': expirationSeconds,
      if (audience != null) 'audience': audience,
    };
  }
}
