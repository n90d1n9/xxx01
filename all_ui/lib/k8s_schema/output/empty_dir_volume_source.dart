class EmptyDirVolumeSource {
  final String? medium;
  final String? sizeLimit;
  EmptyDirVolumeSource({this.medium, this.sizeLimit});
  factory EmptyDirVolumeSource.fromJson(Map<String, dynamic> json) {
    return EmptyDirVolumeSource(
      medium: json['medium'],
      sizeLimit: json['sizeLimit'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (medium != null) 'medium': medium,
      if (sizeLimit != null) 'sizeLimit': sizeLimit,
    };
  }
}
