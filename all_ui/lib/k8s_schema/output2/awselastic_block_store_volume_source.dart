class AWSElasticBlockStoreVolumeSource {
  final String volumeID;
  final String? fsType;
  final int? partition;
  final bool? readOnly;
  AWSElasticBlockStoreVolumeSource({
    required this.volumeID,
    this.fsType,
    this.partition,
    this.readOnly,
  });
  factory AWSElasticBlockStoreVolumeSource.fromJson(Map<String, dynamic> json) {
    return AWSElasticBlockStoreVolumeSource(
      volumeID: json['volumeID'],
      fsType: json['fsType'],
      partition: json['partition'],
      readOnly: json['readOnly'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'volumeID': volumeID,
      if (fsType != null) 'fsType': fsType,
      if (partition != null) 'partition': partition,
      if (readOnly != null) 'readOnly': readOnly,
    };
  }
}
