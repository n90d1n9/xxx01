class CompressionConfig {
  final bool enabled;
  final List<String> algorithms; // gzip, brotli
  final int minSize; // bytes

  CompressionConfig({
    required this.enabled,
    required this.algorithms,
    required this.minSize,
  });

  factory CompressionConfig.fromJson(Map<String, dynamic> json) {
    return CompressionConfig(
      enabled: json['enabled'] as bool,
      algorithms: List<String>.from(json['algorithms'] as List),
      minSize: json['minSize'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'algorithms': algorithms,
    'minSize': minSize,
  };
}
