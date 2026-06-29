class SecretKeySelector {
  final String name;
  final String key;
  final bool? optional;
  SecretKeySelector({required this.name, required this.key, this.optional});
  factory SecretKeySelector.fromJson(Map<String, dynamic> json) {
    return SecretKeySelector(
      name: json['name'],
      key: json['key'],
      optional: json['optional'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'key': key,
      if (optional != null) 'optional': optional,
    };
  }
}
