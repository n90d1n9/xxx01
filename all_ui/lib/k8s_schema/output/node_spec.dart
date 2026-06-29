import 'taint.dart';
import 'node_config_source.dart';

class NodeSpec {
  final String? podCIDR;
  final List<String>? podCIDRs;
  final String? providerID;
  final bool? unschedulable;
  final List<Taint>? taints;
  final NodeConfigSource? configSource;
  NodeSpec({
    this.podCIDR,
    this.podCIDRs,
    this.providerID,
    this.unschedulable,
    this.taints,
    this.configSource,
  });
  factory NodeSpec.fromJson(Map<String, dynamic> json) {
    return NodeSpec(
      podCIDR: json['podCIDR'],
      podCIDRs:
          json['podCIDRs'] != null ? List<String>.from(json['podCIDRs']) : null,
      providerID: json['providerID'],
      unschedulable: json['unschedulable'],
      taints:
          json['taints'] != null
              ? (json['taints'] as List).map((e) => Taint.fromJson(e)).toList()
              : null,
      configSource:
          json['configSource'] != null
              ? NodeConfigSource.fromJson(json['configSource'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (podCIDR != null) 'podCIDR': podCIDR,
      if (podCIDRs != null) 'podCIDRs': podCIDRs,
      if (providerID != null) 'providerID': providerID,
      if (unschedulable != null) 'unschedulable': unschedulable,
      if (taints != null) 'taints': taints!.map((e) => e.toJson()).toList(),
      if (configSource != null) 'configSource': configSource!.toJson(),
    };
  }
}
