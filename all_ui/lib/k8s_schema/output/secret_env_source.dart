class SecretEnvSource {
  final String name;
  final bool? optional;
  SecretEnvSource({required this.name, this.optional});
  factory SecretEnvSource.fromJson(Map<String, dynamic> json) {
    return SecretEnvSource(name: json['name'], optional: json['optional']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name, if (optional != null) 'optional': optional};
  }
}
