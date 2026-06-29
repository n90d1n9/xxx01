class ConfigMapEnvSource {
  final String name;
  final bool? optional;
  ConfigMapEnvSource({required this.name, this.optional});
  factory ConfigMapEnvSource.fromJson(Map<String, dynamic> json) {
    return ConfigMapEnvSource(name: json['name'], optional: json['optional']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name, if (optional != null) 'optional': optional};
  }
}
