class ConfigMapNodeConfigSource {
  final String namespace;
  final String name;
  final String uid;
  final String resourceVersion;
  final String kubeletConfigKey;
  ConfigMapNodeConfigSource({
    required this.namespace,
    required this.name,
    required this.uid,
    required this.resourceVersion,
    required this.kubeletConfigKey,
  });
  factory ConfigMapNodeConfigSource.fromJson(Map<String, dynamic> json) {
    return ConfigMapNodeConfigSource(
      namespace: json['namespace'],
      name: json['name'],
      uid: json['uid'],
      resourceVersion: json['resourceVersion'],
      kubeletConfigKey: json['kubeletConfigKey'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'namespace': namespace,
      'name': name,
      'uid': uid,
      'resourceVersion': resourceVersion,
      'kubeletConfigKey': kubeletConfigKey,
    };
  }
}
