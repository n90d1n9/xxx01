class RollingUpdateDaemonSet {
  final dynamic maxUnavailable;
  final dynamic maxSurge;
  RollingUpdateDaemonSet({this.maxUnavailable, this.maxSurge});
  factory RollingUpdateDaemonSet.fromJson(Map<String, dynamic> json) {
    return RollingUpdateDaemonSet(
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
