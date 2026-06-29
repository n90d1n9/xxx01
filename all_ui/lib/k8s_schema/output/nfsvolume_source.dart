class NFSVolumeSource {
  final String server;
  final String path;
  final bool? readOnly;
  NFSVolumeSource({required this.server, required this.path, this.readOnly});
  factory NFSVolumeSource.fromJson(Map<String, dynamic> json) {
    return NFSVolumeSource(
      server: json['server'],
      path: json['path'],
      readOnly: json['readOnly'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'server': server,
      'path': path,
      if (readOnly != null) 'readOnly': readOnly,
    };
  }
}
