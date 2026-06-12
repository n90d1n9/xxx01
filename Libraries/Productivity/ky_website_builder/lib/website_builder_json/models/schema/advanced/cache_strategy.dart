class CacheStrategy {
  final String type; // cacheFirst, networkFirst, staleWhileRevalidate
  final int maxAge; // seconds
  final List<String>? excludedPaths;

  CacheStrategy({required this.type, required this.maxAge, this.excludedPaths});

  factory CacheStrategy.fromJson(Map<String, dynamic> json) {
    return CacheStrategy(
      type: json['type'] as String,
      maxAge: json['maxAge'] as int,
      excludedPaths:
          json['excludedPaths'] != null
              ? List<String>.from(json['excludedPaths'] as List)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'maxAge': maxAge,
    if (excludedPaths != null) 'excludedPaths': excludedPaths,
  };
}
