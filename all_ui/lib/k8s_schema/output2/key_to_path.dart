class KeyToPath {
  final String key;
  final String path;
  final int? mode;
  KeyToPath({required this.key, required this.path, this.mode});
  factory KeyToPath.fromJson(Map<String, dynamic> json) {
    return KeyToPath(key: json['key'], path: json['path'], mode: json['mode']);
  }
  Map<String, dynamic> toJson() {
    return {'key': key, 'path': path, if (mode != null) 'mode': mode};
  }
}
