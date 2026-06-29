class AttachedVolume {
  final String name;
  final String devicePath;
  AttachedVolume({required this.name, required this.devicePath});
  factory AttachedVolume.fromJson(Map<String, dynamic> json) {
    return AttachedVolume(name: json['name'], devicePath: json['devicePath']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'devicePath': devicePath};
  }
}
