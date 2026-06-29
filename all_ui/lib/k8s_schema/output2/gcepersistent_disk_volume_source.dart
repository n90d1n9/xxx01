class GCEPersistentDiskVolumeSource {
  final String pdName;
  final String? fsType;
  final int? partition;
  final bool? readOnly;
  GCEPersistentDiskVolumeSource({
    required this.pdName,
    this.fsType,
    this.partition,
    this.readOnly,
  });
  factory GCEPersistentDiskVolumeSource.fromJson(Map<String, dynamic> json) {
    return GCEPersistentDiskVolumeSource(
      pdName: json['pdName'],
      fsType: json['fsType'],
      partition: json['partition'],
      readOnly: json['readOnly'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pdName': pdName,
      if (fsType != null) 'fsType': fsType,
      if (partition != null) 'partition': partition,
      if (readOnly != null) 'readOnly': readOnly,
    };
  }
}
