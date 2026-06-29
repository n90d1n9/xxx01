class ResourceQuotaStatus {
  final Map<String, String>? hard;
  final Map<String, String>? used;
  ResourceQuotaStatus({this.hard, this.used});
  factory ResourceQuotaStatus.fromJson(Map<String, dynamic> json) {
    return ResourceQuotaStatus(
      hard:
          json['hard'] != null ? Map<String, String>.from(json['hard']) : null,
      used:
          json['used'] != null ? Map<String, String>.from(json['used']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {if (hard != null) 'hard': hard, if (used != null) 'used': used};
  }
}
