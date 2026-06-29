class PersistentVolumeClaimVolumeSource {
  final String claimName;
  final bool? readOnly;
  PersistentVolumeClaimVolumeSource({required this.claimName, this.readOnly});
  factory PersistentVolumeClaimVolumeSource.fromJson(
    Map<String, dynamic> json,
  ) {
    return PersistentVolumeClaimVolumeSource(
      claimName: json['claimName'],
      readOnly: json['readOnly'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'claimName': claimName, if (readOnly != null) 'readOnly': readOnly};
  }
}
