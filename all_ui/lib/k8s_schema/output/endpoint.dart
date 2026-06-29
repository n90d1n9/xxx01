import 'endpoint_conditions.dart';
import 'endpoint_hints.dart';
import 'object_reference.dart';

class Endpoint {
  final List<String> addresses;
  final EndpointConditions? conditions;
  final String? hostname;
  final ObjectReference? targetRef;
  final EndpointHints? hints;
  final String? nodeName;
  final String? zone;
  Endpoint({
    required this.addresses,
    this.conditions,
    this.hostname,
    this.targetRef,
    this.hints,
    this.nodeName,
    this.zone,
  });
  factory Endpoint.fromJson(Map<String, dynamic> json) {
    return Endpoint(
      addresses: List<String>.from(json['addresses']),
      conditions:
          json['conditions'] != null
              ? EndpointConditions.fromJson(json['conditions'])
              : null,
      hostname: json['hostname'],
      targetRef:
          json['targetRef'] != null
              ? ObjectReference.fromJson(json['targetRef'])
              : null,
      hints:
          json['hints'] != null ? EndpointHints.fromJson(json['hints']) : null,
      nodeName: json['nodeName'],
      zone: json['zone'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'addresses': addresses,
      if (conditions != null) 'conditions': conditions!.toJson(),
      if (hostname != null) 'hostname': hostname,
      if (targetRef != null) 'targetRef': targetRef!.toJson(),
      if (hints != null) 'hints': hints!.toJson(),
      if (nodeName != null) 'nodeName': nodeName,
      if (zone != null) 'zone': zone,
    };
  }
}
