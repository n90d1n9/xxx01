class ScaleSpec {
  final int? replicas;
  ScaleSpec({this.replicas});
  factory ScaleSpec.fromJson(Map<String, dynamic> json) {
    return ScaleSpec(replicas: json['replicas']);
  }
  Map<String, dynamic> toJson() {
    return {if (replicas != null) 'replicas': replicas};
  }
}
