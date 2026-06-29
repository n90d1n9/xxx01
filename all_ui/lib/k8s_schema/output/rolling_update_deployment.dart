class RollingUpdateDeployment {
  final dynamic maxUnavailable;
  final dynamic maxSurge;
  RollingUpdateDeployment({this.maxUnavailable, this.maxSurge});
  factory RollingUpdateDeployment.fromJson(Map<String, dynamic> json) {
    return RollingUpdateDeployment(
      maxUnavailable: json['maxUnavailable'],
      maxSurge: json['maxSurge'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (maxUnavailable != null) 'maxUnavailable': maxUnavailable,
      if (maxSurge != null) 'maxSurge': maxSurge,
    };
  }
}
