class ScaleStatus {
  final int replicas;
  final String? selector;
  ScaleStatus({required this.replicas, this.selector});
  factory ScaleStatus.fromJson(Map<String, dynamic> json) {
    return ScaleStatus(replicas: json['replicas'], selector: json['selector']);
  }
  Map<String, dynamic> toJson() {
    return {'replicas': replicas, if (selector != null) 'selector': selector};
  }
}
