import 'node_affinity.dart';
import 'pod_affinity.dart';
import 'pod_anti_affinity.dart';

class Affinity {
  final NodeAffinity? nodeAffinity;
  final PodAffinity? podAffinity;
  final PodAntiAffinity? podAntiAffinity;
  Affinity({this.nodeAffinity, this.podAffinity, this.podAntiAffinity});
  factory Affinity.fromJson(Map<String, dynamic> json) {
    return Affinity(
      nodeAffinity:
          json['nodeAffinity'] != null
              ? NodeAffinity.fromJson(json['nodeAffinity'])
              : null,
      podAffinity:
          json['podAffinity'] != null
              ? PodAffinity.fromJson(json['podAffinity'])
              : null,
      podAntiAffinity:
          json['podAntiAffinity'] != null
              ? PodAntiAffinity.fromJson(json['podAntiAffinity'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (nodeAffinity != null) 'nodeAffinity': nodeAffinity!.toJson(),
      if (podAffinity != null) 'podAffinity': podAffinity!.toJson(),
      if (podAntiAffinity != null) 'podAntiAffinity': podAntiAffinity!.toJson(),
    };
  }
}
