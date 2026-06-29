import 'endpoint.dart';
import 'endpoint_port.dart';
import 'object_meta.dart';

class EndpointSlice {
  final String apiVersion;
  final String kind;
  final ObjectMeta metadata;
  final String addressType;
  final List<Endpoint>? endpoints;
  final List<EndpointPort>? ports;
  EndpointSlice({
    this.apiVersion = 'discovery.k8s.io/v1',
    this.kind = 'EndpointSlice',
    required this.metadata,
    required this.addressType,
    this.endpoints,
    this.ports,
  });
  factory EndpointSlice.fromJson(Map<String, dynamic> json) {
    return EndpointSlice(
      apiVersion: json['apiVersion'] ?? 'discovery.k8s.io/v1',
      kind: json['kind'] ?? 'EndpointSlice',
      metadata: ObjectMeta.fromJson(json['metadata']),
      addressType: json['addressType'],
      endpoints:
          json['endpoints'] != null
              ? (json['endpoints'] as List)
                  .map((e) => Endpoint.fromJson(e))
                  .toList()
              : null,
      ports:
          json['ports'] != null
              ? (json['ports'] as List)
                  .map((e) => EndpointPort.fromJson(e))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'apiVersion': apiVersion,
      'kind': kind,
      'metadata': metadata.toJson(),
      'addressType': addressType,
      if (endpoints != null)
        'endpoints': endpoints!.map((e) => e.toJson()).toList(),
      if (ports != null) 'ports': ports!.map((e) => e.toJson()).toList(),
    };
  }
}
