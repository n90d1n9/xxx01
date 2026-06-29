import 'network_policy_port.dart';
import 'network_policy_peer.dart';

class NetworkPolicyEgressRule {
  final List<NetworkPolicyPort>? ports;
  final List<NetworkPolicyPeer>? to;
  NetworkPolicyEgressRule({this.ports, this.to});
  factory NetworkPolicyEgressRule.fromJson(Map<String, dynamic> json) {
    return NetworkPolicyEgressRule(
      ports:
          json['ports'] != null
              ? (json['ports'] as List)
                  .map((e) => NetworkPolicyPort.fromJson(e))
                  .toList()
              : null,
      to:
          json['to'] != null
              ? (json['to'] as List)
                  .map((e) => NetworkPolicyPeer.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (ports != null) 'ports': ports!.map((e) => e.toJson()).toList(),
      if (to != null) 'to': to!.map((e) => e.toJson()).toList(),
    };
  }
}
